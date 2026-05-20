<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        apiPrefix: 'api/v1',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        // M3.2: sync endpoint'leri device_id eslesmesini zorunlu kilar.
        $middleware->alias([
            'device.match' => \App\Http\Middleware\EnsureDeviceMatchesJwt::class,
            'premium' => \App\Http\Middleware\EnsurePremiumClinic::class,
        ]);

        // Tum API yanitlarina Content-Length ekle. php artisan serve'in
        // close-delimited buyuk yanitlari mobil Dio'da parse hatasi
        // veriyordu; bu middleware onu cozer.
        $middleware->appendToGroup('api', \App\Http\Middleware\SetContentLength::class);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        //
    })->create();
