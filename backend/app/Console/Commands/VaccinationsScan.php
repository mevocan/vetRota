<?php

declare(strict_types=1);

namespace App\Console\Commands;

use App\Models\VaccinationReminder;
use App\Models\VaccineSchedule;
use App\Services\FarmerPortal\TokenService;
use App\Services\Sms\SmsService;
use App\Sms\TemplateRenderer;
use Illuminate\Console\Command;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Throwable;

// M6.6: Asi hatirlatma tarayicisi.
// Her gun 08:00'da calisir (Kernel scheduler).
// next_due_date <= today + remind_days_before olan aktif schedule'lar icin
// vaccination_reminders kaydi olusturur ve ciftciye SMS yollar.
//
// Idempotent: vaccination_reminders.unique(schedule_id, due_date) sayesinde
// ayni gun icin ikinci satir yazilmaz.
class VaccinationsScan extends Command
{
    protected $signature = 'vaccinations:scan {--dry-run : SMS gondermeden taramayi raporla}';

    protected $description = 'Yaklasan asilar icin hatirlatma uretir ve ciftcilere SMS yollar';

    public function handle(SmsService $sms, TokenService $tokenService): int
    {
        $today = Carbon::today();
        $dryRun = (bool) $this->option('dry-run');

        $count = 0;
        $errors = 0;

        VaccineSchedule::query()
            ->where('is_active', true)
            ->whereNull('deleted_at')
            ->whereDate('next_due_date', '<=', $today->copy()->addDays(30)) // dış sınır
            ->with(['animal.farmer', 'drug'])
            ->chunkById(200, function ($schedules) use ($today, $dryRun, $sms, $tokenService, &$count, &$errors): void {
                foreach ($schedules as $schedule) {
                    try {
                        $remindDate = $schedule->next_due_date->copy()
                            ->subDays($schedule->remind_days_before);
                        if ($remindDate->isAfter($today)) {
                            continue; // henuz hatirlatma vakti gelmemis
                        }

                        $animal = $schedule->animal;
                        $farmer = $animal?->farmer;
                        if ($animal === null || $farmer === null) {
                            continue;
                        }

                        // Idempotency: bu schedule + due_date icin reminder var mi?
                        $existing = VaccinationReminder::where(
                            'vaccine_schedule_id', $schedule->id
                        )->whereDate('due_date', $schedule->next_due_date)->first();

                        if ($existing !== null && in_array(
                            $existing->status,
                            ['sms_sent', 'acknowledged', 'completed'],
                            true,
                        )) {
                            continue;
                        }

                        if ($dryRun) {
                            $this->line(sprintf(
                                ' - DRY: schedule=%s animal=%s farmer=%s due=%s',
                                $schedule->id,
                                $animal->id,
                                $farmer->id,
                                $schedule->next_due_date->toDateString(),
                            ));
                            $count++;
                            continue;
                        }

                        $reminder = $existing ?? VaccinationReminder::create([
                            'id' => (string) Str::uuid(),
                            'vaccine_schedule_id' => $schedule->id,
                            'animal_id' => $animal->id,
                            'farmer_id' => $farmer->id,
                            'clinic_id' => $schedule->clinic_id,
                            'due_date' => $schedule->next_due_date,
                            'reminder_at' => now(),
                            'status' => 'scheduled',
                        ]);

                        // SMS gonder (sadece sms_notifications_enabled ve telefon varsa).
                        if ($farmer->sms_notifications_enabled && !empty($farmer->phone)) {
                            ['raw' => $rawToken, 'model' => $token] = $tokenService->issue(
                                $farmer,
                                'vaccination',
                                'vaccination_reminder',
                                $reminder->id,
                            );

                            $portalUrl = rtrim((string) config('sms.portal_base_url', ''), '/')
                                . '/farmer/' . $rawToken;

                            $body = TemplateRenderer::render(
                                'Sayin {{ad}}, {{hayvan}} icin {{tarih}} tarihinde {{asi}} asisi yapilmali. Detay: {{link}}',
                                [
                                    'ad' => trim(($farmer->first_name ?? '') . ' ' . ($farmer->last_name ?? '')),
                                    'hayvan' => $animal->name ?? ('Kupe ' . ($animal->ear_tag ?? '?')),
                                    'tarih' => $schedule->next_due_date->format('d.m.Y'),
                                    'asi' => $schedule->drug?->name ?? 'asi',
                                    'link' => $portalUrl,
                                ],
                            );

                            $sms->send(
                                $farmer,
                                'vaccination_reminder',
                                $body,
                                ['type' => 'vaccination_reminder', 'id' => $reminder->id],
                                $token->id,
                            );

                            $reminder->forceFill([
                                'status' => 'sms_sent',
                                'sms_sent_at' => now(),
                            ])->save();
                        }

                        $count++;
                    } catch (Throwable $e) {
                        $errors++;
                        Log::error('VaccinationsScan: hata', [
                            'schedule_id' => $schedule->id ?? null,
                            'error' => $e->getMessage(),
                        ]);
                    }
                }
            });

        $this->info("Tarama tamam: {$count} hatirlatma, {$errors} hata. (dry-run=" . ($dryRun ? 'evet' : 'hayir') . ')');
        return self::SUCCESS;
    }
}
