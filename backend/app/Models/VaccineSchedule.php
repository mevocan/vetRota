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

class VaccineSchedule extends Model
{
    use BelongsToClinic, HasFactory, HasSyncColumns, HasUuids, SoftDeletes;

    protected $fillable = [
        'clinic_id', 'animal_id', 'drug_id', 'interval_days',
        'first_due_date', 'next_due_date', 'last_administered_at',
        'remind_days_before', 'is_active', 'notes',
        'origin_device_id',
    ];

    protected function casts(): array
    {
        return [
            'first_due_date' => 'date',
            'next_due_date' => 'date',
            'last_administered_at' => 'datetime',
            'is_active' => 'boolean',
            'interval_days' => 'integer',
            'remind_days_before' => 'integer',
        ];
    }

    public function animal(): BelongsTo
    {
        return $this->belongsTo(Animal::class);
    }

    public function drug(): BelongsTo
    {
        return $this->belongsTo(Drug::class);
    }

    public function reminders(): HasMany
    {
        return $this->hasMany(VaccinationReminder::class);
    }
}
