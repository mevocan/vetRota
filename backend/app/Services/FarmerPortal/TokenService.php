<?php

declare(strict_types=1);

namespace App\Services\FarmerPortal;

use App\Models\Farmer;
use App\Models\FarmerPortalToken;
use Illuminate\Support\Carbon;
use Illuminate\Support\Str;

// M6.2: Çiftçi portal token'larının üretimi/doğrulaması.
// Ham token sadece issue() return değerinde döner; DB'de SHA-256 hash saklanır.
// Scope başına default TTL var (data-model.md §5.7).
class TokenService
{
    /** @var array<string, int> scope -> ttl saat */
    private const TTL_HOURS = [
        'general' => 24 * 365,         // 1 yıl
        'appointment' => 24 * 7,       // 7 gün
        'prescription' => 24 * 30,     // 30 gün
        'vaccination' => 24 * 14,      // 14 gün
        'outbreak_alert' => 72,        // 72 saat
    ];

    public const VALID_SCOPES = [
        'general', 'appointment', 'prescription', 'vaccination', 'outbreak_alert',
    ];

    /**
     * Yeni token üretir; raw token string + DB satırı döner.
     * @return array{raw: string, model: FarmerPortalToken}
     */
    public function issue(
        Farmer $farmer,
        string $scope = 'general',
        ?string $resourceType = null,
        ?string $resourceId = null,
        ?Carbon $expiresAt = null,
    ): array {
        if (!in_array($scope, self::VALID_SCOPES, true)) {
            throw new \InvalidArgumentException("Gecersiz token scope: {$scope}");
        }

        $raw = Str::random(32);
        $hash = hash('sha256', $raw);
        $prefix = substr($raw, 0, 8);
        $expiresAt ??= now()->addHours(self::TTL_HOURS[$scope]);

        $model = FarmerPortalToken::create([
            'farmer_id' => $farmer->id,
            'clinic_id' => $farmer->clinic_id,
            'token_hash' => $hash,
            'token_prefix' => $prefix,
            'scope' => $scope,
            'resource_type' => $resourceType,
            'resource_id' => $resourceId,
            'expires_at' => $expiresAt,
        ]);

        return ['raw' => $raw, 'model' => $model];
    }

    /**
     * Raw token'ı doğrular; geçerliyse model döner, geçersizse null.
     * Geçersizlik nedenleri: bulunamadı, revoke edilmiş, süresi geçmiş.
     */
    public function verify(string $rawToken): ?FarmerPortalToken
    {
        if (strlen($rawToken) < 16) {
            return null;
        }
        $hash = hash('sha256', $rawToken);
        $token = FarmerPortalToken::where('token_hash', $hash)->first();
        if ($token === null) {
            return null;
        }
        if (!$token->isActive()) {
            return null;
        }
        return $token;
    }

    /**
     * Erişim audit alanlarını günceller. IP'yi hash'leyerek saklarız (KVKK).
     */
    public function recordAccess(
        FarmerPortalToken $token,
        ?string $ip = null,
        ?string $userAgent = null,
    ): void {
        $token->forceFill([
            'first_accessed_at' => $token->first_accessed_at ?? now(),
            'last_accessed_at' => now(),
            'access_count' => $token->access_count + 1,
            'last_ip_hash' => $ip ? hash('sha256', $ip) : $token->last_ip_hash,
            'last_user_agent' => $userAgent ? mb_substr($userAgent, 0, 512) : $token->last_user_agent,
        ])->save();
    }

    public function revoke(FarmerPortalToken $token): void
    {
        $token->forceFill(['revoked_at' => now()])->save();
    }
}
