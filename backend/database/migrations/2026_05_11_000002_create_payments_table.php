<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

// M7.3: Borc/odeme ledger. CLAUDE.md kurali: payments asla silinmez,
// ters hareket olarak duzeltilir (additive merge — sync-api.md §7).
// farmers.balance trigger ile guncellenir.
return new class extends Migration {
    public function up(): void
    {
        Schema::create('payments', function (Blueprint $table): void {
            $table->uuid('id')->primary();
            $table->uuid('clinic_id');
            $table->uuid('farmer_id');
            $table->bigInteger('vet_id')->nullable();
            $table->decimal('amount', 10, 2); // pozitif = odeme (alacak), negatif = iade
            $table->string('method', 32)->default('cash'); // cash, transfer, other
            $table->timestampTz('paid_at')->useCurrent();
            $table->text('notes')->nullable();

            // Sync kolonlari (sync-api.md sablonu)
            $table->bigInteger('version')->default(1);
            $table->timestampTz('last_modified_at')->nullable();
            $table->uuid('origin_device_id')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->foreign('clinic_id')->references('id')->on('clinics');
            $table->foreign('farmer_id')->references('id')->on('farmers');
            $table->foreign('vet_id')->references('id')->on('users');

            $table->index(['clinic_id', 'farmer_id']);
            $table->index(['clinic_id', 'paid_at']);
        });

        // last_modified_at trigger (sync icin standart)
        DB::statement('
            CREATE OR REPLACE FUNCTION set_payments_last_modified()
            RETURNS TRIGGER AS $$
            BEGIN
                NEW.last_modified_at = NOW();
                IF TG_OP = \'UPDATE\' THEN
                    NEW.version = OLD.version + 1;
                END IF;
                RETURN NEW;
            END;
            $$ LANGUAGE plpgsql;
        ');
        DB::statement('
            CREATE TRIGGER payments_last_modified
            BEFORE INSERT OR UPDATE ON payments
            FOR EACH ROW EXECUTE FUNCTION set_payments_last_modified();
        ');
    }

    public function down(): void
    {
        DB::statement('DROP TRIGGER IF EXISTS payments_last_modified ON payments');
        DB::statement('DROP FUNCTION IF EXISTS set_payments_last_modified()');
        Schema::dropIfExists('payments');
    }
};
