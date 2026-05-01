<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

// M3.1: Sync kolonlarini mevcut M2 tablolarina ekler.
// - version: optimistic locking; trigger BEFORE UPDATE'de +1
// - last_modified_at: pull cursor'i; trigger now() yazar
// - origin_device_id: echo prevention; cihaz kendi yazdigini geri cekmez
// - clinic_id: tenant scope (villages global oldugu icin haric)
//
// Tablo listesi sync-api.md §2'deki FK siralamasini takip eder.
return new class extends Migration {
    /** clinic_id ALAN tablolar (villages haric — global master). */
    private const TENANT_TABLES = [
        'farmers',
        'animals',
        'appointments',
        'medical_records',
        'drugs',
        'stocks',
        'stock_movements',
    ];

    /** Tum sync tablolari (clinic_id'siz villages dahil). */
    private const ALL_SYNC_TABLES = [
        'villages',
        'farmers',
        'animals',
        'appointments',
        'medical_records',
        'drugs',
        'stocks',
        'stock_movements',
    ];

    public function up(): void
    {
        $defaultClinicId = DB::table('clinics')
            ->where('name', 'VetRota Demo Klinik')
            ->value('id');

        foreach (self::ALL_SYNC_TABLES as $tableName) {
            Schema::table($tableName, function (Blueprint $table) use ($tableName): void {
                $table->bigInteger('version')->default(1)->after('id');
                $table->timestampTz('last_modified_at')->nullable()->after('updated_at');
                $table->uuid('origin_device_id')->nullable()->after('last_modified_at');

                if (in_array($tableName, self::TENANT_TABLES, true)) {
                    $table->uuid('clinic_id')->nullable()->after('id');
                }
            });

            // Mevcut satirlar icin last_modified_at backfill.
            DB::statement("UPDATE {$tableName} SET last_modified_at = COALESCE(updated_at, now()) WHERE last_modified_at IS NULL");

            if (in_array($tableName, self::TENANT_TABLES, true)) {
                DB::table($tableName)
                    ->whereNull('clinic_id')
                    ->update(['clinic_id' => $defaultClinicId]);

                DB::statement("ALTER TABLE {$tableName} ALTER COLUMN clinic_id SET NOT NULL");

                Schema::table($tableName, function (Blueprint $table): void {
                    $table->foreign('clinic_id')->references('id')->on('clinics')->restrictOnDelete();
                    $table->index('clinic_id');
                });
            }

            // last_modified_at index — pull cursor sorgusu icin kritik.
            Schema::table($tableName, function (Blueprint $table) use ($tableName): void {
                $table->index(['last_modified_at', 'id'], "{$tableName}_lmod_id_idx");
            });
        }
    }

    public function down(): void
    {
        foreach (array_reverse(self::ALL_SYNC_TABLES) as $tableName) {
            Schema::table($tableName, function (Blueprint $table) use ($tableName): void {
                $table->dropIndex("{$tableName}_lmod_id_idx");

                if (in_array($tableName, self::TENANT_TABLES, true)) {
                    $table->dropForeign(['clinic_id']);
                    $table->dropIndex(['clinic_id']);
                    $table->dropColumn('clinic_id');
                }

                $table->dropColumn(['version', 'last_modified_at', 'origin_device_id']);
            });
        }
    }
};
