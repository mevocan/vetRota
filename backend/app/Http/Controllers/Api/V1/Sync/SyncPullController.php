<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Sync;

use App\Http\Controllers\Controller;
use App\Services\Sync\SyncPullService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SyncPullController extends Controller
{
    public function __construct(private readonly SyncPullService $pullService) {}

    public function __invoke(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'since'  => ['required', 'date'],
            'tables' => ['sometimes', 'string'],
            'limit'  => ['sometimes', 'integer', 'min:1', 'max:1000'],
            'cursor' => ['sometimes', 'string'],
        ]);

        $deviceId = $request->attributes->get('device_id');

        $response = $this->pullService->execute(
            user: auth()->user(),
            deviceId: $deviceId,
            since: $validated['since'],
            tables: isset($validated['tables'])
                ? array_filter(explode(',', $validated['tables']))
                : null,
            limit: (int) ($validated['limit'] ?? 500),
            cursor: $validated['cursor'] ?? null,
        );

        return response()->json($response);
    }
}
