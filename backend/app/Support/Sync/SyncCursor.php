<?php

declare(strict_types=1);

namespace App\Support\Sync;

// sync-api.md §5.4: keyset cursor — table + last_modified_at + id tasir.
class SyncCursor
{
    public static function encode(array $data): string
    {
        return base64_encode(json_encode($data, JSON_THROW_ON_ERROR));
    }

    public static function decode(string $cursor): array
    {
        $decoded = base64_decode($cursor, true);
        if ($decoded === false) {
            return [];
        }

        return json_decode($decoded, true, 512, JSON_THROW_ON_ERROR);
    }
}
