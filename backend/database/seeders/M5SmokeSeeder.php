<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Models\Animal;
use App\Models\Appointment;
use App\Models\Clinic;
use App\Models\Farmer;
use App\Models\User;
use App\Models\Village;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

// M5.9 cihaz smoke testi icin: bugune 5 randevu, koylere lat/lng.
// Calistir: php artisan db:seed --class=M5SmokeSeeder
//
// Idempotent: ayni gun ayni saat icin tekrar calistirilirsa
// updateOrCreate ile guncellenir.
class M5SmokeSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        $clinic = Clinic::firstOrCreate(
            ['name' => 'VetRota Demo Klinik'],
            ['city' => 'Ankara', 'district' => 'Beypazarı'],
        );

        $vet = User::where('email', 'ahmet@vetrota.com.tr')->firstOrFail();

        // Beypazari + Nallihan civari gercek lat/lng (yaklasik).
        // Veterinerin gunluk dolastigi tipik 5 koy senaryosu.
        $villages = [
            ['name' => 'Büyükdere',  'district' => 'Beypazarı', 'lat' => 40.1660, 'lng' => 31.9260],
            ['name' => 'Karaçam',    'district' => 'Beypazarı', 'lat' => 40.1020, 'lng' => 31.8500],
            ['name' => 'Yeniköy',    'district' => 'Nallıhan',  'lat' => 40.1850, 'lng' => 31.3500],
            ['name' => 'Dutluca',    'district' => 'Nallıhan',  'lat' => 40.2050, 'lng' => 31.4050],
            ['name' => 'Çayırhan',   'district' => 'Nallıhan',  'lat' => 40.1380, 'lng' => 31.5440],
        ];

        $villageRows = [];
        foreach ($villages as $v) {
            $villageRows[] = Village::updateOrCreate(
                ['name' => $v['name'], 'district' => $v['district'], 'city' => 'Ankara'],
                ['lat' => $v['lat'], 'lng' => $v['lng'], 'city' => 'Ankara'],
            );
        }

        // Her koye 1 ciftci.
        $farmers = [];
        foreach ($villageRows as $i => $village) {
            $phone = '5559990' . str_pad((string) ($i + 1), 3, '0', STR_PAD_LEFT);
            $farmers[] = Farmer::updateOrCreate(
                ['phone' => $phone],
                [
                    'first_name' => ['Mehmet', 'Ayşe', 'Hasan', 'Fatma', 'İbrahim'][$i],
                    'last_name' => ['Yıldız', 'Aydın', 'Öztürk', 'Korkmaz', 'Polat'][$i],
                    'phone' => $phone,
                    'village_id' => $village->id,
                    'clinic_id' => $clinic->id,
                ],
            );
        }

        // Her ciftciye 1 hayvan (M5 smoke icin 5 hayvan, 5 ear_tag).
        $animals = [];
        $species = ['cattle', 'sheep', 'goat', 'cattle', 'sheep'];
        $names = ['Boncuk', 'Karakız', 'Pamuk', 'Tosun', 'Yıldız'];
        foreach ($farmers as $i => $farmer) {
            $earTag = 'TR-06-M5-' . str_pad((string) ($i + 1), 3, '0', STR_PAD_LEFT);
            $animals[] = Animal::updateOrCreate(
                ['ear_tag' => $earTag],
                [
                    'farmer_id' => $farmer->id,
                    'village_id' => $farmer->village_id,
                    'ear_tag' => $earTag,
                    'name' => $names[$i],
                    'species' => $species[$i],
                    'gender' => $i % 2 === 0 ? 'female' : 'male',
                    'status' => 'alive',
                    'clinic_id' => $clinic->id,
                ],
            );
        }

        // Bugune 5 randevu, farkli saatlerde.
        $today = now()->startOfDay();
        $slots = [
            ['hour' => 9,  'minute' => 0,  'reason' => 'Gebelik kontrolu',          'type' => 'routine_check'],
            ['hour' => 10, 'minute' => 30, 'reason' => 'Yillik koruyucu asi',       'type' => 'vaccination'],
            ['hour' => 13, 'minute' => 0,  'reason' => 'Yara kontrolu',             'type' => 'follow_up'],
            ['hour' => 14, 'minute' => 30, 'reason' => 'Surudeki genel kontrol',    'type' => 'visit'],
            ['hour' => 16, 'minute' => 0,  'reason' => 'Topallik sikayeti',         'type' => 'routine_check'],
        ];

        foreach ($slots as $i => $slot) {
            $scheduledAt = $today->copy()->setTime($slot['hour'], $slot['minute']);
            Appointment::updateOrCreate(
                ['farmer_id' => $farmers[$i]->id, 'scheduled_at' => $scheduledAt],
                [
                    'farmer_id' => $farmers[$i]->id,
                    'animal_id' => $animals[$i]->id,
                    'village_id' => $villageRows[$i]->id,
                    'scheduled_at' => $scheduledAt,
                    'estimated_duration_minutes' => 30,
                    'appointment_type' => $slot['type'],
                    'reason' => $slot['reason'],
                    'status' => 'planned',
                    'vet_id' => $vet->id,
                    'clinic_id' => $clinic->id,
                ],
            );
        }

        $this->command->info('M5 smoke seed: 5 koy lat/lng, 5 ciftci, 5 hayvan, bugune 5 randevu.');
        $this->command->info('Vet: ' . $vet->email . '  /  Tarih: ' . $today->toDateString());
    }
}
