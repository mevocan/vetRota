<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

// M3.1: User cogul klinik + cihaz farkindaligi.
// - clinic_id: tenant scope, JWT claim'inde tasinacak
// - device_id: JWT claim'inde tasinacak; sync echo prevention icin
// - role: vet, owner, secretary (M2'de tek tip vardi)
return new class extends Migration {
    public function up(): void
    {
        $defaultClinicId = DB::table('clinics')
            ->where('name', 'VetRota Demo Klinik')
            ->value('id');

        Schema::table('users', function (Blueprint $table) use ($defaultClinicId): void {
            $table->uuid('clinic_id')->nullable()->after('id');
            $table->uuid('device_id')->nullable()->after('clinic_id');
            $table->string('role', 32)->default('vet')->after('device_id');
        });

        // Backfill mevcut user'lar -> default klinik.
        DB::table('users')->whereNull('clinic_id')->update([
            'clinic_id' => $defaultClinicId,
        ]);

        // Sonra NOT NULL + FK.
        DB::statement('ALTER TABLE users ALTER COLUMN clinic_id SET NOT NULL');
        Schema::table('users', function (Blueprint $table): void {
            $table->foreign('clinic_id')->references('id')->on('clinics')->restrictOnDelete();
            $table->index('clinic_id');
            $table->index('device_id');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table): void {
            $table->dropForeign(['clinic_id']);
            $table->dropIndex(['clinic_id']);
            $table->dropIndex(['device_id']);
            $table->dropColumn(['clinic_id', 'device_id', 'role']);
        });
    }
};
