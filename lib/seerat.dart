import 'package:allah_every_where/utils/utils/constraints/colors.dart';
import 'package:allah_every_where/utils/utils/constraints/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SeeratScreen extends StatelessWidget {
  final List<Map<String, String>> seeratData = [
    {
      'title': 'Early Life',
      'content': 'Details about the early life of the Prophet Muhammad (PBUH).'
    },
    {
      'title': 'Revelation Period',
      'content': 'The period of revelation and the challenges faced.'
    },
    {
      'title': 'Migration to Medina',
      'content': 'The migration to Medina and establishment of the first Islamic state.'
    },
    {
      'title': 'Battles Fought',
      'content': 'A summary of the key battles fought in the defense of Islam.'
    },
    {
      'title': 'Farewell Sermon',
      'content': 'The final sermon of the Prophet (PBUH) and his key messages.'
    }
  ];

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
          'SEERAT E NABWI',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
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
                                'سیرتِ نبوی',
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
                                onPressed: () async {
                                  await _openSeeratPDF(context);
                                },
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
                          VoidImages.MUHAMMAD_2,
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
                    itemCount: seeratData.length,
                    itemBuilder: (context, index) {
                      final seerah = seeratData[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            Get.to(() => SeeratDetailScreen(
                              title: seerah['title']!,
                              content: seerah['content']!,
                              fullContent: _getFullContent(seerah['title']!),
                            ));
                          },
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
                                  seerah['title']!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  seerah['content']!,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Row(
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
                              ],
                            ),
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

  Future<void> _openSeeratPDF(BuildContext context) async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String path = "${appDocDir.path}/seerat_nabwi.pdf";
      File file = File(path);
      
      if (!file.existsSync()) {
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16.w),
                Text('Downloading Seerat e Nabwi PDF...'),
              ],
            ),
          ),
        );
        
        // Simulate downloading - replace with actual PDF URL
        // For demo purposes, create a dummy file
        await file.writeAsString('This is a sample Seerat-e-Nabwi PDF content for demo purposes.');
        
        Navigator.pop(context); // Close loading dialog
      }
      
      Get.to(() => SeeratPDFScreen(filePath: path));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading PDF: $e')),
      );
    }
  }

  String _getFullContent(String title) {
    switch (title) {
      case 'Early Life':
        return '''
The Prophet Muhammad (ﷺ) was born on the 12th day of Rabi' al-Awwal in the Year of the Elephant (570 CE) in Mecca. His father, Abdullah ibn Abd al-Muttalib, died before his birth, and his mother, Aminah bint Wahb, died when he was six years old.

He was raised first by his grandfather Abd al-Muttalib and then by his uncle Abu Talib. As a young man, he became known for his honesty and trustworthiness, earning the nickname "Al-Amin" (the trustworthy).

At the age of 25, he married Khadijah bint Khuwaylid, a wealthy widow who was 15 years older than him. She was his only wife until her death 25 years later.

Before receiving his first revelation, the Prophet (ﷺ) would often retreat to the cave of Hira for meditation and reflection.''';
      
      case 'Revelation Period':
        return '''
The first revelation came to Prophet Muhammad (ﷺ) when he was 40 years old, in the cave of Hira during the month of Ramadan. The angel Jibril (Gabriel) appeared to him and commanded him to "Read" (Iqra).

The early years of his prophethood were marked by secret preaching to close family and friends. The first to believe in his message were his wife Khadijah, his cousin Ali ibn Abi Talib, his close friend Abu Bakr, and his adopted son Zayd ibn Harithah.

After three years of secret dawah, Allah commanded the Prophet (ﷺ) to publicly proclaim his message. This led to fierce opposition from the Meccan nobility who saw Islam as a threat to their power and the economic benefits they derived from pilgrimage to the Kaaba.

The persecution of early Muslims led to their migration to Abyssinia (Ethiopia) for protection.''';
      
      case 'Migration to Medina':
        return '''
The Hijra (migration) to Medina in 622 CE marked the beginning of the Islamic calendar. The Prophet (ﷺ) and Abu Bakr undertook this journey after receiving an invitation from the people of Yathrib (later renamed Medina).

In Medina, the Prophet (ﷺ) established the first Islamic state and created the Constitution of Medina, which established a multi-religious Islamic state with the first known constitution in the world.

The Ansar (helpers) of Medina welcomed the Muhajirun (emigrants) from Mecca, and a system of brotherhood was established between them.

The Prophet (ﷺ) also built the first mosque in Islam, Masjid an-Nabawi, which served as both a place of worship and his residence.''';
      
      case 'Battles Fought':
        return '''
Several battles were fought during the Prophet's (ﷺ) time in Medina:

1. Battle of Badr (624 CE): The first major battle where the Muslims, though outnumbered, achieved victory against the Meccan army.

2. Battle of Uhud (625 CE): A challenging battle where the Muslims faced setbacks due to some archers abandoning their positions.

3. Battle of the Trench (627 CE): The Muslims successfully defended Medina using a trench strategy suggested by Salman al-Farsi.

4. Treaty of Hudaybiyyah (628 CE): A peace treaty that was initially seen as unfavorable but proved to be a great victory for Islam.

5. Conquest of Mecca (630 CE): The peaceful conquest that led to the mass conversion of the Meccan population to Islam.

These battles were primarily defensive in nature, fought to protect the Muslim community from aggression.''';
      
      case 'Farewell Sermon':
        return '''
The Farewell Sermon (Khutbat al-Wada') was delivered by Prophet Muhammad (ﷺ) on the 9th day of Dhul Hijjah, 10 AH (632 CE) in the Uranah valley of Mount Arafat during his farewell pilgrimage to Mecca.

Key messages from the sermon:

• The sanctity of life, property, and honor
• Equality of all believers regardless of race or social status
• Rights and responsibilities in marriage
• The importance of following the Quran and Sunnah
• The prohibition of usury (riba)
• The completion of the religion of Islam

The sermon concluded with the revelation of the verse: "This day I have perfected for you your religion and completed My favor upon you and have approved for you Islam as religion." (Quran 5:3)

This sermon serves as a comprehensive guide for humanity and remains relevant for all time.''';
      
      default:
        return 'Detailed content about $title will be available soon.';
    }
  }
}

class SeeratDetailScreen extends StatelessWidget {
  final String title;
  final String content;
  final String fullContent;

  const SeeratDetailScreen({
    Key? key,
    required this.title,
    required this.content,
    required this.fullContent,
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
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                    fullContent,
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
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await _openSeeratPDF(context);
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
                ElevatedButton.icon(
                  onPressed: () {
                    // Share functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sharing $title')),
                    );
                  },
                  icon: Icon(Icons.share, size: 18.sp),
                  label: Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSeeratPDF(BuildContext context) async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String path = "${appDocDir.path}/seerat_nabwi.pdf";
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
        await file.writeAsString('This is a sample Seerat-e-Nabwi PDF content for demo purposes.');
        
        Navigator.pop(context);
      }
      
      Get.to(() => SeeratPDFScreen(filePath: path));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading PDF: $e')),
      );
    }
  }
}

class SeeratPDFScreen extends StatelessWidget {
  final String filePath;

  const SeeratPDFScreen({Key? key, required this.filePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seerat e Nabwi PDF'),
        backgroundColor: VoidColors.brown,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf, size: 100.sp, color: VoidColors.brown),
            SizedBox(height: 20.h),
            Text(
              'PDF Viewer Demo',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: VoidColors.brown,
              ),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                'In a production app, this would display the Seerat-e-Nabwi PDF using a proper PDF viewer package like flutter_pdfview or syncfusion_flutter_pdfviewer.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back),
              label: Text('Go Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: VoidColors.brown,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
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
}

