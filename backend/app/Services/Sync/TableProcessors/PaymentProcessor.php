<?php

declare(strict_types=1);

namespace App\Services\Sync\TableProcessors;

use App\Models\Farmer;
use App\Models\Payment;

class PaymentProcessor extends AbstractTableProcessor
{
    protected function tableName(): string { return 'payments'; }
    protected function modelClass(): string { return Payment::class; }

    protected function fillable(): array
    {
        return [
            'clinic_id', 'farmer_id', 'vet_id', 'amount',
            'method', 'paid_at', 'notes',
        ];
    }

    protected function validateData(array $data): ?string
    {
        if (empty($data['farmer_id'])) return 'farmer_id zorunlu';
        if (!isset($data['amount'])) return 'amount zorunlu';

        $farmer = Farmer::find($data['farmer_id']);
        if (!$farmer || $farmer->clinic_id !== $this->user->clinic_id) {
            return 'farmer bulunamadi veya baska klinige ait';
        }
        return null;
    }

    protected function fillDefaults(array &$data): void
    {
        if (empty($data['vet_id'])) {
            $data['vet_id'] = $this->user->id;
        }
        if (empty($data['method'])) {
            $data['method'] = 'cash';
        }
        if (empty($data['paid_at'])) {
            $data['paid_at'] = now();
        }
    }
}
