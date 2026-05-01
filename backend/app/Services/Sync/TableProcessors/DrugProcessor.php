<?php

declare(strict_types=1);

namespace App\Services\Sync\TableProcessors;

use App\Models\Drug;

class DrugProcessor extends AbstractTableProcessor
{
    protected function tableName(): string { return 'drugs'; }
    protected function modelClass(): string { return Drug::class; }

    protected function fillable(): array
    {
        return [
            'clinic_id', 'name', 'active_ingredient', 'manufacturer', 'barcode',
            'drug_type', 'requires_prescription', 'unit', 'package_size',
            'is_vaccine', 'vaccine_duration_days', 'suitable_species',
            'default_price',
        ];
    }

    protected function validateData(array $data): ?string
    {
        if (empty($data['name'])) return 'name zorunlu';
        if (empty($data['unit'])) return 'unit zorunlu';
        return null;
    }
}
