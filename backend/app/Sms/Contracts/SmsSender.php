<?php

declare(strict_types=1);

namespace App\Sms\Contracts;

use App\Sms\SmsPayload;
use App\Sms\SmsResult;

// Driver pattern: tüm SMS sağlayıcıları bu interface'i implement eder.
// MVP: LogSmsSender. Production: NetGsmSmsSender vs.
interface SmsSender
{
    public function send(SmsPayload $payload): SmsResult;

    public function name(): string;
}
