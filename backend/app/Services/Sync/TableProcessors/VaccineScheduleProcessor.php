<?php

declare(strict_types=1);

namespace App\Services\Sync\TableProcessors;

use App\Models\Animal;
use App\Models\Drug;
use App\Models\VaccineSchedule;

class VaccineScheduleProcessor extends AbstractTableProcessor
{
    protected function tableName(): string { return 'vaccine_schedules'; }
    protected function modelClass(): string { return VaccineSchedule::class; }

    protected function fillable(): array
    {
        return [
            'clinic_id', 'animal_id', 'drug_id', 'interval_days',
            'first_due_date', 'next_due_date', 'last_administered_at',
            'remind_days_before', 'is_active', 'notes',
        ];
    }

    protected function validateData(array $data): ?string
    {
        if (empty($data['animal_id'])) return 'animal_id zorunlu';
        if (empty($data['drug_id'])) return 'drug_id zorunlu';
        if (empty($data['first_due_date'])) return 'first_due_date zorunlu';
        if (empty($data['next_due_date'])) return 'next_due_date zorunlu';
        // interval_days NOT NULL + default'suz; null gelirse tum batch'i
        // 500'le dusurmesin diye burada reddet.
        if (!isset($data['interval_days'])) return 'interval_days zorunlu';

        $animal = Animal::find($data['animal_id']);
        if (!$animal) return 'animal_id bulunamadi';
        if ($animal->clinic_id !== $this->user->clinic_id) {
            return 'animal baska klinige ait';
        }

        $drug = Drug::find($data['drug_id']);
        if (!$drug) return 'drug_id bulunamadi';
        if ($drug->clinic_id !== $this->user->clinic_id) {
            return 'drug baska klinige ait';
        }

        return null;
    }
}
