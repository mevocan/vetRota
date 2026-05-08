<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

// M6.2: Çiftçi portal token'ları — SMS link'lerinin arkasındaki kimlik.
// Detay: docs/data-model.md §5.7. Server-only (sync edilmez).
return new class extends Migration {
    public function up(): void
    {
        Schema::create('farmer_portal_tokens', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('farmer_id')->constrained()->cascadeOnDelete();
            $table->uuid('clinic_id');
            $table->string('token_hash')->unique();      // SHA-256 hex
            $table->string('token_prefix', 16);          // ilk 8 karakter (debug)
            $table->string('scope', 32);
            $table->string('resource_type', 32)->nullable();
            $table->uuid('resource_id')->nullable();
            $table->timestampTz('expires_at');
            $table->timestampTz('revoked_at')->nullable();
            $table->timestampTz('first_accessed_at')->nullable();
            $table->timestampTz('last_accessed_at')->nullable();
            $table->integer('access_count')->default(0);
            $table->string('last_ip_hash', 64)->nullable();
            $table->text('last_user_agent')->nullable();
            $table->timestamps();

            $table->foreign('clinic_id')->references('id')->on('clinics')->cascadeOnDelete();

            $table->index(['farmer_id', 'created_at']);
            $table->index(['resource_type', 'resource_id']);
        });

        DB::statement(
            "ALTER TABLE farmer_portal_tokens ADD CONSTRAINT chk_token_scope CHECK (scope IN " .
            "('general','appointment','prescription','vaccination','outbreak_alert'))"
        );

        // Aktif token'lar için kısmi index (revoke veya expired olmayanlar).
        DB::statement(
            "CREATE INDEX idx_portal_tokens_active ON farmer_portal_tokens(token_hash) " .
            "WHERE revoked_at IS NULL"
        );
    }

    public function down(): void
    {
        Schema::dropIfExists('farmer_portal_tokens');
    }
};
