<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('villages', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->string('name');
            $table->string('district');
            $table->string('city');
            $table->decimal('lat', 10, 7)->nullable();
            $table->decimal('lng', 10, 7)->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->unique(['name', 'district', 'city']);
            $table->index(['city', 'district']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('villages');
    }
};
