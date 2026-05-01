<?php

declare(strict_types=1);

namespace App\Models;

use App\Models\Concerns\BelongsToClinic;
use App\Models\Concerns\HasSyncColumns;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class MedicalRecord extends Model
{
    use BelongsToClinic;
    use HasFactory;
    use HasSyncColumns;
    use HasUuids;
    use SoftDeletes;

    protected $fillable = [
        'clinic_id',
        'animal_id',
        'vet_id',
        'village_id',
        'lat',
        'lng',
        'visit_type',
        'chief_complaint',
        'symptoms',
        'diagnosis_notes',
        'treatment_notes',
        'recommendations',
        'temperature_celsius',
        'weight_kg',
        'heart_rate',
        'respiratory_rate',
        'service_fee',
        'examined_at',
        'follow_up_needed',
        'follow_up_date',
    ];

    protected function casts(): array
    {
        return [
            'lat' => 'decimal:7',
            'lng' => 'decimal:7',
            'temperature_celsius' => 'decimal:1',
            'weight_kg' => 'decimal:2',
            'service_fee' => 'decimal:2',
            'heart_rate' => 'integer',
            'respiratory_rate' => 'integer',
            'examined_at' => 'datetime',
            'follow_up_needed' => 'boolean',
            'follow_up_date' => 'date',
        ];
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

    public function drugs(): HasMany
    {
        return $this->hasMany(MedicalRecordDrug::class);
    }
}
