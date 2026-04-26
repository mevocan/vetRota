<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Models\Animal;
use App\Models\Farmer;
use App\Models\User;
use App\Models\Village;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        User::updateOrCreate(
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

        foreach ($animals as $a) {
            Animal::updateOrCreate(['ear_tag' => $a['ear_tag']], $a);
        }
    }
}
