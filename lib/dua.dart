import 'package:allah_every_where/utils/utils/constraints/colors.dart';
import 'package:allah_every_where/utils/utils/constraints/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'dua_2.dart';
import 'duadetail.dart';
import 'dua_category.dart';
import 'controller/DuaController.dart';

class DuaScreen extends StatelessWidget {
  final DuaController _controller = Get.put(DuaController());

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: VoidColors.secondary,
      appBar: AppBar(
        backgroundColor: VoidColors.brown,
        title: Text("Dua",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 19.sp),),
        centerTitle: true,
        automaticallyImplyLeading: false,
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
        actions: [
          IconButton(
            onPressed: () {

            },
            icon: Icon(Icons.search,color: VoidColors.black,size: 25.sp,),
          ),
        ],
      ),

      body: Column(
        children: [

          Stack(
            children: [
              Image.asset(
                VoidImages.hands_dua,
                width: double.infinity,
                fit: BoxFit.cover,
                height: 180.h,
              ),
              Container(
                width: double.infinity,
                height: 180.h,
                child: Image.asset(
                  VoidImages.overlay,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  height: 180.h,
                ),
              ),
              Positioned(
                bottom: 10.h,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 95.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    children: [
                      buildCard("Guidance and Righteousness",
                          "O Allah, guide me, make me steadfast, and set my affairs right."),
                      buildCard("Forgiveness",
                          "O Allah, You are the Most Forgiving, so forgive me."),
                      buildCard("Gratitude",
                          "O Allah, I thank You for Your countless blessings."),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Icon Menu Section
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            child: Container(
              padding: EdgeInsets.all(11.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8.r,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: (){

                    },
                      child: buildIconMenuItem(VoidImages.Question, "Dua Q&A")),
                  buildIconMenuItem(VoidImages.memorize, "Memorize"),
                  buildIconMenuItem(VoidImages.reminder, "Reminder"),
                ],
              ),
            ),
          ),


          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with "View All" button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "All Duas",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Action for "View All"
                        },
                        child: Text(
                          "View all",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: VoidColors.black,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  Expanded(
                    child: Obx(() {
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

                      return ListView.builder(
                        itemCount: _controller.duaCategories.length,
                        itemBuilder: (context, index) {
                          final category = _controller.duaCategories[index];
                          return GestureDetector(
                            onTap: () {
Get.to(() => DuaCategoryScreen(
                                categoryName: category['title'],
                                duas: List<Map<String, dynamic>>.from(category['duas']),
                              ));
                            },
                            child: buildDuaCard(
                              title: category['title'],
                              subCategoryCount: category['subCategoryCount'],
                              duaCount: category['duaCount'],
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget to build scrollable cards
  Widget buildCard(String title, String subtitle) {
    return Container(
      width: 300.w,
      margin: EdgeInsets.only(right: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.r,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  // Widget to build icon menu items
  Widget buildIconMenuItem(String iconPath, String title) {
    return Column(
      children: [
        Image.asset(
          iconPath,
          height: 25.h,
          width: 35.w,
        ),
        SizedBox(height: 8.h),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13.sp,
          ),
        ),
      ],
    );
  }


  Widget buildDuaCard({
    required String title,
    required int subCategoryCount,
    required int duaCount,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Container(
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "$subCategoryCount sub-categories",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            // Right Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "$duaCount",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
                Text(
                  "Duas",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
