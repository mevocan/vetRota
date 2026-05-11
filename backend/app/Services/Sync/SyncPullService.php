<?php

declare(strict_types=1);

namespace App\Services\Sync;

use App\Models\SyncLog;
use App\Models\User;
use App\Support\Sync\SyncCursor;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

// sync-api.md §5. Cursor-based delta pull.
//
// Notlar:
// - villages global tablo — clinic_id filtresi yok.
// - Diger tum tablolar clinic_id ile scoplu.
// - Echo prevention: origin_device_id != current device.
// - Silinmis kayitlar pull'a dahil (deleted_at IS NOT NULL filtre yok);
//   client soft-delete yapar.
// - Ledger (stock_movements) ve M3'te eklenen medical_record_drugs dahil.
class SyncPullService
{
    /** Pull sirasinda ele alinan tablolar. FK siralamasi onemli. */
    private array $tables = [
        'villages',
        'farmers',
        'animals',
        'appointments',
        'medical_records',
        'medical_record_drugs',
        'medical_record_photos',
        'drugs',
        'stocks',
        'stock_movements',
        'routes',
        'route_stops',
        'vaccine_schedules',
        'payments',
    ];

    /** clinic_id filtresi olmayan global tablolar. */
    private array $globalTables = ['villages'];

    /** softDeletes olan tablolar (deleted_at kolonu var). */
    private array $softDeleteTables = [
        'villages', 'farmers', 'animals', 'appointments',
        'medical_records', 'medical_record_drugs', 'medical_record_photos',
        'drugs', 'stocks', 'routes', 'route_stops', 'vaccine_schedules',
        'payments',
    ];

    public function execute(
        User $user,
        string $deviceId,
        string $since,
        ?array $tables,
        int $limit,
        ?string $cursor,
    ): array {
        $tablesToPull = $tables ?? $this->tables;
        $sinceCarbon = Carbon::parse($since);
        $cursorData = $cursor ? SyncCursor::decode($cursor) : null;

        $log = SyncLog::create([
            'device_id' => $deviceId,
            'user_id' => $user->id,
            'clinic_id' => $user->clinic_id,
            'direction' => 'pull',
            'status' => 'in_progress',
            'started_at' => now(),
        ]);

        $data = [];
        $hasMore = false;
        $nextCursor = null;
        $totalRows = 0;

        try {
            // Cursor varsa, o tablodan basla; oncesini atla.
            $startFrom = $cursorData['table'] ?? null;
            $skipping = $startFrom !== null;

            foreach ($tablesToPull as $table) {
                if ($skipping) {
                    if ($table !== $startFrom) {
                        continue;
                    }
                    $skipping = false;
                }

                $query = DB::table($table)
                    ->where('last_modified_at', '>', $sinceCarbon)
                    ->where(function ($q) use ($deviceId): void {
                        $q->whereNull('origin_device_id')
                          ->orWhere('origin_device_id', '!=', $deviceId);
                    });

                if (!in_array($table, $this->globalTables, true)) {
                    $query->where('clinic_id', $user->clinic_id);
                }

                if ($cursorData && ($cursorData['table'] ?? null) === $table) {
                    $cTs = $cursorData['last_modified_at'];
                    $cId = $cursorData['id'];
                    $query->where(function ($q) use ($cTs, $cId): void {
                        $q->where('last_modified_at', '>', $cTs)
                          ->orWhere(function ($q2) use ($cTs, $cId): void {
                              $q2->where('last_modified_at', '=', $cTs)
                                 ->where('id', '>', $cId);
                          });
                    });
                }

                $rows = $query
                    ->orderBy('last_modified_at')
                    ->orderBy('id')
                    ->limit($limit + 1)
                    ->get();

                if ($rows->count() > $limit) {
                    $hasMore = true;
                    $rows = $rows->take($limit);
                    $last = $rows->last();
                    $nextCursor = SyncCursor::encode([
                        'table' => $table,
                        'last_modified_at' => (string) $last->last_modified_at,
                        'id' => $last->id,
                    ]);
                    $data[$table] = $rows->values()->all();
                    $totalRows += $rows->count();
                    break;
                }

                $data[$table] = $rows->values()->all();
                $totalRows += $rows->count();

                // Cursor calistigimiz tablo bittiyse temizle, sonraki
                // tabloya gec.
                $cursorData = null;
            }

            $log->update([
                'completed_at' => now(),
                'pulled_count' => $totalRows,
                'status' => 'success',
            ]);
        } catch (\Throwable $e) {
            $log->update([
                'completed_at' => now(),
                'status' => 'failed',
                'error_message' => $e->getMessage(),
            ]);
            throw $e;
        }

        return [
            'server_time' => now()->toIso8601String(),
            'has_more' => $hasMore,
            'next_cursor' => $nextCursor,
            'next_since' => $hasMore
                ? $sinceCarbon->toIso8601String()
                : now()->toIso8601String(),
            'data' => $data,
        ];
    }
}
