<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

// M5.1: Veterinerin gunluk rotasi. routes 1 satir/gun, route_stops her
// durak (genelde 1 randevu = 1 stop). Optimize butonu nearest-neighbor
// ile sequence belirler ve buraya yazar.
return new class extends Migration {
    public function up(): void
    {
        Schema::create('routes', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->bigInteger('version')->default(1);
            $table->uuid('clinic_id');
            $table->foreignId('vet_id')->constrained('users')->restrictOnDelete();
            $table->date('date');
            $table->decimal('total_distance_km', 8, 2)->nullable();
            $table->integer('total_duration_min')->nullable();
            // start lat/lng — klinik veya manuel pin.
            $table->decimal('start_lat', 10, 7)->nullable();
            $table->decimal('start_lng', 10, 7)->nullable();
            $table->timestamps();
            $table->softDeletes();
            $table->timestampTz('last_modified_at')->nullable();
            $table->uuid('origin_device_id')->nullable();

            $table->foreign('clinic_id')->references('id')->on('clinics')->restrictOnDelete();
            $table->index('clinic_id');
            $table->unique(['vet_id', 'date'], 'routes_vet_date_unique');
            $table->index(['last_modified_at', 'id'], 'routes_lmod_id_idx');
        });

        Schema::create('route_stops', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->bigInteger('version')->default(1);
            $table->uuid('clinic_id');
            $table->foreignUuid('route_id')->constrained()->cascadeOnDelete();
            // appointment_id null olabilir — ad-hoc bir durak da eklenebilir
            // (ornek: yolda gec eklenen ziyaret).
            $table->foreignUuid('appointment_id')->nullable()->constrained()->nullOnDelete();
            $table->integer('sequence');
            $table->decimal('lat', 10, 7);
            $table->decimal('lng', 10, 7);
            $table->decimal('distance_from_prev_km', 8, 2)->nullable();
            $table->string('status', 32)->default('pending'); // pending|visited|skipped
            $table->timestampTz('visited_at')->nullable();
            $table->timestamps();
            $table->softDeletes();
            $table->timestampTz('last_modified_at')->nullable();
            $table->uuid('origin_device_id')->nullable();

            $table->foreign('clinic_id')->references('id')->on('clinics')->restrictOnDelete();
            $table->index('clinic_id');
            $table->index('route_id');
            $table->index(['route_id', 'sequence']);
            $table->index(['last_modified_at', 'id'], 'route_stops_lmod_id_idx');
        });

        // Sync trigger'lara bagla.
        foreach (['routes', 'route_stops'] as $tbl) {
            DB::statement("DROP TRIGGER IF EXISTS {$tbl}_bump_sync_insert ON {$tbl}");
            DB::statement("CREATE TRIGGER {$tbl}_bump_sync_insert BEFORE INSERT ON {$tbl} FOR EACH ROW EXECUTE FUNCTION bump_sync_columns()");
            DB::statement("DROP TRIGGER IF EXISTS {$tbl}_bump_sync_update ON {$tbl}");
            DB::statement("CREATE TRIGGER {$tbl}_bump_sync_update BEFORE UPDATE ON {$tbl} FOR EACH ROW EXECUTE FUNCTION bump_sync_columns()");
        }
    }

    public function down(): void
    {
        foreach (['routes', 'route_stops'] as $tbl) {
            DB::statement("DROP TRIGGER IF EXISTS {$tbl}_bump_sync_insert ON {$tbl}");
            DB::statement("DROP TRIGGER IF EXISTS {$tbl}_bump_sync_update ON {$tbl}");
        }
        Schema::dropIfExists('route_stops');
        Schema::dropIfExists('routes');
    }
};
