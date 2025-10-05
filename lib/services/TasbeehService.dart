import 'dart:convert';
import 'package:http/http.dart' as http;

class TasbeehService {
  static const List<Map<String, dynamic>> defaultTasbeehList = [
    {
      'id': 1,
      'title': 'SubhanAllah',
      'arabic': 'سبحان الله',
      'transliteration': 'SubhanAllah',
      'translation': 'Glory be to Allah',
      'target': 33,
      'reward': 'Each SubhanAllah is like planting a tree in Jannah',
      'reference': 'Sahih Muslim',
    },
    {
      'id': 2,
      'title': 'Alhamdulillah',
      'arabic': 'الحمد لله',
      'transliteration': 'Alhamdulillah',
      'translation': 'All praise is due to Allah',
      'target': 33,
      'reward': 'Fills the scales of good deeds',
      'reference': 'Sahih Muslim',
    },
    {
      'id': 3,
      'title': 'Allahu Akbar',
      'arabic': 'الله أكبر',
      'transliteration': 'Allahu Akbar',
      'translation': 'Allah is the Greatest',
      'target': 34,
      'reward': 'Beloved to Ar-Rahman',
      'reference': 'Sahih Bukhari',
    },
    {
      'id': 4,
      'title': 'La ilaha illa Allah',
      'arabic': 'لا إله إلا الله',
      'transliteration': 'La ilaha illa Allah',
      'translation': 'There is no deity but Allah',
      'target': 100,
      'reward': 'Best of dhikr, key to Paradise',
      'reference': 'Sahih Muslim',
    },
    {
      'id': 5,
      'title': 'Astaghfirullah',
      'arabic': 'أستغفر الله',
      'transliteration': 'Astaghfirullah',
      'translation': 'I seek forgiveness from Allah',
      'target': 100,
      'reward': 'Forgiveness of sins and increased sustenance',
      'reference': 'Sunan Abu Dawood',
    },
    {
      'id': 6,
      'title': 'La hawla wa la quwwata illa billah',
      'arabic': 'لا حول ولا قوة إلا بالله',
      'transliteration': 'La hawla wa la quwwata illa billah',
      'translation': 'There is no power except with Allah',
      'target': 50,
      'reward': 'Treasure from the treasures of Paradise',
      'reference': 'Sahih Bukhari',
    },
    {
      'id': 7,
      'title': 'Subhan Allah wa bihamdihi',
      'arabic': 'سبحان الله وبحمده',
      'transliteration': 'Subhan Allah wa bihamdihi',
      'translation': 'Glory be to Allah and praise is due to Him',
      'target': 100,
      'reward': 'All sins forgiven even if like foam of the sea',
      'reference': 'Sahih Bukhari',
    },
    {
      'id': 8,
      'title': 'Subhan Allah al-Azeem',
      'arabic': 'سبحان الله العظيم',
      'transliteration': 'Subhan Allah al-Azeem',
      'translation': 'Glory be to Allah, the Magnificent',
      'target': 50,
      'reward': 'Light on the tongue, heavy in the scales',
      'reference': 'Sahih Bukhari',
    },
    {
      'id': 9,
      'title': 'Allahumma salli ala Muhammad',
      'arabic': 'اللهم صل على محمد',
      'transliteration': 'Allahumma salli ala Muhammad',
      'translation': 'O Allah, send prayers upon Muhammad',
      'target': 100,
      'reward': 'Allah sends ten prayers for every one',
      'reference': 'Sahih Muslim',
    },
    {
      'id': 10,
      'title': 'Ayatul Kursi',
      'arabic': 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
      'transliteration': 'Allahu la ilaha illa huwa al-hayyu al-qayyum',
      'translation': 'Allah - there is no deity except Him, the Ever-Living, the Self-Sustaining',
      'target': 7,
      'reward': 'Protection from Satan until morning/evening',
      'reference': 'Sahih Bukhari',
    },
  ];

  static List<Map<String, dynamic>> getAllTasbeeh() {
    return defaultTasbeehList;
  }

  static Map<String, dynamic>? getTasbeehById(int id) {
    try {
      return defaultTasbeehList.firstWhere((tasbeeh) => tasbeeh['id'] == id);
    } catch (e) {
      return null;
    }
  }

  static List<Map<String, dynamic>> getRecommendedTasbeeh() {
    // Return most common daily dhikr
    return defaultTasbeehList.where((tasbeeh) => 
      [1, 2, 3, 4, 5].contains(tasbeeh['id'])
    ).toList();
  }

  static List<Map<String, dynamic>> getMorningTasbeeh() {
    return [
      {
        'id': 11,
        'title': 'Morning Dhikr 1',
        'arabic': 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ',
        'transliteration': 'Asbahna wa asbahal-mulku lillah',
        'translation': 'We have entered the morning and the dominion belongs to Allah',
        'target': 1,
        'reward': 'Protection throughout the day',
        'reference': 'Muslim',
      },
      {
        'id': 12,
        'title': 'Morning Dhikr 2',
        'arabic': 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
        'transliteration': 'A\'udhu bi kalimatillahit-tammati min sharri ma khalaq',
        'translation': 'I seek refuge in the perfect words of Allah from the evil of what He has created',
        'target': 3,
        'reward': 'Protection from all harm',
        'reference': 'Muslim',
      },
    ];
  }

  static List<Map<String, dynamic>> getEveningTasbeeh() {
    return [
      {
        'id': 13,
        'title': 'Evening Dhikr 1',
        'arabic': 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ',
        'transliteration': 'Amsayna wa amsal-mulku lillah',
        'translation': 'We have entered the evening and the dominion belongs to Allah',
        'target': 1,
        'reward': 'Protection throughout the night',
        'reference': 'Muslim',
      },
    ];
  }

  static List<Map<String, dynamic>> getAfterPrayerTasbeeh() {
    return defaultTasbeehList.where((tasbeeh) => 
      [1, 2, 3].contains(tasbeeh['id'])
    ).toList();
  }

  // Get random dhikr for motivation
  static Map<String, dynamic> getRandomTasbeeh() {
    final list = getAllTasbeeh();
    list.shuffle();
    return list.first;
  }

  // Calculate total reward points (simple scoring system)
  static int calculateRewardPoints(int count, int tasbeehId) {
    final tasbeeh = getTasbeehById(tasbeehId);
    if (tasbeeh == null) return count;
    
    int multiplier = 1;
    if (tasbeehId <= 3) multiplier = 10; // SubhanAllah, Alhamdulillah, Allahu Akbar
    else if (tasbeehId == 4) multiplier = 25; // La ilaha illa Allah
    else if (tasbeehId == 5) multiplier = 15; // Astaghfirullah
    else multiplier = 20;
    
    return count * multiplier;
  }

  // Get completion percentage
  static double getCompletionPercentage(int currentCount, int target) {
    if (target <= 0) return 0.0;
    return (currentCount / target).clamp(0.0, 1.0);
  }

  // Get motivational message based on progress
  static String getMotivationalMessage(double percentage) {
    if (percentage >= 1.0) {
      return "Alhamdulillah! You've completed your dhikr. May Allah accept it.";
    } else if (percentage >= 0.8) {
      return "Almost there! Keep going, you're doing great.";
    } else if (percentage >= 0.5) {
      return "You're halfway there! Continue with your dhikr.";
    } else if (percentage >= 0.25) {
      return "Good start! Keep remembering Allah.";
    } else {
      return "Begin your dhikr with Bismillah.";
    }
  }

  // Check if it's time for specific dhikr
  static List<Map<String, dynamic>> getTimeBasedTasbeeh() {
    final now = DateTime.now();
    final hour = now.hour;
    
    if (hour >= 5 && hour < 12) {
      // Morning time
      return getMorningTasbeeh();
    } else if (hour >= 17 && hour < 21) {
      // Evening time
      return getEveningTasbeeh();
    } else {
      // General dhikr anytime
      return getRecommendedTasbeeh();
    }
  }
}