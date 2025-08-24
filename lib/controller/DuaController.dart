import 'package:get/get.dart';
import '../services/DuaService.dart';

class DuaController extends GetxController {
  var duas = <Map<String, dynamic>>[].obs;
  var duaCategories = <Map<String, dynamic>>[].obs;
  var filteredDuas = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  final DuaService _duaService = DuaService();

  void fetchDuas() async {
    try {
      isLoading(true);
      var fetchedDuas = await _duaService.getAllDuas();
      duas.assignAll(fetchedDuas);
      filteredDuas.assignAll(fetchedDuas);
      _generateCategories();
    } catch (e) {
      errorMessage.value = 'Error fetching duas: $e';
    } finally {
      isLoading(false);
    }
  }

  void _generateCategories() {
    Map<String, List<Map<String, dynamic>>> categorizedDuas = {};
    
    for (var dua in duas) {
      String category = dua['category'] ?? 'General';
      if (!categorizedDuas.containsKey(category)) {
        categorizedDuas[category] = [];
      }
      categorizedDuas[category]!.add(dua);
    }
    
    var categories = categorizedDuas.entries.map((entry) => {
      'title': entry.key,
      'subCategoryCount': 1,
      'duaCount': entry.value.length,
      'duas': entry.value,
    }).toList();
    
    duaCategories.assignAll(categories);
  }

  void searchDuas(String query) {
    if (query.isEmpty) {
      filteredDuas.assignAll(duas);
    } else {
      filteredDuas.assignAll(
        duas.where((dua) {
          String title = dua['title'].toLowerCase();
          String translation = dua['translation'].toLowerCase();
          return title.contains(query.toLowerCase()) || 
                 translation.contains(query.toLowerCase());
        }).toList(),
      );
    }
  }

  List<Map<String, dynamic>> getDuasByCategory(String category) {
    return duas.where((dua) => dua['category'] == category).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchDuas();
  }
}
