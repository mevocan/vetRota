<?php

declare(strict_types=1);

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Tymon\JWTAuth\Facades\JWTAuth;

// sync-api.md §11.3: Sync endpoint'lerinde JWT'deki device_id ile
// X-Device-Id header'inin (veya body'nin) eslesmesini zorunlu kilar.
// Eslesmiyorsa 403 doner. JWT'de device_id yok ise 403.
//
// Mobile sync icin zorunlu; web login akisinda bu middleware uygulanmaz
// (sync endpoint'lerine bagli).
class EnsureDeviceMatchesJwt
{
    public function handle(Request $request, Closure $next): Response
    {
        $payload = JWTAuth::parseToken()->getPayload();
        $jwtDeviceId = $payload->get('device_id');

        if (! $jwtDeviceId) {
            return response()->json([
                'error' => 'device_id_required',
                'message' => 'Sync icin login sirasinda device_id gonderilmedi.',
            ], 403);
        }

        $headerDeviceId = $request->header('X-Device-Id')
            ?? $request->input('device_id');

        if ($headerDeviceId && $headerDeviceId !== $jwtDeviceId) {
            return response()->json([
                'error' => 'device_mismatch',
                'message' => 'Cihaz kimligi token ile eslesmiyor.',
            ], 403);
        }

        $request->attributes->set('device_id', $jwtDeviceId);
        $request->attributes->set('clinic_id', $payload->get('clinic_id'));

        return $next($request);
    }
}
