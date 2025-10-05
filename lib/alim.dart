import 'package:allah_every_where/chat.dart';
import 'package:allah_every_where/services/ChatService.dart';
import 'package:allah_every_where/utils/utils/constraints/colors.dart';
import 'package:allah_every_where/utils/utils/constraints/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'live_messages.dart';
import 'masail&issues.dart';

class AlimScreen extends StatefulWidget {
  @override
  _AlimScreenState createState() => _AlimScreenState();
}

class _AlimScreenState extends State<AlimScreen> {
  final ChatService _chatService = ChatService();
  List<Map<String, dynamic>> _availableAlims = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      final alims = await _chatService.getAvailableAlims();
      final categories = _chatService.getChatCategories();
      
      setState(() {
        _availableAlims = alims;
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading data: $e');
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
          'Ask an Alim',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.black),
            onPressed: () => _showHelpDialog(),
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
            child: _isLoading 
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Banner
                      _buildWelcomeBanner(),
                      SizedBox(height: 24.h),
                      
                      // Quick Actions
                      _buildQuickActions(),
                      SizedBox(height: 24.h),
                      
                      // Available Scholars
                      _buildAvailableScholars(),
                      SizedBox(height: 24.h),
                      
                      // Categories
                      _buildCategories(),
                      SizedBox(height: 24.h),
                      
                      // Menu Options
                      ..._buildMenuOptions(),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner() {
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
                  'Ask Islamic Questions',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: VoidColors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'عَالِم',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: VoidColors.white,
                    fontFamily: 'NotoNaskhArabic',
                  ),
                ),
                Text(
                  'Get guidance from qualified scholars',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: VoidColors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                ElevatedButton(
                  onPressed: () => _showQuestionDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VoidColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ask Question',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.chat,
                        size: 14.sp,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            VoidImages.alim_name,
            height: 150.h,
            width: 120.w,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            'Quick Question',
            Icons.flash_on,
            Color(0xFF4CAF50),
            () => _showQuestionDialog(),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildQuickActionCard(
            'My Chats',
            Icons.chat_bubble_outline,
            Color(0xFF2196F3),
            () => _showMyChats(),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildQuickActionCard(
            'Emergency',
            Icons.priority_high,
            Color(0xFFF44336),
            () => _showEmergencyDialog(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableScholars() {
    if (_availableAlims.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Available Scholars',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextButton(
              onPressed: () => _showAllScholars(),
              child: Text('View All'),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          height: 200.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _availableAlims.take(5).length,
            itemBuilder: (context, index) {
              final alim = _availableAlims[index];
              return _buildScholarCard(alim);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildScholarCard(Map<String, dynamic> alim) {
    return Container(
      width: 160.w,
      margin: EdgeInsets.only(right: 12.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundImage: alim['profilePicture'].isNotEmpty
                        ? NetworkImage(alim['profilePicture'])
                        : AssetImage('assets/images/default_avatar.png') as ImageProvider,
                  ),
                  if (alim['isOnline'])
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 8.w),
              if (alim['isVerified'])
                Icon(Icons.verified, color: Colors.blue, size: 16),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            alim['name'],
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            alim['title'],
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 12),
              SizedBox(width: 2.w),
              Text(
                '${alim['rating']}',
                style: TextStyle(fontSize: 11.sp),
              ),
              SizedBox(width: 4.w),
              Text(
                '(${alim['totalReviews']})',
                style: TextStyle(fontSize: 10.sp, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _startChatWithAlim(alim),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 6.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Chat',
                style: TextStyle(fontSize: 12.sp, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question Categories',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 12.h),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.5,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            return _buildCategoryCard(category);
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () => _showCategoryDialog(category),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              category['icon'],
              color: Colors.blue,
              size: 24.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              category['name'],
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Text(
              category['description'],
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMenuOptions() {
    final menuItems = [
      {
        'title': 'Masail and Issues',
        'icon': VoidImages.masail,
        'colors': [Color(0xFFD9D9D9), Color(0xFFA1729B)],
        'route': () => Get.to(() => MasailAndIssues()),
      },
      {
        'title': 'Live Questions',
        'icon': VoidImages.live_questions,
        'colors': [Color(0xFF8FA134), Color(0xFFA9BF3C)],
        'route': () => Get.to(() => LiveMessagesScreen()),
      },
      {
        'title': 'Recent Fatwas',
        'icon': VoidImages.fatwa,
        'colors': [Color(0xFFE4D3A3), Color(0xFF8C8360)],
        'route': () => _showComingSoon('Recent Fatwas'),
      },
      {
        'title': 'Daily Islamic Tips',
        'icon': VoidImages.islamic_tips,
        'colors': [Color(0xFF779FC1), Color(0xFF384B5B)],
        'route': () => _showComingSoon('Daily Islamic Tips'),
      },
      {
        'title': 'Saved Questions',
        'icon': VoidImages.saved_questions,
        'colors': [Color(0xFFFF7BAC), Color(0xFFDB8289)],
        'route': () => _showComingSoon('Saved Questions'),
      },
    ];

    return menuItems.map((item) {
      return Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: item['colors'] as List<Color>,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
            leading: Image.asset(
              item['icon'] as String,
              height: 60.h,
              width: 40.w,
              fit: BoxFit.fill,
            ),
            title: Text(
              item['title'] as String,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 20.sp,
              color: Colors.white,
            ),
            onTap: () => (item['route'] as VoidCallback)(),
          ),
        ),
      );
    }).toList();
  }

  void _showQuestionDialog() {
    showDialog(
      context: context,
      builder: (context) => QuestionDialog(
        onSubmit: (question, category) {
          _findScholarForQuestion(question, category);
        },
      ),
    );
  }

  void _findScholarForQuestion(String question, String category) async {
    // Show available scholars for this category
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: ScholarSelectionSheet(
          question: question,
          category: category,
          scholars: _availableAlims,
          onScholarSelected: (scholar) => _startChatWithAlim(scholar, question: question),
        ),
      ),
    );
  }

  void _startChatWithAlim(Map<String, dynamic> alim, {String? question}) async {
    try {
      final chatId = await _chatService.createChatSession(
        alimId: alim['id'],
        question: question ?? 'Assalamu Alaikum, I have a question.',
        category: 'general',
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatId: chatId,
            alimName: alim['name'],
            alimProfilePicture: alim['profilePicture'],
            isAlimOnline: alim['isOnline'],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start chat: $e')),
      );
    }
  }

  void _showMyChats() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyChatsScreen()),
    );
  }

  void _showAllScholars() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllScholarsScreen(scholars: _availableAlims),
      ),
    );
  }

  void _showCategoryDialog(Map<String, dynamic> category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(category['icon']),
            SizedBox(width: 8),
            Text(category['name']),
          ],
        ),
        content: Text(category['description']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showQuestionDialog();
            },
            child: Text('Ask Question'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Emergency Support'),
        content: Text('For urgent Islamic guidance, you will be connected with available scholars immediately.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Connect with first available online scholar
              final onlineAlim = _availableAlims.firstWhere(
                (alim) => alim['isOnline'],
                orElse: () => _availableAlims.isNotEmpty ? _availableAlims.first : {},
              );
              if (onlineAlim.isNotEmpty) {
                _startChatWithAlim(onlineAlim, question: 'Emergency: I need urgent Islamic guidance.');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Connect Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon!')),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('How it Works'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Select a question category'),
            Text('2. Choose an available scholar'),
            Text('3. Ask your Islamic question'),
            Text('4. Get authentic Islamic guidance'),
            SizedBox(height: 16),
            Text(
              'All our scholars are qualified and verified Islamic experts.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }
}

// Additional screens that would be implemented
class QuestionDialog extends StatefulWidget {
  final Function(String question, String category) onSubmit;

  const QuestionDialog({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _QuestionDialogState createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<QuestionDialog> {
  final TextEditingController _questionController = TextEditingController();
  String _selectedCategory = 'general';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ask Your Question'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(labelText: 'Category'),
            items: [
              DropdownMenuItem(value: 'general', child: Text('General')),
              DropdownMenuItem(value: 'prayer', child: Text('Prayer & Worship')),
              DropdownMenuItem(value: 'family', child: Text('Family & Marriage')),
              DropdownMenuItem(value: 'business', child: Text('Business & Finance')),
            ],
            onChanged: (value) => setState(() => _selectedCategory = value!),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _questionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Your Question',
              hintText: 'Type your Islamic question here...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_questionController.text.trim().isNotEmpty) {
              Navigator.pop(context);
              widget.onSubmit(_questionController.text.trim(), _selectedCategory);
            }
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}

class ScholarSelectionSheet extends StatelessWidget {
  final String question;
  final String category;
  final List<Map<String, dynamic>> scholars;
  final Function(Map<String, dynamic>) onScholarSelected;

  const ScholarSelectionSheet({
    Key? key,
    required this.question,
    required this.category,
    required this.scholars,
    required this.onScholarSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Select a Scholar',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: scholars.length,
              itemBuilder: (context, index) {
                final scholar = scholars[index];
                return Card(
                  child: ListTile(
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          backgroundImage: scholar['profilePicture'].isNotEmpty
                              ? NetworkImage(scholar['profilePicture'])
                              : AssetImage('assets/images/default_avatar.png') as ImageProvider,
                        ),
                        if (scholar['isOnline'])
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Text(scholar['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(scholar['title']),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            Text(' ${scholar['rating']} (${scholar['totalReviews']} reviews)'),
                          ],
                        ),
                        Text('Response time: ${scholar['responseTime']}'),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onScholarSelected(scholar);
                      },
                      child: Text('Select'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MyChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Chats')),
      body: Center(child: Text('My Chats Screen - Coming Soon')),
    );
  }
}

class AllScholarsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> scholars;

  const AllScholarsScreen({Key? key, required this.scholars}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All Scholars')),
      body: ListView.builder(
        itemCount: scholars.length,
        itemBuilder: (context, index) {
          final scholar = scholars[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: scholar['profilePicture'].isNotEmpty
                    ? NetworkImage(scholar['profilePicture'])
                    : AssetImage('assets/images/default_avatar.png') as ImageProvider,
              ),
              title: Text(scholar['name']),
              subtitle: Text(scholar['title']),
              trailing: Text('${scholar['rating']} ⭐'),
            ),
          );
        },
      ),
    );
  }
}


