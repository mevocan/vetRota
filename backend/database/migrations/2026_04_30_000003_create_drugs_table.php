<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// M2 vertical slice 4: ilac katalogu.
// Kapsam disi (sonraki milestone'larda ALTER TABLE ile eklenecek):
//   - clinic_id (M2.5/M3 cogul klinik gecisinde)
//   - sync kolonlari: last_modified_at, origin_device_id, version (M3)
return new class extends Migration {
    public function up(): void
    {
        Schema::create('drugs', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->string('name');
            $table->string('active_ingredient')->nullable();
            $table->string('manufacturer')->nullable();
            $table->string('barcode')->nullable();
            $table->string('drug_type', 32);                // 'antibiotic', 'vaccine', 'antiparasitic', vb.
            $table->boolean('requires_prescription')->default(true);
            $table->string('unit', 16);                     // 'ml', 'tablet', 'doz', 'g'
            $table->decimal('package_size', 10, 2)->nullable();
            $table->boolean('is_vaccine')->default(false);
            $table->integer('vaccine_duration_days')->nullable();
            $table->jsonb('suitable_species')->default(json_encode(['cattle', 'sheep', 'goat']));
            $table->decimal('default_price', 10, 2)->nullable();
            $table->timestamps();
            $table->softDeletes();
        });

        // Telefon ornegindeki gibi: name partial unique (silinmis kayit ayni isimle yeniden eklenebilsin).
        \DB::statement('CREATE UNIQUE INDEX drugs_name_unique_active ON drugs (name) WHERE deleted_at IS NULL');
    }

    public function down(): void
    {
        Schema::dropIfExists('drugs');
    }
};
