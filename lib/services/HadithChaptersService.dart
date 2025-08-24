import 'dart:convert';
import 'package:http/http.dart' as http;

class HadithChaptersService {
  static const String apiKey = '\$2y\$10\$OmrfIisZDLTzAHs23oTpQKuOA1Vbr9gsb2SrRfWsyiPFQx6WdEC';

  Future<List<dynamic>> fetchChapters(String bookSlug) async {
    final String apiUrl = 'https://hadithapi.com/api/$bookSlug/chapters?apiKey=$apiKey';

// After HTTP call:


    try {
      final response = await http.get(Uri.parse(apiUrl));
      print('Using slug: $bookSlug');
      print('Requesting: $apiUrl');
      print('Status: ${response.statusCode}, Body: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['chapters'].map((chapter) => {
          'id': chapter['chapterNumber'],
          'chapterNumber': chapter['chapterNumber'],
          'chapterEnglish': chapter['titleEnglish'],
          'chapterUrdu': chapter['titleUrdu'] ?? '',
        }));
      } else {
        throw Exception('Failed to load chapters');
      }
    } catch (e) {
      throw Exception('Error fetching chapters: $e');
    }
  }

}
