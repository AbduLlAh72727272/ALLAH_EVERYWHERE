import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'package:allah_every_where/services/AuthService.dart';

class QuranService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static const String _baseUrl = 'https://api.alquran.cloud/v1';
  static const String _altBaseUrl = 'https://api.quran.com/api/v4';
  static const String _audioBaseUrl = 'https://verses.quran.com';
  
  // Cache keys
  static const String _bookmarksKey = 'quran_bookmarks';
  static const String _lastReadKey = 'last_read_position';
  static const String _readingProgressKey = 'reading_progress';
  static const String _translationPreferenceKey = 'translation_preference';
  static const String _reciterPreferenceKey = 'reciter_preference';

  // Available translations - Updated IDs for AlQuran.cloud API
  static const Map<String, String> availableTranslations = {
    'en.sahih': 'Sahih International',
    'en.pickthall': 'Pickthall',
    'en.yusufali': 'Yusuf Ali',
    'en.arberry': 'Arberry',
    'ur.jalandhry': 'Urdu - Jalandhry',
    'ur.fateh': 'Urdu - Fateh Muhammad',
  };

  // Available reciters
  static const Map<String, String> availableReciters = {
    '7': 'Mishary Rashid Alafasy',
    '1': 'Abdul Basit Abdul Samad',
    '6': 'Saad Al Ghamdi',
    '9': 'Mahmoud Khalil Al-Hussary',
    '10': 'Minshawi',
    '11': 'Muhammad Siddiq Al-Minshawi',
  };

  // Get verse with translation - Updated to use AlQuran.cloud API
  static Future<Map<String, dynamic>> getVerse(int surahNumber, int verseNumber) async {
    try {
      String translationId = await getPreferredTranslation();
      
      // Get Arabic text
      final arabicResponse = await http.get(
        Uri.parse('$_baseUrl/ayah/${surahNumber}:${verseNumber}'),
        headers: {'Accept': 'application/json'},
      );
      
      // Get translation
      final translationResponse = await http.get(
        Uri.parse('$_baseUrl/ayah/${surahNumber}:${verseNumber}/$translationId'),
        headers: {'Accept': 'application/json'},
      );

      if (arabicResponse.statusCode == 200 && translationResponse.statusCode == 200) {
        final arabicData = json.decode(arabicResponse.body);
        final translationData = json.decode(translationResponse.body);
        
        if (arabicData['status'] == 'OK' && translationData['status'] == 'OK') {
          return {
            'verse': {
              'verse_number': arabicData['data']['numberInSurah'],
              'text_uthmani': arabicData['data']['text'],
              'text_simple': arabicData['data']['text'], // Arabic text
              'page_number': arabicData['data']['page'] ?? 1,
              'juz_number': arabicData['data']['juz'] ?? 1,
              'hizb_number': arabicData['data']['hizbQuarter'] ?? 1,
              'rub_number': arabicData['data']['rub'] ?? 1,
            },
            'translations': [
              {
                'id': translationId,
                'name': availableTranslations[translationId] ?? 'Unknown',
                'text': translationData['data']['text'],
                'language_name': 'English',
              }
            ]
          };
        }
      }
    } catch (e) {
      print('Quran API Error: $e');
    }
    
    // Fallback to local data
    return _getFallbackVerse(surahNumber, verseNumber);
  }

  // Get chapter (surah) information
  static Future<Map<String, dynamic>> getSurahInfo(int surahNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/surah/$surahNumber'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return {
            'id': data['data']['number'],
            'name_simple': data['data']['englishName'],
            'name_arabic': data['data']['name'],
            'verses_count': data['data']['numberOfAyahs'],
            'revelation_place': data['data']['revelationType'],
          };
        }
      }
    } catch (e) {
      print('Surah Info API Error: $e');
    }
    
    // Fallback to local data
    return _getFallbackSurahInfo(surahNumber);
  }

  // Get multiple verses for a surah
  static Future<List<Map<String, dynamic>>> getSurahVerses(int surahNumber) async {
    try {
      String translationId = await getPreferredTranslation();
      
      // Get Arabic verses
      final arabicResponse = await http.get(
        Uri.parse('$_baseUrl/surah/$surahNumber'),
        headers: {'Accept': 'application/json'},
      );
      
      // Get translated verses
      final translationResponse = await http.get(
        Uri.parse('$_baseUrl/surah/$surahNumber/$translationId'),
        headers: {'Accept': 'application/json'},
      );

      if (arabicResponse.statusCode == 200 && translationResponse.statusCode == 200) {
        final arabicData = json.decode(arabicResponse.body);
        final translationData = json.decode(translationResponse.body);
        
        if (arabicData['status'] == 'OK' && translationData['status'] == 'OK') {
          List<Map<String, dynamic>> verses = [];
          final arabicAyahs = arabicData['data']['ayahs'];
          final translationAyahs = translationData['data']['ayahs'];
          
          for (int i = 0; i < arabicAyahs.length; i++) {
            final arabicVerse = arabicAyahs[i];
            final translatedVerse = i < translationAyahs.length ? translationAyahs[i] : null;
            
            verses.add({
              'verse_number': arabicVerse['numberInSurah'],
              'text_uthmani': arabicVerse['text'],
              'text': arabicVerse['text'],
              'translation': translatedVerse?['text'] ?? '',
              'page_number': arabicVerse['page'] ?? 1,
              'juz_number': arabicVerse['juz'] ?? 1,
              'sajdah': arabicVerse['sajda'] != null,
            });
          }
          
          return verses;
        }
      }
    } catch (e) {
      print('Surah Verses API Error: $e');
    }
    
    // Fallback to local data
    return _getFallbackSurahVerses(surahNumber);
  }

  // Audio related methods
  static String getVerseAudioUrl(int surahNumber, int verseNumber) {
    String surahPadded = surahNumber.toString().padLeft(3, '0');
    String versePadded = verseNumber.toString().padLeft(3, '0');
    return '$_audioBaseUrl/Alafasy/$surahPadded$versePadded.mp3';
  }

  static Future<String> getVerseAudio(int surahNumber, int verseNumber) async {
    return getVerseAudioUrl(surahNumber, verseNumber);
  }

  static Future<void> updateLastReadPosition(int surahNumber, int verseNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> position = {
      'surah_number': surahNumber,
      'verse_number': verseNumber,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_lastReadKey, json.encode(position));
  }

  static Future<void> removeBookmarkByVerse(int surahNumber, int verseNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList(_bookmarksKey) ?? [];
    
    bookmarks.removeWhere((bookmark) {
      Map<String, dynamic> bookmarkData = json.decode(bookmark);
      return bookmarkData['surah_number'] == surahNumber && 
             bookmarkData['verse_number'] == verseNumber;
    });
    
    await prefs.setStringList(_bookmarksKey, bookmarks);
  }

  static Future<void> playVerse(int surahNumber, int verseNumber) async {
    try {
      String audioUrl = getVerseAudioUrl(surahNumber, verseNumber);
      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing verse: $e');
    }
  }

  static Future<void> playFullSurah(int surahNumber) async {
    try {
      String surahPadded = surahNumber.toString().padLeft(3, '0');
      String audioUrl = '$_audioBaseUrl/Alafasy/$surahPadded.mp3';
      
      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing full surah: $e');
    }
  }

  static Future<void> pauseAudio() async {
    await _audioPlayer.pause();
  }

  static Future<void> stopAudio() async {
    await _audioPlayer.stop();
  }

  static Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  static Stream<Duration> get positionStream => _audioPlayer.positionStream;
  static Duration? get duration => _audioPlayer.duration;
  static Duration get position => _audioPlayer.position;

  // Bookmark management
  static Future<void> addBookmark(int surahNumber, int verseNumber, String note) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList(_bookmarksKey) ?? [];
    
    Map<String, dynamic> bookmark = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'surah_number': surahNumber,
      'verse_number': verseNumber,
      'note': note,
      'created_at': DateTime.now().toIso8601String(),
    };
    
    bookmarks.add(json.encode(bookmark));
    await prefs.setStringList(_bookmarksKey, bookmarks);
  }

  static Future<void> removeBookmark(String bookmarkId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList(_bookmarksKey) ?? [];
    
    bookmarks.removeWhere((bookmark) {
      Map<String, dynamic> bookmarkData = json.decode(bookmark);
      return bookmarkData['id'] == bookmarkId;
    });
    
    await prefs.setStringList(_bookmarksKey, bookmarks);
  }

  static Future<List<Map<String, dynamic>>> getBookmarks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList(_bookmarksKey) ?? [];
    
    return bookmarks.map((bookmark) {
      return json.decode(bookmark) as Map<String, dynamic>;
    }).toList();
  }

  // Reading progress tracking
  static Future<void> updateReadingProgress(int surahNumber, int verseNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, int> readingStats = await getReadingStats();
    
    String progressKey = '${surahNumber}_progress';
    readingStats[progressKey] = verseNumber;
    readingStats['total_verses_read'] = (readingStats['total_verses_read'] ?? 0) + 1;
    readingStats['total_time_spent'] = (readingStats['total_time_spent'] ?? 0) + 1;
    
    await prefs.setString(_readingProgressKey, json.encode(readingStats));
    
    // Update last read position
    await updateLastReadPosition(surahNumber, verseNumber);
  }

  static Future<Map<String, dynamic>?> getLastReadPosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? progressJson = prefs.getString(_lastReadKey);
    
    if (progressJson != null) {
      return json.decode(progressJson);
    }
    return null;
  }

  static Future<Map<String, int>> getReadingStats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? statsJson = prefs.getString(_readingProgressKey);
    
    if (statsJson != null) {
      Map<String, dynamic> rawStats = json.decode(statsJson);
      return rawStats.map((key, value) => MapEntry(key, value as int));
    }
    
    return <String, int>{};
  }

  // Search functionality
  static Future<List<Map<String, dynamic>>> searchVerses(String query) async {
    try {
      String translationId = await getPreferredTranslation();
      
      // For now, we'll search through local fallback data
      // In a real implementation, you'd use a proper search API
      List<Map<String, dynamic>> searchResults = [];
      
      // Search through all surahs (simplified version)
      for (int surah = 1; surah <= 114; surah++) {
        List<Map<String, dynamic>> verses = await getSurahVerses(surah);
        for (var verse in verses) {
          if (verse['translation']?.toString().toLowerCase().contains(query.toLowerCase()) == true ||
              verse['text']?.toString().contains(query) == true) {
            searchResults.add({
              'surah_number': surah,
              'verse_number': verse['verse_number'],
              'text': verse['text'],
              'translation': verse['translation'],
            });
          }
        }
        
        if (searchResults.length >= 50) break; // Limit results
      }
      
      return searchResults;
    } catch (e) {
      print('Search error: $e');
      return [];
    }
  }

  // Preferences
  static Future<String> getPreferredTranslation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_translationPreferenceKey) ?? 'en.sahih'; // Default to Sahih International
  }

  static Future<void> setPreferredTranslation(String translationId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_translationPreferenceKey, translationId);
  }

  static String getPreferredReciter() {
    return '7'; // Default to Alafasy
  }

  static Future<void> setPreferredReciter(String reciterId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reciterPreferenceKey, reciterId);
  }

  // Utility methods
  static int getSurahVerseCount(int surahNumber) {
    final verseCounts = [
      7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52, 99,
      128, 111, 110, 98, 135, 112, 78, 118, 64, 77, 227, 93, 88, 69, 60,
      34, 30, 73, 54, 45, 83, 182, 88, 75, 85, 54, 53, 89, 59, 37, 35,
      38, 29, 18, 45, 60, 49, 62, 55, 78, 96, 29, 22, 24, 13, 14, 11,
      11, 18, 12, 12, 30, 52, 52, 44, 28, 28, 20, 56, 40, 31, 50, 40,
      46, 42, 29, 19, 36, 25, 22, 17, 19, 26, 30, 20, 15, 21, 11, 8,
      8, 19, 5, 8, 8, 11, 11, 8, 3, 9, 5, 4, 7, 3, 6, 3, 5, 4, 5, 6
    ];
    
    if (surahNumber >= 1 && surahNumber <= 114) {
      return verseCounts[surahNumber - 1];
    }
    return 0;
  }

  static String getSurahName(int surahNumber) {
    final surahNames = [
      'Al-Fatihah', 'Al-Baqarah', 'Aal-E-Imran', 'An-Nisa', 'Al-Maidah',
      'Al-Anam', 'Al-Araf', 'Al-Anfal', 'At-Tawbah', 'Yunus', 'Hud',
      'Yusuf', 'Ar-Rad', 'Ibrahim', 'Al-Hijr', 'An-Nahl', 'Al-Isra',
      'Al-Kahf', 'Maryam', 'Taha', 'Al-Anbiya', 'Al-Hajj', 'Al-Muminun',
      'An-Nur', 'Al-Furqan', 'Ash-Shuara', 'An-Naml', 'Al-Qasas',
      'Al-Ankabut', 'Ar-Rum', 'Luqman', 'As-Sajdah', 'Al-Ahzab', 'Saba',
      'Fatir', 'Ya-Sin', 'As-Saffat', 'Sad', 'Az-Zumar', 'Ghafir',
      'Fussilat', 'Ash-Shuraa', 'Az-Zukhruf', 'Ad-Dukhan', 'Al-Jathiyah',
      'Al-Ahqaf', 'Muhammad', 'Al-Fath', 'Al-Hujurat', 'Qaf', 'Adh-Dhariyat',
      'At-Tur', 'An-Najm', 'Al-Qamar', 'Ar-Rahman', 'Al-Waqiah', 'Al-Hadid',
      'Al-Mujadila', 'Al-Hashr', 'Al-Mumtahanah', 'As-Saf', 'Al-Jumuah',
      'Al-Munafiqun', 'At-Taghabun', 'At-Talaq', 'At-Tahrim', 'Al-Mulk',
      'Al-Qalam', 'Al-Haqqah', 'Al-Maarij', 'Nuh', 'Al-Jinn', 'Al-Muzzammil',
      'Al-Muddaththir', 'Al-Qiyamah', 'Al-Insan', 'Al-Mursalat', 'An-Naba',
      'An-Naziat', 'Abasa', 'At-Takwir', 'Al-Infitar', 'Al-Mutaffifin',
      'Al-Inshiqaq', 'Al-Buruj', 'At-Tariq', 'Al-Ala', 'Al-Ghashiyah',
      'Al-Fajr', 'Al-Balad', 'Ash-Shams', 'Al-Lail', 'Ad-Duhaa', 'Ash-Sharh',
      'At-Tin', 'Al-Alaq', 'Al-Qadr', 'Al-Bayyinah', 'Az-Zalzalah',
      'Al-Adiyat', 'Al-Qariah', 'At-Takathur', 'Al-Asr', 'Al-Humazah',
      'Al-Fil', 'Quraysh', 'Al-Maun', 'Al-Kawthar', 'Al-Kafirun', 'An-Nasr',
      'Al-Masad', 'Al-Ikhlas', 'Al-Falaq', 'An-Nas'
    ];
    
    if (surahNumber >= 1 && surahNumber <= 114) {
      return surahNames[surahNumber - 1];
    }
    return 'Unknown';
  }

  // Fallback methods
  static Map<String, dynamic> _getFallbackVerse(int surahNumber, int verseNumber) {
    return {
      'verse': {
        'verse_number': verseNumber,
        'text_uthmani': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        'text_simple': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        'page_number': 1,
        'juz_number': 1,
      },
      'translations': [
        {
          'text': 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
          'language_name': 'English',
        }
      ]
    };
  }

  static Map<String, dynamic> _getFallbackSurahInfo(int surahNumber) {
    return {
      'id': surahNumber,
      'name_simple': getSurahName(surahNumber),
      'name_arabic': 'سورة',
      'verses_count': getSurahVerseCount(surahNumber),
      'revelation_place': 'makkah',
    };
  }

  static List<Map<String, dynamic>> _getFallbackSurahVerses(int surahNumber) {
    return [
      {
        'verse_number': 1,
        'text_uthmani': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        'text': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        'translation': 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
        'page_number': 1,
        'juz_number': 1,
        'sajdah': false,
      }
    ];
  }

  static void dispose() {
    _audioPlayer.dispose();
  }
}