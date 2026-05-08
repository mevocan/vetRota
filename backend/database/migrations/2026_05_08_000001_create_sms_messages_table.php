<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// M6.1: SMS log tablosu — server-only (sync edilmez).
// Detay: docs/data-model.md §5.7.
return new class extends Migration {
    public function up(): void
    {
        Schema::create('sms_messages', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('clinic_id');
            $table->foreignUuid('farmer_id')->nullable()->constrained()->nullOnDelete();
            $table->string('phone', 32);          // snapshot
            $table->text('body');
            $table->string('sender_id', 32)->default('VETROTA');
            $table->string('trigger_type', 32);
            $table->string('trigger_reference_type', 32)->nullable();
            $table->uuid('trigger_reference_id')->nullable();
            $table->uuid('portal_token_id')->nullable();
            $table->string('status', 16)->default('queued');
            $table->string('provider', 32)->nullable();
            $table->string('provider_message_id')->nullable();
            $table->integer('attempts')->default(0);
            $table->text('last_error')->nullable();
            $table->timestampTz('queued_at')->useCurrent();
            $table->timestampTz('sent_at')->nullable();
            $table->timestampTz('delivered_at')->nullable();
            $table->decimal('cost', 8, 4)->nullable();
            $table->integer('sms_segment_count')->default(1);
            $table->timestamps();

            $table->foreign('clinic_id')->references('id')->on('clinics')->cascadeOnDelete();

            $table->index(['farmer_id', 'queued_at']);
            $table->index(['clinic_id', 'queued_at']);
            $table->index(['status', 'queued_at']);
            $table->index(['trigger_reference_type', 'trigger_reference_id']);
        });

        // Constraint check'leri (PostgreSQL).
        \Illuminate\Support\Facades\DB::statement(
            "ALTER TABLE sms_messages ADD CONSTRAINT chk_sms_trigger CHECK (trigger_type IN " .
            "('appointment_reminder','appointment_confirm','vaccination_reminder'," .
            "'prescription_delivery','outbreak_alert','general'))"
        );
        \Illuminate\Support\Facades\DB::statement(
            "ALTER TABLE sms_messages ADD CONSTRAINT chk_sms_status CHECK (status IN " .
            "('queued','sending','sent','delivered','failed','rejected'))"
        );
    }

    public function down(): void
    {
        Schema::dropIfExists('sms_messages');
    }
};
