<?php

declare(strict_types=1);

namespace App\Services\Sync\TableProcessors;

use App\Models\Drug;
use App\Models\MedicalRecord;
use App\Models\MedicalRecordDrug;

class MedicalRecordDrugProcessor extends AbstractTableProcessor
{
    protected function tableName(): string { return 'medical_record_drugs'; }
    protected function modelClass(): string { return MedicalRecordDrug::class; }

    protected function fillable(): array
    {
        return [
            'clinic_id', 'medical_record_id', 'drug_id',
            'quantity', 'unit', 'route', 'frequency',
            'unit_price', 'batch_number', 'notes',
        ];
    }

    protected function validateData(array $data): ?string
    {
        if (empty($data['medical_record_id'])) return 'medical_record_id zorunlu';
        if (empty($data['drug_id'])) return 'drug_id zorunlu';
        if (!isset($data['quantity'])) return 'quantity zorunlu';

        $mr = MedicalRecord::find($data['medical_record_id']);
        if (!$mr || $mr->clinic_id !== $this->user->clinic_id) {
            return 'medical_record bulunamadi veya baska klinige ait';
        }

        if (!Drug::where('id', $data['drug_id'])->exists()) {
            return 'drug_id bulunamadi';
        }

        return null;
    }
}
