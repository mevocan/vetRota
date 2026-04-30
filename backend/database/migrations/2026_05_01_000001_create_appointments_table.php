<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

// M2 vertical slice 5: randevular.
// Kapsam disi (sonraki milestone'larda eklenecek):
//   - clinic_id (M2.5/M3 cogul klinik)
//   - source / source_reference_id (M5: asi takvimi/follow-up otomatik
//     randevu tetikleyicileri)
//   - sms_reminder_sent_at / confirmed_by_farmer_at (M6 SMS akislari)
//   - completed_medical_record_id (M2.5: muayene ile baglama)
//   - sync kolonlari (M3)
return new class extends Migration {
    public function up(): void
    {
        Schema::create('appointments', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('farmer_id')->constrained()->restrictOnDelete();
            $table->foreignUuid('animal_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('vet_id')->constrained('users')->restrictOnDelete();
            $table->foreignUuid('village_id')->nullable()->constrained()->nullOnDelete();

            $table->timestampTz('scheduled_at');
            $table->integer('estimated_duration_minutes')->nullable()->default(30);
            $table->string('appointment_type', 32)->default('visit');
            $table->text('reason')->nullable();
            $table->text('notes')->nullable();
            $table->string('status', 32)->default('planned');
            $table->timestampTz('status_changed_at')->nullable();

            $table->timestamps();
            $table->softDeletes();

            $table->index(['vet_id', 'scheduled_at']);
            $table->index(['farmer_id', 'scheduled_at']);
            $table->index(['animal_id', 'scheduled_at']);
            $table->index(['status', 'scheduled_at']);
        });

        DB::statement("ALTER TABLE appointments ADD CONSTRAINT chk_appt_type CHECK (appointment_type IN ('visit','vaccination','follow_up','emergency','routine_check'))");
        DB::statement("ALTER TABLE appointments ADD CONSTRAINT chk_appt_status CHECK (status IN ('planned','confirmed','in_progress','completed','cancelled','no_show'))");
    }

    public function down(): void
    {
        Schema::dropIfExists('appointments');
    }
};
