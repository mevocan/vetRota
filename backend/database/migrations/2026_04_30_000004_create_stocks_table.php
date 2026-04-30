<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// M2 vertical slice 4: stok cache.
// stocks tablosu = stock_movements'in cumulative cache'i. Movement insert
// edildikce StockMovementObserver ile guncellenir.
// Kapsam disi: clinic_id, owner_user_id (cogul vet/klinik M3+).
return new class extends Migration {
    public function up(): void
    {
        Schema::create('stocks', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('drug_id')->unique()->constrained()->restrictOnDelete();
            $table->decimal('current_quantity', 12, 3)->default(0);
            $table->decimal('critical_threshold', 12, 3)->nullable();
            $table->decimal('reorder_quantity', 12, 3)->nullable();
            $table->timestampTz('last_purchased_at')->nullable();
            $table->date('earliest_expiry_at')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('stocks');
    }
};
