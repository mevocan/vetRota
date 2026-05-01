<?php

declare(strict_types=1);

namespace App\Services\Sync\TableProcessors;

use App\Models\Farmer;
use App\Models\Village;

class FarmerProcessor extends AbstractTableProcessor
{
    protected function tableName(): string { return 'farmers'; }
    protected function modelClass(): string { return Farmer::class; }

    protected function fillable(): array
    {
        return [
            'clinic_id', 'village_id', 'first_name', 'last_name',
            'phone', 'email', 'address_detail', 'balance',
            'sms_notifications_enabled', 'preferred_sms_language', 'notes',
        ];
    }

    protected function validateData(array $data): ?string
    {
        if (empty($data['first_name'])) return 'first_name zorunlu';
        if (empty($data['phone'])) return 'phone zorunlu';

        if (!empty($data['village_id'])) {
            if (!Village::where('id', $data['village_id'])->exists()) {
                return 'village_id bulunamadi';
            }
        }

        return null;
    }
}
