// M7.1: Tur bazli gebelik suresi. Server'daki PregnancyService ile
// ayni degerler — UI form'da expected_birth_date'i pre-fill ederken
// kullanilir. Sunucu push'tan sonra dogru degeri zaten yazar.
class PregnancyHelper {
  static const Map<String, int> _gestationDays = {
    'cattle': 283,
    'sheep': 150,
    'goat': 150,
    'horse': 340,
  };

  static int gestationDaysFor(String species) =>
      _gestationDays[species] ?? 283;

  static DateTime calculateBirthDate(String species, DateTime startedAt) =>
      startedAt.add(Duration(days: gestationDaysFor(species)));
}
