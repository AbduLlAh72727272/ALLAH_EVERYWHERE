import 'package:allah_every_where/utils/utils/constraints/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'duadetail.dart';

class DuaCategoryScreen extends StatelessWidget {
  final String categoryName;
  final List<Map<String, dynamic>> duas;

  DuaCategoryScreen({
    Key? key,
    required this.categoryName,
    required this.duas,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VoidColors.secondary,
      appBar: AppBar(
        toolbarHeight: 60.h,
        backgroundColor: VoidColors.brown,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: VoidColors.black,
            size: 20.sp,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          categoryName,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${duas.length} Duas",
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: ListView.builder(
                itemCount: duas.length,
                itemBuilder: (context, index) {
                  final dua = duas[index];
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => DuaDetailScreen(
                        title: dua['title'] ?? 'Untitled',
                        arabicText: dua['arabic'] ?? '',
                        transliteration: dua['transliteration'] ?? '',
                        translation: dua['translation'] ?? '',
                        reference: dua['description'] ?? '',
                        hadithReference: dua['reference'] ?? '',
                      ));
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6.r,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dua['title'] ?? 'Untitled',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            dua['translation'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14.sp,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Icon(
                                Icons.book,
                                color: VoidColors.brown,
                                size: 16.sp,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                dua['reference'] ?? '',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: VoidColors.brown,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
