<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class Appointment extends Model
{
    use HasFactory;
    use HasUuids;
    use SoftDeletes;

    protected $fillable = [
        'farmer_id',
        'animal_id',
        'vet_id',
        'village_id',
        'scheduled_at',
        'estimated_duration_minutes',
        'appointment_type',
        'reason',
        'notes',
        'status',
        'status_changed_at',
    ];

    protected function casts(): array
    {
        return [
            'scheduled_at' => 'datetime',
            'status_changed_at' => 'datetime',
            'estimated_duration_minutes' => 'integer',
        ];
    }

    public function farmer(): BelongsTo
    {
        return $this->belongsTo(Farmer::class);
    }

    public function animal(): BelongsTo
    {
        return $this->belongsTo(Animal::class);
    }

    public function vet(): BelongsTo
    {
        return $this->belongsTo(User::class, 'vet_id');
    }

    public function village(): BelongsTo
    {
        return $this->belongsTo(Village::class);
    }
}
