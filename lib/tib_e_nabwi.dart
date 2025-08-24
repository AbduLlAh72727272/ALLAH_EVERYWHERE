import 'package:allah_every_where/utils/utils/constraints/colors.dart';
import 'package:allah_every_where/utils/utils/constraints/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class TibENabwi extends StatelessWidget {
  final List<Map<String, String>> tibData = [
    {
      'title': 'Honey',
      'benefits': 'Known for its healing properties and used in various remedies.'
    },
    {
      'title': 'Olive Oil',
      'benefits': 'Used for its moisturizing properties and as a digestion aid.'
    },
    {
      'title': 'Black Seed',
      'benefits': 'Believed to have a cure for everything but death.'
    },
    {
      'title': 'Milk',
      'benefits': 'Considered a complete food source and encouraged for consumption.'
    },
    {
      'title': 'Dates',
      'benefits': 'Highly nutritious and used to break fasts.'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      automaticallyImplyLeading: false,
        title: Text(
          'Tib e Nabwi (S.A.W) ',
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
          Image.asset(
            width: double.infinity,
            VoidImages.quran_background,
            fit: BoxFit.fill,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 90.h),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                              SizedBox(height: 4.h),
                              Text(
                                'تعظيم النبي',
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                  color: VoidColors.white,
                                ),
                              ),
                              Text(
                                'Page no 250',
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
                          VoidImages.tib_e_nabwi,
                          height: 150.h,
                          width: 150.w,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: tibData.length,
                    itemBuilder: (context, index) {
                      final item = tibData[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                item['benefits']!,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              GestureDetector(
                                onTap: () {
                                  Get.to(() => TibDetailScreen(
                                    title: item['title']!,
                                    benefits: _getDetailedBenefits(item['title']!),
                                  ));
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 14.sp,
                                      color: Colors.grey[600],
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'Read more',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
  );
  }

  String _getDetailedBenefits(String title) {
    switch (title) {
      case 'Honey':
        return '''Honey is mentioned in the Quran as having healing properties for people. The Prophet Muhammad (ﷺ) said: "Honey is a remedy for every illness and the Quran is a remedy for all illness of the mind, therefore I recommend to you both remedies, the Quran and honey."

Benefits:
• Natural antibacterial and antifungal properties
• Helps in wound healing
• Soothes sore throats and coughs
• Provides energy and nutrients
• Aids in digestion

Prophetic Guidance: The Prophet (ﷺ) recommended honey for stomach ailments and general health.''';
      
      case 'Olive Oil':
        return '''Olive oil is blessed and mentioned in the Quran. The Prophet Muhammad (ﷺ) said: "Eat olive oil and massage it over your bodies since it is a holy tree."

Benefits:
• Rich in healthy monounsaturated fats
• Contains antioxidants and vitamin E
• Anti-inflammatory properties
• Good for heart health
• Beneficial for skin and hair when applied topically

Prophetic Guidance: Used both internally and externally for health and beauty.''';
      
      case 'Black Seed':
        return '''The Prophet Muhammad (ﷺ) said: "In the black seed is healing for every disease except death." (Sahih Bukhari)

Benefits:
• Boosts immune system
• Anti-inflammatory and antioxidant properties
• Helps with respiratory issues
• Supports digestive health
• May help regulate blood sugar
• Beneficial for skin conditions

Prophetic Guidance: Can be consumed as oil, powder, or whole seeds for various ailments.''';
      
      case 'Milk':
        return '''The Prophet Muhammad (ﷺ) said: "When any one of you eats food, let him say: 'O Allah, bless us in what You have provided us and feed us with something better than it.' When he drinks milk, let him say: 'O Allah, bless us in what You have provided us and give us more of it.'"

Benefits:
• Complete source of nutrition
• Rich in calcium and protein
• Supports bone health
• Contains essential vitamins and minerals
• Good for muscle building and repair

Prophetic Guidance: The Prophet (ﷺ) preferred milk over other drinks and considered it a complete food.''';
      
      case 'Dates':
        return '''The Prophet Muhammad (ﷺ) said: "If anyone of you is fasting, let him break his fast with dates. In case he does not have them, then with water, for it is purifying." (Abu Dawood)

Benefits:
• High in natural sugars for quick energy
• Rich in fiber, potassium, and antioxidants
• Contains vitamins and minerals
• Helps maintain heart health
• Natural source of iron
• Aids digestion

Prophetic Guidance: The Prophet (ﷺ) used to break his fast with dates and recommended them for pregnant women and general nutrition.''';
      
      default:
        return 'Detailed benefits about $title according to Prophetic medicine will be available soon.';
    }
  }
}

class TibDetailScreen extends StatelessWidget {
  final String title;
  final String benefits;

  const TibDetailScreen({
    Key? key,
    required this.title,
    required this.benefits,
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
          title,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
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
                    title,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: VoidColors.brown,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    benefits,
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            
            ElevatedButton.icon(
              onPressed: () async {
                await _openTibPDF(context);
              },
              icon: Icon(Icons.picture_as_pdf, size: 18.sp),
              label: Text('Read PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: VoidColors.brown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openTibPDF(BuildContext context) async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String path = "${appDocDir.path}/tib_e_nabwi.pdf";
      File file = File(path);
      
      if (!file.existsSync()) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16.w),
                Text('Downloading PDF...'),
              ],
            ),
          ),
        );
        
        // For demo purposes, create a dummy file
        await file.writeAsString('This is a sample Tib-e-Nabwi PDF content for demo purposes.');
        
        Navigator.pop(context);
      }
      
      Get.to(() => TibPDFScreen(filePath: path));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading PDF: $e')),
      );
    }
  }
}

class TibPDFScreen extends StatelessWidget {
  final String filePath;

  const TibPDFScreen({Key? key, required this.filePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tib e Nabwi PDF'),
        backgroundColor: VoidColors.brown,
      ),
      body: PDF().fromUrl(
        filePath,
        placeholder: (progress) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(value: progress),
              SizedBox(height: 16.h),
              Text('Loading PDF... ${(progress * 100).toInt()}%'),
            ],
          ),
        ),
        errorWidget: (error) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64.sp, color: Colors.red),
              SizedBox(height: 16.h),
              Text('Error loading PDF: $error'),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }


}

