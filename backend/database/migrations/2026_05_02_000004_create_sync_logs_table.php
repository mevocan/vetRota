<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// M3.1: Sync calistigi/basarisiz oldugu her seferi log'lar.
// /sync/status endpoint'i bu tabloyu okur.
return new class extends Migration {
    public function up(): void
    {
        Schema::create('sync_logs', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('device_id');
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->uuid('clinic_id')->nullable();
            $table->string('direction', 16); // 'push' | 'pull'
            $table->string('status', 16);    // 'in_progress' | 'success' | 'failed'
            $table->timestampTz('started_at');
            $table->timestampTz('completed_at')->nullable();
            $table->integer('pushed_count')->default(0);
            $table->integer('pulled_count')->default(0);
            $table->integer('conflict_count')->default(0);
            $table->text('error_message')->nullable();
            $table->jsonb('metadata')->nullable();
            $table->timestamps();

            $table->index(['device_id', 'direction', 'status']);
            $table->index('completed_at');
            $table->foreign('clinic_id')->references('id')->on('clinics')->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sync_logs');
    }
};
