import 'package:allah_every_where/surah.dart';
import 'package:allah_every_where/services/QuranService.dart';
import 'package:allah_every_where/utils/utils/constraints/colors.dart';
import 'package:allah_every_where/utils/utils/constraints/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'controller/QuranController.dart';

class QuranScreen extends StatefulWidget {
  @override
  _QuranScreenState createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> with TickerProviderStateMixin {
  final QuranController controller = Get.put(QuranController());
  final TextEditingController _searchController = TextEditingController();
  
  late TabController _tabController;
  String _selectedView = 'surah'; // 'surah' or 'juz'
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  Map<String, dynamic>? _lastReadPosition;
  List<Map<String, dynamic>> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadLastReadPosition();
    await _loadBookmarks();
  }

  Future<void> _loadLastReadPosition() async {
    try {
      final position = await QuranService.getLastReadPosition();
      setState(() {
        _lastReadPosition = position;
      });
    } catch (e) {
      print('Error loading last read position: $e');
    }
  }

  Future<void> _loadBookmarks() async {
    try {
      final bookmarks = await QuranService.getBookmarks();
      setState(() {
        _bookmarks = bookmarks;
      });
    } catch (e) {
      print('Error loading bookmarks: $e');
    }
  }

  Future<void> _searchVerses(String query) async {
    if (query.length < 3) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await QuranService.searchVerses(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Quran',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark, color: Colors.black),
            onPressed: () => _showBookmarksDialog(),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  _showQuranSettings();
                  break;
                case 'search':
                  _showSearchDialog();
                  break;
                case 'progress':
                  _showReadingProgress();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'search', child: Row(children: [Icon(Icons.search), SizedBox(width: 8), Text('Search')])),
              PopupMenuItem(value: 'progress', child: Row(children: [Icon(Icons.analytics), SizedBox(width: 8), Text('Progress')])),
              PopupMenuItem(value: 'settings', child: Row(children: [Icon(Icons.settings), SizedBox(width: 8), Text('Settings')])),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              VoidImages.quran_background,
              fit: BoxFit.fill,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 48.h),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Last Read Section
                  _buildLastReadSection(),
                  SizedBox(height: 20.h),
                  
                  // Search and Filter Section
                  _buildSearchAndFilterSection(),
                  SizedBox(height: 20.h),

                  // Content based on search or normal view
                  if (_searchResults.isNotEmpty)
                    _buildSearchResults()
                  else if (_isSearching)
                    Center(child: CircularProgressIndicator())
                  else
                    _buildSurahList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastReadSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(VoidImages.quran_banner),
          fit: BoxFit.fill,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last Read',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: VoidColors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _lastReadPosition != null
                      ? QuranService.getSurahName(_lastReadPosition!['surah_number'])
                      : 'Al-Fatihah',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: VoidColors.white,
                    fontFamily: 'NotoNaskhArabic',
                  ),
                ),
                if (_lastReadPosition != null)
                  Text(
                    'Verse ${_lastReadPosition!['verse_number']}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: VoidColors.white,
                    ),
                  ),
                SizedBox(height: 8.h),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_lastReadPosition != null) {
                      Get.to(() => SurahScreen(
                        surahName: QuranService.getSurahName(_lastReadPosition!['surah_number']),
                        surahId: _lastReadPosition!['surah_number'],
                        initialVerse: _lastReadPosition!['verse_number'],
                      ));
                    } else {
                      Get.to(() => SurahScreen(
                        surahName: 'Al-Fatihah',
                        surahId: 1,
                      ));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VoidColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    elevation: 2,
                  ),
                  icon: Icon(Icons.play_arrow, size: 16.sp, color: Colors.black),
                  label: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            VoidImages.quran_majeed,
            height: 120.h,
            width: 120.w,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Color(0XFF9B9A99),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 8.w),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _searchVerses,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search verses, surahs...',
                      hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchResults = [];
                        _isSearching = false;
                      });
                    },
                  ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Tab Selection
          Row(
            children: [
              Expanded(
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.black54,
                  tabs: [
                    Tab(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Text('SURAH', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    Tab(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Text('JUZ', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Text(
            'Search Results (${_searchResults.length})',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            final result = _searchResults[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 4.h),
              child: ListTile(
                title: Text(
                  'Surah ${QuranService.getSurahName(result['surah_number'])} - Verse ${result['verse_number']}',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4.h),
                    Text(
                      result['translation'],
                      style: TextStyle(fontSize: 12.sp),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 16.sp),
                onTap: () {
                  Get.to(() => SurahScreen(
                    surahName: QuranService.getSurahName(result['surah_number']),
                    surahId: result['surah_number'],
                    initialVerse: result['verse_number'],
                  ));
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSurahList() {
    return Container(
      height: 600.h,
      child: TabBarView(
        controller: _tabController,
        children: [
          // Surah List
          Obx(() {
            if (controller.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              itemCount: controller.filteredSurahList.length,
              itemBuilder: (context, index) {
                final surah = controller.filteredSurahList[index];
                return GestureDetector(
                  onTap: () {
                    controller.updateLastReadSurah(surah['surahName'], index + 1, 1);
                    Get.to(() => SurahScreen(
                      surahName: surah['surahName'],
                      surahId: index + 1,
                    ));
                  },
                  child: _buildSurahTile(
                    surah['surahName']!,
                    surah['surahNameArabic']!,
                    surah['surahNameTranslation']!,
                    surah['totalAyah'].toString(),
                    index + 1,
                  ),
                );
              },
            );
          }),
          
          // Juz (Para) List
          _buildJuzList(),
        ],
      ),
    );
  }

  Widget _buildJuzList() {
    return ListView.builder(
      itemCount: 30,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 4.h),
          child: ListTile(
            leading: CircleAvatar(
              radius: 20.r,
              backgroundColor: Color(0XFF9B9A99),
              child: Text(
                '${index + 1}',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            title: Text(
              'Juz ${index + 1}',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Para ${index + 1}',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 16.sp),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Juz reading coming soon!')),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSurahTile(String surahName, String arabicName, String translation, String totalAyah, int serialNumber) {
    bool hasBookmark = _bookmarks.any((bookmark) => bookmark['surah_number'] == serialNumber);
    
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          radius: 20.r,
          backgroundColor: Color(0XFF9B9A99),
          child: Text(
            '$serialNumber',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                surahName,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            if (hasBookmark)
              Icon(Icons.bookmark, color: Colors.blue, size: 16.sp),
          ],
        ),
        subtitle: Text(
          '$translation ($totalAyah verses)',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              arabicName,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'NotoNaskhArabic',
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.arrow_forward_ios, size: 16.sp),
          ],
        ),
      ),
    );
  }

  void _showBookmarksDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bookmarks'),
        content: Container(
          width: double.maxFinite,
          height: 300.h,
          child: _bookmarks.isEmpty
              ? Center(child: Text('No bookmarks yet'))
              : ListView.builder(
                  itemCount: _bookmarks.length,
                  itemBuilder: (context, index) {
                    final bookmark = _bookmarks[index];
                    return ListTile(
                      title: Text('${QuranService.getSurahName(bookmark['surah_number'])} - Verse ${bookmark['verse_number']}'),
                      subtitle: Text(bookmark['note'] ?? ''),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await QuranService.removeBookmark(bookmark['id']);
                          await _loadBookmarks();
                          Navigator.pop(context);
                        },
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Get.to(() => SurahScreen(
                          surahName: QuranService.getSurahName(bookmark['surah_number']),
                          surahId: bookmark['surah_number'],
                          initialVerse: bookmark['verse_number'],
                        ));
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showQuranSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quran Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Translation'),
              subtitle: Text('Choose your preferred translation'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () => _showTranslationDialog(),
            ),
            ListTile(
              title: Text('Reciter'),
              subtitle: Text('Choose your preferred reciter'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () => _showReciterDialog(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTranslationDialog() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Translation'),
        content: Container(
          width: double.maxFinite,
          height: 300.h,
          child: ListView(
            children: QuranService.availableTranslations.entries.map((entry) {
              return ListTile(
                title: Text(entry.value),
                onTap: () async {
                  await QuranService.setPreferredTranslation(entry.key);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Translation updated')),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showReciterDialog() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Reciter'),
        content: Container(
          width: double.maxFinite,
          height: 300.h,
          child: ListView(
            children: QuranService.availableReciters.entries.map((entry) {
              return ListTile(
                title: Text(entry.value),
                onTap: () async {
                  await QuranService.setPreferredReciter(entry.key);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Reciter updated')),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Advanced Search'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Search Query',
                hintText: 'Enter keywords to search...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (query) {
                Navigator.pop(context);
                _searchController.text = query;
                _searchVerses(query);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showReadingProgress() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reading Progress'),
        content: Container(
          width: double.maxFinite,
          height: 200.h,
          child: Column(
            children: [
              if (_lastReadPosition != null) ...[
                ListTile(
                  leading: Icon(Icons.bookmark, color: Colors.blue),
                  title: Text('Last Read'),
                  subtitle: Text('${QuranService.getSurahName(_lastReadPosition!['surah_number'])} - Verse ${_lastReadPosition!['verse_number']}'),
                ),
              ],
              ListTile(
                leading: Icon(Icons.bookmark_border, color: Colors.orange),
                title: Text('Bookmarks'),
                subtitle: Text('${_bookmarks.length} saved'),
              ),
              ListTile(
                leading: Icon(Icons.schedule, color: Colors.green),
                title: Text('Reading Time'),
                subtitle: Text('Track your reading sessions'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}

