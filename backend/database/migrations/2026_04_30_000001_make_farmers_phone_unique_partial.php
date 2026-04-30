<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

// Partial unique index: telefon yalnizca soft-delete edilmemis kayitlar arasinda essiz olsun.
// Boylece silinen bir ciftcinin telefonu serbest kalir, ayni telefonla yeni ciftci eklenebilir.
return new class extends Migration {
    public function up(): void
    {
        DB::statement('ALTER TABLE farmers DROP CONSTRAINT IF EXISTS farmers_phone_unique');
        DB::statement('CREATE UNIQUE INDEX farmers_phone_unique_active ON farmers (phone) WHERE deleted_at IS NULL');
    }

    public function down(): void
    {
        DB::statement('DROP INDEX IF EXISTS farmers_phone_unique_active');
        DB::statement('ALTER TABLE farmers ADD CONSTRAINT farmers_phone_unique UNIQUE (phone)');
    }
};
