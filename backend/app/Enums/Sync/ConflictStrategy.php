<?php

declare(strict_types=1);

namespace App\Enums\Sync;

// sync-api.md §8 — tablo bazinda strateji.
enum ConflictStrategy: string
{
    case LastWriteWins = 'last_write_wins';
    case AdditiveMerge = 'additive_merge';
    case ServerAuthoritative = 'server_authoritative';
    case Manual = 'manual';

    public static function forTable(string $table): self
    {
        return match ($table) {
            'stock_movements', 'payments' => self::AdditiveMerge,
            'outbreak_alerts', 'daily_reports' => self::ServerAuthoritative,
            default => self::LastWriteWins,
        };
    }
}
