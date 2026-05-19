<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// M10.1: clinics tablosuna abonelik alanlari.
// data-model.md §clinics ile uyumlu: free | premium + expires_at.
// MVP: odeme entegrasyonu yok; upgrade endpoint'i tier'i degistirir + 30g uzatir.
return new class extends Migration {
    public function up(): void
    {
        Schema::table('clinics', function (Blueprint $table): void {
            $table->string('subscription_tier', 16)->default('free')->after('settings');
            $table->timestampTz('subscription_expires_at')->nullable()->after('subscription_tier');
            $table->index('subscription_tier', 'idx_clinics_subscription');
        });
    }

    public function down(): void
    {
        Schema::table('clinics', function (Blueprint $table): void {
            $table->dropIndex('idx_clinics_subscription');
            $table->dropColumn(['subscription_tier', 'subscription_expires_at']);
        });
    }
};
