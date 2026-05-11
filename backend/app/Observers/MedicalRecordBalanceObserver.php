<?php

declare(strict_types=1);

namespace App\Observers;

use App\Models\MedicalRecord;
use Illuminate\Support\Facades\DB;

// M7.3: Muayene olusunca farmer.balance -= service_fee (borc artirir).
// service_fee 0 ise no-op. Silinen muayene icin ters cevir.
//
// Not: Update'ta service_fee degisirse delta uygulanir.
class MedicalRecordBalanceObserver
{
    public function created(MedicalRecord $mr): void
    {
        $this->applyDelta($mr, -(float) $mr->service_fee);
    }

    public function updated(MedicalRecord $mr): void
    {
        $old = (float) $mr->getOriginal('service_fee');
        $new = (float) $mr->service_fee;
        $delta = -($new - $old);
        if (abs($delta) > 0.001) {
            $this->applyDelta($mr, $delta);
        }
    }

    public function deleted(MedicalRecord $mr): void
    {
        $this->applyDelta($mr, (float) $mr->service_fee);
    }

    public function restored(MedicalRecord $mr): void
    {
        $this->applyDelta($mr, -(float) $mr->service_fee);
    }

    private function applyDelta(MedicalRecord $mr, float $delta): void
    {
        if (abs($delta) < 0.001) {
            return;
        }
        // animal -> farmer iliskisini ucuza al
        $farmerId = DB::table('animals')->where('id', $mr->animal_id)->value('farmer_id');
        if (!$farmerId) {
            return;
        }
        DB::table('farmers')
            ->where('id', $farmerId)
            ->update([
                'balance' => DB::raw("balance + $delta"),
                'updated_at' => now(),
            ]);
    }
}
