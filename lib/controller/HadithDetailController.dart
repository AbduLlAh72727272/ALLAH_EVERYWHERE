import 'package:get/get.dart';


import '../services/HadithDetailService.dart';

class HadithDetailController extends GetxController {
  var isLoading = true.obs;
  var hadithData = [].obs;
  var chapterName = ''.obs;
  var errorMessage = ''.obs;

  final HadithDetailService _service = HadithDetailService();

  Future<void> fetchHadiths(String bookSlug, int chapterId) async {
    try {
      isLoading(true);
      var data = await _service.fetchHadiths(bookSlug, chapterId);
      if (data.isNotEmpty) {
        hadithData.value = data;
        chapterName.value = 'Chapter $chapterId';
      } else {
        errorMessage.value = 'No Hadiths found for this chapter.';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      // Use fallback hadiths on error
      hadithData.value = _service.getFallbackHadiths();
    } finally {
      isLoading(false);
    }
  }
}

