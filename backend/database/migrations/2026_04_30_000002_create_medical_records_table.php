<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// M2 vertical slice 3: muayene (medical_records) tam CRUD.
// Kapsam disi (sonraki milestone'larda ALTER TABLE ile eklenecek):
//   - clinic_id (M2.5/M3 cogul klinik gecisinde)
//   - diagnosis_id (M3+ tani sozlugu)
//   - appointment_id (M4 randevular)
//   - invoice_id (M7 e-fatura)
//   - sync kolonlari: last_modified_at, origin_device_id, version (M3)
return new class extends Migration {
    public function up(): void
    {
        Schema::create('medical_records', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('animal_id')->constrained()->restrictOnDelete();
            // users tablosu su an bigint id; M3'te UUID'e gecince ALTER TABLE ile uyumlulanir.
            $table->foreignId('vet_id')->constrained('users')->restrictOnDelete();
            $table->foreignUuid('village_id')->nullable()->constrained()->nullOnDelete();

            $table->decimal('lat', 10, 7)->nullable();
            $table->decimal('lng', 10, 7)->nullable();

            $table->string('visit_type', 32)->default('examination');

            $table->text('chief_complaint')->nullable();
            $table->text('symptoms')->nullable();
            $table->text('diagnosis_notes')->nullable();
            $table->text('treatment_notes')->nullable();
            $table->text('recommendations')->nullable();

            $table->decimal('temperature_celsius', 4, 1)->nullable();
            $table->decimal('weight_kg', 6, 2)->nullable();
            $table->integer('heart_rate')->nullable();
            $table->integer('respiratory_rate')->nullable();

            $table->decimal('service_fee', 10, 2)->default(0);

            $table->timestampTz('examined_at');
            $table->boolean('follow_up_needed')->default(false);
            $table->date('follow_up_date')->nullable();

            $table->timestamps();
            $table->softDeletes();

            $table->index(['animal_id', 'examined_at']);
            $table->index(['vet_id', 'examined_at']);
            $table->index(['village_id', 'examined_at']);
            $table->index('follow_up_date');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('medical_records');
    }
};
