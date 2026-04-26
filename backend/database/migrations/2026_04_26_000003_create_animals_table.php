<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('animals', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('farmer_id')->constrained()->restrictOnDelete();
            $table->foreignUuid('village_id')->nullable()->constrained()->nullOnDelete();
            $table->string('ear_tag')->nullable();
            $table->string('name')->nullable();
            $table->string('species'); // 'cattle','sheep','goat','poultry','other'
            $table->string('breed')->nullable();
            $table->date('birth_date')->nullable();
            $table->string('gender'); // 'male','female','unknown'
            $table->decimal('weight_kg', 6, 2)->nullable();
            $table->string('color')->nullable();
            $table->boolean('is_pregnant')->default(false);
            $table->timestampTz('last_vaccination_at')->nullable();
            $table->string('status')->default('alive'); // 'alive','sold','deceased','lost'
            $table->timestampTz('status_changed_at')->nullable();
            $table->text('status_notes')->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->index('farmer_id');
            $table->index('village_id');
            $table->index('ear_tag');
            $table->index('status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('animals');
    }
};
