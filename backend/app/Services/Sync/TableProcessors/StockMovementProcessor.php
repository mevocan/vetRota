<?php

declare(strict_types=1);

namespace App\Services\Sync\TableProcessors;

use App\Enums\Sync\SyncResult;
use App\Models\Drug;
use App\Models\Stock;
use App\Models\StockMovement;
use Illuminate\Database\Eloquent\Model;

// sync-api.md §8.3: Ledger — additive merge.
// upsert: her zaman INSERT (client UUID urettigi icin cakisma imkansiz);
//         existing kayit + farkli expected_version olsa bile reddedilir
//         (resolveAdditive). Pratikte client ayni id ile 2. kez upsert
//         atmaz; atarsa 'additive_no_update' rejected donusu.
// delete: REJECTED (ledger silinmez).
class StockMovementProcessor extends AbstractTableProcessor
{
    protected function tableName(): string { return 'stock_movements'; }
    protected function modelClass(): string { return StockMovement::class; }

    protected function fillable(): array
    {
        return [
            'clinic_id', 'stock_id', 'drug_id', 'movement_type', 'quantity',
            'unit_price', 'batch_number', 'expiry_date', 'supplier_name',
            'related_medical_record_id', 'related_movement_id',
            'performed_by', 'notes', 'occurred_at',
        ];
    }

    protected function validateData(array $data): ?string
    {
        if (empty($data['stock_id'])) return 'stock_id zorunlu';
        if (empty($data['drug_id'])) return 'drug_id zorunlu';
        if (empty($data['movement_type'])) return 'movement_type zorunlu';
        if (!isset($data['quantity'])) return 'quantity zorunlu';
        if (empty($data['occurred_at'])) return 'occurred_at zorunlu';

        $stock = Stock::find($data['stock_id']);
        if (!$stock || $stock->clinic_id !== $this->user->clinic_id) {
            return 'stock bulunamadi veya baska klinige ait';
        }

        if (!Drug::where('id', $data['drug_id'])->exists()) {
            return 'drug_id bulunamadi';
        }

        $valid = ['purchase', 'usage', 'transfer_in', 'transfer_out',
                  'adjustment', 'waste', 'return'];
        if (!in_array($data['movement_type'], $valid, true)) {
            return 'gecersiz movement_type';
        }

        return null;
    }

    /**
     * StockMovement INSERT'te performed_by zorunlu (FK NOT NULL).
     * Client gondermezse otomatik current user'i kullan.
     */
    protected function insertNew(array $record): array
    {
        if (empty($record['data']['performed_by'])) {
            $record['data']['performed_by'] = $this->user->id;
        }
        return parent::insertNew($record);
    }
}
