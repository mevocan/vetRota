<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

// M4: muayene fotograflari. Binary verisi storage'da, metadata burada.
// Sync iki kanal: metadata /sync/push + /sync/pull, binary /sync/photos.
return new class extends Migration {
    public function up(): void
    {
        Schema::create('medical_record_photos', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->bigInteger('version')->default(1);
            $table->uuid('clinic_id');
            $table->foreignUuid('medical_record_id')->constrained()->cascadeOnDelete();
            // animal_id denormalize — galeri sorgusu animal_id ile direkt tara,
            // muayene join'ine girmeden.
            $table->foreignUuid('animal_id')->constrained()->cascadeOnDelete();
            // storage_path: 'photos/<clinic_id>/<animal_id>/<uuid>.jpg' formatinda;
            // Laravel storage::disk('local')->path() ile mutlak yola cevrilir.
            // Henuz upload edilmemis (sadece metadata pull edilen) kayitlarda
            // null kalabilir.
            $table->string('storage_path', 512)->nullable();
            $table->string('original_filename')->nullable();
            $table->string('mime_type', 64)->nullable();
            $table->bigInteger('size_bytes')->nullable();
            $table->integer('width')->nullable();
            $table->integer('height')->nullable();
            $table->timestampTz('taken_at');
            $table->text('caption')->nullable();
            $table->timestamps();
            $table->softDeletes();
            $table->timestampTz('last_modified_at')->nullable();
            $table->uuid('origin_device_id')->nullable();

            $table->foreign('clinic_id')->references('id')->on('clinics')->restrictOnDelete();
            $table->index('clinic_id');
            $table->index('medical_record_id');
            $table->index('animal_id');
            $table->index(['last_modified_at', 'id'], 'medical_record_photos_lmod_id_idx');
        });

        // Sync trigger'i bu tabloya da bagla (function 000008'de zaten kurulu).
        DB::statement('DROP TRIGGER IF EXISTS medical_record_photos_bump_sync_insert ON medical_record_photos');
        DB::statement(<<<'SQL'
            CREATE TRIGGER medical_record_photos_bump_sync_insert
            BEFORE INSERT ON medical_record_photos
            FOR EACH ROW
            EXECUTE FUNCTION bump_sync_columns();
        SQL);
        DB::statement('DROP TRIGGER IF EXISTS medical_record_photos_bump_sync_update ON medical_record_photos');
        DB::statement(<<<'SQL'
            CREATE TRIGGER medical_record_photos_bump_sync_update
            BEFORE UPDATE ON medical_record_photos
            FOR EACH ROW
            EXECUTE FUNCTION bump_sync_columns();
        SQL);
    }

    public function down(): void
    {
        DB::statement('DROP TRIGGER IF EXISTS medical_record_photos_bump_sync_insert ON medical_record_photos');
        DB::statement('DROP TRIGGER IF EXISTS medical_record_photos_bump_sync_update ON medical_record_photos');
        Schema::dropIfExists('medical_record_photos');
    }
};
