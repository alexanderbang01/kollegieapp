import 'api_service.dart';

class FoodplanService {
  // Hent madplan for en specifik uge
  static Future<Map<String, dynamic>> getFoodplan({
    int? week,
    int? year,
  }) async {
    Map<String, String> queryParams = {};

    if (week != null) {
      queryParams['week'] = week.toString();
    }

    if (year != null) {
      queryParams['year'] = year.toString();
    }

    return await ApiService.get(
      endpoint: '/foodplan/get_foodplan.php',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
  }

  // Hent madplan for nuværende uge
  static Future<Map<String, dynamic>> getCurrentWeekFoodplan() async {
    final now = DateTime.now();
    final currentWeek = _getWeekNumber(now);
    final currentYear = now.year;

    return await getFoodplan(week: currentWeek, year: currentYear);
  }

  // Hjælpefunktion til at beregne ugenummer
  static int _getWeekNumber(DateTime date) {
    // Beregn ugenummer baseret på ISO 8601 standard
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    final firstMonday = DateTime(date.year, 1, 1);
    final firstMondayWeekday = firstMonday.weekday;

    // Juster for at finde første mandag
    final daysToFirstMonday = firstMondayWeekday <= DateTime.monday
        ? DateTime.monday - firstMondayWeekday
        : 7 - firstMondayWeekday + DateTime.monday;

    final firstMondayOfYear = firstMonday.add(
      Duration(days: daysToFirstMonday),
    );

    if (date.isBefore(firstMondayOfYear)) {
      // Hvis datoen er før årets første mandag, tilhører den sidste uge af forrige år
      return _getWeekNumber(DateTime(date.year - 1, 12, 31));
    }

    final weekNumber =
        ((date.difference(firstMondayOfYear).inDays) / 7).floor() + 1;

    // Håndter hvis ugenummeret er større end 52/53
    if (weekNumber > 52) {
      final lastDayOfYear = DateTime(date.year, 12, 31);
      final lastWeekOfYear = _getWeekNumber(lastDayOfYear);
      if (weekNumber > lastWeekOfYear) {
        return 1; // Første uge af næste år
      }
    }

    return weekNumber;
  }

  // Hjælpefunktion til at få ugenummer for en bestemt dato (simplificeret)
  static int getSimpleWeekNumber(DateTime date) {
    // Enklere beregning af ugenummer
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }
}
