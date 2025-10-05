import 'package:allah_every_where/services/QuranService.dart';
import 'package:allah_every_where/utils/utils/constraints/colors.dart';
import 'package:allah_every_where/utils/utils/constraints/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';

class SurahScreen extends StatefulWidget {
  final String surahName;
  final int surahId;
  final int? initialVerse;

  const SurahScreen({
    Key? key,
    required this.surahName,
    required this.surahId,
    this.initialVerse,
  }) : super(key: key);

  @override
  _SurahScreenState createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, dynamic>> verses = [];
  bool isLoading = true;
  bool isAudioLoading = false;
  bool isPlaying = false;
  int currentPage = 1;
  int versesPerPage = 3;
  int totalPages = 1;
  int? currentPlayingVerse;
  
  AudioPlayer? audioPlayer;
  String? preferredTranslation;
  String? preferredReciter;
  Map<String, dynamic>? surahInfo;
  List<int> bookmarkedVerses = [];

  @override
  void initState() {
    super.initState();
    _initializeAudio();
    _loadData();
  }

  Future<void> _initializeAudio() async {
    audioPlayer = AudioPlayer();
    audioPlayer?.playerStateStream.listen((state) {
      setState(() {
        isPlaying = state.playing;
      });
    });
  }

  Future<void> _loadData() async {
    try {
      // Load preferences
      preferredTranslation = await QuranService.getPreferredTranslation();
      preferredReciter = QuranService.getPreferredReciter();
      
      // Load surah info
      surahInfo = await QuranService.getSurahInfo(widget.surahId);
      
      // Load verses
      final surahData = await QuranService.getSurahVerses(widget.surahId);
      
      // Load bookmarks for this surah
      final allBookmarks = await QuranService.getBookmarks();
      bookmarkedVerses = allBookmarks
          .where((bookmark) => bookmark['surah_number'] == widget.surahId)
          .map<int>((bookmark) => bookmark['verse_number'])
          .toList();

      setState(() {
        verses = surahData;
        totalPages = (verses.length / versesPerPage).ceil();
        isLoading = false;
      });

      // Navigate to initial verse if provided
      if (widget.initialVerse != null) {
        _scrollToVerse(widget.initialVerse!);
      }

      // Update last read position
      await QuranService.updateLastReadPosition(widget.surahId, widget.initialVerse ?? 1);
      
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading surah: $e')),
      );
    }
  }

  void _scrollToVerse(int verseNumber) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetPage = ((verseNumber - 1) / versesPerPage).floor();
      if (targetPage < totalPages) {
        _pageController.animateToPage(
          targetPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() {
          currentPage = targetPage + 1;
        });
      }
    });
  }

  Future<void> _playVerse(int verseNumber) async {
    if (audioPlayer == null) return;

    setState(() {
      isAudioLoading = true;
      currentPlayingVerse = verseNumber;
    });

    try {
      final audioUrl = await QuranService.getVerseAudio(
        widget.surahId, 
        verseNumber
      );
      
      if (audioUrl != null) {
        await audioPlayer!.setUrl(audioUrl);
        await audioPlayer!.play();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Audio not available for this verse')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing audio: $e')),
      );
    } finally {
      setState(() {
        isAudioLoading = false;
      });
    }
  }

  Future<void> _stopAudio() async {
    if (audioPlayer != null) {
      await audioPlayer!.stop();
      setState(() {
        currentPlayingVerse = null;
      });
    }
  }

  Future<void> _toggleBookmark(int verseNumber) async {
    try {
      if (bookmarkedVerses.contains(verseNumber)) {
        await QuranService.removeBookmarkByVerse(widget.surahId, verseNumber);
        setState(() {
          bookmarkedVerses.remove(verseNumber);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bookmark removed')),
        );
      } else {
        await QuranService.addBookmark(widget.surahId, verseNumber, widget.surahName);
        setState(() {
          bookmarkedVerses.add(verseNumber);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bookmark added')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating bookmark: $e')),
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
          widget.surahName,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.black,
            ),
            onPressed: () {
              if (isPlaying) {
                _stopAudio();
              } else if (verses.isNotEmpty) {
                final currentPageFirstVerse = ((currentPage - 1) * versesPerPage) + 1;
                _playVerse(currentPageFirstVerse);
              }
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  _showSettings();
                  break;
                case 'info':
                  _showSurahInfo();
                  break;
                case 'bookmarks':
                  _showBookmarks();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'info', child: Row(children: [Icon(Icons.info), SizedBox(width: 8), Text('Surah Info')])),
              PopupMenuItem(value: 'bookmarks', child: Row(children: [Icon(Icons.bookmark), SizedBox(width: 8), Text('Bookmarks')])),
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
          if (isLoading)
            Center(child: CircularProgressIndicator())
          else
            Column(
              children: [
                SizedBox(height: 100.h),
                // Surah Header
                _buildSurahHeader(),
                SizedBox(height: 16.h),
                
                // Verses Content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (page) {
                      setState(() {
                        currentPage = page + 1;
                      });
                    },
                    itemCount: totalPages,
                    itemBuilder: (context, pageIndex) {
                      return _buildVersePage(pageIndex);
                    },
                  ),
                ),
                
                // Bottom Controls
                _buildBottomControls(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSurahHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9B9A99), Color(0xFF7A7979)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Text(
            widget.surahName,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (surahInfo != null) ...[
            SizedBox(height: 8.h),
            Text(
              '${surahInfo!['revelation_place']} • ${verses.length} Verses',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white70,
              ),
            ),
          ],
          SizedBox(height: 12.h),
          // Bismillah for all surahs except At-Tawbah
          if (widget.surahId != 9) _buildBismillah(),
        ],
      ),
    );
  }

  Widget _buildBismillah() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'NotoNaskhArabic',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildVersePage(int pageIndex) {
    final startIndex = pageIndex * versesPerPage;
    final endIndex = (startIndex + versesPerPage).clamp(0, verses.length);
    final pageVerses = verses.sublist(startIndex, endIndex);

    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: pageVerses.map((verse) => _buildVerseCard(verse)).toList(),
      ),
    );
  }

  Widget _buildVerseCard(Map<String, dynamic> verse) {
    final verseNumber = verse['verse_number'];
    final isBookmarked = bookmarkedVerses.contains(verseNumber);
    final isCurrentlyPlaying = currentPlayingVerse == verseNumber;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Verse Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Color(0xFF9B9A99).withOpacity(0.8),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16.r,
                  backgroundColor: Colors.white,
                  child: Text(
                    '$verseNumber',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked ? Colors.blue : Colors.white,
                    size: 20.sp,
                  ),
                  onPressed: () => _toggleBookmark(verseNumber),
                ),
                IconButton(
                  icon: isAudioLoading && isCurrentlyPlaying
                      ? SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          isCurrentlyPlaying && isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                  onPressed: () {
                    if (isCurrentlyPlaying && isPlaying) {
                      _stopAudio();
                    } else {
                      _playVerse(verseNumber);
                    }
                  },
                ),
              ],
            ),
          ),
          
          // Arabic Text
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    verse['text_uthmani'] ?? verse['text'] ?? '',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontFamily: 'NotoNaskhArabic',
                      height: 2.0,
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ),
                
                SizedBox(height: 16.h),
                
                // Translation
                if (verse['translation'] != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      verse['translation'],
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Page
          IconButton(
            onPressed: currentPage > 1
                ? () {
                    _pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            icon: Icon(
              Icons.arrow_back_ios,
              color: currentPage > 1 ? Colors.black : Colors.grey,
            ),
          ),
          
          // Page Indicator
          Text(
            'Page $currentPage of $totalPages',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          
          // Next Page
          IconButton(
            onPressed: currentPage < totalPages
                ? () {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            icon: Icon(
              Icons.arrow_forward_ios,
              color: currentPage < totalPages ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showSurahInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.surahName),
        content: surahInfo != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('English Name: ${surahInfo!['name_simple']}'),
                  Text('Arabic Name: ${surahInfo!['name_arabic']}'),
                  Text('Meaning: ${surahInfo!['translated_name']['name']}'),
                  Text('Revelation: ${surahInfo!['revelation_place']}'),
                  Text('Total Verses: ${verses.length}'),
                ],
              )
            : Text('Loading surah information...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showBookmarks() {
    final surahBookmarks = bookmarkedVerses;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bookmarks in ${widget.surahName}'),
        content: Container(
          width: double.maxFinite,
          height: 300.h,
          child: surahBookmarks.isEmpty
              ? Center(child: Text('No bookmarks in this surah'))
              : ListView.builder(
                  itemCount: surahBookmarks.length,
                  itemBuilder: (context, index) {
                    final verseNumber = surahBookmarks[index];
                    return ListTile(
                      title: Text('Verse $verseNumber'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _toggleBookmark(verseNumber);
                          Navigator.pop(context);
                        },
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _scrollToVerse(verseNumber);
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

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reading Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Translation'),
              subtitle: Text(QuranService.availableTranslations[preferredTranslation] ?? 'Sahih International'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () => _showTranslationDialog(),
            ),
            ListTile(
              title: Text('Reciter'),
              subtitle: Text(QuranService.availableReciters[preferredReciter] ?? 'Mishary Alafasy'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () => _showReciterDialog(),
            ),
            ListTile(
              title: Text('Verses per Page'),
              subtitle: Text('$versesPerPage verses'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () => _showVersesPerPageDialog(),
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
                leading: Radio<String>(
                  value: entry.key,
                  groupValue: preferredTranslation,
                  onChanged: (value) async {
                    if (value != null) {
                      await QuranService.setPreferredTranslation(value);
                      Navigator.pop(context);
                      setState(() {
                        preferredTranslation = value;
                      });
                      _loadData(); // Reload with new translation
                    }
                  },
                ),
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
                leading: Radio<String>(
                  value: entry.key,
                  groupValue: preferredReciter,
                  onChanged: (value) async {
                    if (value != null) {
                      await QuranService.setPreferredReciter(value);
                      Navigator.pop(context);
                      setState(() {
                        preferredReciter = value;
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showVersesPerPageDialog() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Verses per Page'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [1, 3, 5, 10].map((count) {
            return ListTile(
              title: Text('$count verses'),
              leading: Radio<int>(
                value: count,
                groupValue: versesPerPage,
                onChanged: (value) {
                  if (value != null) {
                    Navigator.pop(context);
                    setState(() {
                      versesPerPage = value;
                      totalPages = (verses.length / versesPerPage).ceil();
                      currentPage = 1;
                    });
                    _pageController.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    audioPlayer?.dispose();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}