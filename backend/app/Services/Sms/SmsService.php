<?php

declare(strict_types=1);

namespace App\Services\Sms;

use App\Jobs\SendSmsJob;
use App\Models\Farmer;
use App\Models\SmsMessage;
use Illuminate\Support\Str;

// M6.3: Üst seviye SMS API'si.
// 1) sms_messages satırı oluşturur (status=queued)
// 2) SendSmsJob'u queue'ya iter
// Çağıran observer/scheduler/controller bu servisi kullanır.
class SmsService
{
    /**
     * @param array{type: string, id: string}|null $reference  Tetikleyen kayıt
     * @param string|null $portalTokenId  Bu SMS bir portal link'i içeriyorsa token id
     */
    public function send(
        Farmer $farmer,
        string $triggerType,
        string $body,
        ?array $reference = null,
        ?string $portalTokenId = null,
    ): SmsMessage {
        if (empty($farmer->phone)) {
            throw new \InvalidArgumentException(
                "Ciftcinin telefon numarasi yok: farmer_id={$farmer->id}"
            );
        }

        $msg = SmsMessage::create([
            'id' => (string) Str::uuid(),
            'clinic_id' => $farmer->clinic_id,
            'farmer_id' => $farmer->id,
            'phone' => $farmer->phone,
            'body' => $body,
            'sender_id' => (string) config('sms.sender_id', 'VETROTA'),
            'trigger_type' => $triggerType,
            'trigger_reference_type' => $reference['type'] ?? null,
            'trigger_reference_id' => $reference['id'] ?? null,
            'portal_token_id' => $portalTokenId,
            'status' => 'queued',
            'queued_at' => now(),
        ]);

        SendSmsJob::dispatch($msg->id);

        return $msg;
    }
}
