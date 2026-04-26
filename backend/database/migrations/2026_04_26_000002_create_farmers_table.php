<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('farmers', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('village_id')->nullable()->constrained()->nullOnDelete();
            $table->string('first_name');
            $table->string('last_name');
            $table->string('phone');
            $table->string('email')->nullable();
            $table->text('address_detail')->nullable();
            $table->decimal('balance', 12, 2)->default(0);
            $table->boolean('sms_notifications_enabled')->default(true);
            $table->string('preferred_sms_language', 10)->default('tr');
            $table->text('notes')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->unique('phone');
            $table->index('village_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('farmers');
    }
};
