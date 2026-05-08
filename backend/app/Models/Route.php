<?php

declare(strict_types=1);

namespace App\Models;

use App\Models\Concerns\HasSyncColumns;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Route extends Model
{
    use HasSyncColumns;
    use HasUuids;
    use SoftDeletes;

    protected $fillable = [
        'clinic_id',
        'vet_id',
        'date',
        'total_distance_km',
        'total_duration_min',
        'start_lat',
        'start_lng',
    ];

    protected function casts(): array
    {
        return [
            'date' => 'date',
            'total_distance_km' => 'decimal:2',
            'start_lat' => 'decimal:7',
            'start_lng' => 'decimal:7',
        ];
    }

    public function vet(): BelongsTo
    {
        return $this->belongsTo(User::class, 'vet_id');
    }

    public function clinic(): BelongsTo
    {
        return $this->belongsTo(Clinic::class);
    }

    public function stops(): HasMany
    {
        return $this->hasMany(RouteStop::class)->orderBy('sequence');
    }
}
