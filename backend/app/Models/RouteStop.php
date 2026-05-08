<?php

declare(strict_types=1);

namespace App\Models;

use App\Models\Concerns\HasSyncColumns;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class RouteStop extends Model
{
    use HasSyncColumns;
    use HasUuids;
    use SoftDeletes;

    protected $fillable = [
        'clinic_id',
        'route_id',
        'appointment_id',
        'sequence',
        'lat',
        'lng',
        'distance_from_prev_km',
        'status',
        'visited_at',
    ];

    protected function casts(): array
    {
        return [
            'sequence' => 'integer',
            'lat' => 'decimal:7',
            'lng' => 'decimal:7',
            'distance_from_prev_km' => 'decimal:2',
            'visited_at' => 'datetime',
        ];
    }

    public function route(): BelongsTo
    {
        return $this->belongsTo(Route::class);
    }

    public function appointment(): BelongsTo
    {
        return $this->belongsTo(Appointment::class);
    }

    public function clinic(): BelongsTo
    {
        return $this->belongsTo(Clinic::class);
    }
}
