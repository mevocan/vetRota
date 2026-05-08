<?php

declare(strict_types=1);

namespace App\Jobs;

use App\Models\SmsMessage;
use App\Sms\Contracts\SmsSender;
use App\Sms\SmsPayload;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Throwable;

// M6.3: SMS gönderim queue job'u.
// Idempotent: SmsMessage satırı önceden create edildi (status=queued);
// job sadece driver'a gönderir ve status'u günceller.
class SendSmsJob implements ShouldQueue
{
    use Queueable;

    public int $tries = 3;

    /** @return array<int> seconds */
    public function backoff(): array
    {
        return [60, 300, 900];
    }

    public function __construct(
        public readonly string $smsMessageId,
    ) {}

    public function handle(SmsSender $sender): void
    {
        /** @var SmsMessage|null $msg */
        $msg = SmsMessage::find($this->smsMessageId);
        if ($msg === null) {
            return; // Silinmiş — sessizce çık.
        }
        if (in_array($msg->status, ['sent', 'delivered'], true)) {
            return; // Idempotent — zaten gönderilmiş.
        }

        $msg->forceFill([
            'status' => 'sending',
            'attempts' => $msg->attempts + 1,
        ])->save();

        $payload = new SmsPayload(
            id: $msg->id,
            phone: $msg->phone,
            body: $msg->body,
            senderId: $msg->sender_id,
            triggerType: $msg->trigger_type,
        );

        try {
            $result = $sender->send($payload);

            if ($result->success) {
                $msg->forceFill([
                    'status' => 'sent',
                    'provider' => $result->provider,
                    'provider_message_id' => $result->providerMessageId,
                    'sms_segment_count' => $result->segmentCount,
                    'sent_at' => now(),
                    'last_error' => null,
                ])->save();
            } else {
                $msg->forceFill([
                    'status' => 'failed',
                    'provider' => $result->provider,
                    'last_error' => $result->error,
                ])->save();
                throw new \RuntimeException("SMS gonderim basarisiz: {$result->error}");
            }
        } catch (Throwable $e) {
            $msg->forceFill([
                'status' => $msg->attempts >= $this->tries ? 'failed' : 'queued',
                'last_error' => $e->getMessage(),
            ])->save();
            throw $e;
        }
    }

    public function failed(Throwable $e): void
    {
        SmsMessage::where('id', $this->smsMessageId)->update([
            'status' => 'failed',
            'last_error' => $e->getMessage(),
        ]);
    }
}
