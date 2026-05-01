<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Sync;

use App\Http\Controllers\Controller;
use App\Models\SyncConflict;
use App\Models\SyncLog;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

// sync-api.md §7.
class SyncStatusController extends Controller
{
    public function __invoke(Request $request): JsonResponse
    {
        $deviceId = $request->attributes->get('device_id');

        $lastPush = SyncLog::where('device_id', $deviceId)
            ->where('direction', 'push')
            ->where('status', 'success')
            ->latest('completed_at')
            ->value('completed_at');

        $lastPull = SyncLog::where('device_id', $deviceId)
            ->where('direction', 'pull')
            ->where('status', 'success')
            ->latest('completed_at')
            ->value('completed_at');

        $pendingConflicts = SyncConflict::where('device_id', $deviceId)
            ->where('resolution', 'pending')
            ->count();

        return response()->json([
            'device_id' => $deviceId,
            'last_pushed_at' => $lastPush?->toIso8601String(),
            'last_pulled_at' => $lastPull?->toIso8601String(),
            'pending_conflicts' => $pendingConflicts,
            'server_time' => now()->toIso8601String(),
        ]);
    }
}
