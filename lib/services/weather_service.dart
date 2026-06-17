import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // Using Open-Meteo - free, no API key needed
  Future<Map<String, dynamic>?> getWeather(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,weathercode,windspeed_10m&timezone=auto',
      );
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final current = data['current'];
        return {
          'temp': current['temperature_2m'],
          'windspeed': current['windspeed_10m'],
          'description': _codeToDescription(current['weathercode']),
          'icon': _codeToIcon(current['weathercode']),
        };
      }
    } catch (_) {}
    return null;
  }

  String _codeToDescription(int code) {
    if (code == 0) return 'שמיים בהירים';
    if (code <= 3) return 'מעונן חלקית';
    if (code <= 48) return 'ערפל';
    if (code <= 67) return 'גשם';
    if (code <= 77) return 'שלג';
    if (code <= 82) return 'מקלחות גשם';
    return 'סופת רעמים';
  }

  String _codeToIcon(int code) {
    if (code == 0) return '☀️';
    if (code <= 3) return '⛅';
    if (code <= 48) return '🌫️';
    if (code <= 67) return '🌧️';
    if (code <= 77) return '❄️';
    if (code <= 82) return '🌦️';
    return '⛈️';
  }
}
