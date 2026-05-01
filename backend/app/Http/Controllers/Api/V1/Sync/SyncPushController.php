<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Sync;

use App\Http\Controllers\Controller;
use App\Http\Requests\Sync\SyncPushRequest;
use App\Services\Sync\SyncPushService;
use App\Support\Sync\SyncIdempotencyCache;
use Illuminate\Http\JsonResponse;

class SyncPushController extends Controller
{
    public function __construct(
        private readonly SyncPushService $pushService,
        private readonly SyncIdempotencyCache $idempotency,
    ) {}

    public function __invoke(SyncPushRequest $request): JsonResponse
    {
        $syncId = $request->input('client_sync_id');

        // sync-api.md §9: Idempotent retry — ayni sync_id 24 saat icinde
        // ayni response ile cevaplanir.
        if ($cached = $this->idempotency->get($syncId)) {
            return response()->json($cached);
        }

        $deviceId = $request->attributes->get('device_id');

        $response = $this->pushService->execute(
            user: auth()->user(),
            deviceId: $deviceId,
            clientSyncId: $syncId,
            batch: $request->input('batch', []),
        );

        $this->idempotency->put($syncId, $response);

        return response()->json($response);
    }
}
