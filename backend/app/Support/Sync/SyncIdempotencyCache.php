<?php

declare(strict_types=1);

namespace App\Support\Sync;

use Illuminate\Support\Facades\Cache;

// sync-api.md §9: aynı `client_sync_id` ile gelen 2. push aynı response'u
// döner, DB'ye dokunmaz. TTL 24 saat.
class SyncIdempotencyCache
{
    private const PREFIX = 'sync:idempotency:';

    public function get(string $syncId): ?array
    {
        return Cache::get(self::PREFIX . $syncId);
    }

    public function put(string $syncId, array $response, int $ttl = 86400): void
    {
        Cache::put(self::PREFIX . $syncId, $response, $ttl);
    }
}
