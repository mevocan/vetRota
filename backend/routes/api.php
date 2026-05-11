<?php

declare(strict_types=1);

use App\Http\Controllers\Api\AnimalController;
use App\Http\Controllers\Api\AppointmentController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DrugController;
use App\Http\Controllers\Api\FarmerController;
use App\Http\Controllers\Api\MedicalRecordController;
use App\Http\Controllers\Api\StockMovementController;
use App\Http\Controllers\Api\VaccineScheduleController;
use App\Http\Controllers\Api\V1\FarmerPortal\FarmerPortalController;
use App\Http\Controllers\Api\V1\Reports\DailyReportController;
use App\Http\Controllers\Api\V1\Sync\SyncPhotoController;
use App\Http\Controllers\Api\V1\Sync\SyncPullController;
use App\Http\Controllers\Api\V1\Sync\SyncPushController;
use App\Http\Controllers\Api\V1\Sync\SyncStatusController;
use App\Http\Controllers\Api\VillageController;
use Illuminate\Support\Facades\Route;

// M6.7: Ciftci portal — auth'suz, token ile dogrulanir.
Route::get('farmer-portal/{token}', [FarmerPortalController::class, 'show'])
    ->where('token', '[A-Za-z0-9]{16,64}')
    ->name('farmer-portal.show');

Route::prefix('auth')->group(function (): void {
    Route::post('login', [AuthController::class, 'login']);

    Route::middleware('auth:api')->group(function (): void {
        Route::get('me', [AuthController::class, 'me']);
        Route::post('logout', [AuthController::class, 'logout']);
        Route::post('refresh', [AuthController::class, 'refresh']);
    });
});

Route::middleware('auth:api')->group(function (): void {
    // M2 vertical slice 1: Hayvan tam CRUD.
    Route::apiResource('animals', AnimalController::class);
    // M7.2: hayvan icin QR etiket PDF.
    Route::get('animals/{animal}/qr.pdf', \App\Http\Controllers\Api\V1\Animals\AnimalQrController::class)
        ->name('animals.qr');
    // M2 vertical slice 2: Cifci tam CRUD.
    Route::apiResource('farmers', FarmerController::class);
    // M2 vertical slice 3: Muayene tam CRUD (URL'de medical-records).
    Route::apiResource('medical-records', MedicalRecordController::class);
    // M2 vertical slice 4: Ilac CRUD + stok hareketleri.
    Route::apiResource('drugs', DrugController::class);
    Route::get('stock-movements', [StockMovementController::class, 'index']);
    Route::post('stock-movements', [StockMovementController::class, 'store']);
    // M2 vertical slice 5: Randevular.
    Route::apiResource('appointments', AppointmentController::class);
    // M6.9: Asi planlari CRUD.
    Route::apiResource('vaccine-schedules', VaccineScheduleController::class)
        ->parameters(['vaccine-schedules' => 'vaccineSchedule']);
    // Koy dropdown icin read-only.
    Route::get('villages', [VillageController::class, 'index']);

    // M7.3: odeme ledger (sync hem push hem REST UI'da).
    Route::get('payments', [\App\Http\Controllers\Api\PaymentController::class, 'index']);
    Route::post('payments', [\App\Http\Controllers\Api\PaymentController::class, 'store']);

    // M5.2: gunluk rapor (server-only, sync disi).
    Route::get('reports/daily/{date}', [DailyReportController::class, 'show'])
        ->where('date', '\d{4}-\d{2}-\d{2}')
        ->name('reports.daily.show');

    // M3.3: Sync push. device.match middleware JWT'deki device_id ile
    // header X-Device-Id eslesmesini zorunlu kilar.
    Route::middleware('device.match')->prefix('sync')->group(function (): void {
        Route::post('push', SyncPushController::class)->name('sync.push');
        Route::get('pull', SyncPullController::class)->name('sync.pull');
        Route::get('status', SyncStatusController::class)->name('sync.status');
        // M4.2: muayene fotograflari icin ayri multipart kanal.
        Route::post('photos', SyncPhotoController::class)->name('sync.photos');
    });
});
