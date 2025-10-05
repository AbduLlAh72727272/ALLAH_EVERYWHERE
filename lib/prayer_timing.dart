import 'package:allah_every_where/services/PrayerService.dart';
import 'package:allah_every_where/utils/utils/constraints/colors.dart';
import 'package:allah_every_where/utils/utils/constraints/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class PrayerTimingScreen extends StatefulWidget {
  @override
  _PrayerTimingScreenState createState() => _PrayerTimingScreenState();
}

class _PrayerTimingScreenState extends State<PrayerTimingScreen> {
  Map<String, String>? prayerTimes;
  Map<String, dynamic>? nextPrayer;
  Map<String, dynamic>? islamicDate;
  Position? currentPosition;
  String currentLocation = 'Loading...';
  bool isLoading = true;
  bool notificationsEnabled = true;
  Timer? _timer;
  
  // Prayer completion tracking
  Map<String, bool> prayerCompleted = {
    'Fajr': false,
    'Dhuhr': false,
    'Asr': false,
    'Maghrib': false,
    'Isha': false,
  };

  @override
  void initState() {
    super.initState();
    _initializeData();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadLocation();
    await _loadPrayerTimes();
    await _loadIslamicDate();
    await _loadNotificationSettings();
    _updateNextPrayer();
  }

  Future<void> _loadLocation() async {
    try {
      currentPosition = await PrayerService.getCurrentLocation();
      if (currentPosition != null) {
        currentLocation = await PrayerService.getAddressFromCoordinates(
          currentPosition!.latitude,
          currentPosition!.longitude,
        );
      }
    } catch (e) {
      currentLocation = 'Location unavailable';
    }
    if (mounted) setState(() {});
  }

  Future<void> _loadPrayerTimes() async {
    try {
      final data = await PrayerService.getCurrentLocationPrayerTimes();
      if (data != null && data['timings'] != null) {
        prayerTimes = Map<String, String>.from(data['timings']);
        
        // Schedule notifications if enabled
        if (notificationsEnabled && prayerTimes != null) {
          await PrayerService.schedulePrayerNotifications(prayerTimes!);
        }
      }
    } catch (e) {
      print('Error loading prayer times: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadIslamicDate() async {
    islamicDate = await PrayerService.getIslamicDate();
    if (mounted) setState(() {});
  }

  Future<void> _loadNotificationSettings() async {
    notificationsEnabled = await PrayerService.getNotificationsEnabled();
    if (mounted) setState(() {});
  }

  void _updateNextPrayer() {
    if (prayerTimes != null) {
      nextPrayer = PrayerService.getNextPrayer(prayerTimes!);
      if (mounted) setState(() {});
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      _updateNextPrayer();
    });
  }

  Future<void> _toggleNotifications() async {
    setState(() {
      notificationsEnabled = !notificationsEnabled;
    });
    
    await PrayerService.setNotificationsEnabled(notificationsEnabled);
    
    if (notificationsEnabled && prayerTimes != null) {
      await PrayerService.schedulePrayerNotifications(prayerTimes!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Prayer notifications enabled')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Prayer notifications disabled')),
      );
    }
  }

  Future<void> _showSettings() async {
    final methods = PrayerService.calculationMethods;
    final currentMethod = await PrayerService.getCalculationMethod();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Prayer Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Calculation Method'),
              subtitle: Text(methods[currentMethod] ?? 'ISNA'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pop(context);
                _showMethodSelection();
              },
            ),
            SwitchListTile(
              title: Text('Notifications'),
              subtitle: Text('Receive prayer time notifications'),
              value: notificationsEnabled,
              onChanged: (value) {
                Navigator.pop(context);
                _toggleNotifications();
              },
            ),
            ListTile(
              title: Text('Monthly Calendar'),
              subtitle: Text('View full month prayer times'),
              trailing: Icon(Icons.calendar_month),
              onTap: () {
                Navigator.pop(context);
                _showMonthlyCalendar();
              },
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

  void _showMethodSelection() {
    final methods = PrayerService.calculationMethods;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Calculation Method'),
        content: Container(
          width: double.maxFinite,
          height: 400.h,
          child: ListView(
            children: methods.entries.map((entry) {
              return ListTile(
                title: Text(
                  entry.value,
                  style: TextStyle(fontSize: 12.sp),
                ),
                onTap: () async {
                  await PrayerService.setCalculationMethod(entry.key);
                  Navigator.pop(context);
                  setState(() {
                    isLoading = true;
                  });
                  await _loadPrayerTimes();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Calculation method updated')),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showMonthlyCalendar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MonthlyPrayerCalendar(
          latitude: currentPosition?.latitude ?? 0.0,
          longitude: currentPosition?.longitude ?? 0.0,
        ),
      ),
    );
  }

  String _formatTimeRemaining(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Images
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(VoidImages.details_background),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Positioned(
            top: 120.h,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(VoidImages.prayer_timing_background),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          
          // Header
          Positioned(
            top: 40.h,
            left: 16.w,
            right: 16.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
                Column(
                  children: [
                    Text(
                      'Prayer Timing',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      currentLocation,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Image.asset(
                      VoidImages.bismillah,
                      height: 30.h,
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.settings, color: Colors.white),
                  onPressed: _showSettings,
                ),
              ],
            ),
          ),

          // Islamic Date and Next Prayer Info
          Positioned(
            top: 160.h,
            left: 16.w,
            right: 16.w,
            child: Column(
              children: [
                // Islamic Date
                if (islamicDate != null)
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${islamicDate!['day']} ${islamicDate!['month']['en']} ${islamicDate!['year']} AH',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${islamicDate!['weekday']['en']}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                
                SizedBox(height: 12.h),
                
                // Next Prayer Info
                if (nextPrayer != null)
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: VoidColors.secondary.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Next Prayer',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              '${nextPrayer!['name']} at ${nextPrayer!['time']}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Time Remaining',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              _formatTimeRemaining(nextPrayer!['timeRemaining']),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: VoidColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Prayer Times List
          Positioned(
            top: 320.h,
            left: 16.w,
            right: 16.w,
            bottom: 20.h,
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
                decoration: BoxDecoration(
                  color: VoidColors.secondary,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: isLoading
                    ? Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16.h),
                            Text('Loading prayer times...'),
                          ],
                        ),
                      )
                    : prayerTimes == null
                        ? Center(
                            child: Column(
                              children: [
                                Icon(Icons.error, size: 48.sp, color: Colors.red),
                                SizedBox(height: 16.h),
                                Text('Failed to load prayer times'),
                                SizedBox(height: 8.h),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    _loadPrayerTimes();
                                  },
                                  child: Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              // Notification toggle
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.notifications, color: Colors.black54),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Prayer Notifications',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Spacer(),
                                    Switch(
                                      value: notificationsEnabled,
                                      onChanged: (value) => _toggleNotifications(),
                                      activeColor: VoidColors.primary,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16.h),
                              
                              // Prayer times
                              ...['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'].map((prayer) {
                                if (prayerTimes!.containsKey(prayer)) {
                                  return PrayerTimingRow(
                                    time: prayerTimes![prayer]!,
                                    label: prayer,
                                    isCompleted: prayerCompleted[prayer] ?? false,
                                    onCompletedChanged: (completed) {
                                      setState(() {
                                        prayerCompleted[prayer] = completed;
                                      });
                                    },
                                  );
                                }
                                return SizedBox.shrink();
                              }).toList(),
                            ],
                          ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PrayerTimingRow extends StatelessWidget {
  final String time;
  final String label;
  final bool isCompleted;
  final Function(bool) onCompletedChanged;

  const PrayerTimingRow({
    Key? key,
    required this.time,
    required this.label,
    required this.isCompleted,
    required this.onCompletedChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0.h),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Prayer Icon
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: VoidColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                _getPrayerIcon(label),
                color: VoidColors.primary,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            
            // Prayer Name and Time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            
            // Action Buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Volume/Sound button
                IconButton(
                  icon: Icon(Icons.volume_up, color: Colors.grey[600]),
                  onPressed: () {
                    // TODO: Play adhan sound
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$label adhan sound')),
                    );
                  },
                ),
                
                // Completion checkbox
                Checkbox(
                  value: isCompleted,
                  onChanged: (bool? value) {
                    if (value != null) {
                      onCompletedChanged(value);
                    }
                  },
                  activeColor: VoidColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPrayerIcon(String prayer) {
    switch (prayer) {
      case 'Fajr':
        return Icons.wb_twilight;
      case 'Dhuhr':
        return Icons.wb_sunny;
      case 'Asr':
        return Icons.brightness_6;
      case 'Maghrib':
        return Icons.brightness_3;
      case 'Isha':
        return Icons.nights_stay;
      default:
        return Icons.access_time;
    }
  }
}

// Monthly Prayer Calendar Screen
class MonthlyPrayerCalendar extends StatefulWidget {
  final double latitude;
  final double longitude;

  const MonthlyPrayerCalendar({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  _MonthlyPrayerCalendarState createState() => _MonthlyPrayerCalendarState();
}

class _MonthlyPrayerCalendarState extends State<MonthlyPrayerCalendar> {
  List<Map<String, dynamic>> monthlyData = [];
  DateTime selectedMonth = DateTime.now();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMonthlyData();
  }

  Future<void> _loadMonthlyData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final method = await PrayerService.getCalculationMethod();
      final data = await PrayerService.getMonthlyPrayerTimes(
        latitude: widget.latitude,
        longitude: widget.longitude,
        month: selectedMonth,
        method: method,
      );
      
      setState(() {
        monthlyData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monthly Prayer Times'),
        backgroundColor: VoidColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedMonth,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null && picked != selectedMonth) {
                setState(() {
                  selectedMonth = picked;
                });
                _loadMonthlyData();
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : monthlyData.isEmpty
              ? Center(child: Text('No data available'))
              : ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: monthlyData.length,
                  itemBuilder: (context, index) {
                    final dayData = monthlyData[index];
                    final date = dayData['date'];
                    final timings = dayData['timings'];
                    
                    return Card(
                      margin: EdgeInsets.only(bottom: 8.h),
                      child: Padding(
                        padding: EdgeInsets.all(12.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${date['readable']}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildTimeColumn('Fajr', timings['Fajr']),
                                _buildTimeColumn('Dhuhr', timings['Dhuhr']),
                                _buildTimeColumn('Asr', timings['Asr']),
                                _buildTimeColumn('Maghrib', timings['Maghrib']),
                                _buildTimeColumn('Isha', timings['Isha']),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildTimeColumn(String prayer, String? time) {
    return Column(
      children: [
        Text(
          prayer,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          time ?? '--:--',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
