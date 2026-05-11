<?php

declare(strict_types=1);

namespace App\Observers;

use App\Models\Payment;
use Illuminate\Support\Facades\DB;

// M7.3: Odeme yapildiginda farmer.balance += amount (alacak siler).
// Soft delete'te ters cevirir. Update edilirse delta uygulanir.
class PaymentObserver
{
    public function created(Payment $payment): void
    {
        $this->applyDelta($payment->farmer_id, (float) $payment->amount);
    }

    public function updated(Payment $payment): void
    {
        $old = (float) $payment->getOriginal('amount');
        $new = (float) $payment->amount;
        $delta = $new - $old;
        if (abs($delta) > 0.001) {
            $this->applyDelta($payment->farmer_id, $delta);
        }
    }

    public function deleted(Payment $payment): void
    {
        // Soft delete'te de ters cevir — gercek silme olmasa bile
        // balance domain'de odeme silindi gibi davranmali.
        $this->applyDelta($payment->farmer_id, -(float) $payment->amount);
    }

    public function restored(Payment $payment): void
    {
        $this->applyDelta($payment->farmer_id, (float) $payment->amount);
    }

    private function applyDelta(string $farmerId, float $delta): void
    {
        DB::table('farmers')
            ->where('id', $farmerId)
            ->update([
                'balance' => DB::raw("balance + $delta"),
                'updated_at' => now(),
            ]);
    }
}
