<?php

declare(strict_types=1);

namespace App\Http\Middleware;

use App\Models\Clinic;
use Closure;
use Illuminate\Http\Request;
use PHPOpenSourceSaver\JWTAuth\Facades\JWTAuth;
use Symfony\Component\HttpFoundation\Response;

// M10.1: Premium ozelliklere erisimi kisitlar.
// proje.md §4.2: rota optimizasyonu, SMS portali, fotograf, hastalik haritasi,
// gun sonu PDF, analytics, asi hatirlatma, recete PDF.
// Free tier 402 doner — istemci upgrade ekranina yonlendirir.
class EnsurePremiumClinic
{
    public function handle(Request $request, Closure $next): Response
    {
        $clinicId = JWTAuth::parseToken()->getPayload()->get('clinic_id');

        $clinic = $clinicId ? Clinic::find($clinicId) : null;

        if (! $clinic || ! $clinic->isPremium()) {
            return response()->json([
                'error' => 'premium_required',
                'message' => 'Bu özellik Premium paket gerektirir.',
                'tier' => $clinic?->subscription_tier ?? 'free',
            ], 402);
        }

        return $next($request);
    }
}
