import 'dart:convert';
import 'package:http/http.dart' as http;

class HadithDetailService {
  static const String apiKey = '\$2y\$10\$OmrfIisZDLTzAHs23oTpQKuOA1Vbr9gsb2SrRfWsyiPFQx6WdEC';
  
  // Fetch all hadiths with pagination support
  Future<List<dynamic>> fetchAllHadiths({int page = 1, int limit = 10}) async {
    final String apiUrl = 'https://hadithapi.com/api/hadiths/?apiKey=$apiKey&page=$page&limit=$limit';

    try {
      print('Fetching hadiths from: $apiUrl');
      final response = await http.get(Uri.parse(apiUrl));
      print('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data keys: ${data.keys}');
        
        if (data['hadiths'] != null && data['hadiths']['data'] != null) {
          return data['hadiths']['data'];
        } else {
          print('No hadiths found in response');
          return [];
        }
      } else {
        throw Exception('Failed to load hadiths: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching hadiths: $e');
      throw Exception('Error fetching hadiths: $e');
    }
  }
  
  // Fetch hadiths by book slug and chapter
  Future<List<dynamic>> fetchHadiths(String bookSlug, int chapterId) async {
    final String apiUrl = 'https://hadithapi.com/api/hadiths?apiKey=$apiKey&book=$bookSlug&chapter=$chapterId';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['hadiths'] != null && data['hadiths']['data'] != null) {
          return List<Map<String, dynamic>>.from(data['hadiths']['data'].map((h) => {
            'hadithNumber': h['number'],
            'hadithArabic': h['arab'],
            'hadithEnglish': h['id'], // fix if wrong — might need different key
            'hadithUrdu': h['urdu'] ?? '',
            'urduNarrator': h['narrator'] ?? 'Unknown',
            'book': {'bookName': bookSlug},
          }));
        }
      }
    } catch (e) {
      print('Error fetching hadiths: $e');
    }

    return getFallbackHadiths();
  }

  
  // Fallback local hadiths when API fails
  List<dynamic> getFallbackHadiths() {
    return [
      {
        'id': 1,
        'hadithNumber': 1,
        'englishNarrator': 'Umar ibn al-Khattab',
        'hadithEnglish': 'Actions are but by intention and every man shall have but that which he intended. So whoever emigrated for Allah and His Messenger, his emigration was for Allah and His Messenger, and whoever emigrated for worldly gain or to marry a woman, his emigration was for that for which he emigrated.',
        'hadithArabic': 'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى، فَمَنْ كَانَتْ هِجْرَتُهُ إِلَى اللَّهِ وَرَسُولِهِ فَهِجْرَتُهُ إِلَى اللَّهِ وَرَسُولِهِ، وَمَنْ كَانَتْ هِجْرَتُهُ لِدُنْيَا يُصِيبُهَا أَوِ امْرَأَةٍ يَنْكِحُهَا فَهِجْرَتُهُ إِلَى مَا هَاجَرَ إِلَيْهِ',
        'status': 'Sahih',
        'bookSlug': 'sahih-bukhari'
      },
      {
        'id': 2,
        'hadithNumber': 2,
        'englishNarrator': 'Aisha',
        'hadithEnglish': 'The Messenger of Allah (ﷺ) said: "Whoever innovates something in this matter of ours (i.e., Islam) that is not part of it will have it rejected."',
        'hadithArabic': 'قَالَتْ قَالَ رَسُولُ اللَّهِ صلى الله عليه وسلم مَنْ أَحْدَثَ فِي أَمْرِنَا هَذَا مَا لَيْسَ فِيهِ فَهُوَ رَدٌّ',
        'status': 'Sahih',
        'bookSlug': 'sahih-bukhari'
      },
      {
        'id': 3,
        'hadithNumber': 3,
        'englishNarrator': 'Abu Hurairah',
        'hadithEnglish': 'The Prophet (ﷺ) said: "Religion is very easy and whoever overburdens himself in his religion will not be able to continue in that way. So you should not be extremists, but try to be near to perfection and receive the good tidings that you will be rewarded."',
        'hadithArabic': 'عَنْ أَبِي هُرَيْرَةَ عَنِ النَّبِيِّ صلى الله عليه وسلم قَالَ إِنَّ الدِّينَ يُسْرٌ وَلَنْ يُشَادَّ الدِّينَ أَحَدٌ إِلاَّ غَلَبَهُ فَسَدِّدُوا وَقَارِبُوا وَأَبْشِرُوا',
        'status': 'Sahih',
        'bookSlug': 'sahih-bukhari'
      }
    ];
  }
}

