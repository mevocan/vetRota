<?php

declare(strict_types=1);

namespace App\Sms;

// M6.3: Basit SMS template render — `{{ key }}` placeholder'larını
// substitute eder. Blade gibi karmaşık template'e gerek yok; SMS kısa
// metin, runtime'da güvenli string replace yeterli.
class TemplateRenderer
{
    /**
     * @param array<string, string|int|float> $vars
     */
    public static function render(string $template, array $vars): string
    {
        return preg_replace_callback(
            '/\{\{\s*(\w+)\s*\}\}/u',
            function (array $m) use ($vars): string {
                $key = $m[1];
                return isset($vars[$key]) ? (string) $vars[$key] : $m[0];
            },
            $template,
        ) ?? $template;
    }
}
