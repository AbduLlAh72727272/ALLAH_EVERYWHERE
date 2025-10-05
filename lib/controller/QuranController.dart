import 'package:get/get.dart';
import '../services/QuranService.dart';

class QuranController extends GetxController {
  var surahList = <Map<String, dynamic>>[].obs;
  var filteredSurahList = <Map<String, dynamic>>[].obs; // For the filtered list
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  // Variables for last read Surah
  var lastReadSurahName = ''.obs;
  var lastReadSurahId = 0.obs;
  var lastReadAyah = 1.obs; // Default to Ayah 1

  @override
  void onInit() {
    fetchSurahs();
    super.onInit();
  }

  Future<void> fetchSurahs() async {
    try {
      isLoading(true);
      
      // Generate Surah list from local data since we have the utility methods
      List<Map<String, dynamic>> surahs = [];
      for (int i = 1; i <= 114; i++) {
        surahs.add({
          'surahName': QuranService.getSurahName(i),
          'surahNameArabic': 'سورة ${QuranService.getSurahName(i)}',
          'surahNameTranslation': QuranService.getSurahName(i),
          'totalAyah': QuranService.getSurahVerseCount(i),
          'surahId': i,
        });
      }
      
      surahList.value = surahs;
      filteredSurahList.value = surahs; // Initially set filtered list to all surahs
    } catch (e) {
      errorMessage.value = 'Error fetching data';
    } finally {
      isLoading(false);
    }
  }

  // Function to update last read Surah
  void updateLastReadSurah(String surahName, int surahId, int ayah) {
    lastReadSurahName.value = surahName;
    lastReadSurahId.value = surahId;
    lastReadAyah.value = ayah;
  }

  // Function to filter surah list based on search query
  void searchSurah(String query) {
    if (query.isEmpty) {
      filteredSurahList.value = surahList; // Show all surahs if query is empty
    } else {
      filteredSurahList.value = surahList.where((surah) {
        // Filter based on surah name or translation
        return surah['surahName'].toLowerCase().contains(query.toLowerCase()) ||
            surah['surahNameTranslation'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }
}
