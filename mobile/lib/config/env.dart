// Konfigurasyon — derleme sirasinda --dart-define ile uzerine yazilabilir.
// Ornek: flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
class Env {
  // Android emulator -> host machine icin 10.0.2.2; iOS simulator
  // localhost'u dogrudan kullanabilir; gercek cihazda LAN IP gerekir.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  // Marka rengi — CLAUDE.md §5.
  static const primaryColorHex = 0xFF2E7D32;
  static const primaryDarkHex = 0xFF1B5E20;
}
