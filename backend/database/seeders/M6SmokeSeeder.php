<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Models\Animal;
use App\Models\Drug;
use App\Models\VaccineSchedule;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Carbon;

// M6.10 smoke testi icin: yarin ya da 5 gun sonra due olan asi plani.
// vaccinations:scan calistirilinca SMS yollar.
//
// Calistir:
//   docker compose exec app php artisan db:seed --class=M6SmokeSeeder
//   docker compose exec app php artisan vaccinations:scan
//   docker compose exec app php artisan queue:work --once
//   docker compose exec app tail -50 storage/logs/laravel.log
class M6SmokeSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        // Mevcut bir aşı tipi ilac bul (DatabaseSeeder Sap Asisi'ni ekledi).
        $vaccine = Drug::where('is_vaccine', true)->first();
        if ($vaccine === null) {
            $this->command->error('Asi tipi ilac bulunamadi. Once DatabaseSeeder calistirin.');
            return;
        }

        // Bir hayvan bul (ear_tag ile).
        $animal = Animal::orderBy('created_at')->first();
        if ($animal === null) {
            $this->command->error('Hayvan bulunamadi. Once DatabaseSeeder calistirin.');
            return;
        }

        // 5 gun sonra due olan plan: remind_days_before=7 oldugu icin
        // bugun scan edilince (5 < 7+0 = 7) hatirlatma uretilir.
        $dueDate = Carbon::today()->addDays(5);

        $schedule = VaccineSchedule::updateOrCreate(
            [
                'animal_id' => $animal->id,
                'drug_id' => $vaccine->id,
            ],
            [
                'clinic_id' => $animal->clinic_id,
                'interval_days' => 365,
                'first_due_date' => $dueDate,
                'next_due_date' => $dueDate,
                'remind_days_before' => 7,
                'is_active' => true,
                'notes' => 'M6 smoke seed plani.',
            ],
        );

        $this->command->info("M6 smoke seed: schedule={$schedule->id}");
        $this->command->info("Animal: {$animal->name} (ear_tag={$animal->ear_tag})");
        $this->command->info("Vaccine: {$vaccine->name}");
        $this->command->info("Due: {$dueDate->toDateString()} (today + 5 gun)");
        $this->command->newLine();
        $this->command->line('Sonraki adim:');
        $this->command->line('  php artisan vaccinations:scan');
        $this->command->line('  php artisan queue:work --once');
        $this->command->line('  tail -50 storage/logs/laravel.log');
    }
}
