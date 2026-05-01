<?php

declare(strict_types=1);

namespace App\Enums\Sync;

enum SyncOperation: string
{
    case Upsert = 'upsert';
    case Delete = 'delete';
}
