<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// M3.1: LWW cakisma audit trail. sync-api.md §8.2:
// "Conflict detected → sync_conflicts tablosuna log (audit icin)
//                    → client verisi server'a yazilir".
return new class extends Migration {
    public function up(): void
    {
        Schema::create('sync_conflicts', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('device_id');
            $table->uuid('clinic_id')->nullable();
            $table->string('table_name', 64);
            $table->uuid('record_id');
            $table->bigInteger('local_version');
            $table->bigInteger('server_version');
            $table->jsonb('local_payload')->nullable();
            $table->jsonb('server_payload')->nullable();
            $table->string('resolution_strategy', 32); // last_write_wins, additive_merge, ...
            $table->string('resolution', 32);          // resolved_local, resolved_server, pending
            $table->timestampTz('resolved_at')->nullable();
            $table->timestamps();

            $table->index(['device_id', 'resolution']);
            $table->index(['table_name', 'record_id']);
            $table->foreign('clinic_id')->references('id')->on('clinics')->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sync_conflicts');
    }
};
