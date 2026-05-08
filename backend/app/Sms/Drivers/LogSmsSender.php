<?php

declare(strict_types=1);

namespace App\Sms\Drivers;

use App\Sms\Contracts\SmsSender;
use App\Sms\SmsPayload;
use App\Sms\SmsResult;
use Illuminate\Log\LogManager;

// MVP driver: gerçek SMS göndermez, Laravel logger'a yazar.
// Test ve geliştirme sırasında çiftçileri spam'lemeden akışı doğrulamayı
// sağlar. Provider message id olarak "log-{id}" üretir.
class LogSmsSender implements SmsSender
{
    public function __construct(
        private readonly LogManager $log,
        private readonly string $channel = 'stack',
    ) {}

    public function send(SmsPayload $payload): SmsResult
    {
        $segments = $this->estimateSegments($payload->body);

        $this->log->channel($this->channel)->info('SMS gonderildi (LOG driver)', [
            'sms_id' => $payload->id,
            'phone' => $this->maskPhone($payload->phone),
            'sender_id' => $payload->senderId,
            'trigger_type' => $payload->triggerType,
            'segments' => $segments,
            'body' => $payload->body,
        ]);

        return new SmsResult(
            success: true,
            provider: $this->name(),
            providerMessageId: 'log-' . $payload->id,
            segmentCount: $segments,
        );
    }

    public function name(): string
    {
        return 'log';
    }

    // GSM-7 vs UCS-2 ayrımı yapmadan kaba bir tahmin: Türkçe karakter
    // (ç, ğ, ı, ö, ş, ü) varsa unicode (70 char/segment), yoksa 160.
    private function estimateSegments(string $body): int
    {
        $hasUnicode = preg_match('/[çÇğĞıİöÖşŞüÜ]/u', $body) === 1;
        $perSegment = $hasUnicode ? 70 : 160;
        $len = mb_strlen($body);
        return (int) max(1, ceil($len / $perSegment));
    }

    private function maskPhone(string $phone): string
    {
        $len = strlen($phone);
        if ($len <= 4) return $phone;
        return substr($phone, 0, 3) . str_repeat('*', $len - 5) . substr($phone, -2);
    }
}
