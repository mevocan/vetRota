<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// M7.1: Gebelik takibi.
// is_pregnant zaten var; tarih bilgisi ve not eklendi.
// expected_birth_date servis katmaninda tur bazli gebelik suresi
// ile hesaplaniyor (cattle=283, sheep/goat=150, horse=340 gun).
return new class extends Migration {
    public function up(): void
    {
        Schema::table('animals', function (Blueprint $table): void {
            $table->date('pregnancy_started_at')->nullable()->after('is_pregnant');
            $table->date('expected_birth_date')->nullable()->after('pregnancy_started_at');
            $table->text('pregnancy_notes')->nullable()->after('expected_birth_date');
        });
    }

    public function down(): void
    {
        Schema::table('animals', function (Blueprint $table): void {
            $table->dropColumn(['pregnancy_started_at', 'expected_birth_date', 'pregnancy_notes']);
        });
    }
};
