<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// M5.2: gunluk veteriner raporu. Server-only — sync'e dahil degil
// (data-model.md §3 listesinde isaretli). Hesaplama on-demand veya
// gun sonu cron tarafindan tetiklenir, PDF storage'a yazilir.
return new class extends Migration {
    public function up(): void
    {
        Schema::create('daily_reports', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('clinic_id');
            $table->foreignId('vet_id')->constrained('users')->restrictOnDelete();
            $table->date('date');
            $table->integer('animals_visited')->default(0);
            $table->integer('medical_records_count')->default(0);
            $table->decimal('total_distance_km', 8, 2)->nullable();
            $table->decimal('total_revenue', 12, 2)->default(0);
            $table->jsonb('drugs_used')->nullable(); // [{drug_id, name, total_quantity, unit}]
            $table->string('pdf_path', 512)->nullable();
            $table->timestampTz('generated_at')->nullable();
            $table->timestamps();

            $table->foreign('clinic_id')->references('id')->on('clinics')->restrictOnDelete();
            $table->unique(['vet_id', 'date'], 'daily_reports_vet_date_unique');
            $table->index('clinic_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('daily_reports');
    }
};
