import 'package:allah_every_where/services/AuthService.dart';
import 'package:allah_every_where/utils/utils/constraints/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'About_us.dart';
import 'login.dart';
import 'notification.dart';
import 'editprofilescreen.dart';
import 'change_password_screen.dart';
import 'privacy_policy.dart';
import 'settings.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isGuestMode = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      _isGuestMode = await AuthService.isGuestMode();
      
      if (!_isGuestMode) {
        final userData = await AuthService.getUserData();
        setState(() {
          _userData = userData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          if (!_isGuestMode)
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () => Get.to(() => EditProfileScreen()),
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header
                  _buildProfileHeader(),
                  SizedBox(height: 20.h),
                  
                  // Statistics Section
                  if (!_isGuestMode) _buildStatisticsSection(),
                  if (!_isGuestMode) SizedBox(height: 20.h),
                  
                  // Menu Options
                  _buildMenuOptions(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    if (_isGuestMode) {
      return Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50.r,
              backgroundColor: Colors.grey[300],
              child: Icon(
                Icons.person_outline,
                size: 50.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Guest User',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'Sign in to access all features',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => Get.off(() => Login()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              ),
              child: Text(
                'Sign In',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Picture
          Stack(
            children: [
              CircleAvatar(
                radius: 50.r,
                backgroundColor: Colors.grey[200],
                backgroundImage: _userData?['photoUrl'] != null && _userData!['photoUrl'].isNotEmpty
                    ? NetworkImage(_userData!['photoUrl'])
                    : AssetImage(VoidImages.profile) as ImageProvider,
              ),
              if (!AuthService.isEmailVerified)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.warning,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          
          // User Name
          Text(
            _userData?['name'] ?? 'User',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4.h),
          
          // Email
          Text(
            _userData?['email'] ?? '',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          
          // Email verification status
          if (!AuthService.isEmailVerified)
            Container(
              margin: EdgeInsets.only(top: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning, size: 16, color: Colors.orange),
                  SizedBox(width: 4.w),
                  Text(
                    'Email not verified',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.orange[800],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    final stats = _userData?['stats'] ?? {};
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Islamic Journey',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Hadith Read',
                '${stats['hadithRead'] ?? 0}',
                Icons.book,
                Colors.green,
              ),
              _buildStatItem(
                'Mosques',
                '${stats['mosqueVisited'] ?? 0}',
                Icons.mosque,
                Colors.blue,
              ),
              _buildStatItem(
                'Tasbeeh',
                '${stats['tasbeehCount'] ?? 0}',
                Icons.radio_button_checked,
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 60.w,
          height: 60.h,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Icon(icon, color: color, size: 30.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMenuOptions() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (!_isGuestMode) ...[
            _buildMenuItem(
              icon: Icons.person,
              text: 'Edit Profile',
              onTap: () => Get.to(() => EditProfileScreen()),
            ),
            _buildMenuItem(
              icon: Icons.lock,
              text: 'Change Password',
              onTap: () => Get.to(() => ChangePasswordScreen()),
            ),
            if (!AuthService.isEmailVerified)
              _buildMenuItem(
                icon: Icons.verified_user,
                text: 'Verify Email',
                onTap: _verifyEmail,
                color: Colors.orange,
              ),
          ],
          _buildMenuItem(
            icon: Icons.favorite,
            text: 'Your Favorites',
            onTap: () => _showComingSoon('Favorites'),
          ),
          _buildMenuItem(
            icon: Icons.settings,
            text: 'Settings',
            onTap: () => Get.to(() => SettingsScreen()),
          ),
          _buildMenuItem(
            icon: Icons.notifications,
            text: 'Notifications',
            onTap: () => Get.to(() => NotificationsScreen()),
          ),
          _buildMenuItem(
            icon: Icons.privacy_tip,
            text: 'Privacy Policy',
            onTap: () => Get.to(() => PrivacyPolicyScreen()),
          ),
          _buildMenuItem(
            icon: Icons.info,
            text: 'About Us',
            onTap: () => Get.to(() => AboutUsScreen()),
          ),
          _buildMenuItem(
            icon: Icons.share,
            text: 'Share App',
            onTap: _shareApp,
          ),
          if (!_isGuestMode)
            _buildMenuItem(
              icon: Icons.delete,
              text: 'Delete Account',
              onTap: _showDeleteAccountDialog,
              color: Colors.red,
            ),
          _buildMenuItem(
            icon: Icons.logout,
            text: _isGuestMode ? 'Sign In' : 'Log Out',
            onTap: _isGuestMode ? () => Get.off(() => Login()) : _showLogoutDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? Colors.blue,
        size: 24.sp,
      ),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 16.sp,
          color: color ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16.sp,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  void _verifyEmail() async {
    try {
      await AuthService.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification email sent! Check your inbox.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send verification email: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _shareApp() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature feature coming soon!')),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account'),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _showPasswordConfirmationDialog(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPasswordConfirmationDialog() {
    final TextEditingController passwordController = TextEditingController();
    
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please enter your password to delete your account:'),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
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
            onPressed: () async {
              try {
                await AuthService.deleteAccount(passwordController.text);
                Navigator.pop(context);
                Get.offAll(() => Login());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Account deleted successfully')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete account: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete Account', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log Out'),
        content: Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await AuthService.signOut();
                Navigator.pop(context);
                Get.offAll(() => Login());
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to log out: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
