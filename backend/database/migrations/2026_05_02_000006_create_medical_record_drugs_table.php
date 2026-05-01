<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// M3: muayenede kullanilan ilaclar — push payload'inda ayri tablo olarak
// yer alir (sync-api.md §2). M2'de muayene metni ve stok hareketi ayri
// duruyordu; bu tablo "muayene <-> kullandigi ilac" iliskisini denormalize
// eder ve client offline'da kayit yapabilsin diye sync edilir.
return new class extends Migration {
    public function up(): void
    {
        Schema::create('medical_record_drugs', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->bigInteger('version')->default(1);
            $table->uuid('clinic_id');
            $table->foreignUuid('medical_record_id')->constrained()->cascadeOnDelete();
            $table->foreignUuid('drug_id')->constrained()->restrictOnDelete();
            $table->decimal('quantity', 12, 3);
            $table->string('unit', 16);
            $table->string('route', 32)->nullable();      // 'oral','im','iv','sc','topical'
            $table->string('frequency', 64)->nullable();  // serbest text: '2x1, 5 gun'
            $table->decimal('unit_price', 10, 2)->nullable(); // snapshot
            $table->string('batch_number')->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();
            $table->softDeletes();
            $table->timestampTz('last_modified_at')->nullable();
            $table->uuid('origin_device_id')->nullable();

            $table->foreign('clinic_id')->references('id')->on('clinics')->restrictOnDelete();
            $table->index('clinic_id');
            $table->index('medical_record_id');
            $table->index('drug_id');
            $table->index(['last_modified_at', 'id'], 'medical_record_drugs_lmod_id_idx');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('medical_record_drugs');
    }
};
