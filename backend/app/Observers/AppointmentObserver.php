<?php

declare(strict_types=1);

namespace App\Observers;

use App\Models\Appointment;
use App\Services\FarmerPortal\TokenService;
use App\Services\Sms\SmsService;
use App\Sms\TemplateRenderer;
use Illuminate\Support\Facades\Log;
use Throwable;

// M6.4: Yeni randevu olustugunda ciftciye SMS hatirlatma.
// Kosullar:
// - farmer.sms_notifications_enabled = true
// - farmer.phone dolu
// - status in (planned, confirmed)
// Idempotent: sms_messages'ta ayni (appointment_id, trigger=appointment_reminder)
// satiri varsa tekrar gondermez.
class AppointmentObserver
{
    public function __construct(
        private readonly SmsService $smsService,
        private readonly TokenService $tokenService,
    ) {}

    public function created(Appointment $appointment): void
    {
        $this->maybeSendReminder($appointment);
    }

    private function maybeSendReminder(Appointment $appointment): void
    {
        if (!in_array($appointment->status, ['planned', 'confirmed'], true)) {
            return;
        }

        $farmer = $appointment->farmer;
        if ($farmer === null || !$farmer->sms_notifications_enabled || empty($farmer->phone)) {
            return;
        }

        // Idempotency: ayni randevu icin daha once SMS atilmis mi?
        $alreadySent = \App\Models\SmsMessage::where('trigger_reference_type', 'appointment')
            ->where('trigger_reference_id', $appointment->id)
            ->where('trigger_type', 'appointment_reminder')
            ->exists();
        if ($alreadySent) {
            return;
        }

        try {
            ['raw' => $rawToken, 'model' => $token] = $this->tokenService->issue(
                $farmer,
                'appointment',
                'appointment',
                $appointment->id,
            );

            $portalUrl = rtrim((string) config('sms.portal_base_url', ''), '/')
                . '/farmer/' . $rawToken;

            $body = TemplateRenderer::render(
                'Sayin {{ad}}, {{tarih}} {{saat}} randevunuz onaylandi. Detay: {{link}}',
                [
                    'ad' => trim(($farmer->first_name ?? '') . ' ' . ($farmer->last_name ?? '')),
                    'tarih' => $appointment->scheduled_at->format('d.m.Y'),
                    'saat' => $appointment->scheduled_at->format('H:i'),
                    'link' => $portalUrl,
                ],
            );

            $this->smsService->send(
                $farmer,
                'appointment_reminder',
                $body,
                ['type' => 'appointment', 'id' => $appointment->id],
                $token->id,
            );
        } catch (Throwable $e) {
            // SMS hatasi randevu olusumunu bozmamali — sadece logla.
            Log::error('AppointmentObserver: SMS gonderim hatasi', [
                'appointment_id' => $appointment->id,
                'error' => $e->getMessage(),
            ]);
        }
    }
}
