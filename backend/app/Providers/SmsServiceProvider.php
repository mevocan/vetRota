<?php

declare(strict_types=1);

namespace App\Providers;

use App\Sms\Contracts\SmsSender;
use App\Sms\Drivers\LogSmsSender;
use Illuminate\Contracts\Foundation\Application;
use Illuminate\Log\LogManager;
use Illuminate\Support\ServiceProvider;
use RuntimeException;

class SmsServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->singleton(SmsSender::class, function (Application $app): SmsSender {
            $driver = config('sms.default', 'log');

            return match ($driver) {
                'log' => new LogSmsSender(
                    $app->make(LogManager::class),
                    (string) config('sms.drivers.log.channel', 'stack'),
                ),
                default => throw new RuntimeException("Bilinmeyen SMS driver: {$driver}"),
            };
        });
    }
}
