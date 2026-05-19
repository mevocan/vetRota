<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Clinic;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use PHPOpenSourceSaver\JWTAuth\Facades\JWTAuth;

// M10.1: Abonelik durumu + upgrade.
// MVP: gercek odeme yok. POST /subscription/upgrade tier'i premium yapar,
// expires_at = now + 30g (aylik) veya 365g (yillik). iyzico/PayTR sonra.
class SubscriptionController extends Controller
{
    public function show(): JsonResponse
    {
        $clinic = $this->clinic();

        return response()->json([
            'tier' => $clinic->subscription_tier,
            'expires_at' => $clinic->subscription_expires_at,
            'is_premium' => $clinic->isPremium(),
            'monthly_price' => 1250,
            'yearly_price' => 12500,
        ]);
    }

    public function upgrade(Request $request): JsonResponse
    {
        $data = $request->validate([
            'period' => ['required', 'in:monthly,yearly'],
        ]);

        $clinic = $this->clinic();

        $now = now();
        $base = ($clinic->isPremium() && $clinic->subscription_expires_at?->isFuture())
            ? $clinic->subscription_expires_at
            : $now;

        $expires = $data['period'] === 'yearly' ? $base->copy()->addYear() : $base->copy()->addMonth();

        $clinic->forceFill([
            'subscription_tier' => Clinic::TIER_PREMIUM,
            'subscription_expires_at' => $expires,
        ])->save();

        return response()->json([
            'tier' => $clinic->subscription_tier,
            'expires_at' => $clinic->subscription_expires_at,
            'is_premium' => true,
            'message' => 'Premium pakete geçildi.',
        ]);
    }

    public function cancel(): JsonResponse
    {
        $clinic = $this->clinic();

        $clinic->forceFill([
            'subscription_tier' => Clinic::TIER_FREE,
            'subscription_expires_at' => null,
        ])->save();

        return response()->json([
            'tier' => Clinic::TIER_FREE,
            'is_premium' => false,
            'message' => 'Free pakete dönüldü.',
        ]);
    }

    private function clinic(): Clinic
    {
        $clinicId = JWTAuth::parseToken()->getPayload()->get('clinic_id');
        abort_unless($clinicId, 403, 'clinic_id yok.');

        return Clinic::findOrFail($clinicId);
    }
}
