import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../utils/utils/constraints/api_constants.dart';

class MosqueService {
  
  Future<List<Map<String, dynamic>>> getNearbyMosques({
    double? latitude,
    double? longitude,
    int radius = 5000, // 5km radius
  }) async {
    try {
      // Get current location if not provided
      if (latitude == null || longitude == null) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        latitude = position.latitude;
        longitude = position.longitude;
      }

      // Check if API key is configured
      if (ApiConstant.googlePlacesApiKey == "YOUR_GOOGLE_PLACES_API_KEY_HERE") {
        print('Google Places API key not configured, using fallback data');
        return _getFallbackMosques();
      }

      final String url = 
          '${ApiConstant.googlePlacesBase}/nearbysearch/json?'
          'location=$latitude,$longitude&'
          'radius=$radius&'
          'type=mosque&'
          'key=${ApiConstant.googlePlacesApiKey}';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          List<Map<String, dynamic>> mosques = [];
          
          for (var place in data['results']) {
            mosques.add({
              'id': place['place_id'],
              'name': place['name'],
              'vicinity': place['vicinity'],
              'rating': place['rating']?.toDouble() ?? 0.0,
              'user_ratings_total': place['user_ratings_total'] ?? 0,
              'latitude': place['geometry']['location']['lat'],
              'longitude': place['geometry']['location']['lng'],
              'photo_reference': place['photos']?[0]?['photo_reference'],
              'is_open': place['opening_hours']?['open_now'] ?? true,
              'price_level': place['price_level'] ?? 0,
            });
          }
          
          return mosques;
        }
      }
    } catch (e) {
      print('Mosque API Error: $e');
    }
    
    // Fallback to local data
    return _getFallbackMosques();
  }

  List<Map<String, dynamic>> _getFallbackMosques() {
    return [
      {
        'id': 'faisal_mosque',
        'name': 'Faisal Mosque',
        'vicinity': 'Islamabad, Pakistan',
        'rating': 4.7,
        'user_ratings_total': 15000,
        'latitude': 33.7294,
        'longitude': 73.0376,
        'photo_reference': null,
        'is_open': true,
        'price_level': 0,
      },
      {
        'id': 'badshahi_mosque',
        'name': 'Badshahi Mosque',  
        'vicinity': 'Lahore, Pakistan',
        'rating': 4.6,
        'user_ratings_total': 8500,
        'latitude': 31.5883,
        'longitude': 74.3099,
        'photo_reference': null,
        'is_open': true,
        'price_level': 0,
      },
      {
        'id': 'masjid_al_haram',
        'name': 'Masjid al-Haram',
        'vicinity': 'Mecca, Saudi Arabia',
        'rating': 5.0,
        'user_ratings_total': 50000,
        'latitude': 21.4225,
        'longitude': 39.8262,
        'photo_reference': null,
        'is_open': true,
        'price_level': 0,
      },
      {
        'id': 'masjid_an_nabawi',
        'name': 'Masjid an-Nabawi',
        'vicinity': 'Medina, Saudi Arabia', 
        'rating': 5.0,
        'user_ratings_total': 45000,
        'latitude': 24.4673,
        'longitude': 39.6108,
        'photo_reference': null,
        'is_open': true,
        'price_level': 0,
      },
      {
        'id': 'al_aqsa_mosque',
        'name': 'Al-Aqsa Mosque',
        'vicinity': 'Jerusalem, Palestine',
        'rating': 4.9,
        'user_ratings_total': 25000,
        'latitude': 31.7767,
        'longitude': 35.2345,
        'photo_reference': null,
        'is_open': true,
        'price_level': 0,
      },
      {
        'id': 'blue_mosque',
        'name': 'Blue Mosque',
        'vicinity': 'Istanbul, Turkey',
        'rating': 4.5,
        'user_ratings_total': 30000,
        'latitude': 41.0055,
        'longitude': 28.9769,
        'photo_reference': null,
        'is_open': true,
        'price_level': 0,
      }
    ];
  }

  Future<Map<String, dynamic>?> getMosqueDetails(String placeId) async {
    try {
      if (ApiConstant.googlePlacesApiKey == "YOUR_GOOGLE_PLACES_API_KEY_HERE") {
        // Return fallback details for known mosques
        final mosques = _getFallbackMosques();
        return mosques.firstWhere((mosque) => mosque['id'] == placeId);
      }

      final String url = 
          '${ApiConstant.googlePlacesBase}/details/json?'
          'place_id=$placeId&'
          'fields=name,rating,formatted_phone_number,opening_hours,website,formatted_address,geometry&'
          'key=${ApiConstant.googlePlacesApiKey}';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final place = data['result'];
          return {
            'name': place['name'],
            'rating': place['rating']?.toDouble() ?? 0.0,
            'phone': place['formatted_phone_number'],
            'website': place['website'],
            'address': place['formatted_address'],
            'latitude': place['geometry']['location']['lat'],
            'longitude': place['geometry']['location']['lng'],
            'opening_hours': place['opening_hours']?['weekday_text'] ?? [],
            'is_open': place['opening_hours']?['open_now'] ?? true,
          };
        }
      }
    } catch (e) {
      print('Mosque Details API Error: $e');
    }
    
    return null;
  }

  String? getMosquePhotoUrl(String? photoReference, {int maxWidth = 400}) {
    if (photoReference == null || ApiConstant.googlePlacesApiKey == "YOUR_GOOGLE_PLACES_API_KEY_HERE") {
      return null;
    }
    
    return '${ApiConstant.googlePlacesBase}/photo?'
           'maxwidth=$maxWidth&'
           'photo_reference=$photoReference&'
           'key=${ApiConstant.googlePlacesApiKey}';
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  Future<List<Map<String, dynamic>>> searchMosques(String query) async {
    final allMosques = await getNearbyMosques();
    return allMosques.where((mosque) => 
        mosque['name'].toLowerCase().contains(query.toLowerCase()) ||
        mosque['vicinity'].toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
