<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// M2 vertical slice 4: ledger - stok hareketleri.
// CLAUDE.md kurali: "Ledger tablolari (stock_movements, payments) hic
// silinmez". Bu tabloda deleted_at YOK.
// Silme istenirse ters hareket eklenir.
return new class extends Migration {
    public function up(): void
    {
        Schema::create('stock_movements', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->foreignUuid('stock_id')->constrained()->restrictOnDelete();
            $table->foreignUuid('drug_id')->constrained()->restrictOnDelete();
            $table->string('movement_type', 32);
            $table->decimal('quantity', 12, 3); // pozitif = giris, negatif = cikis
            $table->decimal('unit_price', 10, 2)->nullable();
            $table->string('batch_number')->nullable();
            $table->date('expiry_date')->nullable();
            $table->string('supplier_name')->nullable();
            $table->foreignUuid('related_medical_record_id')->nullable()->constrained('medical_records')->nullOnDelete();
            // Ters hareket icin self-reference; PG ayni CREATE TABLE'da
            // self-FK problemi cikariyor, FK constraint M3'te ALTER TABLE
            // ile eklenecek. Su an sadece UUID kolonu.
            $table->uuid('related_movement_id')->nullable();
            $table->foreignId('performed_by')->constrained('users')->restrictOnDelete();
            $table->text('notes')->nullable();
            $table->timestampTz('occurred_at');
            $table->timestamps();
            // softDeletes YOK - ledger.

            $table->index(['stock_id', 'occurred_at']);
            $table->index(['drug_id', 'occurred_at']);
            $table->index(['movement_type', 'occurred_at']);
        });

        // movement_type CHECK constraint (PG)
        \DB::statement("ALTER TABLE stock_movements ADD CONSTRAINT chk_movement_type CHECK (movement_type IN ('purchase','usage','transfer_in','transfer_out','adjustment','waste','return'))");
    }

    public function down(): void
    {
        Schema::dropIfExists('stock_movements');
    }
};
