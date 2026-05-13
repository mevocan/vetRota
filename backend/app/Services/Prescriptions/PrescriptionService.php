<?php

declare(strict_types=1);

namespace App\Services\Prescriptions;

use App\Models\MedicalRecord;
use App\Models\Prescription;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

// M7.4.2: Muayeneden recete olustur. Ilac listesi medical_record_drugs'tan
// okunur (zaten muayene kaydedilirken giriliyor). PrescriptionObserver
// kayit sonrasi token uretir ve SMS gonderir.
class PrescriptionService
{
    public function createFromMedicalRecord(
        MedicalRecord $mr,
        ?string $notes = null,
    ): Prescription {
        $mr->loadMissing(['animal.farmer', 'drugs']);

        $animal = $mr->animal;
        $farmer = $animal?->farmer;

        if ($animal === null || $farmer === null) {
            throw new \RuntimeException(
                'Recete olusturulamadi: hayvan veya ciftci bulunamadi.'
            );
        }

        return DB::transaction(function () use ($mr, $animal, $farmer, $notes) {
            return Prescription::create([
                'id' => (string) Str::uuid(),
                'clinic_id' => $mr->clinic_id,
                'medical_record_id' => $mr->id,
                'farmer_id' => $farmer->id,
                'animal_id' => $animal->id,
                'vet_id' => $mr->vet_id,
                'prescription_number' => $this->generateNumber(),
                'notes' => $notes,
            ]);
        });
    }

    private function generateNumber(): string
    {
        // RX-YYMMDD-XXXX (XXXX random hex). Cakisma olasiligi dusuk;
        // unique index varsa retry mantigi gerekirse eklenir.
        return sprintf(
            'RX-%s-%s',
            now()->format('ymd'),
            strtoupper(substr(bin2hex(random_bytes(2)), 0, 4)),
        );
    }
}
