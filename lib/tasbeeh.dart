import 'package:allah_every_where/utils/utils/constraints/colors.dart';
import 'package:allah_every_where/services/TasbeehService.dart';
import 'package:allah_every_where/services/NotificationService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class TasbeehScreen extends StatefulWidget {
  @override
  _TasbeehScreenState createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> with TickerProviderStateMixin {
  int tasbeehCount = 0;
  int totalCount = 0;
  int lapCount = 0;
  int selectedTasbeehId = 1;
  Map<String, dynamic> currentTasbeeh = TasbeehService.defaultTasbeehList[0];
  Color beadColor = Colors.blue;
  List<bool> beadStates = List.generate(33, (index) => false);
  
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  
  bool _isVibrationEnabled = true;
  bool _isSoundEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _setupAnimations();
    _loadProgress();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedTasbeehId = prefs.getInt('selected_tasbeeh_id') ?? 1;
      currentTasbeeh = TasbeehService.getTasbeehById(selectedTasbeehId) ?? 
                      TasbeehService.defaultTasbeehList[0];
      _isVibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      _isSoundEnabled = prefs.getBool('sound_enabled') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_tasbeeh_id', selectedTasbeehId);
    await prefs.setBool('vibration_enabled', _isVibrationEnabled);
    await prefs.setBool('sound_enabled', _isSoundEnabled);
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      tasbeehCount = prefs.getInt('tasbeeh_count_$selectedTasbeehId') ?? 0;
      totalCount = prefs.getInt('total_tasbeeh_count_$selectedTasbeehId') ?? 0;
      lapCount = prefs.getInt('lap_count_$selectedTasbeehId') ?? 0;
      
      // Update bead states based on current count
      int currentBeadIndex = tasbeehCount % (currentTasbeeh['target'] as int);
      beadStates = List.generate(currentTasbeeh['target'] as int, (index) => index < currentBeadIndex);
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbeeh_count_$selectedTasbeehId', tasbeehCount);
    await prefs.setInt('total_tasbeeh_count_$selectedTasbeehId', totalCount);
    await prefs.setInt('lap_count_$selectedTasbeehId', lapCount);
  }

  void incrementTasbeeh() {
    setState(() {
      tasbeehCount++;
      totalCount++;
      
      int target = currentTasbeeh['target'] as int;
      int currentIndex = (tasbeehCount - 1) % target;
      
      // Reset beads when starting a new cycle
      if (currentIndex == 0 && tasbeehCount > 1) {
        beadStates = List.generate(target, (index) => false);
        lapCount++;
      }
      
      // Update current bead
      beadStates[currentIndex] = true;
      
      // Trigger animations
      _pulseController.forward().then((_) => _pulseController.reverse());
      _rotationController.forward().then((_) => _rotationController.reverse());
      
      // Haptic feedback
      if (_isVibrationEnabled) {
        HapticFeedback.lightImpact();
      }
      
      // Check if target reached
      if (tasbeehCount % target == 0) {
        _onTargetReached();
      }
    });
    
    _saveProgress();
  }

  void _onTargetReached() async {
    // Strong haptic feedback for completion
    if (_isVibrationEnabled) {
      HapticFeedback.mediumImpact();
    }
    
    // Show completion dialog
    _showCompletionDialog();
    
    // Send notification
    await NotificationService.showInstantNotification(
      title: 'Tasbeeh Completed!',
      body: 'Alhamdulillah! You have completed ${currentTasbeeh['title']}',
      payload: 'tasbeeh_completed',
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alhamdulillah!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: Colors.amber, size: 50),
              SizedBox(height: 16),
              Text('You have completed ${currentTasbeeh['title']}'),
              SizedBox(height: 8),
              Text(currentTasbeeh['reward'], 
                   style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _continueTasbeeh();
              },
              child: Text('Continue'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _switchTasbeeh();
              },
              child: Text('Switch Dhikr'),
            ),
          ],
        );
      },
    );
  }

  void _continueTasbeeh() {
    // Continue with the same dhikr
  }

  void _switchTasbeeh() {
    _showTasbeehSelector();
  }

  void resetTasbeeh() {
    setState(() {
      tasbeehCount = 0;
      lapCount = 0;
      int target = currentTasbeeh['target'] as int;
      beadStates = List.generate(target, (index) => false);
    });
    _saveProgress();
  }

  void resetAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tasbeeh_count_$selectedTasbeehId');
    await prefs.remove('total_tasbeeh_count_$selectedTasbeehId');
    await prefs.remove('lap_count_$selectedTasbeehId');
    
    setState(() {
      tasbeehCount = 0;
      totalCount = 0;
      lapCount = 0;
      int target = currentTasbeeh['target'] as int;
      beadStates = List.generate(target, (index) => false);
    });
  }

  void changeBeadColor(Color color) {
    setState(() {
      beadColor = color;
    });
  }

  void _showTasbeehSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Select Dhikr',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: TasbeehService.getAllTasbeeh().length,
                  itemBuilder: (context, index) {
                    final tasbeeh = TasbeehService.getAllTasbeeh()[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${tasbeeh['id']}'),
                        backgroundColor: selectedTasbeehId == tasbeeh['id'] 
                          ? Colors.green : Colors.grey,
                      ),
                      title: Text(tasbeeh['title']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tasbeeh['arabic'], 
                               style: TextStyle(fontFamily: 'NotoNaskhArabic')),
                          Text('Target: ${tasbeeh['target']}'),
                        ],
                      ),
                      trailing: selectedTasbeehId == tasbeeh['id'] 
                        ? Icon(Icons.check, color: Colors.green) 
                        : null,
                      onTap: () {
                        setState(() {
                          selectedTasbeehId = tasbeeh['id'];
                          currentTasbeeh = tasbeeh;
                          int target = currentTasbeeh['target'] as int;
                          beadStates = List.generate(target, (index) => false);
                        });
                        _saveSettings();
                        _loadProgress();
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  SwitchListTile(
                    title: Text('Vibration'),
                    value: _isVibrationEnabled,
                    onChanged: (value) {
                      setModalState(() {
                        _isVibrationEnabled = value;
                      });
                      setState(() {
                        _isVibrationEnabled = value;
                      });
                      _saveSettings();
                    },
                  ),
                  SwitchListTile(
                    title: Text('Sound'),
                    value: _isSoundEnabled,
                    onChanged: (value) {
                      setModalState(() {
                        _isSoundEnabled = value;
                      });
                      setState(() {
                        _isSoundEnabled = value;
                      });
                      _saveSettings();
                    },
                  ),
                  ListTile(
                    title: Text('Reset All Progress'),
                    leading: Icon(Icons.refresh, color: Colors.red),
                    onTap: () {
                      Navigator.pop(context);
                      _showResetConfirmation();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset All Progress'),
          content: Text('Are you sure you want to reset all your tasbeeh progress? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetAllProgress();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int target = currentTasbeeh['target'] as int;
    double progress = TasbeehService.getCompletionPercentage(tasbeehCount % target, target);
    String motivationalMessage = TasbeehService.getMotivationalMessage(progress);
    
    return Scaffold(
      backgroundColor: VoidColors.secondary,
      body: Column(
        children: [
          // Custom App Bar
          Stack(
            children: [
              ClipPath(
                clipper: CustomAppBarClipper(),
                child: Container(
                  height: 120.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFC6AC9F), Color(0xFF60534D)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  alignment: Alignment.center,
                ),
              ),
              Positioned(
                top: 40.h,
                left: 16.w,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Positioned(
                top: 60.h,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Digital Tasbeeh',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40.h,
                right: 16.w,
                child: PopupMenuButton(
                  icon: Icon(Icons.more_vert, color: Colors.black),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'select',
                      child: Row(
                        children: [
                          Icon(Icons.list),
                          SizedBox(width: 8),
                          Text('Select Dhikr'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: [
                          Icon(Icons.settings),
                          SizedBox(width: 8),
                          Text('Settings'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'select') {
                      _showTasbeehSelector();
                    } else if (value == 'settings') {
                      _showSettings();
                    }
                  },
                ),
              ),
            ],
          ),

          // Current Dhikr Info
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  currentTasbeeh['title'],
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  currentTasbeeh['arabic'],
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontFamily: 'NotoNaskhArabic',
                    color: Colors.green.shade700,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  currentTasbeeh['translation'],
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                SizedBox(height: 8),
                Text(
                  '${tasbeehCount % target} / $target',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Digital Tasbeeh Counter
          Expanded(
            child: GestureDetector(
              onTap: incrementTasbeeh,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationAnimation.value,
                          child: Container(
                            margin: EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  beadColor.withOpacity(0.8),
                                  beadColor,
                                  beadColor.withOpacity(0.6),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: beadColor.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${tasbeehCount % target}',
                                    style: TextStyle(
                                      fontSize: 48.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'TAP TO COUNT',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.white.withOpacity(0.8),
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  if (lapCount > 0) ...[
                                    SizedBox(height: 8),
                                    Text(
                                      'Cycles: $lapCount',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          // Motivational Message
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Text(
              motivationalMessage,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.green.shade700,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Statistics and Reset Section
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard('Today', '${tasbeehCount % target}'),
                    _buildStatCard('Total', '$totalCount'),
                    _buildStatCard('Cycles', '$lapCount'),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: resetTasbeeh,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Reset Current', style: TextStyle(color: Colors.white)),
                    ),
                    // Color Selector
                    Row(
                      children: [
                        ColorPicker(color: Colors.blue, onTap: () => changeBeadColor(Colors.blue)),
                        SizedBox(width: 8),
                        ColorPicker(color: Colors.green, onTap: () => changeBeadColor(Colors.green)),
                        SizedBox(width: 8),
                        ColorPicker(color: Colors.purple, onTap: () => changeBeadColor(Colors.purple)),
                        SizedBox(width: 8),
                        ColorPicker(color: Colors.orange, onTap: () => changeBeadColor(Colors.orange)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class CustomAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class ColorPicker extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const ColorPicker({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30.w,
        height: 30.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
      ),
    );
  }
}
