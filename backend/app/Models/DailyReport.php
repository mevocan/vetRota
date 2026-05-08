<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DailyReport extends Model
{
    use HasUuids;

    protected $fillable = [
        'clinic_id',
        'vet_id',
        'date',
        'animals_visited',
        'medical_records_count',
        'total_distance_km',
        'total_revenue',
        'drugs_used',
        'pdf_path',
        'generated_at',
    ];

    protected function casts(): array
    {
        return [
            'date' => 'date',
            'animals_visited' => 'integer',
            'medical_records_count' => 'integer',
            'total_distance_km' => 'decimal:2',
            'total_revenue' => 'decimal:2',
            'drugs_used' => 'array',
            'generated_at' => 'datetime',
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
}
