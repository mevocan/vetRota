<?php

declare(strict_types=1);

namespace App\Services\Sync\TableProcessors;

use App\Models\Animal;
use App\Models\Farmer;

class AnimalProcessor extends AbstractTableProcessor
{
    protected function tableName(): string { return 'animals'; }
    protected function modelClass(): string { return Animal::class; }

    protected function fillable(): array
    {
        return [
            'clinic_id', 'farmer_id', 'village_id', 'ear_tag', 'name',
            'species', 'breed', 'birth_date', 'gender', 'weight_kg',
            'color', 'is_pregnant', 'pregnancy_started_at',
            'expected_birth_date', 'pregnancy_notes',
            'last_vaccination_at', 'status',
            'status_changed_at', 'status_notes', 'notes',
        ];
    }

    protected function validateData(array $data): ?string
    {
        if (empty($data['farmer_id'])) return 'farmer_id zorunlu';
        if (empty($data['species'])) return 'species zorunlu';
        if (empty($data['gender'])) return 'gender zorunlu';

        $farmer = Farmer::find($data['farmer_id']);
        if (!$farmer) return 'farmer_id bulunamadi';
        if ($farmer->clinic_id !== $this->user->clinic_id) {
            return 'farmer baska klinige ait';
        }

        $validSpecies = ['cattle', 'sheep', 'goat', 'poultry', 'other'];
        if (!in_array($data['species'], $validSpecies, true)) {
            return 'invalid species';
        }

        return null;
    }
}
