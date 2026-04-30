<?php

declare(strict_types=1);

namespace App\Observers;

use App\Models\Stock;
use App\Models\StockMovement;
use Illuminate\Support\Facades\DB;

// Bir stock_movement insert edildikce stocks.current_quantity'i ve
// turetilmis alanlari (last_purchased_at, earliest_expiry_at) gunceller.
// Ledger ekle-ve-cache-yenile pattern'i.
class StockMovementObserver
{
    public function created(StockMovement $movement): void
    {
        DB::transaction(function () use ($movement): void {
            $stock = Stock::lockForUpdate()->find($movement->stock_id);
            if (!$stock) {
                return;
            }

            $stock->current_quantity = (float) $stock->current_quantity + (float) $movement->quantity;

            if ($movement->movement_type === 'purchase' && $movement->quantity > 0) {
                $stock->last_purchased_at = $movement->occurred_at;
            }

            // earliest_expiry_at: yeni alimin son kullanma tarihi mevcut
            // earliest'tan onceyse guncelle. Cikislarda dokunma.
            if ($movement->expiry_date && $movement->quantity > 0) {
                if ($stock->earliest_expiry_at === null || $movement->expiry_date->lt($stock->earliest_expiry_at)) {
                    $stock->earliest_expiry_at = $movement->expiry_date;
                }
            }

            $stock->save();
        });
    }
}
