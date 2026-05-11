<?php

namespace App\Providers;

use App\Models\Appointment;
use App\Models\MedicalRecord;
use App\Models\Payment;
use App\Models\StockMovement;
use App\Observers\AppointmentObserver;
use App\Observers\MedicalRecordBalanceObserver;
use App\Observers\PaymentObserver;
use App\Observers\StockMovementObserver;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        //
    }

    public function boot(): void
    {
        StockMovement::observe(StockMovementObserver::class);
        Appointment::observe(AppointmentObserver::class);
        Payment::observe(PaymentObserver::class);
        MedicalRecord::observe(MedicalRecordBalanceObserver::class);
    }
}
