<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Models\Animal;
use App\Models\Appointment;
use App\Models\Clinic;
use App\Models\DailyReport;
use App\Models\Drug;
use App\Models\Farmer;
use App\Models\FarmerPortalToken;
use App\Models\MedicalRecord;
use App\Models\MedicalRecordDrug;
use App\Models\Payment;
use App\Models\Prescription;
use App\Models\Route;
use App\Models\RouteStop;
use App\Models\SmsMessage;
use App\Models\Stock;
use App\Models\StockMovement;
use App\Models\User;
use App\Models\VaccinationReminder;
use App\Models\VaccineSchedule;
use App\Models\Village;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * Demo/gercekci veri seti. Beypazari + Nallihan bolgesinde Premium klinik:
 * 2 vet, 10 koy, 30 ciftci, ~130 hayvan, ~280 muayene (son 60 gun),
 * ilac+stok hareketleri, randevular, receteler, asi planlari+hatirlatma,
 * borc-odeme ledgeri, SMS gecmisi, rotalar, gun sonu raporu, iki outbreak.
 */
class DemoSeeder extends Seeder
{
    use WithoutModelEvents;

    private const TURKISH_MALE = [
        'Ahmet', 'Mehmet', 'Ali', 'Hasan', 'Hüseyin', 'İbrahim', 'Mustafa', 'Osman',
        'Recep', 'Salih', 'Veli', 'Yusuf', 'Halil', 'Kemal', 'Ramazan', 'Süleyman',
    ];

    private const TURKISH_FEMALE = [
        'Ayşe', 'Fatma', 'Emine', 'Hatice', 'Zeynep', 'Meryem', 'Elif', 'Hülya',
        'Gül', 'Şükran', 'Sevgi', 'Nazmiye',
    ];

    private const TURKISH_SURNAMES = [
        'Yılmaz', 'Demir', 'Kaya', 'Şahin', 'Çelik', 'Yıldız', 'Aydın', 'Öztürk',
        'Arslan', 'Doğan', 'Kurt', 'Polat', 'Korkmaz', 'Çetin', 'Erdoğan', 'Koç',
        'Karaca', 'Bulut', 'Aksoy', 'Bozkurt', 'Acar', 'Tekin',
    ];

    private const CATTLE_NAMES = ['Sarıkız', 'Karabaş', 'Boncuk', 'Kıvırcık', 'Maviş', 'Lale', 'Pamuk', 'Yıldız', 'Çakır', 'Benekli', 'Karagöz', 'Tombul'];
    private const CATTLE_BREEDS = ['Holstein', 'Simental', 'Jersey', 'Yerli Kara', 'Montofon', 'Şarole'];
    private const SHEEP_BREEDS = ['Akkaraman', 'Morkaraman', 'Kıvırcık', 'İvesi', 'Dağlıç'];
    private const GOAT_BREEDS = ['Kıl Keçisi', 'Saanen', 'Ankara Keçisi'];

    public function run(): void
    {
        DB::transaction(function (): void {
            $this->seedAll();
        });
    }

    private function seedAll(): void
    {
        mt_srand(20260519);

        // -------- Klinik (Premium aktif) --------
        $clinic = Clinic::create([
            'name' => 'VetRota Beypazarı Kliniği',
            'phone' => '03126301010',
            'email' => 'info@vetrota.com.tr',
            'city' => 'Ankara',
            'district' => 'Beypazarı',
            'subscription_tier' => 'premium',
            'subscription_expires_at' => now()->addMonths(11),
        ]);

        // -------- Veterinerler --------
        $ahmet = User::create([
            'name' => 'Ahmet Yıldırım',
            'email' => 'ahmet@vetrota.com.tr',
            'password' => Hash::make('sifre1234'),
            'clinic_id' => $clinic->id,
            'role' => 'vet',
        ]);

        $ayse = User::create([
            'name' => 'Ayşe Demir',
            'email' => 'ayse@vetrota.com.tr',
            'password' => Hash::make('sifre1234'),
            'clinic_id' => $clinic->id,
            'role' => 'vet',
        ]);

        $sekreter = User::create([
            'name' => 'Selma Acar',
            'email' => 'selma@vetrota.com.tr',
            'password' => Hash::make('sifre1234'),
            'clinic_id' => $clinic->id,
            'role' => 'secretary',
        ]);

        $vets = [$ahmet, $ayse];

        // -------- Köyler (lat/lng) --------
        $villageSpecs = [
            ['Büyükdere', 'Beypazarı', 40.1880, 31.9020],
            ['Karaçam', 'Beypazarı', 40.1543, 31.8721],
            ['Kapullu', 'Beypazarı', 40.2210, 31.9450],
            ['Karaşar', 'Beypazarı', 40.0901, 31.9700],
            ['Uruş', 'Beypazarı', 40.0500, 31.8200],
            ['Yeniköy', 'Nallıhan', 40.2010, 31.4123],
            ['Dutluca', 'Nallıhan', 40.2456, 31.3502],
            ['Çayırhan', 'Nallıhan', 40.1700, 31.4800],
            ['Sarıyar', 'Nallıhan', 40.0823, 31.5612],
            ['Akçakese', 'Nallıhan', 40.0998, 31.7500],
        ];

        $villages = [];
        foreach ($villageSpecs as [$name, $district, $lat, $lng]) {
            $villages[] = Village::create([
                'name' => $name,
                'district' => $district,
                'city' => 'Ankara',
                'lat' => $lat,
                'lng' => $lng,
            ]);
        }

        // -------- İlaçlar --------
        $drugSpecs = [
            // [name, ai, manufacturer, type, unit, package, requires_rx, is_vaccine, duration, price, threshold, initial_qty, expiry]
            ['Amoksisilin LA',   'Amoksisilin',  'Vetaş',    'antibiotic',    'ml',  100, true,  false, null, 280.00,  200,   3500, '2027-06-30'],
            ['Penisilin Prokain','Penisilin',    'Topkim',   'antibiotic',    'ml',  100, true,  false, null, 195.00,  150,   2800, '2027-03-15'],
            ['Şap Aşısı (Trivalan)', null,        'Pendik',   'vaccine',       'doz', 50,  true,  true,  180,  15.00,   100,   850,  '2026-09-15'],
            ['Brusella Aşısı',   null,            'Pendik',   'vaccine',       'doz', 25,  true,  true,  365,  22.00,   80,    420,  '2026-11-30'],
            ['Enterotoksemi',    null,            'Vetal',    'vaccine',      'doz',  100, true,  true,  365,  18.00,   100,   620,  '2027-01-10'],
            ['İvermektin',       'İvermektin',    'Bayer',    'antiparasitic','ml',   50,  false, false, null, 95.00,   100,   65,   '2027-03-01'], // kritik altında - DEMO için bilerek
            ['Albendazol',       'Albendazol',    'Topkim',   'antiparasitic','ml',   100, false, false, null, 120.00,  100,   1800, '2027-08-20'],
            ['Meloksikam',       'Meloksikam',    'Vetaş',    'painkiller',   'ml',   50,  true,  false, null, 165.00,  60,    1400, '2027-05-15'],
            ['Vitamin B Kompleks', null,         'Pfizer',   'vitamin',       'ml',  100, false, false, null, 75.00,   80,    2200, '2027-12-01'],
            ['Oksitosin',        'Oksitosin',     'İlsan',    'hormone',       'ml',  10,  true,  false, null, 55.00,   30,    520,  '2027-04-10'],
        ];

        $drugs = [];
        $stocks = [];
        foreach ($drugSpecs as [$name, $ai, $mfr, $type, $unit, $pkg, $rx, $isVac, $dur, $price, $threshold, $initial, $expiry]) {
            $drug = Drug::create([
                'clinic_id' => $clinic->id,
                'name' => $name,
                'active_ingredient' => $ai,
                'manufacturer' => $mfr,
                'drug_type' => $type,
                'unit' => $unit,
                'package_size' => $pkg,
                'requires_prescription' => $rx,
                'is_vaccine' => $isVac,
                'vaccine_duration_days' => $dur,
                'default_price' => $price,
                'suitable_species' => ['cattle', 'sheep', 'goat'],
            ]);

            $stock = Stock::create([
                'clinic_id' => $clinic->id,
                'drug_id' => $drug->id,
                'current_quantity' => $initial,
                'critical_threshold' => $threshold,
                'last_purchased_at' => now()->subDays(45),
                'earliest_expiry_at' => $expiry,
            ]);

            StockMovement::create([
                'clinic_id' => $clinic->id,
                'stock_id' => $stock->id,
                'drug_id' => $drug->id,
                'movement_type' => 'purchase',
                'quantity' => $initial,
                'unit_price' => $price,
                'expiry_date' => $expiry,
                'supplier_name' => 'Vet Toptan Tedarik',
                'performed_by' => $ahmet->id,
                'notes' => 'Aylık toptan alım.',
                'occurred_at' => now()->subDays(45),
            ]);

            $drugs[$name] = $drug;
            $stocks[$drug->id] = $stock;
        }

        // -------- Çiftçiler (30) --------
        $farmers = [];
        for ($i = 0; $i < 30; $i++) {
            $isMale = mt_rand(0, 10) > 2;
            $first = $isMale
                ? self::TURKISH_MALE[array_rand(self::TURKISH_MALE)]
                : self::TURKISH_FEMALE[array_rand(self::TURKISH_FEMALE)];
            $last = self::TURKISH_SURNAMES[array_rand(self::TURKISH_SURNAMES)];
            $village = $villages[$i % count($villages)];

            $farmers[] = Farmer::create([
                'clinic_id' => $clinic->id,
                'village_id' => $village->id,
                'first_name' => $first,
                'last_name' => $last,
                'phone' => '55' . str_pad((string) (10000000 + $i * 7919 + mt_rand(0, 999)), 9, '0', STR_PAD_LEFT),
                'address_detail' => $village->name . ' köyü, ' . mt_rand(1, 120) . '. sokak No:' . mt_rand(1, 50),
                'balance' => 0, // payments + service_fee farkı ile baştan 0
                'sms_notifications_enabled' => mt_rand(0, 10) > 1,
                'preferred_sms_language' => 'tr',
            ]);
        }

        // -------- Hayvanlar (~130) --------
        $animals = [];
        $earTagCounter = 1;
        foreach ($farmers as $farmer) {
            $herdSize = mt_rand(2, 7);
            for ($j = 0; $j < $herdSize; $j++) {
                $speciesRoll = mt_rand(0, 100);
                if ($speciesRoll < 55) {
                    $species = 'cattle';
                    $breed = self::CATTLE_BREEDS[array_rand(self::CATTLE_BREEDS)];
                    $weight = mt_rand(180, 650);
                    $hasName = mt_rand(0, 10) > 3;
                    $name = $hasName ? self::CATTLE_NAMES[array_rand(self::CATTLE_NAMES)] : null;
                } elseif ($speciesRoll < 85) {
                    $species = 'sheep';
                    $breed = self::SHEEP_BREEDS[array_rand(self::SHEEP_BREEDS)];
                    $weight = mt_rand(35, 80);
                    $name = null;
                } else {
                    $species = 'goat';
                    $breed = self::GOAT_BREEDS[array_rand(self::GOAT_BREEDS)];
                    $weight = mt_rand(30, 65);
                    $name = null;
                }

                $gender = mt_rand(0, 10) > 3 ? 'female' : 'male';
                $isPregnant = $gender === 'female' && $species === 'cattle' && mt_rand(0, 100) < 25;

                $birth = now()->subDays(mt_rand(180, 2200));
                $statusRoll = mt_rand(0, 100);
                $status = match (true) {
                    $statusRoll < 92 => 'alive',
                    $statusRoll < 96 => 'sold',
                    default => 'deceased',
                };

                $animal = Animal::create([
                    'clinic_id' => $clinic->id,
                    'farmer_id' => $farmer->id,
                    'village_id' => $farmer->village_id,
                    'ear_tag' => sprintf('TR-06-%05d', $earTagCounter++),
                    'name' => $name,
                    'species' => $species,
                    'breed' => $breed,
                    'birth_date' => $birth->toDateString(),
                    'gender' => $gender,
                    'weight_kg' => $weight,
                    'is_pregnant' => $isPregnant,
                    'pregnancy_started_at' => $isPregnant ? now()->subDays(mt_rand(30, 240))->toDateString() : null,
                    'expected_birth_date' => $isPregnant ? now()->addDays(mt_rand(15, 200))->toDateString() : null,
                    'status' => $status,
                    'status_changed_at' => $status !== 'alive' ? now()->subDays(mt_rand(1, 90)) : null,
                ]);

                $animals[] = $animal;
            }
        }

        $aliveAnimals = array_values(array_filter($animals, fn ($a) => $a->status === 'alive'));

        // -------- Muayeneler (son 60 gün) + iki outbreak --------
        // Outbreak 1: Çayırhan'da şap (15 vaka, son 14 günde)
        // Outbreak 2: Karaşar'da mastitis (10 vaka, son 21 günde)
        $cayirhan = collect($villages)->firstWhere('name', 'Çayırhan');
        $karasar = collect($villages)->firstWhere('name', 'Karaşar');

        $cayirhanAnimals = array_values(array_filter($aliveAnimals, fn ($a) => $a->village_id === $cayirhan->id && $a->species === 'cattle'));
        $karasarAnimals = array_values(array_filter($aliveAnimals, fn ($a) => $a->village_id === $karasar->id && $a->species === 'cattle' && $a->gender === 'female'));

        $sapTemplates = [
            'Ağız mukozasında yaralar, salya akıntısı. Şap şüphesi.',
            'Tırnak arası yara, topallık. Şap belirtileri belirgin.',
            'Yüksek ateş, iştahsızlık, ağızda lezyon. Şap.',
        ];
        $mastitisTemplates = [
            'Meme bezi şişkin ve sıcak. Süt veriminde belirgin düşüş. Mastitis.',
            'Sütte pıhtı, meme hassasiyeti. Mastitis tedavisi başlatıldı.',
            'Klinik mastitis, antibiyotik tedavisi uygulandı.',
        ];

        $records = [];

        // Outbreak şap — bazı hayvanlara birden fazla muayene (kontrol/follow-up)
        foreach ($cayirhanAnimals as $idx => $a) {
            if ($idx >= 18) break;
            $records[] = $this->makeRecord($clinic->id, $a, $vets[mt_rand(0, 1)]->id, $cayirhan,
                'examination',
                'Şap şüphesi, ağızda yaralar, topallık, ateş.',
                $sapTemplates[array_rand($sapTemplates)],
                Carbon::now()->subDays(mt_rand(1, 14))->setTime(mt_rand(8, 17), mt_rand(0, 59)),
                400.00,
            );
            // Aynı hayvana follow-up
            if (mt_rand(0, 10) > 5) {
                $records[] = $this->makeRecord($clinic->id, $a, $vets[mt_rand(0, 1)]->id, $cayirhan,
                    'follow_up',
                    'Şap takip kontrolü, ağız lezyonları iyileşiyor.',
                    'Tedaviye devam, antiseptik ağız bakımı.',
                    Carbon::now()->subDays(mt_rand(1, 7))->setTime(mt_rand(8, 17), mt_rand(0, 59)),
                    200.00,
                );
            }
        }
        // Outbreak mastitis
        foreach ($karasarAnimals as $idx => $a) {
            if ($idx >= 10) break;
            $records[] = $this->makeRecord($clinic->id, $a, $vets[mt_rand(0, 1)]->id, $karasar,
                'examination',
                'Mastitis. Meme bezi şiş, süt veriminde düşüş.',
                $mastitisTemplates[array_rand($mastitisTemplates)],
                Carbon::now()->subDays(mt_rand(1, 21))->setTime(mt_rand(8, 17), mt_rand(0, 59)),
                350.00,
            );
        }

        // Genel muayeneler: ~250 adet, son 60 gün dağılımı
        $visitTypes = ['examination', 'vaccination', 'follow_up', 'pregnancy_check', 'routine_check'];
        $complaints = [
            'examination' => ['İştahsızlık ve halsizlik', 'Hafif ateş', 'Gözde akıntı', 'Yem tüketiminde azalma', 'Genel kontrol talebi'],
            'vaccination' => ['Yıllık koruyucu aşı', 'Şap aşısı zamanı', 'Brusella aşı kampanyası', 'Enterotoksemi aşısı'],
            'follow_up' => ['Önceki tedavinin kontrolü', 'Yara iyileşme takibi', 'İlaç dozaj kontrolü'],
            'pregnancy_check' => ['Gebelik kontrolü', 'Doğum öncesi kontrol', 'Gebelik ultrason'],
            'routine_check' => ['Rutin sağlık taraması', 'Sürü genel kontrolü', 'Süt verimi düşüklüğü araştırması'],
        ];
        $treatments = [
            'examination' => ['Geniş spektrumlu antibiyotik tedavisi uygulandı.', 'Ateş düşürücü ve destek tedavisi.', 'Topikal tedavi önerildi.'],
            'vaccination' => ['Aşı kas içi yapıldı.', 'Karma aşı uygulandı, reaksiyon gözlemlenmedi.'],
            'follow_up' => ['İyileşme iyi, tedavi sonlandırıldı.', 'Tedaviye bir hafta daha devam.'],
            'pregnancy_check' => ['Gebelik teyit edildi, takvim oluşturuldu.', 'Vitamin desteği önerildi.'],
            'routine_check' => ['Parazit ilacı uygulandı.', 'Klinik bulgu normal.'],
        ];

        for ($k = 0; $k < 250; $k++) {
            $animal = $aliveAnimals[array_rand($aliveAnimals)];
            $village = collect($villages)->firstWhere('id', $animal->village_id);
            $type = $visitTypes[array_rand($visitTypes)];
            $when = Carbon::now()->subDays(mt_rand(0, 60))->setTime(mt_rand(8, 18), mt_rand(0, 59));
            $records[] = $this->makeRecord(
                $clinic->id, $animal, $vets[mt_rand(0, 1)]->id, $village,
                $type,
                $complaints[$type][array_rand($complaints[$type])],
                $treatments[$type][array_rand($treatments[$type])],
                $when,
                $type === 'vaccination' ? 120.00 : ($type === 'pregnancy_check' ? 250.00 : (float) mt_rand(150, 450)),
            );
        }

        // Insert records ve drugs ile birlikte stok düşümü
        $insertedRecords = [];
        foreach ($records as $r) {
            $rec = MedicalRecord::create($r);
            $insertedRecords[] = $rec;

            // Her muayeneye 1-2 ilaç ekle (rastgele)
            $useCount = mt_rand(1, 2);
            $usedDrugs = [];
            for ($u = 0; $u < $useCount; $u++) {
                $drug = $drugs[array_rand($drugs)];
                if (in_array($drug->id, $usedDrugs, true)) continue;
                $usedDrugs[] = $drug->id;

                // İvermektin'i kritik test için use'da seçmeyelim, ya da çok az kullanılsın
                if ($drug->name === 'İvermektin') {
                    continue;
                }
                $qty = $drug->is_vaccine ? mt_rand(1, 2) : (float) (mt_rand(20, 80) / 10);
                MedicalRecordDrug::create([
                    'clinic_id' => $clinic->id,
                    'medical_record_id' => $rec->id,
                    'drug_id' => $drug->id,
                    'quantity' => $qty,
                    'unit' => $drug->unit,
                    'route' => $drug->is_vaccine ? 'IM' : 'IV',
                    'frequency' => 'günde 1',
                    'unit_price' => $drug->default_price,
                ]);

                $stock = $stocks[$drug->id];
                StockMovement::create([
                    'clinic_id' => $clinic->id,
                    'stock_id' => $stock->id,
                    'drug_id' => $drug->id,
                    'movement_type' => 'usage',
                    'quantity' => -$qty,
                    'unit_price' => $drug->default_price,
                    'related_medical_record_id' => $rec->id,
                    'performed_by' => $rec->vet_id,
                    'occurred_at' => $rec->examined_at,
                ]);
                $stock->current_quantity = (float) $stock->current_quantity - (float) $qty;
                $stock->save();
            }
        }

        // -------- Randevular --------
        $apptTypes = ['visit', 'vaccination', 'follow_up', 'routine_check'];
        $apptReasons = [
            'visit' => 'Genel kontrol ziyareti',
            'vaccination' => 'Yıllık koruyucu aşı',
            'follow_up' => 'Tedavi sonrası kontrol',
            'routine_check' => 'Rutin sağlık kontrolü',
            'emergency' => 'Acil müdahale',
        ];

        // Geçmişte tamamlanan + bugün + yaklaşan
        for ($a = 0; $a < 40; $a++) {
            $animal = $aliveAnimals[array_rand($aliveAnimals)];
            $farmer = collect($farmers)->firstWhere('id', $animal->farmer_id);
            // NOT: "bugun" randevulari asagidaki ayri-koy bloku uretir
            // (rota demosu temiz gorunsun diye). Buradaki rastgele randevular
            // sadece gecmis + gelecek; bugune dusmesin ki pinler cakismasin.
            $when = match (true) {
                $a < 14 => now()->subDays(mt_rand(1, 20))->setTime(mt_rand(9, 16), [0, 15, 30, 45][mt_rand(0, 3)]),
                default => now()->addDays(mt_rand(1, 14))->setTime(mt_rand(9, 16), [0, 15, 30, 45][mt_rand(0, 3)]),
            };
            $type = $apptTypes[array_rand($apptTypes)];
            $isPast = $when->isPast();
            $status = $isPast
                ? (mt_rand(0, 10) > 1 ? 'completed' : (mt_rand(0, 1) ? 'cancelled' : 'no_show'))
                : (mt_rand(0, 10) > 4 ? 'confirmed' : 'planned');

            Appointment::create([
                'clinic_id' => $clinic->id,
                'farmer_id' => $farmer->id,
                'animal_id' => mt_rand(0, 1) ? $animal->id : null,
                'vet_id' => $vets[mt_rand(0, 1)]->id,
                'village_id' => $farmer->village_id,
                'scheduled_at' => $when,
                'estimated_duration_minutes' => [30, 45, 60][mt_rand(0, 2)],
                'appointment_type' => $type,
                'reason' => $apptReasons[$type],
                'status' => $status,
                'status_changed_at' => $isPast ? $when->copy()->addHour() : null,
            ]);
        }

        // -------- BUGÜNE sabitlenmiş rota demo randevuları --------
        // Rota optimizasyonu demosu icin: bugun, farkli 6 koyde, confirmed
        // randevu. Fresh seed gunu mobil "Bugunku Rota" ekraninda 6 dagilmis
        // durak olur, "Rotayi optimize et" gorsel olarak etkili calisir.
        $routeHours = [8, 9, 11, 13, 14, 16];
        $vIdx = 0;
        foreach ($villages as $village) {
            if ($vIdx >= 6) break;
            // Bu koyde bir ciftci + canli hayvan bul
            $farmerInV = collect($farmers)->firstWhere('village_id', $village->id);
            if ($farmerInV === null) continue;
            $animalInV = collect($aliveAnimals)->firstWhere('farmer_id', $farmerInV->id);

            Appointment::create([
                'clinic_id' => $clinic->id,
                'farmer_id' => $farmerInV->id,
                'animal_id' => $animalInV?->id,
                'vet_id' => $ahmet->id,
                'village_id' => $village->id,
                'scheduled_at' => now()->setTime($routeHours[$vIdx], 0),
                'estimated_duration_minutes' => [30, 45, 60][mt_rand(0, 2)],
                'appointment_type' => $apptTypes[array_rand($apptTypes)],
                'reason' => $apptReasons['visit'],
                'status' => 'confirmed',
            ]);
            $vIdx++;
        }

        // -------- Reçeteler (son 20 muayene) --------
        $recentForRx = collect($insertedRecords)
            ->filter(fn ($r) => $r->examined_at->gt(now()->subDays(30)))
            ->sortByDesc('examined_at')
            ->take(20)
            ->values();

        $rxNo = 1;
        foreach ($recentForRx as $rec) {
            Prescription::create([
                'clinic_id' => $clinic->id,
                'medical_record_id' => $rec->id,
                'farmer_id' => $rec->animal->farmer_id,
                'animal_id' => $rec->animal_id,
                'vet_id' => $rec->vet_id,
                'prescription_number' => 'RX-' . now()->format('Y') . '-' . str_pad((string) $rxNo++, 5, '0', STR_PAD_LEFT),
                'notes' => 'İlaçları belirtilen dozda kullanınız.',
                'sms_sent_at' => mt_rand(0, 10) > 2 ? $rec->examined_at->copy()->addMinutes(15) : null,
            ]);
        }

        // -------- Aşı planları + hatırlatma --------
        $sapDrug = $drugs['Şap Aşısı (Trivalan)'];
        $brusellaDrug = $drugs['Brusella Aşısı'];

        $cattleAlive = array_values(array_filter($aliveAnimals, fn ($a) => $a->species === 'cattle'));
        shuffle($cattleAlive);
        foreach (array_slice($cattleAlive, 0, 35) as $i => $animal) {
            $drug = $i % 2 === 0 ? $sapDrug : $brusellaDrug;
            $interval = (int) ($drug->vaccine_duration_days ?? 180);
            $first = now()->subDays(mt_rand(10, 150))->startOfDay();
            $next = $first->copy()->addDays($interval);

            $schedule = VaccineSchedule::create([
                'clinic_id' => $clinic->id,
                'animal_id' => $animal->id,
                'drug_id' => $drug->id,
                'interval_days' => $interval,
                'first_due_date' => $first->toDateString(),
                'next_due_date' => $next->toDateString(),
                'last_administered_at' => $first,
                'remind_days_before' => 7,
                'is_active' => true,
                'notes' => 'Periyodik koruyucu aşı.',
            ]);

            // Yaklaşan hatırlatma (next_due_date - 7)
            $reminderAt = $next->copy()->subDays(7)->setTime(9, 0);
            $status = match (true) {
                $reminderAt->isPast() && mt_rand(0, 10) > 6 => 'completed',
                $reminderAt->isPast() && mt_rand(0, 10) > 4 => 'sms_sent',
                default => 'scheduled',
            };

            VaccinationReminder::create([
                'vaccine_schedule_id' => $schedule->id,
                'animal_id' => $animal->id,
                'farmer_id' => $animal->farmer_id,
                'clinic_id' => $clinic->id,
                'due_date' => $next->toDateString(),
                'reminder_at' => $reminderAt,
                'status' => $status,
                'sms_sent_at' => in_array($status, ['sms_sent', 'completed'], true) ? $reminderAt : null,
            ]);
        }

        // -------- Ödemeler (çiftçi başına) --------
        // service_fee toplamı çiftçi bazında, kısmi ödemeler ile borç dengesi.
        $feeByFarmer = collect($insertedRecords)
            ->groupBy(fn ($r) => $r->animal->farmer_id)
            ->map(fn ($g) => (float) $g->sum('service_fee'));

        foreach ($farmers as $farmer) {
            $totalFee = (float) ($feeByFarmer[$farmer->id] ?? 0.0);
            if ($totalFee <= 0) continue;

            // 1-3 ödeme ile %50-110 arasını kapatmış olsun
            $paidRatio = mt_rand(50, 110) / 100;
            $totalPaid = round($totalFee * $paidRatio, 2);
            $payments = mt_rand(1, 3);
            $perPayment = round($totalPaid / $payments, 2);

            for ($p = 0; $p < $payments; $p++) {
                Payment::create([
                    'clinic_id' => $clinic->id,
                    'farmer_id' => $farmer->id,
                    'vet_id' => $vets[mt_rand(0, 1)]->id,
                    'amount' => $perPayment,
                    'method' => ['cash', 'cash', 'transfer'][mt_rand(0, 2)],
                    'paid_at' => now()->subDays(mt_rand(1, 55)),
                    'notes' => $p === 0 ? null : 'Kısmi ödeme.',
                ]);
            }

            $farmer->update(['balance' => round($totalFee - ($perPayment * $payments), 2)]);
        }

        // -------- SMS geçmişi --------
        $smsTemplates = [
            'appointment_reminder' => 'Sayın {ad}, yarın saat {saat} randevunuz var. VetRota Beypazarı.',
            'vaccination_reminder' => 'Sayın {ad}, hayvanınızın aşı zamanı yaklaştı. Detay: vetrota.com.tr/farmer/{token}',
            'prescription_delivery' => 'Sayın {ad}, reçeteniz hazır: vetrota.com.tr/farmer/{token}',
            'outbreak_alert' => 'DİKKAT: Bölgenizde salgın tespit edildi. Detay: vetrota.com.tr/farmer/{token}',
        ];

        for ($s = 0; $s < 60; $s++) {
            $farmer = $farmers[array_rand($farmers)];
            $trigger = array_rand($smsTemplates);
            $status = ['sent', 'delivered', 'delivered', 'delivered', 'failed'][mt_rand(0, 4)];
            $body = str_replace(
                ['{ad}', '{saat}', '{token}'],
                [$farmer->first_name, '10:30', Str::random(8)],
                $smsTemplates[$trigger],
            );
            SmsMessage::create([
                'clinic_id' => $clinic->id,
                'farmer_id' => $farmer->id,
                'phone' => $farmer->phone,
                'body' => $body,
                'trigger_type' => $trigger,
                'status' => $status,
                'provider' => 'log',
                'attempts' => $status === 'failed' ? 3 : 1,
                'queued_at' => now()->subDays(mt_rand(0, 40))->setTime(mt_rand(8, 18), mt_rand(0, 59)),
                'sent_at' => $status !== 'failed' ? now()->subDays(mt_rand(0, 40)) : null,
                'delivered_at' => $status === 'delivered' ? now()->subDays(mt_rand(0, 40)) : null,
                'cost' => 0.30,
                'sms_segment_count' => 1,
            ]);
        }

        // -------- Çiftçi portal token örnekleri --------
        foreach (array_slice($farmers, 0, 5) as $farmer) {
            FarmerPortalToken::create([
                'farmer_id' => $farmer->id,
                'clinic_id' => $clinic->id,
                'token_hash' => hash('sha256', Str::random(32)),
                'token_prefix' => substr(Str::random(8), 0, 8),
                'scope' => 'general',
                'expires_at' => now()->addDays(30),
                'access_count' => mt_rand(0, 5),
                'last_accessed_at' => mt_rand(0, 1) ? now()->subDays(mt_rand(1, 10)) : null,
            ]);
        }

        // -------- Rotalar (son 5 gün) --------
        for ($d = 1; $d <= 5; $d++) {
            $date = now()->subDays($d)->startOfDay();
            $todaysAppts = Appointment::where('clinic_id', $clinic->id)
                ->whereBetween('scheduled_at', [$date->copy(), $date->copy()->endOfDay()])
                ->where('status', 'completed')
                ->limit(5)
                ->get();
            if ($todaysAppts->isEmpty()) continue;

            $route = Route::create([
                'clinic_id' => $clinic->id,
                'vet_id' => $ahmet->id,
                'date' => $date->toDateString(),
                'total_distance_km' => (float) mt_rand(45, 180),
                'total_duration_min' => mt_rand(180, 420),
                'start_lat' => 40.1670,
                'start_lng' => 31.9210,
            ]);

            $seq = 1;
            foreach ($todaysAppts as $appt) {
                $village = collect($villages)->firstWhere('id', $appt->village_id);
                RouteStop::create([
                    'clinic_id' => $clinic->id,
                    'route_id' => $route->id,
                    'appointment_id' => $appt->id,
                    'sequence' => $seq++,
                    'lat' => $village?->lat,
                    'lng' => $village?->lng,
                    'distance_from_prev_km' => (float) mt_rand(8, 35),
                    'status' => 'visited',
                    'visited_at' => $appt->scheduled_at,
                ]);
            }
        }

        // -------- Günlük raporlar (son 7 gün) --------
        for ($d = 1; $d <= 7; $d++) {
            $date = now()->subDays($d)->startOfDay();
            $dayRecords = collect($insertedRecords)
                ->filter(fn ($r) => $r->examined_at->isSameDay($date));
            if ($dayRecords->isEmpty()) continue;

            DailyReport::create([
                'clinic_id' => $clinic->id,
                'vet_id' => $ahmet->id,
                'date' => $date->toDateString(),
                'animals_visited' => $dayRecords->pluck('animal_id')->unique()->count(),
                'medical_records_count' => $dayRecords->count(),
                'total_distance_km' => (float) mt_rand(60, 150),
                'total_revenue' => (float) $dayRecords->sum('service_fee'),
                'drugs_used' => [],
                'generated_at' => $date->copy()->setTime(20, 0),
            ]);
        }

        // ============================================================
        //  FREE klinik (demo karsilastirma icin) - yeni kayit olmus
        //  bir tek-veteriner senaryosu. Premium kilitli ekranlari
        //  goruntulemek/uygrade akisini test etmek icin kullanilir.
        // ============================================================
        $freeClinic = Clinic::create([
            'name' => 'VetRota Polatlı Demo Klinik',
            'phone' => '03126400505',
            'email' => 'demo@vetrota.com.tr',
            'city' => 'Ankara',
            'district' => 'Polatlı',
            'subscription_tier' => 'free',
            'subscription_expires_at' => null,
        ]);

        $freeVet = User::create([
            'name' => 'Demo Veteriner',
            'email' => 'demo@vetrota.com.tr',
            'password' => Hash::make('sifre1234'),
            'clinic_id' => $freeClinic->id,
            'role' => 'vet',
        ]);

        $freeVillage = Village::create([
            'name' => 'Sazılar',
            'district' => 'Polatlı',
            'city' => 'Ankara',
            'lat' => 39.5840,
            'lng' => 32.1471,
        ]);

        // Free icin minimal ornek: 2 ciftci + 6 hayvan + 3 muayene.
        // Free limiti 100 hayvan; sembolik kalsin ki "buraya hayvan ekleyip
        // ekranlari hemen anlik gorebileyim" hissi versin.
        $freeFarmers = [];
        foreach ([['Salim', 'Yılmaz', '5559990001'], ['Hatice', 'Demir', '5559990002']] as [$first, $last, $phone]) {
            $freeFarmers[] = Farmer::create([
                'clinic_id' => $freeClinic->id,
                'village_id' => $freeVillage->id,
                'first_name' => $first,
                'last_name' => $last,
                'phone' => $phone,
                'address_detail' => 'Polatlı, Sazılar köyü',
                'balance' => 0,
                'sms_notifications_enabled' => true,
                'preferred_sms_language' => 'tr',
            ]);
        }

        $freeAnimals = [];
        for ($i = 0; $i < 6; $i++) {
            $freeAnimals[] = Animal::create([
                'clinic_id' => $freeClinic->id,
                'farmer_id' => $freeFarmers[$i % 2]->id,
                'village_id' => $freeVillage->id,
                'ear_tag' => sprintf('TR-06-F%04d', $i + 1),
                'name' => null,
                'species' => $i < 3 ? 'cattle' : 'sheep',
                'breed' => $i < 3 ? 'Holstein' : 'Akkaraman',
                'birth_date' => now()->subDays(mt_rand(200, 1500))->toDateString(),
                'gender' => $i % 2 === 0 ? 'female' : 'male',
                'weight_kg' => $i < 3 ? mt_rand(250, 500) : mt_rand(40, 70),
                'status' => 'alive',
            ]);
        }

        foreach (array_slice($freeAnimals, 0, 3) as $a) {
            MedicalRecord::create([
                'clinic_id' => $freeClinic->id,
                'animal_id' => $a->id,
                'vet_id' => $freeVet->id,
                'village_id' => $freeVillage->id,
                'visit_type' => 'examination',
                'chief_complaint' => 'Genel kontrol.',
                'treatment_notes' => 'Klinik bulgu normal.',
                'service_fee' => 200.00,
                'examined_at' => now()->subDays(mt_rand(1, 14)),
            ]);
        }
    }

    /**
     * @return array<string, mixed>
     */
    private function makeRecord(
        string $clinicId,
        Animal $animal,
        int $vetId,
        ?Village $village,
        string $visitType,
        string $complaint,
        string $treatment,
        Carbon $when,
        float $fee,
    ): array {
        return [
            'clinic_id' => $clinicId,
            'animal_id' => $animal->id,
            'vet_id' => $vetId,
            'village_id' => $animal->village_id,
            'lat' => $village?->lat,
            'lng' => $village?->lng,
            'visit_type' => $visitType,
            'chief_complaint' => $complaint,
            'symptoms' => null,
            'treatment_notes' => $treatment,
            'temperature_celsius' => 38.0 + (mt_rand(-10, 25) / 10),
            'weight_kg' => $animal->weight_kg,
            'heart_rate' => mt_rand(60, 100),
            'respiratory_rate' => mt_rand(18, 40),
            'service_fee' => $fee,
            'examined_at' => $when,
            'follow_up_needed' => mt_rand(0, 10) > 7,
            'follow_up_date' => mt_rand(0, 10) > 7 ? $when->copy()->addDays(mt_rand(7, 21))->toDateString() : null,
        ];
    }
}
