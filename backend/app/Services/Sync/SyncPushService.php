<?php

declare(strict_types=1);

namespace App\Services\Sync;

use App\Enums\Sync\SyncResult;
use App\Models\SyncLog;
use App\Models\User;
use App\Services\Sync\TableProcessors\AnimalProcessor;
use App\Services\Sync\TableProcessors\AppointmentProcessor;
use App\Services\Sync\TableProcessors\DrugProcessor;
use App\Services\Sync\TableProcessors\FarmerProcessor;
use App\Services\Sync\TableProcessors\MedicalRecordDrugProcessor;
use App\Services\Sync\TableProcessors\MedicalRecordProcessor;
use App\Services\Sync\TableProcessors\PaymentProcessor;
use App\Services\Sync\TableProcessors\StockMovementProcessor;
use App\Services\Sync\TableProcessors\StockProcessor;
use App\Services\Sync\TableProcessors\VaccineScheduleProcessor;
use App\Services\Sync\TableProcessors\VillageProcessor;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

// sync-api.md §11.8 — orkestrator. FK siralamasi sabit.
class SyncPushService
{
    /** @var array<string, class-string> */
    private array $processors = [
        'villages'             => VillageProcessor::class,
        'farmers'              => FarmerProcessor::class,
        'animals'              => AnimalProcessor::class,
        'appointments'         => AppointmentProcessor::class,
        'medical_records'      => MedicalRecordProcessor::class,
        'medical_record_drugs' => MedicalRecordDrugProcessor::class,
        'drugs'                => DrugProcessor::class,
        'stocks'               => StockProcessor::class,
        'stock_movements'      => StockMovementProcessor::class,
        'payments'             => PaymentProcessor::class,
        // vaccine_schedules animals + drugs'a bagli; ikisi de yukarida islendigi
        // icin en sona eklendi (FK siralamasi). M9'da mobil push'a girmisti ama
        // burada processor'i eksikti — asi planlari sessizce hic sync olmuyordu.
        'vaccine_schedules'    => VaccineScheduleProcessor::class,
    ];

    public function execute(User $user, string $deviceId, string $clientSyncId, array $batch): array
    {
        $results = ['accepted' => [], 'conflicts' => [], 'rejected' => []];

        $syncLog = SyncLog::create([
            'device_id' => $deviceId,
            'user_id' => $user->id,
            'clinic_id' => $user->clinic_id,
            'direction' => 'push',
            'status' => 'in_progress',
            'started_at' => now(),
        ]);

        try {
            DB::transaction(function () use ($batch, $user, $deviceId, &$results): void {
                foreach ($this->processors as $table => $processorClass) {
                    $records = $batch[$table] ?? [];
                    if (empty($records)) {
                        continue;
                    }

                    /** @var \App\Services\Sync\Contracts\TableProcessorInterface $processor */
                    $processor = app($processorClass);
                    $processor->setContext($user, $deviceId);

                    foreach ($records as $record) {
                        $result = $processor->process($record);
                        $this->bucket($results, $table, $record['id'], $result);
                    }
                }
            });

            $syncLog->update([
                'completed_at' => now(),
                'pushed_count' => count($results['accepted']),
                'conflict_count' => count($results['conflicts']),
                'status' => 'success',
                'metadata' => ['rejected_count' => count($results['rejected'])],
            ]);
        } catch (\Throwable $e) {
            Log::error('Sync push failed', [
                'device_id' => $deviceId,
                'sync_id' => $clientSyncId,
                'error' => $e->getMessage(),
            ]);

            $syncLog->update([
                'completed_at' => now(),
                'status' => 'failed',
                'error_message' => $e->getMessage(),
            ]);

            throw $e;
        }

        return [
            'client_sync_id' => $clientSyncId,
            'server_time' => now()->toIso8601String(),
            'results' => $results,
        ];
    }

    private function bucket(array &$results, string $table, string $id, array $result): void
    {
        switch ($result['status']) {
            case SyncResult::Accepted->value:
                $results['accepted'][] = [
                    'table' => $table,
                    'id' => $id,
                    'new_version' => $result['version'] ?? null,
                ];
                break;

            case SyncResult::Conflict->value:
                $results['conflicts'][] = array_merge(
                    ['table' => $table, 'id' => $id],
                    $result['conflict'] ?? [],
                );
                break;

            case SyncResult::Rejected->value:
                $results['rejected'][] = [
                    'table' => $table,
                    'id' => $id,
                    'reason' => $result['reason'] ?? 'unknown',
                    'detail' => $result['detail'] ?? null,
                ];
                break;
        }
    }
}
