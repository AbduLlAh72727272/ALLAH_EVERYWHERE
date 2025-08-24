import 'dart:convert';
import 'package:http/http.dart' as http;

class DuaService {
  // Using Islamhouse API
  final String islamhouseApiBase = 'https://islamhouse.com/api/v1';
  final String duaApiBase = 'https://dua-api.vercel.app/api';

  Future<List<Map<String, dynamic>>> getAllDuas() async {
    // Try multiple API endpoints
    try {
      // First try Islamhouse API for duas
      final response = await http.get(
        Uri.parse('$islamhouseApiBase/main?type=item&language=en&cat_code=dua'),
        headers: {'Accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data']['items'] != null) {
          return List<Map<String, dynamic>>.from(
            data['data']['items'].map((item) => {
              'id': item['id'] ?? 0,
              'title': item['title'] ?? 'Unknown Dua',
              'category': 'Daily',
              'arabic': item['content_ar'] ?? '',
              'transliteration': '',
              'translation': item['content_en'] ?? item['title'] ?? '',
              'description': item['description'] ?? '',
              'reference': item['source'] ?? 'Islamhouse',
              'benefits': '',
            })
          );
        }
      }
    } catch (e) {
      print('Islamhouse API Error: $e');
    }
    
    // Try alternative dua API
    try {
      final response = await http.get(
        Uri.parse('$duaApiBase/duas'),
        headers: {'Accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(
            data.map((dua) => {
              'id': dua['id'] ?? 0,
              'title': dua['name'] ?? dua['title'] ?? 'Dua',
              'category': dua['category'] ?? 'Daily',
              'arabic': dua['arabic'] ?? dua['ar'] ?? '',
              'transliteration': dua['transliteration'] ?? dua['romanized'] ?? '',
              'translation': dua['translation'] ?? dua['english'] ?? dua['en'] ?? '',
              'description': dua['description'] ?? '',
              'reference': dua['reference'] ?? dua['source'] ?? 'Sunnah',
              'benefits': dua['benefits'] ?? '',
            })
          );
        }
      }
    } catch (e) {
      print('Alternative Dua API Error: $e');
    }
    
    // Fallback to local duas if API fails
    return getLocalDuas();
  }

  Future<List<Map<String, dynamic>>> getDuasByCategory(String category) async {
    try {
      final response = await http.get(Uri.parse('$duaApiBase/duas/category/$category'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Dua Category API Error: $e');
    }
    
    return getLocalDuasByCategory(category);
  }

  List<Map<String, dynamic>> getLocalDuas() {
    return [
      {
        'id': 1,
        'title': 'Morning Duas',
        'category': 'Daily',
        'arabic': 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ',
        'transliteration': 'Asbahna wa asbahal-mulku lillah',
        'translation': 'We have entered the morning and the dominion belongs to Allah',
        'description': 'A morning dua to start the day',
        'reference': 'Muslim',
        'benefits': 'Protection throughout the day'
      },
      {
        'id': 2,
        'title': 'Evening Duas',
        'category': 'Daily',
        'arabic': 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ',
        'transliteration': 'Amsayna wa amsal-mulku lillah',
        'translation': 'We have entered the evening and the dominion belongs to Allah',
        'description': 'An evening dua for protection',
        'reference': 'Muslim',
        'benefits': 'Protection throughout the night'
      },
      {
        'id': 3,
        'title': 'Before Eating',
        'category': 'Food',
        'arabic': 'بِسْمِ اللَّهِ',
        'transliteration': 'Bismillah',
        'translation': 'In the name of Allah',
        'description': 'Dua before eating food',
        'reference': 'Abu Dawood',
        'benefits': 'Blessing in food'
      },
      {
        'id': 4,
        'title': 'After Eating',
        'category': 'Food',
        'arabic': 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَذَا وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ',
        'transliteration': 'Alhamdulillahil-ladhi at\'amani hadha wa razaqanihi min ghayri hawlin minni wa la quwwah',
        'translation': 'Praise be to Allah who has fed me this and provided it for me without any might or power on my part',
        'description': 'Dua after finishing meal',
        'reference': 'Abu Dawood',
        'benefits': 'Gratitude and forgiveness'
      },
      {
        'id': 5,
        'title': 'Before Sleep',
        'category': 'Sleep',
        'arabic': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
        'transliteration': 'Bismika Allahumma amutu wa ahya',
        'translation': 'In Your name, O Allah, I die and I live',
        'description': 'Dua before going to sleep',
        'reference': 'Bukhari',
        'benefits': 'Protection during sleep'
      },
      {
        'id': 6,
        'title': 'Upon Waking Up',
        'category': 'Sleep',
        'arabic': 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
        'transliteration': 'Alhamdulillahil-ladhi ahyana ba\'da ma amatana wa ilayhin-nushur',
        'translation': 'Praise be to Allah who has brought us back to life after causing us to die, and to Him is the resurrection',
        'description': 'Dua upon waking up',
        'reference': 'Bukhari',
        'benefits': 'Gratitude for new day'
      },
      {
        'id': 7,
        'title': 'For Guidance',
        'category': 'Seeking Help',
        'arabic': 'اللَّهُمَّ اهْدِنِي فِيمَنْ هَدَيْتَ',
        'transliteration': 'Allahumma ihdini fiman hadayt',
        'translation': 'O Allah, guide me among those You have guided',
        'description': 'Dua for seeking guidance',
        'reference': 'Abu Dawood',
        'benefits': 'Divine guidance'
      },
      {
        'id': 8,
        'title': 'For Forgiveness',
        'category': 'Repentance',
        'arabic': 'اللَّهُمَّ اغْفِرْ لِي ذَنْبِي وَخَطَئِي وَجَهْلِي',
        'transliteration': 'Allahummaghfir li dhanbi wa khata\'i wa jahli',
        'translation': 'O Allah, forgive my sins, my mistakes, and my ignorance',
        'description': 'Seeking forgiveness from Allah',
        'reference': 'Bukhari',
        'benefits': 'Forgiveness of sins'
      },
      {
        'id': 9,
        'title': 'For Protection',
        'category': 'Protection',
        'arabic': 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
        'transliteration': 'A\'udhu bi kalimatillahit-tammati min sharri ma khalaq',
        'translation': 'I seek refuge in the perfect words of Allah from the evil of what He has created',
        'description': 'Seeking protection from evil',
        'reference': 'Muslim',
        'benefits': 'Protection from harm'
      },
      {
        'id': 10,
        'title': 'For Good Health',
        'category': 'Health',
        'arabic': 'اللَّهُمَّ عَافِنِي فِي بَدَنِي اللَّهُمَّ عَافِنِي فِي سَمْعِي اللَّهُمَّ عَافِنِي فِي بَصَرِي',
        'transliteration': 'Allahumma \'afini fi badani, Allahumma \'afini fi sam\'i, Allahumma \'afini fi basari',
        'translation': 'O Allah, grant me health in my body, O Allah, grant me health in my hearing, O Allah, grant me health in my sight',
        'description': 'Dua for good health',
        'reference': 'Abu Dawood',
        'benefits': 'Good health and wellness'
      }
    ];
  }

  List<Map<String, dynamic>> getLocalDuasByCategory(String category) {
    final allDuas = getLocalDuas();
    return allDuas.where((dua) => dua['category'].toString().toLowerCase() == category.toLowerCase()).toList();
  }

  List<String> getDuaCategories() {
    return [
      'Daily',
      'Food',
      'Sleep',
      'Travel',
      'Health',
      'Protection',
      'Repentance',
      'Seeking Help',
      'Weather',
      'Family',
      'Work',
      'Prayer'
    ];
  }

  Future<Map<String, dynamic>?> getDuaById(int id) async {
    final allDuas = await getAllDuas();
    try {
      return allDuas.firstWhere((dua) => dua['id'] == id);
    } catch (e) {
      return null;
    }
  }
}
