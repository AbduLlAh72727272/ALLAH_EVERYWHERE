import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:math' as math;

class PrayerService {
  static const String _baseUrl = 'https://api.aladhan.com/v1';
  static const String _prayerTimesKey = 'prayer_times';
  static const String _locationKey = 'user_location';
  static const String _notificationsKey = 'prayer_notifications';
  static const String _methodKey = 'calculation_method';
  static const String _qiblaKey = 'qibla_direction';
  
  static FlutterLocalNotificationsPlugin? _notificationsPlugin;

  // Available calculation methods
  static const Map<int, String> calculationMethods = {
    1: 'University of Islamic Sciences, Karachi',
    2: 'Islamic Society of North America (ISNA)',
    3: 'Muslim World League (MWL)',
    4: 'Umm al-Qura, Makkah',
    5: 'Egyptian General Authority of Survey',
    7: 'Institute of Geophysics, University of Tehran',
    8: 'Gulf Region',
    9: 'Kuwait',
    10: 'Qatar',
    11: 'Majlis Ugama Islam Singapura, Singapore',
    12: 'Union Organization Islamic de France',
    13: 'Diyanet İşleri Başkanlığı, Turkey',
    14: 'Spiritual Administration of Muslims of Russia',
  };

  // Prayer names in order
  static const List<String> prayerNames = [
    'Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Sunset', 'Maghrib', 'Isha'
  ];

  // Initialize notification service
  static Future<void> initializeNotifications() async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    
    await _notificationsPlugin!.initialize(initializationSettings);
    
    // Request notification permissions
    await Permission.notification.request();
  }

  // Get current location
  static Future<Position?> getCurrentLocation() async {
    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      );

      // Save location to preferences
      await _saveLocation(position);
      
      return position;
    } catch (e) {
      print('Error getting location: $e');
      return await _getSavedLocation();
    }
  }

  // Get address from coordinates
  static Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.locality}, ${place.country}';
      }
    } catch (e) {
      print('Error getting address: $e');
    }
    return 'Unknown Location';
  }

  // Get prayer times for a specific date and location
  static Future<Map<String, dynamic>?> getPrayerTimes({
    required double latitude,
    required double longitude,
    DateTime? date,
    int method = 2, // ISNA by default
  }) async {
    try {
      date ??= DateTime.now();
      final dateString = '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
      
      final url = '$_baseUrl/timings/$dateString?latitude=$latitude&longitude=$longitude&method=$method';
      
      final response = await http.get(Uri.parse(url)).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200) {
          final timings = data['data']['timings'];
          final meta = data['data']['meta'];
          
          // Clean up and format prayer times
          Map<String, String> prayerTimes = {};
          prayerNames.forEach((prayer) {
            if (timings[prayer] != null) {
              prayerTimes[prayer] = _formatTime(timings[prayer]);
            }
          });
          
          final result = {
            'timings': prayerTimes,
            'date': data['data']['date'],
            'meta': meta,
          };
          
          // Cache the prayer times
          await _cachePrayerTimes(result);
          
          return result;
        }
      }
      
      // Return cached data if API fails
      return await _getCachedPrayerTimes();
    } catch (e) {
      print('Error fetching prayer times: $e');
      return await _getCachedPrayerTimes();
    }
  }

  // Get prayer times for current location
  static Future<Map<String, dynamic>?> getCurrentLocationPrayerTimes() async {
    final position = await getCurrentLocation();
    if (position != null) {
      final method = await getCalculationMethod();
      return await getPrayerTimes(
        latitude: position.latitude,
        longitude: position.longitude,
        method: method,
      );
    }
    return null;
  }

  // Calculate Qibla direction
  static Future<double> calculateQiblaDirection({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Kaaba coordinates
      const double kaabaLat = 21.4224779;
      const double kaabaLng = 39.8251832;
      
      // Convert to radians
      final lat1 = latitude * (math.pi / 180);
      final lng1 = longitude * (math.pi / 180);
      final lat2 = kaabaLat * (math.pi / 180);
      final lng2 = kaabaLng * (math.pi / 180);
      
      final dLng = lng2 - lng1;
      
      final y = math.sin(dLng) * math.cos(lat2);
      final x = math.cos(lat1) * math.sin(lat2) - 
                math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
      
      double bearing = math.atan2(y, x);
      bearing = bearing * (180 / math.pi);
      bearing = (bearing + 360) % 360;
      
      // Cache the direction
      await _cacheQiblaDirection(bearing);
      
      return bearing;
    } catch (e) {
      print('Error calculating Qibla direction: $e');
      return await _getCachedQiblaDirection();
    }
  }

  // Get Qibla direction for current location
  static Future<double> getCurrentLocationQiblaDirection() async {
    final position = await getCurrentLocation();
    if (position != null) {
      return await calculateQiblaDirection(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    }
    return 0.0;
  }

  // Schedule prayer notifications
  static Future<void> schedulePrayerNotifications(Map<String, String> prayerTimes) async {
    if (_notificationsPlugin == null) {
      await initializeNotifications();
    }

    // Cancel existing notifications
    await _notificationsPlugin!.cancelAll();

    final now = DateTime.now();
    int notificationId = 1;

    for (String prayer in ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
      if (prayerTimes.containsKey(prayer)) {
        final prayerTime = _parseTime(prayerTimes[prayer]!);
        final scheduledDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          prayerTime.hour,
          prayerTime.minute,
        );

        // If time has passed today, schedule for tomorrow
        final finalDateTime = scheduledDateTime.isBefore(now)
            ? scheduledDateTime.add(Duration(days: 1))
            : scheduledDateTime;

        await _scheduleNotification(
          notificationId++,
          '$prayer Prayer Time',
          'It\'s time for $prayer prayer. May Allah accept your prayers.',
          finalDateTime,
        );

        // Schedule reminder 15 minutes before
        final reminderDateTime = finalDateTime.subtract(Duration(minutes: 15));
        if (reminderDateTime.isAfter(now)) {
          await _scheduleNotification(
            notificationId++,
            '$prayer Prayer Reminder',
            '$prayer prayer will begin in 15 minutes.',
            reminderDateTime,
          );
        }
      }
    }
  }

  // Get next prayer information
  static Map<String, dynamic>? getNextPrayer(Map<String, String> prayerTimes) {
    final now = DateTime.now();
    final currentTime = TimeOfDay.now();

    for (String prayer in ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
      if (prayerTimes.containsKey(prayer)) {
        final prayerTime = _parseTime(prayerTimes[prayer]!);
        
        if (_isTimeAfter(prayerTime, currentTime)) {
          final prayerDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            prayerTime.hour,
            prayerTime.minute,
          );
          
          return {
            'name': prayer,
            'time': prayerTimes[prayer],
            'timeRemaining': prayerDateTime.difference(now),
          };
        }
      }
    }

    // If no prayer found for today, return Fajr for tomorrow
    if (prayerTimes.containsKey('Fajr')) {
      final fajrTime = _parseTime(prayerTimes['Fajr']!);
      final fajrDateTime = DateTime(
        now.year,
        now.month,
        now.day + 1,
        fajrTime.hour,
        fajrTime.minute,
      );
      
      return {
        'name': 'Fajr',
        'time': prayerTimes['Fajr'],
        'timeRemaining': fajrDateTime.difference(now),
      };
    }

    return null;
  }

  // Get monthly prayer times
  static Future<List<Map<String, dynamic>>> getMonthlyPrayerTimes({
    required double latitude,
    required double longitude,
    DateTime? month,
    int method = 2,
  }) async {
    try {
      month ??= DateTime.now();
      final monthString = '${month.month.toString().padLeft(2, '0')}-${month.year}';
      
      final url = '$_baseUrl/calendar/$monthString?latitude=$latitude&longitude=$longitude&method=$method';
      
      final response = await http.get(Uri.parse(url)).timeout(Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200) {
          List<Map<String, dynamic>> monthlyData = [];
          
          for (var dayData in data['data']) {
            final timings = dayData['timings'];
            Map<String, String> prayerTimes = {};
            
            prayerNames.forEach((prayer) {
              if (timings[prayer] != null) {
                prayerTimes[prayer] = _formatTime(timings[prayer]);
              }
            });
            
            monthlyData.add({
              'date': dayData['date'],
              'timings': prayerTimes,
            });
          }
          
          return monthlyData;
        }
      }
    } catch (e) {
      print('Error fetching monthly prayer times: $e');
    }
    
    return [];
  }

  // Preferences management
  static Future<void> setCalculationMethod(int method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_methodKey, method);
  }

  static Future<int> getCalculationMethod() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_methodKey) ?? 2; // Default to ISNA
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }

  static Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true;
  }

  // Helper methods
  static String _formatTime(String time) {
    // Remove timezone and seconds if present
    time = time.split(' ')[0]; // Remove timezone
    final parts = time.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }
    return time;
  }

  static TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  static bool _isTimeAfter(TimeOfDay time1, TimeOfDay time2) {
    return time1.hour > time2.hour || 
           (time1.hour == time2.hour && time1.minute > time2.minute);
  }

  static Future<void> _scheduleNotification(
    int id,
    String title,
    String body,
    DateTime scheduledDateTime,
  ) async {
    await _notificationsPlugin!.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDateTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_channel',
          'Prayer Notifications',
          channelDescription: 'Notifications for prayer times',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> _cachePrayerTimes(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prayerTimesKey, json.encode(data));
  }

  static Future<Map<String, dynamic>?> _getCachedPrayerTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_prayerTimesKey);
    if (cached != null) {
      return json.decode(cached);
    }
    return null;
  }

  static Future<void> _saveLocation(Position position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_locationKey, json.encode({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }));
  }

  static Future<Position?> _getSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_locationKey);
    if (saved != null) {
      final data = json.decode(saved);
      return Position(
        latitude: data['latitude'],
        longitude: data['longitude'],
        timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp']),
        accuracy: 0.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
    }
    return null;
  }

  static Future<void> _cacheQiblaDirection(double direction) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_qiblaKey, direction);
  }

  static Future<double> _getCachedQiblaDirection() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_qiblaKey) ?? 0.0;
  }

  // Get Islamic date
  static Future<Map<String, dynamic>?> getIslamicDate() async {
    try {
      final now = DateTime.now();
      final dateString = '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
      
      final url = '$_baseUrl/gToH/$dateString';
      final response = await http.get(Uri.parse(url)).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200) {
          return data['data']['hijri'];
        }
      }
    } catch (e) {
      print('Error fetching Islamic date: $e');
    }
    return null;
  }

  // Check if it's prayer time
  static bool isPrayerTime(String currentTime, String prayerTime) {
    final current = _parseTime(currentTime);
    final prayer = _parseTime(prayerTime);
    
    return current.hour == prayer.hour && current.minute == prayer.minute;
  }

  // Get prayer time status
  static String getPrayerStatus(Map<String, String> prayerTimes) {
    final now = TimeOfDay.now();
    
    for (int i = 0; i < prayerNames.length - 1; i++) {
      final currentPrayer = prayerNames[i];
      final nextPrayer = prayerNames[i + 1];
      
      if (prayerTimes.containsKey(currentPrayer) && prayerTimes.containsKey(nextPrayer)) {
        final currentTime = _parseTime(prayerTimes[currentPrayer]!);
        final nextTime = _parseTime(prayerTimes[nextPrayer]!);
        
        if (_isTimeAfter(now, currentTime) && !_isTimeAfter(now, nextTime)) {
          return 'It is time for $currentPrayer prayer';
        }
      }
    }
    
    return 'Prayer time passed';
  }
}