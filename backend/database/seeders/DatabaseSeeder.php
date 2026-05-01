<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Models\Animal;
use App\Models\Appointment;
use App\Models\Clinic;
use App\Models\Drug;
use App\Models\Farmer;
use App\Models\MedicalRecord;
use App\Models\Stock;
use App\Models\StockMovement;
use App\Models\User;
use App\Models\Village;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        // M3.1: Default klinik. Migration'da olusturuldu, seeder tekrar
        // edildiginde firstOrCreate ile idempotent kalir.
        $clinic = Clinic::firstOrCreate(
            ['name' => 'VetRota Demo Klinik'],
            ['city' => 'Ankara', 'district' => 'Beypazarı'],
        );

        $vet = User::updateOrCreate(
            ['email' => 'ahmet@vetrota.com.tr'],
            [
                'name' => 'Ahmet Veteriner',
                'password' => 'sifre1234',
                'clinic_id' => $clinic->id,
                'role' => 'vet',
            ],
        );

        $villages = collect([
            ['name' => 'Büyükdere', 'district' => 'Beypazarı', 'city' => 'Ankara'],
            ['name' => 'Karaçam', 'district' => 'Beypazarı', 'city' => 'Ankara'],
            ['name' => 'Yeniköy', 'district' => 'Nallıhan', 'city' => 'Ankara'],
            ['name' => 'Dutluca', 'district' => 'Nallıhan', 'city' => 'Ankara'],
        ])->map(fn (array $v): Village => Village::updateOrCreate(
            ['name' => $v['name'], 'district' => $v['district'], 'city' => $v['city']],
            $v,
        ));

        $farmers = collect([
            ['first_name' => 'Mehmet', 'last_name' => 'Yılmaz', 'phone' => '5551110001', 'village_id' => $villages[0]->id],
            ['first_name' => 'Ayşe', 'last_name' => 'Demir', 'phone' => '5551110002', 'village_id' => $villages[0]->id],
            ['first_name' => 'Hasan', 'last_name' => 'Kaya', 'phone' => '5551110003', 'village_id' => $villages[1]->id],
            ['first_name' => 'Fatma', 'last_name' => 'Şahin', 'phone' => '5551110004', 'village_id' => $villages[2]->id],
            ['first_name' => 'İbrahim', 'last_name' => 'Çelik', 'phone' => '5551110005', 'village_id' => $villages[3]->id],
        ])->map(fn (array $f): Farmer => Farmer::updateOrCreate(
            ['phone' => $f['phone']],
            array_merge($f, ['clinic_id' => $clinic->id]),
        ));

        // Iki ornek hayvan; tekrar seed'lerde duplicate olmasin diye ear_tag uzerinden idempotent.
        $animals = [
            [
                'farmer_id' => $farmers[0]->id,
                'village_id' => $farmers[0]->village_id,
                'ear_tag' => 'TR-06-001',
                'name' => 'Sarıkız',
                'species' => 'cattle',
                'breed' => 'Simental',
                'gender' => 'female',
                'birth_date' => '2022-03-15',
                'weight_kg' => 420.50,
                'is_pregnant' => true,
                'status' => 'alive',
            ],
            [
                'farmer_id' => $farmers[2]->id,
                'village_id' => $farmers[2]->village_id,
                'ear_tag' => 'TR-06-014',
                'name' => null,
                'species' => 'sheep',
                'breed' => 'Akkaraman',
                'gender' => 'male',
                'birth_date' => '2024-04-10',
                'weight_kg' => 38.20,
                'status' => 'alive',
            ],
        ];

        $createdAnimals = collect($animals)->map(
            fn (array $a): Animal => Animal::updateOrCreate(
                ['ear_tag' => $a['ear_tag']],
                array_merge($a, ['clinic_id' => $clinic->id]),
            )
        );

        // Idempotent muayene seed: ayni hayvan + tarih kombinasyonu varsa olusturma.
        $records = [
            [
                'animal_id' => $createdAnimals[0]->id,
                'village_id' => $createdAnimals[0]->village_id,
                'visit_type' => 'pregnancy_check',
                'examined_at' => '2026-04-20 10:30:00',
                'chief_complaint' => 'Gebelik kontrolu.',
                'diagnosis_notes' => 'Yaklasik 4 aylik gebelik tespit edildi.',
                'treatment_notes' => 'Vitamin destegi onerildi.',
                'recommendations' => 'Iki hafta sonra tekrar kontrol.',
                'temperature_celsius' => 38.7,
                'weight_kg' => 425.00,
                'heart_rate' => 72,
                'service_fee' => 350.00,
                'follow_up_needed' => true,
                'follow_up_date' => '2026-05-04',
            ],
            [
                'animal_id' => $createdAnimals[1]->id,
                'village_id' => $createdAnimals[1]->village_id,
                'visit_type' => 'vaccination',
                'examined_at' => '2026-04-22 14:00:00',
                'chief_complaint' => 'Yillik koruyucu asi.',
                'treatment_notes' => 'Sap-icim ve enterotoksemi karma asisi yapildi.',
                'temperature_celsius' => 39.0,
                'weight_kg' => 39.50,
                'service_fee' => 120.00,
            ],
        ];

        foreach ($records as $r) {
            MedicalRecord::updateOrCreate(
                ['animal_id' => $r['animal_id'], 'examined_at' => $r['examined_at']],
                array_merge($r, ['vet_id' => $vet->id, 'clinic_id' => $clinic->id]),
            );
        }

        // Ilaclar (3 ornek + her birine baslangic stoku ve ilk alim hareketi).
        $drugs = collect([
            [
                'name' => 'Amoksisilin LA',
                'active_ingredient' => 'Amoksisilin',
                'manufacturer' => 'Vetaş',
                'drug_type' => 'antibiotic',
                'unit' => 'ml',
                'package_size' => 100,
                'requires_prescription' => true,
                'is_vaccine' => false,
                'default_price' => 280.00,
                'critical_threshold' => 200,
                'initial_stock' => 1000,
                'expiry' => '2027-06-30',
            ],
            [
                'name' => 'Şap Aşısı (Trivalan)',
                'active_ingredient' => null,
                'manufacturer' => 'Pendik',
                'drug_type' => 'vaccine',
                'unit' => 'doz',
                'package_size' => 50,
                'requires_prescription' => true,
                'is_vaccine' => true,
                'vaccine_duration_days' => 180,
                'default_price' => 15.00,
                'critical_threshold' => 100,
                'initial_stock' => 500,
                'expiry' => '2026-09-15',
            ],
            [
                'name' => 'İvermektin',
                'active_ingredient' => 'İvermektin',
                'manufacturer' => 'Bayer',
                'drug_type' => 'antiparasitic',
                'unit' => 'ml',
                'package_size' => 50,
                'requires_prescription' => false,
                'is_vaccine' => false,
                'default_price' => 95.00,
                'critical_threshold' => 100,
                'initial_stock' => 80, // bilerek dusuk - kritik testi icin
                'expiry' => '2027-03-01',
            ],
        ]);

        foreach ($drugs as $d) {
            $initial = $d['initial_stock'];
            $expiry = $d['expiry'];
            $threshold = $d['critical_threshold'];
            unset($d['initial_stock'], $d['expiry'], $d['critical_threshold']);

            $drug = Drug::firstOrCreate(
                ['name' => $d['name']],
                array_merge($d, ['clinic_id' => $clinic->id]),
            );

            $stock = Stock::firstOrCreate(
                ['drug_id' => $drug->id],
                ['clinic_id' => $clinic->id, 'current_quantity' => 0, 'critical_threshold' => $threshold]
            );

            // Idempotent: ayni drug icin baslangic 'purchase' hareketi sadece 1 kez eklensin.
            $alreadySeeded = StockMovement::where('drug_id', $drug->id)
                ->where('movement_type', 'purchase')
                ->where('notes', 'Seed: baslangic stoku')
                ->exists();
            if (!$alreadySeeded) {
                StockMovement::create([
                    'clinic_id' => $clinic->id,
                    'stock_id' => $stock->id,
                    'drug_id' => $drug->id,
                    'movement_type' => 'purchase',
                    'quantity' => $initial,
                    'unit_price' => $d['default_price'],
                    'expiry_date' => $expiry,
                    'supplier_name' => 'Seed Tedarikçi',
                    'performed_by' => $vet->id,
                    'notes' => 'Seed: baslangic stoku',
                    'occurred_at' => now()->subDays(30),
                ]);

                // Seeder WithoutModelEvents kullaniyor; observer calismadigi icin
                // stocks cache'ini el ile guncelle.
                $stock->update([
                    'current_quantity' => $initial,
                    'last_purchased_at' => now()->subDays(30),
                    'earliest_expiry_at' => $expiry,
                ]);
            }
        }

        // Randevular: idempotent kombinasyon = farmer + scheduled_at.
        $appointments = [
            [
                'farmer_id' => $farmers[0]->id,
                'animal_id' => $createdAnimals[0]->id,
                'village_id' => $createdAnimals[0]->village_id,
                'scheduled_at' => now()->addDay()->setTime(10, 0),
                'estimated_duration_minutes' => 45,
                'appointment_type' => 'follow_up',
                'reason' => 'Gebelik takip kontrolu (Sarikiz).',
                'status' => 'planned',
            ],
            [
                'farmer_id' => $farmers[2]->id,
                'animal_id' => $createdAnimals[1]->id,
                'village_id' => $createdAnimals[1]->village_id,
                'scheduled_at' => now()->addDays(2)->setTime(14, 30),
                'estimated_duration_minutes' => 30,
                'appointment_type' => 'vaccination',
                'reason' => 'Yillik koruyucu asi.',
                'status' => 'confirmed',
            ],
            [
                'farmer_id' => $farmers[1]->id,
                'animal_id' => null,
                'village_id' => $farmers[1]->village_id,
                'scheduled_at' => now()->addDays(3)->setTime(9, 30),
                'estimated_duration_minutes' => 60,
                'appointment_type' => 'visit',
                'reason' => 'Surudeki tum hayvanlar icin genel kontrol.',
                'status' => 'planned',
            ],
            [
                'farmer_id' => $farmers[3]->id,
                'animal_id' => null,
                'village_id' => $farmers[3]->village_id,
                'scheduled_at' => now()->subDay()->setTime(11, 0),
                'estimated_duration_minutes' => 30,
                'appointment_type' => 'routine_check',
                'reason' => 'Rutin kontrol.',
                'status' => 'completed',
                'status_changed_at' => now()->subDay()->setTime(12, 0),
            ],
        ];

        foreach ($appointments as $a) {
            Appointment::updateOrCreate(
                ['farmer_id' => $a['farmer_id'], 'scheduled_at' => $a['scheduled_at']],
                array_merge($a, ['vet_id' => $vet->id, 'clinic_id' => $clinic->id]),
            );
        }
    }
}
