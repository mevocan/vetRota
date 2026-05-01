<?php

declare(strict_types=1);

namespace App\Models\Concerns;

// Sync kolonlarini Eloquent attribute olarak gun yuzune cikarir.
// Trigger BEFORE UPDATE'de version + last_modified_at'i yazar; bu trait
// sadece cast + fillable bagsizligini saglar.
//
// Sync push servisi `saveQuietly()` + manuel `version++` kullanir
// (sync-api.md §11.10).
trait HasSyncColumns
{
    public function initializeHasSyncColumns(): void
    {
        $this->mergeCasts([
            'version'          => 'integer',
            'last_modified_at' => 'datetime',
        ]);
    }
}
