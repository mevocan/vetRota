<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class VaccinationReminder extends Model
{
    use HasFactory, HasUuids, SoftDeletes;

    protected $fillable = [
        'vaccine_schedule_id', 'animal_id', 'farmer_id', 'clinic_id',
        'due_date', 'reminder_at', 'status', 'sms_sent_at',
        'acknowledged_at', 'completed_medical_record_id',
    ];

    protected function casts(): array
    {
        return [
            'due_date' => 'date',
            'reminder_at' => 'datetime',
            'sms_sent_at' => 'datetime',
            'acknowledged_at' => 'datetime',
        ];
    }

    public function schedule(): BelongsTo
    {
        return $this->belongsTo(VaccineSchedule::class, 'vaccine_schedule_id');
    }

    public function animal(): BelongsTo
    {
        return $this->belongsTo(Animal::class);
    }

    public function farmer(): BelongsTo
    {
        return $this->belongsTo(Farmer::class);
    }
}
