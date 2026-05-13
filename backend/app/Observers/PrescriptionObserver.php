<?php

declare(strict_types=1);

namespace App\Observers;

use App\Models\Prescription;
use App\Services\FarmerPortal\TokenService;
use App\Services\Sms\SmsService;
use Illuminate\Support\Facades\Log;

// M7.4.4: Recete olustugunda otomatik portal token uretir ve SMS gonderir.
// Ciftcinin telefonu yoksa sadece token uretilir (PDF panelden indirilebilir).
class PrescriptionObserver
{
    public function __construct(
        private readonly TokenService $tokenService,
        private readonly SmsService $smsService,
    ) {}

    public function created(Prescription $prescription): void
    {
        $farmer = $prescription->farmer;
        if ($farmer === null) {
            return;
        }

        try {
            $tokenResult = $this->tokenService->issue(
                farmer: $farmer,
                scope: 'prescription',
                resourceType: 'prescription',
                resourceId: $prescription->id,
            );
            $prescription->forceFill([
                'portal_token_id' => $tokenResult['model']->id,
            ])->saveQuietly();

            if (empty($farmer->phone)) {
                return;
            }

            $base = rtrim((string) config('sms.portal_base_url', 'http://localhost:3000'), '/');
            $url = $base . '/prescription/' . $tokenResult['raw'];
            $animal = $prescription->animal;
            $body = sprintf(
                "VetRota: %s icin receteniz hazir. %s",
                $animal?->name ?: ($animal?->ear_tag ?: 'hayvaniniz'),
                $url,
            );

            $msg = $this->smsService->send(
                farmer: $farmer,
                triggerType: 'prescription',
                body: $body,
                reference: ['type' => 'prescription', 'id' => $prescription->id],
                portalTokenId: $tokenResult['model']->id,
            );

            $prescription->forceFill([
                'sms_sent_at' => $msg->queued_at ?? now(),
            ])->saveQuietly();
        } catch (\Throwable $e) {
            Log::warning('Recete SMS gonderilemedi', [
                'prescription_id' => $prescription->id,
                'error' => $e->getMessage(),
            ]);
        }
    }
}
