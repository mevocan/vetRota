<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

// M3 test fix: Eski trigger sadece BEFORE UPDATE'di, dolayisiyla M2
// controller'lari uzerinden olusan kayitlarda last_modified_at NULL
// kaliyordu ve SyncPullService gorunmuyordu (WHERE last_modified_at > since
// NULL'i eler).
//
// Cozum: Fonksiyonu TG_OP'a duyarli hale getir, BEFORE INSERT trigger'i
// da ekle. INSERT yolu NULL-safe: sync push manuel set ettigi icin
// onun degerlerine dokunmaz. UPDATE yolu eski davranis.
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
                IF TG_OP = 'INSERT' THEN
                    IF NEW.version IS NULL THEN
                        NEW.version = 1;
                    END IF;
                    IF NEW.last_modified_at IS NULL THEN
                        NEW.last_modified_at = now();
                    END IF;
                ELSE
                    NEW.version = OLD.version + 1;
                    NEW.last_modified_at = now();
                    NEW.updated_at = now();
                END IF;
                RETURN NEW;
            END;
            $$ LANGUAGE plpgsql;
        SQL);

        foreach (self::SYNC_TABLES as $table) {
            $insertTrigger = "{$table}_bump_sync_insert";
            DB::statement("DROP TRIGGER IF EXISTS {$insertTrigger} ON {$table}");
            DB::statement(<<<SQL
                CREATE TRIGGER {$insertTrigger}
                BEFORE INSERT ON {$table}
                FOR EACH ROW
                EXECUTE FUNCTION bump_sync_columns();
            SQL);
        }
    }

    public function down(): void
    {
        foreach (self::SYNC_TABLES as $table) {
            DB::statement("DROP TRIGGER IF EXISTS {$table}_bump_sync_insert ON {$table}");
        }

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
    }
};
