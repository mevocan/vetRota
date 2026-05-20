<?php

declare(strict_types=1);

namespace App\Services\Sync\TableProcessors;

use App\Models\Appointment;
use App\Models\Farmer;

class AppointmentProcessor extends AbstractTableProcessor
{
    protected function tableName(): string { return 'appointments'; }
    protected function modelClass(): string { return Appointment::class; }

    protected function fillable(): array
    {
        return [
            'clinic_id', 'farmer_id', 'animal_id', 'vet_id', 'village_id',
            'scheduled_at', 'estimated_duration_minutes', 'appointment_type',
            'reason', 'notes', 'status', 'status_changed_at',
        ];
    }

    protected function validateData(array $data): ?string
    {
        if (empty($data['farmer_id'])) return 'farmer_id zorunlu';
        if (empty($data['scheduled_at'])) return 'scheduled_at zorunlu';

        $farmer = Farmer::find($data['farmer_id']);
        if (!$farmer || $farmer->clinic_id !== $this->user->clinic_id) {
            return 'farmer bulunamadi veya baska klinige ait';
        }

        return null;
    }

    // Mobil randevu formu vet_id'yi set etmiyor; push'u yapan authenticated
    // kullanici randevuyu yapan veteriner oldugu icin onu doldur.
    protected function fillDefaults(array &$data): void
    {
        if (empty($data['vet_id'])) {
            $data['vet_id'] = $this->user->id;
        }
        // Eski mobil surumler status'u 'scheduled' gonderiyor; server
        // vocabulary'si 'planned'. chk_appt_status ihlalini onlemek icin
        // tolere et (yeni mobil zaten 'planned' gonderiyor).
        if (($data['status'] ?? null) === 'scheduled') {
            $data['status'] = 'planned';
        }
    }
}
