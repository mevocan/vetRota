<?php

declare(strict_types=1);

use App\Http\Controllers\Api\AnimalController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\FarmerController;
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
    // M2 vertical slice: Hayvan tam CRUD; village/farmer dropdown icin read-only.
    Route::apiResource('animals', AnimalController::class);
    Route::get('farmers', [FarmerController::class, 'index']);
    Route::get('villages', [VillageController::class, 'index']);
});
