<?php

declare(strict_types=1);

// M6.1: SMS sağlayıcı driver konfigürasyonu.
// MVP'de "log" driver kullanılır; gerçek SMS gitmez, Laravel logger'a yazılır.
// Production'da "netgsm" veya benzeri eklenir; .env'den seçilir.
return [
    'default' => env('SMS_DRIVER', 'log'),

    'sender_id' => env('SMS_SENDER_ID', 'VETROTA'),

    // Çiftçi portal link'inde kullanılacak base URL (SMS gövdesinde).
    'portal_base_url' => env('SMS_PORTAL_BASE_URL', 'http://localhost:3000'),

    'drivers' => [
        'log' => [
            'channel' => env('SMS_LOG_CHANNEL', 'stack'),
        ],

        // 'netgsm' => [
        //     'username' => env('NETGSM_USERNAME'),
        //     'password' => env('NETGSM_PASSWORD'),
        //     'header' => env('NETGSM_HEADER'),
        // ],
    ],
];
