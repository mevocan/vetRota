<?php

namespace App\Providers;

use App\Models\StockMovement;
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
    }
}
