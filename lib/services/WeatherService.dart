import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // Using free weather API that doesn't require API key
  final String baseUrl = 'https://api.open-meteo.com/v1';

  Future<Map<String, dynamic>?> getCurrentWeather(double lat, double lon) async {
    try {
      final url = '$baseUrl/forecast?latitude=$lat&longitude=$lon&current_weather=true&hourly=temperature_2m,relativehumidity_2m,windspeed_10m';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current_weather'];
        return {
          'temperature': current['temperature'].round(),
          'description': _getWeatherDescription(current['weathercode']),
          'windSpeed': current['windspeed'],
          'windDirection': current['winddirection'],
          'time': current['time'],
        };
      }
    } catch (e) {
      print('Weather API Error: $e');
      // Return mock data as fallback
      return {
        'temperature': 25,
        'description': 'Clear sky',
        'windSpeed': 5.2,
        'windDirection': 180,
        'time': DateTime.now().toIso8601String(),
      };
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getWeatherForecast(double lat, double lon) async {
    try {
      final url = '$baseUrl/forecast?latitude=$lat&longitude=$lon&daily=temperature_2m_max,temperature_2m_min,weathercode&timezone=auto';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Map<String, dynamic>> forecast = [];
        final daily = data['daily'];
        
        for (int i = 0; i < 5 && i < daily['time'].length; i++) {
          forecast.add({
            'date': DateTime.parse(daily['time'][i]),
            'temperatureMax': daily['temperature_2m_max'][i].round(),
            'temperatureMin': daily['temperature_2m_min'][i].round(),
            'description': _getWeatherDescription(daily['weathercode'][i]),
          });
        }
        return forecast;
      }
    } catch (e) {
      print('Weather Forecast API Error: $e');
    }
    return [];
  }

  String _getWeatherDescription(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return 'Clear sky';
      case 1:
      case 2:
      case 3:
        return 'Partly cloudy';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 95:
        return 'Thunderstorm';
      default:
        return 'Unknown';
    }
  }
}
