<?php

declare(strict_types=1);

namespace App\Services\Sync\TableProcessors;

use App\Models\Animal;
use App\Models\MedicalRecord;

class MedicalRecordProcessor extends AbstractTableProcessor
{
    protected function tableName(): string { return 'medical_records'; }
    protected function modelClass(): string { return MedicalRecord::class; }

    protected function fillable(): array
    {
        return [
            'clinic_id', 'animal_id', 'vet_id', 'village_id', 'lat', 'lng',
            'visit_type', 'chief_complaint', 'symptoms', 'diagnosis_notes',
            'treatment_notes', 'recommendations', 'temperature_celsius',
            'weight_kg', 'heart_rate', 'respiratory_rate', 'service_fee',
            'examined_at', 'follow_up_needed', 'follow_up_date',
        ];
    }

    protected function validateData(array $data): ?string
    {
        if (empty($data['animal_id'])) return 'animal_id zorunlu';
        if (empty($data['examined_at'])) return 'examined_at zorunlu';
        if (empty($data['visit_type'])) return 'visit_type zorunlu';

        $animal = Animal::find($data['animal_id']);
        if (!$animal || $animal->clinic_id !== $this->user->clinic_id) {
            return 'animal bulunamadi veya baska klinige ait';
        }

        return null;
    }
}
