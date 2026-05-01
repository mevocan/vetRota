<?php

declare(strict_types=1);

namespace App\Services\Sync\TableProcessors;

use App\Models\Drug;
use App\Models\Stock;

// Stock'ta `current_quantity` turetilmis alandir (sync-api.md §8.4):
// stock_movements toplamindan hesaplanir. Client push'unda current_quantity
// gelse bile applyUpdate fillable'i araciligiyla yazilir; Observer M3.6'da
// devreye girince stock_movements toplamiyla overwrite edilir. MVP'de
// dogrudan kabul ediyoruz.
class StockProcessor extends AbstractTableProcessor
{
    protected function tableName(): string { return 'stocks'; }
    protected function modelClass(): string { return Stock::class; }

    protected function fillable(): array
    {
        return [
            'clinic_id', 'drug_id', 'current_quantity', 'critical_threshold',
            'reorder_quantity', 'last_purchased_at', 'earliest_expiry_at',
        ];
    }

    protected function validateData(array $data): ?string
    {
        if (empty($data['drug_id'])) return 'drug_id zorunlu';
        if (!Drug::where('id', $data['drug_id'])->exists()) {
            return 'drug_id bulunamadi';
        }
        return null;
    }
}
