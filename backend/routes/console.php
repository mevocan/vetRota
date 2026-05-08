<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// M6.6: Asi hatirlatma tarayicisi her gun 08:00 (Europe/Istanbul).
Schedule::command('vaccinations:scan')
    ->dailyAt('08:00')
    ->timezone('Europe/Istanbul')
    ->onOneServer()
    ->withoutOverlapping();
