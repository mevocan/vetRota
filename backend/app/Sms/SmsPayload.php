<?php

declare(strict_types=1);

namespace App\Sms;

// SMS gönderim yükü — driver'a verilir.
// id: önceden oluşturulmuş sms_messages.id (UUID), driver result'ında geri döner
// böylece status/sent_at güncellenir.
final class SmsPayload
{
    public function __construct(
        public readonly string $id,
        public readonly string $phone,
        public readonly string $body,
        public readonly string $senderId,
        public readonly string $triggerType,
    ) {}
}
