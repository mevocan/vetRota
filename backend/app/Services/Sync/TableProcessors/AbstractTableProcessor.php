<?php

declare(strict_types=1);

namespace App\Services\Sync\TableProcessors;

use App\Enums\Sync\ConflictStrategy;
use App\Enums\Sync\SyncResult;
use App\Models\SyncConflict;
use App\Models\User;
use App\Services\Sync\Contracts\TableProcessorInterface;
use Illuminate\Database\Eloquent\Model;

// sync-api.md §11.9 + §8.
//
// Versiyonlama notu:
// - INSERT: version=1 manuel set. Trigger BEFORE UPDATE oldugu icin
//   INSERT'te calismaz.
// - UPDATE: $server->save() — DB trigger version'u +1 yapar, last_modified_at
//   ve updated_at'i now() yapar. Eloquent updated_at da set eder; cakisma
//   olmaz, ikisi de now()'da bulusur.
abstract class AbstractTableProcessor implements TableProcessorInterface
{
    protected User $user;
    protected string $deviceId;

    abstract protected function tableName(): string;

    abstract protected function modelClass(): string;

    /** @return array<string> */
    abstract protected function fillable(): array;

    /** Override edilebilir. null = ok, string = hata mesaji. */
    // Subclass'lar gerekli default'lari (orn. vet_id = current user)
    // insert oncesi enjekte edebilir. Update path'inde calismaz.
    protected function fillDefaults(array &$data): void {}

    protected function validateData(array $data): ?string
    {
        return null;
    }

    public function setContext(User $user, string $deviceId): void
    {
        $this->user = $user;
        $this->deviceId = $deviceId;
    }

    public function process(array $record): array
    {
        $modelClass = $this->modelClass();

        $query = $modelClass::query();
        if (method_exists($modelClass, 'bootSoftDeletes')
            || in_array(\Illuminate\Database\Eloquent\SoftDeletes::class, class_uses_recursive($modelClass), true)) {
            $query = $modelClass::withTrashed();
        }

        /** @var Model|null $server */
        $server = $query->where('id', $record['id'])->lockForUpdate()->first();

        return match ($record['op']) {
            'upsert' => $this->handleUpsert($record, $server),
            'delete' => $this->handleDelete($record, $server),
            default  => [
                'status' => SyncResult::Rejected->value,
                'reason' => 'invalid_op',
                'detail' => "Unknown op: {$record['op']}",
            ],
        };
    }

    protected function handleUpsert(array $record, ?Model $server): array
    {
        $data = $record['data'] ?? null;
        if (!is_array($data)) {
            return [
                'status' => SyncResult::Rejected->value,
                'reason' => 'missing_data',
                'detail' => 'upsert op requires data',
            ];
        }

        if ($error = $this->validateData($data)) {
            return [
                'status' => SyncResult::Rejected->value,
                'reason' => 'validation',
                'detail' => $error,
            ];
        }

        if (!$server) {
            return $this->insertNew($record);
        }

        if (method_exists($server, 'trashed') && $server->trashed()) {
            return [
                'status' => SyncResult::Conflict->value,
                'conflict' => [
                    'strategy' => ConflictStrategy::LastWriteWins->value,
                    'resolution' => 'server_won_deleted',
                    'server_version' => $server->version,
                ],
            ];
        }

        if ((int) $server->version === (int) $record['expected_version']) {
            return $this->applyUpdate($server, $record);
        }

        return $this->resolveConflict($server, $record);
    }

    protected function insertNew(array $record): array
    {
        $modelClass = $this->modelClass();
        $data = array_intersect_key($record['data'], array_flip($this->fillable()));
        $data['id'] = $record['id'];
        $data['version'] = 1;
        $data['origin_device_id'] = $this->deviceId;
        $data['last_modified_at'] = now();
        if (in_array('clinic_id', $this->fillable(), true)
            && empty($data['clinic_id'])) {
            $data['clinic_id'] = $this->user->clinic_id;
        }

        $this->fillDefaults($data);

        // forceFill: client'in UUID v4 id'si ve version=1 fillable'da degil
        // ama offline-first sozlesmesi geregi server-side override edilmemeli.
        $model = (new $modelClass())->forceFill($data);
        $model->save();

        return [
            'status' => SyncResult::Accepted->value,
            'version' => (int) $model->version,
        ];
    }

    protected function applyUpdate(Model $server, array $record): array
    {
        $data = array_intersect_key($record['data'], array_flip($this->fillable()));
        // clinic_id degistirilemez (tenant kaymasini engelle).
        unset($data['clinic_id']);

        $server->fill($data);
        $server->origin_device_id = $this->deviceId;
        $server->save(); // BEFORE UPDATE trigger version++ ve last_modified_at = now()

        return [
            'status' => SyncResult::Accepted->value,
            'version' => (int) $server->fresh()->version,
        ];
    }

    protected function resolveConflict(Model $server, array $record): array
    {
        $strategy = ConflictStrategy::forTable($this->tableName());

        return match ($strategy) {
            ConflictStrategy::LastWriteWins      => $this->resolveLWW($server, $record),
            ConflictStrategy::AdditiveMerge      => $this->resolveAdditive($server, $record),
            ConflictStrategy::ServerAuthoritative => $this->resolveServerWins($server, $record),
            ConflictStrategy::Manual             => $this->flagManual($server, $record),
        };
    }

    /** Client her zaman hakli (sync-api.md §8.2). */
    protected function resolveLWW(Model $server, array $record): array
    {
        SyncConflict::create([
            'device_id' => $this->deviceId,
            'clinic_id' => $this->user->clinic_id,
            'table_name' => $this->tableName(),
            'record_id' => $record['id'],
            'local_version' => $record['expected_version'],
            'server_version' => $server->version,
            'local_payload' => $record['data'] ?? null,
            'server_payload' => $server->toArray(),
            'resolution_strategy' => ConflictStrategy::LastWriteWins->value,
            'resolution' => 'resolved_local',
            'resolved_at' => now(),
        ]);

        $update = $this->applyUpdate($server, $record);

        return [
            'status' => SyncResult::Conflict->value,
            'conflict' => [
                'strategy' => ConflictStrategy::LastWriteWins->value,
                'resolution' => 'client_won',
                'server_version' => $update['version'],
            ],
        ];
    }

    protected function resolveAdditive(Model $server, array $record): array
    {
        return [
            'status' => SyncResult::Rejected->value,
            'reason' => 'additive_no_update',
            'detail' => 'Ledger tablolari update kabul etmez.',
        ];
    }

    protected function resolveServerWins(Model $server, array $record): array
    {
        return [
            'status' => SyncResult::Conflict->value,
            'conflict' => [
                'strategy' => ConflictStrategy::ServerAuthoritative->value,
                'resolution' => 'server_won',
                'server_version' => $server->version,
            ],
        ];
    }

    protected function flagManual(Model $server, array $record): array
    {
        SyncConflict::create([
            'device_id' => $this->deviceId,
            'clinic_id' => $this->user->clinic_id,
            'table_name' => $this->tableName(),
            'record_id' => $record['id'],
            'local_version' => $record['expected_version'],
            'server_version' => $server->version,
            'local_payload' => $record['data'] ?? null,
            'server_payload' => $server->toArray(),
            'resolution_strategy' => ConflictStrategy::Manual->value,
            'resolution' => 'pending',
        ]);

        return [
            'status' => SyncResult::Conflict->value,
            'conflict' => [
                'strategy' => ConflictStrategy::Manual->value,
                'resolution' => 'pending_manual',
                'server_version' => $server->version,
            ],
        ];
    }

    protected function handleDelete(array $record, ?Model $server): array
    {
        if (!$server) {
            return ['status' => SyncResult::Accepted->value]; // idempotent no-op
        }

        if (in_array($this->tableName(), ['stock_movements', 'payments'], true)) {
            return [
                'status' => SyncResult::Rejected->value,
                'reason' => 'ledger_immutable',
                'detail' => 'Ledger kayitlari silinemez.',
            ];
        }

        $server->origin_device_id = $this->deviceId;
        $server->save();
        $server->delete(); // soft delete

        return ['status' => SyncResult::Accepted->value];
    }
}
