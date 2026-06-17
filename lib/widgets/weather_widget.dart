import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  final _weatherService = WeatherService();
  Map<String, dynamic>? _weather;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // Default: Tel Aviv coordinates
    _weatherService.getWeather(32.0853, 34.7818).then((data) {
      if (mounted) setState(() { _weather = data; _loading = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox(height: 50, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    if (_weather == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF43A047), Color(0xFF1DE9B6)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(_weather!['icon'], style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('מזג אוויר בתל אביב', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text('${_weather!['temp']}°C  •  ${_weather!['description']}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('רוח: ${_weather!['windspeed']} קמ"ש',
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
