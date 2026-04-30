<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Models\Animal;
use App\Models\Farmer;
use App\Models\MedicalRecord;
use App\Models\User;
use App\Models\Village;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        $vet = User::updateOrCreate(
            ['email' => 'ahmet@vetrota.com.tr'],
            [
                'name' => 'Ahmet Veteriner',
                'password' => 'sifre1234',
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
        ])->map(fn (array $f): Farmer => Farmer::updateOrCreate(['phone' => $f['phone']], $f));

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
            fn (array $a): Animal => Animal::updateOrCreate(['ear_tag' => $a['ear_tag']], $a)
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
                array_merge($r, ['vet_id' => $vet->id]),
            );
        }
    }
}
