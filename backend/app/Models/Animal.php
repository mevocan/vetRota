<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class Animal extends Model
{
    use HasFactory;
    use HasUuids;
    use SoftDeletes;

    protected $fillable = [
        'farmer_id',
        'village_id',
        'ear_tag',
        'name',
        'species',
        'breed',
        'birth_date',
        'gender',
        'weight_kg',
        'color',
        'is_pregnant',
        'last_vaccination_at',
        'status',
        'status_changed_at',
        'status_notes',
        'notes',
    ];

    protected function casts(): array
    {
        return [
            'birth_date' => 'date',
            'weight_kg' => 'decimal:2',
            'is_pregnant' => 'boolean',
            'last_vaccination_at' => 'datetime',
            'status_changed_at' => 'datetime',
        ];
    }

    public function farmer(): BelongsTo
    {
        return $this->belongsTo(Farmer::class);
    }

    public function village(): BelongsTo
    {
        return $this->belongsTo(Village::class);
    }
}
