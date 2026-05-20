<?php
// Gecici demo scripti: calisan bir ciftci portal linki uretir.
// Kullanim: docker compose exec -T backend php artisan tinker demo_portal_link.php
// (sonra silinebilir)

use App\Models\Animal;
use App\Models\Clinic;
use App\Models\Farmer;
use App\Models\VaccinationReminder;
use App\Services\FarmerPortal\TokenService;

$clinic = Clinic::where('name', 'VetRota Beypazarı Kliniği')->first();

$reminder = VaccinationReminder::where('clinic_id', $clinic->id)
    ->whereIn('status', ['scheduled', 'sms_sent'])
    ->orderBy('due_date')
    ->first();

$farmer = Farmer::find($reminder->farmer_id);
$svc = app(TokenService::class);
$res = $svc->issue($farmer, 'general', null, null, now()->addDays(30));
$animalCount = Animal::where('farmer_id', $farmer->id)->count();

echo PHP_EOL;
echo '================ DEMO PORTAL LINKI ================' . PHP_EOL;
echo 'Ciftci  : ' . $farmer->first_name . ' ' . $farmer->last_name . ' (' . $animalCount . ' hayvan)' . PHP_EOL;
echo 'Telefon : ' . $farmer->phone . PHP_EOL;
echo 'Bitis   : ' . $res['model']->expires_at . PHP_EOL;
echo PHP_EOL;
echo 'Local web   : http://localhost:3000/farmer/' . $res['raw'] . PHP_EOL;
echo 'Raw token   : ' . $res['raw'] . PHP_EOL;
echo '===================================================' . PHP_EOL;
