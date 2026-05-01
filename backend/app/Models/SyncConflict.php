<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class SyncConflict extends Model
{
    use HasUuids;

    protected $fillable = [
        'device_id',
        'clinic_id',
        'table_name',
        'record_id',
        'local_version',
        'server_version',
        'local_payload',
        'server_payload',
        'resolution_strategy',
        'resolution',
        'resolved_at',
    ];

    protected function casts(): array
    {
        return [
            'local_payload' => 'array',
            'server_payload' => 'array',
            'local_version' => 'integer',
            'server_version' => 'integer',
            'resolved_at' => 'datetime',
        ];
    }
}
