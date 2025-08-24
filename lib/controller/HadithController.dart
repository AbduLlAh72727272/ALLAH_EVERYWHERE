import 'package:get/get.dart';
import '../services/HadithService.dart';

class HadithController extends GetxController {
  var books = <dynamic>[].obs;
  var filteredBooks = <dynamic>[].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  final HadithService _hadithService = HadithService();

  void fetchBooks() async {
    try {
      isLoading(true);

      var fetchedBooks = await _hadithService.fetchBooks();

      // ✅ Map and rename the keys properly
      var formattedBooks = fetchedBooks.map((book) => {
        'id': book['id'],
        'bookName': book['name'],
        'bookSlug': book['slug'], // ✅ This is the real slug
        'writerName': book['writerName'] ?? 'Unknown',
        'chapters_count': book['chapters_count'] ?? 0,
        'hadith_count': book['hadith_count'] ?? 0,
      }).toList();

      books.assignAll(formattedBooks);
      filteredBooks.assignAll(formattedBooks);
    } catch (e) {
      errorMessage.value = 'Error fetching books: $e';
    } finally {
      isLoading(false);
    }
  }


  void searchBooks(String query) {
    if (query.isEmpty) {
      filteredBooks.assignAll(books);
    } else {
      filteredBooks.assignAll(
        books.where((book) {
          String bookName = book['bookName'].toLowerCase();
          String writerName = book['writerName'].toLowerCase();
          return bookName.contains(query.toLowerCase()) || writerName.contains(query.toLowerCase());
        }).toList(),
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchBooks();
  }
}
