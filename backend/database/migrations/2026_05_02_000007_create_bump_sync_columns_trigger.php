<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

// M3.1: PostgreSQL BEFORE UPDATE trigger'i her sync tablosuna baglar.
// Normal API yazimlari (M2 endpoint'leri, web panel) trigger'dan gecer
// ve version+last_modified_at otomatik artar. Sync push servisi
// `saveQuietly()` veya `DB::update()` ile trigger'i bypass eder ve
// version'u manuel yonetir (sync-api.md §11.10 uyarisi).
//
// data-model.md §2.4 referansi.
return new class extends Migration {
    private const SYNC_TABLES = [
        'villages',
        'farmers',
        'animals',
        'appointments',
        'medical_records',
        'medical_record_drugs',
        'drugs',
        'stocks',
        'stock_movements',
    ];

    public function up(): void
    {
        DB::statement(<<<'SQL'
            CREATE OR REPLACE FUNCTION bump_sync_columns()
            RETURNS TRIGGER AS $$
            BEGIN
                NEW.version = OLD.version + 1;
                NEW.last_modified_at = now();
                NEW.updated_at = now();
                RETURN NEW;
            END;
            $$ LANGUAGE plpgsql;
        SQL);

        foreach (self::SYNC_TABLES as $table) {
            $triggerName = "{$table}_bump_sync";
            DB::statement("DROP TRIGGER IF EXISTS {$triggerName} ON {$table}");
            DB::statement(<<<SQL
                CREATE TRIGGER {$triggerName}
                BEFORE UPDATE ON {$table}
                FOR EACH ROW
                EXECUTE FUNCTION bump_sync_columns();
            SQL);
        }
    }

    public function down(): void
    {
        foreach (self::SYNC_TABLES as $table) {
            DB::statement("DROP TRIGGER IF EXISTS {$table}_bump_sync ON {$table}");
        }
        DB::statement('DROP FUNCTION IF EXISTS bump_sync_columns()');
    }
};
