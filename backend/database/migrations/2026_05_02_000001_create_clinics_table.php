<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

// M3.1: cogul klinik temel tablo. MVP'de tek demo klinik seed'lenir;
// yonetim UI'si M8+ kapsaminda. Diger tum tenant tablolari (animals,
// farmers, ...) clinic_id ile bu tabloya baglanir.
return new class extends Migration {
    public function up(): void
    {
        Schema::create('clinics', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->string('name');
            $table->string('phone')->nullable();
            $table->string('email')->nullable();
            $table->string('city')->nullable();
            $table->string('district')->nullable();
            $table->jsonb('settings')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });

        // Default klinik — mevcut M2 verisi backfill icin gerekiyor.
        // Sonraki migration'lar `WHERE name = 'VetRota Demo Klinik'` ile bulur.
        DB::table('clinics')->insert([
            'id' => (string) Str::uuid(),
            'name' => 'VetRota Demo Klinik',
            'city' => 'Ankara',
            'district' => 'Beypazarı',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    public function down(): void
    {
        Schema::dropIfExists('clinics');
    }
};
