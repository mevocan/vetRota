<?php

declare(strict_types=1);

namespace App\Enums\Sync;

enum SyncResult: string
{
    case Accepted = 'accepted';
    case Conflict = 'conflict';
    case Rejected = 'rejected';
}
