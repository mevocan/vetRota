<?php

declare(strict_types=1);

use App\Http\Controllers\Api\AnimalController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\FarmerController;
use App\Http\Controllers\Api\MedicalRecordController;
use App\Http\Controllers\Api\VillageController;
use Illuminate\Support\Facades\Route;

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
    // M2 vertical slice 2: Cifci tam CRUD.
    Route::apiResource('farmers', FarmerController::class);
    // M2 vertical slice 3: Muayene tam CRUD (URL'de medical-records).
    Route::apiResource('medical-records', MedicalRecordController::class);
    // Koy dropdown icin read-only.
    Route::get('villages', [VillageController::class, 'index']);
});
