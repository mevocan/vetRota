<?php

declare(strict_types=1);

namespace App\Sms;

// Driver'dan dönen sonuç. Provider'a özel mesaj id'si ve adetlere göre
// segment sayısı (160 ASCII / 70 unicode karakter başına 1 segment).
final class SmsResult
{
    public function __construct(
        public readonly bool $success,
        public readonly string $provider,
        public readonly ?string $providerMessageId = null,
        public readonly int $segmentCount = 1,
        public readonly ?string $error = null,
    ) {}
}
