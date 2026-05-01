<?php

declare(strict_types=1);

namespace App\Services\Sync\TableProcessors;

use App\Models\Village;

class VillageProcessor extends AbstractTableProcessor
{
    protected function tableName(): string { return 'villages'; }
    protected function modelClass(): string { return Village::class; }

    protected function fillable(): array
    {
        return ['name', 'district', 'city', 'lat', 'lng'];
    }

    protected function validateData(array $data): ?string
    {
        if (empty($data['name'])) return 'name zorunlu';
        if (empty($data['city'])) return 'city zorunlu';
        return null;
    }
}
