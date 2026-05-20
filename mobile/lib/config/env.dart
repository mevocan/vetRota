// Konfigurasyon — derleme sirasinda --dart-define ile uzerine yazilabilir.
// Ornek: flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
class Env {
  // Varsayilan: http://localhost:8000 + `adb reverse tcp:8000 tcp:8000`.
  // Android emulator'un 10.0.2.2 NAT'i buyuk transferlerde baglantiyi
  // kesebiliyor ("Connection closed while receiving data"); adb reverse
  // emulator localhost:8000 -> host 8000 koprusu kurarak bunu asar (host'a
  // curl ile dogrulanan saglam yol). Gercek cihaz/APK/prod icin
  // --dart-define=API_BASE_URL=https://... ile uzerine yazilir.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  // Marka rengi — CLAUDE.md §5.
  static const primaryColorHex = 0xFF2E7D32;
  static const primaryDarkHex = 0xFF1B5E20;
}
