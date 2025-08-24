import 'package:allah_every_where/utils/utils/constraints/colors.dart';
import 'package:allah_every_where/utils/utils/constraints/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'controller/HadithController.dart';
import 'hadith_chapters.dart';

class HadithScreen extends StatelessWidget {
  final HadithController _controller = Get.put(HadithController());

  final Map<String, String> bookNamesInUrdu = {
    'Sahih Bukhari': 'صحیح بخاری',
    'Sahih Muslim': 'صحیح مسلم',
    'Jami\' Al-Tirmidhi': 'جامع ترمذی',
    'Sunan Abu Dawood': 'سنن ابوداؤد',
    'Sunan Ibn-e-Majah': 'سنن ابن ماجہ',
    'Sunan An-Nasa`i': 'سنن نسائی',
    'Mishkat Al-Masabih': 'مشکوٰۃ المصابیح',
    'Musnad Ahmad': 'مسند احمد بن حنبل',
    'Al-Silsila Sahiha': 'السلسلہ الصحیحہ',
  };

  final RxBool isSurahActive = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Hadith',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
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
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 47.h),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Continue Banner Container (as before)
                  Container(
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
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            children: [
                              Text(
                                'Last Read',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: VoidColors.white,
                                ),
                              ),
                              SizedBox(height: 0.h),
                              Text(
                                'صحيح مسلم',
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                  color: VoidColors.white,
                                ),
                              ),
                              Text(
                                'Chapters (Abwab, أبواب)',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: VoidColors.white,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: VoidColors.secondary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  elevation: 2,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Continue',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward,
                                      size: 14.sp,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Image.asset(
                          VoidImages.MUHAMMAD_1,
                          height: 150.h,
                          width: 150.w,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Search bar
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      color: Color(0XFF9B9A99),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Column(
                      children: [
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
                                  onChanged: (query) {
                                    _controller.searchBooks(query);
                                  },
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Search For Hadith Book',
                                    hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 4.h),
                      ],
                    ),
                  ),
                  Obx(() {
                    if (_controller.isLoading.value) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (_controller.errorMessage.isNotEmpty) {
                      return Center(
                        child: Text(
                          _controller.errorMessage.value,
                          style: TextStyle(fontSize: 16.sp, color: Colors.red),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _controller.filteredBooks.length,
                          itemBuilder: (context, index) {
                            final book = _controller.filteredBooks[index];
                            String bookNameInUrdu = bookNamesInUrdu[book['bookName']] ?? '';

                            return GestureDetector(
                              onTap: () {
                                print('📦 Book tapped: ${book.toString()}');
                                final slug = book['bookSlug'] ?? 'unknown-slug';
                                print('📦 Slug: ${book['bookSlug']}');

                                Get.to(() => HidthChaptersScreen(
                                  bookSlug: slug,
                                  bookNameInArabic: book['bookName'] ?? 'Unknown',
                                ));
                              },
                              child: buildSurahTile(
                                book['id']?.toString() ?? '',
                                book['bookName'] ?? '',
                                book['writerName'] ?? '',
                                book['chapters_count']?.toString() ?? '',
                                bookNamesInUrdu[book['bookName']] ?? '',
                              ),
                            );

                          },
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSurahTile(
      String? id, String? bookName, String? writerName, String? chaptersCount, String? bookNameInUrdu) {
    String safeId = id ?? "N/A";
    String safeBookName = bookName ?? "Unknown Book";
    String safeWriterName = writerName ?? "Unknown Writer";
    String safeChaptersCount = chaptersCount ?? "0";
    String safeBookNameInUrdu = bookNameInUrdu ?? '';

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: Color(0XFF9B9A99),
                child: Text(
                  safeId,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          safeBookName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 20.w),
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            safeBookNameInUrdu,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'Noto Nastaliq Urdu',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Writer: $safeWriterName',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                    ),
                    Text(
                      'Chapters: $safeChaptersCount',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(
          thickness: 1.h,
          color: Colors.grey[400],
          height: 16.h,
        ),
      ],
    );
  }
}

