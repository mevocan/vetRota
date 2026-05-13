<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// M7.4: Recete kayitlari. Muayene tamamlandiktan sonra server tarafinda
// uretilir; ilac listesi medical_record_drugs'tan okunur. SMS observer
// otomatik link gonderir. Sync disi — sadece online iken POST edilir.
return new class extends Migration {
    public function up(): void
    {
        Schema::create('prescriptions', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('clinic_id');
            $table->foreignUuid('medical_record_id')->constrained()->cascadeOnDelete();
            $table->foreignUuid('farmer_id')->constrained()->restrictOnDelete();
            $table->foreignUuid('animal_id')->constrained()->restrictOnDelete();
            $table->bigInteger('vet_id')->nullable();
            $table->string('prescription_number', 32)->nullable()->unique();
            $table->text('notes')->nullable();
            $table->uuid('portal_token_id')->nullable();
            $table->timestampTz('sms_sent_at')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->foreign('clinic_id')->references('id')->on('clinics');
            $table->foreign('vet_id')->references('id')->on('users');
            $table->foreign('portal_token_id')->references('id')->on('farmer_portal_tokens')->nullOnDelete();

            $table->index(['clinic_id', 'created_at']);
            $table->index('farmer_id');
            $table->index('animal_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('prescriptions');
    }
};
