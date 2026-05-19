<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    public function login(Request $request): JsonResponse
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
            'device_id' => ['sometimes', 'uuid'],
        ]);

        $deviceId = $credentials['device_id']
            ?? $request->header('X-Device-Id');

        // M3.2: device_id JWT claim olarak gomulur (sync-api.md §3).
        // Mobile login eder, web etmeyebilir — sync endpoint'leri zorunlu kilar.
        $guard = Auth::guard('api');
        if ($deviceId) {
            $guard->claims(['device_id' => $deviceId]);
        }

        $token = $guard->attempt([
            'email' => $credentials['email'],
            'password' => $credentials['password'],
        ]);

        if (! $token) {
            return response()->json([
                'message' => 'E-posta veya şifre hatalı.',
            ], 401);
        }

        // Mobile cihazlarda son login eden device_id'yi user'a not et
        // (audit/raporlama icin; sync zorunlulugu degil — JWT zaten claim tasiyor).
        if ($deviceId) {
            $user = Auth::guard('api')->user();
            $user->forceFill(['device_id' => $deviceId])->saveQuietly();
        }

        return $this->respondWithToken($token);
    }

    public function me(): JsonResponse
    {
        $user = Auth::guard('api')->user();
        $payload = Auth::guard('api')->payload();

        // M10.1: tier UI rozetinde + gating'de kullanilir.
        $clinic = $user->clinic;

        return response()->json([
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role,
            'clinic_id' => $payload->get('clinic_id'),
            'device_id' => $payload->get('device_id'),
            'subscription_tier' => $clinic?->subscription_tier ?? 'free',
            'subscription_expires_at' => $clinic?->subscription_expires_at,
            'is_premium' => (bool) $clinic?->isPremium(),
        ]);
    }

    public function logout(): JsonResponse
    {
        Auth::guard('api')->logout();

        return response()->json(['message' => 'Çıkış yapıldı.']);
    }

    public function refresh(): JsonResponse
    {
        return $this->respondWithToken(Auth::guard('api')->refresh());
    }

    private function respondWithToken(string $token): JsonResponse
    {
        return response()->json([
            'access_token' => $token,
            'token_type' => 'bearer',
            'expires_in' => Auth::guard('api')->factory()->getTTL() * 60,
        ]);
    }
}
