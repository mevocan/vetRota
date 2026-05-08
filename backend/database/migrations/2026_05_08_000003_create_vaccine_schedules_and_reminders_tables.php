<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

// M6.5: Asi planlari + hatirlatma kayitlari.
// vaccine_schedules SYNC edilir (veteriner offline iken plan tanimlayabilsin).
// vaccination_reminders SERVER-ONLY (scheduler urettir, sync edilmez).
return new class extends Migration {
    public function up(): void
    {
        Schema::create('vaccine_schedules', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->bigInteger('version')->default(1);
            $table->uuid('clinic_id');
            $table->foreignUuid('animal_id')->constrained()->cascadeOnDelete();
            $table->foreignUuid('drug_id')->constrained()->restrictOnDelete();
            $table->integer('interval_days');
            $table->date('first_due_date');
            $table->date('next_due_date');
            $table->timestampTz('last_administered_at')->nullable();
            $table->integer('remind_days_before')->default(7);
            $table->boolean('is_active')->default(true);
            $table->text('notes')->nullable();
            $table->timestamps();
            $table->softDeletes();
            $table->timestampTz('last_modified_at')->nullable();
            $table->uuid('origin_device_id')->nullable();

            $table->foreign('clinic_id')->references('id')->on('clinics')->cascadeOnDelete();
            $table->index('clinic_id');
            $table->index('animal_id');
            $table->index('next_due_date');
            $table->index(['last_modified_at', 'id'], 'vaccine_sch_lmod_id_idx');
        });

        // Sync trigger.
        DB::statement("DROP TRIGGER IF EXISTS vaccine_schedules_bump_sync_insert ON vaccine_schedules");
        DB::statement("CREATE TRIGGER vaccine_schedules_bump_sync_insert BEFORE INSERT ON vaccine_schedules FOR EACH ROW EXECUTE FUNCTION bump_sync_columns()");
        DB::statement("DROP TRIGGER IF EXISTS vaccine_schedules_bump_sync_update ON vaccine_schedules");
        DB::statement("CREATE TRIGGER vaccine_schedules_bump_sync_update BEFORE UPDATE ON vaccine_schedules FOR EACH ROW EXECUTE FUNCTION bump_sync_columns()");

        Schema::create('vaccination_reminders', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('vaccine_schedule_id')->constrained('vaccine_schedules')->cascadeOnDelete();
            $table->foreignUuid('animal_id')->constrained()->cascadeOnDelete();
            $table->foreignUuid('farmer_id')->constrained()->restrictOnDelete();
            $table->uuid('clinic_id');
            $table->date('due_date');
            $table->timestampTz('reminder_at');
            $table->string('status', 16)->default('scheduled');
            $table->timestampTz('sms_sent_at')->nullable();
            $table->timestampTz('acknowledged_at')->nullable();
            $table->uuid('completed_medical_record_id')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->foreign('clinic_id')->references('id')->on('clinics')->cascadeOnDelete();
            $table->foreign('completed_medical_record_id')->references('id')->on('medical_records')->nullOnDelete();

            $table->index(['status', 'reminder_at']);
            $table->index(['animal_id', 'due_date']);
            $table->index(['farmer_id', 'due_date']);
            $table->unique(['vaccine_schedule_id', 'due_date'], 'vacc_rem_sch_due_unq');
        });

        DB::statement(
            "ALTER TABLE vaccination_reminders ADD CONSTRAINT chk_vacc_rem_status CHECK (status IN " .
            "('scheduled','sms_sent','acknowledged','completed','missed','cancelled'))"
        );
    }

    public function down(): void
    {
        Schema::dropIfExists('vaccination_reminders');
        DB::statement("DROP TRIGGER IF EXISTS vaccine_schedules_bump_sync_insert ON vaccine_schedules");
        DB::statement("DROP TRIGGER IF EXISTS vaccine_schedules_bump_sync_update ON vaccine_schedules");
        Schema::dropIfExists('vaccine_schedules');
    }
};
