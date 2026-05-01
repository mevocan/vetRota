<?php

declare(strict_types=1);

namespace App\Services\Sync\Contracts;

use App\Models\User;

interface TableProcessorInterface
{
    public function setContext(User $user, string $deviceId): void;

    /**
     * Tek kayit isle. Donen array sekli:
     *   ['status' => SyncResult::value, 'version' => int|null,
     *    'conflict' => ['strategy' => ..., 'resolution' => ...],
     *    'reason' => 'validation', 'detail' => 'text']
     */
    public function process(array $record): array;
}
