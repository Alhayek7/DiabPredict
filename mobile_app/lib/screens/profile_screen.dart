import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/local_storage_service.dart';
import 'package:share_plus/share_plus.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final LocalStorageService _storageService = LocalStorageService();
  final AuthService _authService = AuthService.instance;

  String _userName = 'مستخدم النظام';
  String _userEmail = 'user@example.com';
  int _predictionsCount = 0;
  double _averageRisk = 0;
  String _lastPredictionDate = 'لا توجد تنبؤات';
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'العربية';
  bool _isLoading = true;

  final List<String> _languages = ['العربية', 'English', 'Français'];

  @override
  void initState() {
    super.initState();
    _initAuth();
    _loadUserData();
    _loadStats();
  }

  Future<void> _initAuth() async {
    await _authService.init();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = _authService.currentUser;

    setState(() {
      if (_authService.isLoggedIn && currentUser != null) {
        _userName = currentUser.username;
        _userEmail = currentUser.email;
      } else if (_authService.isGuest && currentUser != null) {
        _userName = 'زائر (${currentUser.id.substring(0, 8)})';
        _userEmail = 'guest@diabpredict.local';
      }
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _selectedLanguage = prefs.getString('language') ?? 'العربية';
    });
  }

  Future<void> _loadStats() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    // ✅ استخدام Hive بدلاً من SharedPreferences
    final allPredictions = _storageService.getAllPredictions();
    final predictionsCount = allPredictions.length;

    double avgRisk = 0;
    if (predictionsCount > 0) {
      double sum = 0;
      for (var data in allPredictions) {
        sum += data.localRisk ?? data.calculateRiskLocally();
      }
      avgRisk = sum / predictionsCount;
    }

    String lastDate = 'لا توجد تنبؤات';
    if (predictionsCount > 0) {
      lastDate = _formatDate(allPredictions.last.timestamp.toIso8601String());
    }

    if (mounted) {
      setState(() {
        _predictionsCount = predictionsCount;
        _averageRisk = avgRisk;
        _lastPredictionDate = lastDate;
        _isLoading = false;
      });
    }
  }

// ✅ الكود الصحيح (بدون تكرار):
  Future<void> _updateUserName() async {
    final controller = TextEditingController(text: _userName);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل الاسم'),
        content: TextField(
          controller: controller,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            hintText: 'أدخل اسمك',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
            ),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', result);

      if (mounted) {
        setState(() => _userName = result);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم تحديث الاسم بنجاح'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);

    if (mounted) {
      // ✅ إضافة التحقق
      setState(() => _notificationsEnabled = value);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(value ? '✅ تم تفعيل الإشعارات' : '🔕 تم إيقاف الإشعارات'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _changeLanguage() async {
    String? tempLanguage = _selectedLanguage;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('اختر اللغة'),
              content: SizedBox(
                width: double.minPositive,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _languages.map((lang) {
                      return RadioMenuButton<String>(
                        value: lang,
                        groupValue: tempLanguage,
                        onChanged: (value) {
                          setStateDialog(() {
                            tempLanguage = value;
                          });
                        },
                        style: ButtonStyle(
                          overlayColor: WidgetStateProperty.all(
                            const Color(0xFF2563EB).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Text(lang, style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, tempLanguage);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                  ),
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    ).then((result) async {
      if (result != null && result != _selectedLanguage) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('language', result);

        if (mounted) {
          // ✅ إضافة التحقق
          setState(() => _selectedLanguage = result);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🌐 تم تغيير اللغة إلى $result'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  Future<void> _shareApp() async {
    await Share.share(
      'اكتشف تطبيق DiabPredict للتنبؤ المبكر بخطر السكري!\n\n'
      'https://play.google.com/store/apps/details?id=com.example.mobile_app',
      subject: 'DiabPredict - تنبؤ ذكي للسكري',
    );

    if (mounted) {
      // ✅ إضافة التحقق
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📱 تم نسخ رابط التطبيق'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
               foregroundColor: Colors.white,

            ),
          child: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white)),  ),
        ],
      ),
    );

    if (confirm == true) {
      // ✅ تسجيل الخروج من نظام المصادقة
      await _authService.logout();

      if (mounted) {
        // ✅ العودة إلى شاشة تسجيل الدخول
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'DiabPredict',
      applicationVersion: 'الإصدار 1.0.0',
      applicationIcon: const Icon(Icons.health_and_safety,
          size: 40, color: Color(0xFF2563EB)),
      children: const [
        SizedBox(height: 16),
        Text(
          'نظام ذكي للتنبؤ المبكر بخطر مرض السكري باستخدام تقنيات الذكاء الاصطناعي.',
          style: TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          '© 2025 - UCAS University',
          style: TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // void _showRateDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('قيم التطبيق'),
  //       content: const Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Text('هل أعجبك التطبيق؟ ساعدنا في تحسينه بتقييم 5 نجوم!'),
  //           SizedBox(height: 16),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Icon(Icons.star, color: Colors.amber, size: 32),
  //               Icon(Icons.star, color: Colors.amber, size: 32),
  //               Icon(Icons.star, color: Colors.amber, size: 32),
  //               Icon(Icons.star, color: Colors.amber, size: 32),
  //               Icon(Icons.star, color: Colors.amber, size: 32),
  //             ],
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('لاحقاً'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             if (mounted) {
  //               // ✅ إضافة التحقق
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 const SnackBar(
  //                   content: Text('شكراً لتقييمك! ⭐'),
  //                   duration: Duration(seconds: 2),
  //                 ),
  //               );
  //             }
  //           },
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: const Color(0xFF2563EB),
  //           ),
  //           child: const Text('تقييم الآن'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
appBar: AppBar(
  leading: IconButton(
    icon: const Icon(Icons.arrow_back_ios),
    onPressed: () {
      Navigator.pushNamedAndRemoveUntil(
        context, 
        '/home', 
        (route) => false,
      );
    },
    tooltip: 'العودة إلى الرئيسية',
  ),
  title: const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.person, size: 24),
      SizedBox(width: 8),
      Text(
        'الملف الشخصي',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ],
  ),
  backgroundColor: Colors.white,
  foregroundColor: const Color(0xFF1E293B),
  elevation: 0,
  centerTitle: true,
  actions: [
    IconButton(
      icon: const Icon(Icons.edit_outlined),
      onPressed: _updateUserName,
      tooltip: 'تعديل الملف',
    ),
  ],
),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProfileCard(),
              const SizedBox(height: 20),
              _buildStatsSection(),
              const SizedBox(height: 20),
              _buildSettingsSection(),
              const SizedBox(height: 20),
              _buildActionsSection(),
              const SizedBox(height: 20),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '👤',
                style: TextStyle(fontSize: 48),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _userName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email_outlined, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                _userEmail,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _updateUserName,
            icon: const Icon(Icons.edit, size: 18),
            label: const Text(
              'تعديل الملف',
              style: TextStyle(fontSize: 13),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.analytics,
                    color: Color(0xFF2563EB), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'إحصائياتي',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Row(
              children: [
                _buildStatItem(
                  icon: Icons.history,
                  value: '$_predictionsCount',
                  label: 'تنبؤ',
                  color: const Color(0xFF2563EB),
                ),
                _buildStatItem(
                  icon: Icons.trending_up,
                  value: '${_averageRisk.toStringAsFixed(1)}%',
                  label: 'متوسط الخطر',
                  color: _averageRisk < 30
                      ? const Color(0xFF10B981)
                      : (_averageRisk < 60
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFFEF4444)),
                ),
                _buildStatItem(
                  icon: Icons.calendar_today,
                  value: _lastPredictionDate,
                  label: 'آخر تنبؤ',
                  color: const Color(0xFF7C3AED),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.settings,
                    color: Color(0xFF2563EB), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'الإعدادات',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingsSwitch(
            icon: Icons.notifications,
            title: 'الإشعارات',
            subtitle: 'تلقي تنبيهات وتذكيرات صحية',
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
          ),
          const Divider(height: 0),
          _buildSettingsTile(
            icon: Icons.language,
            title: 'اللغة',
            subtitle: _selectedLanguage,
            trailing: const Icon(Icons.chevron_left, size: 20),
            onTap: _changeLanguage,
          ),
          // const Divider(height: 0),
          // _buildSettingsSwitch(
          //   icon: Icons.dark_mode,
          //   title: 'الوضع المظلم',
          //   subtitle: 'قيد التطوير',
          //   value: false,
          //   onChanged: (value) {},
          //   enabled: false,
          // ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.more_horiz,
                    color: Color(0xFF2563EB), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'إجراءات',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActionsTile(
            icon: Icons.info_outline,
            title: 'عن التطبيق',
            subtitle: 'الإصدار 1.0.0',
            onTap: _showAboutDialog,
          ),
          const Divider(height: 0),
          _buildActionsTile(
            icon: Icons.share,
            title: 'مشاركة التطبيق',
            subtitle: 'أرسل الرابط لأصدقائك',
            onTap: _shareApp,
          ),
          const Divider(height: 0),
          _buildActionsTile(
            icon: Icons.logout,
            title: 'تسجيل الخروج',
            subtitle: 'الخروج من التطبيق',
            onTap: _logout,
            iconColor: Colors.red,
            textColor: const Color.fromARGB(255, 255, 254, 254),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2563EB), size: 22),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  Widget _buildSettingsSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    bool enabled = true,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: const Color(0xFF2563EB), size: 22),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      value: value,
      onChanged: enabled ? onChanged : null,
      activeTrackColor: const Color(0xFF2563EB),
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  Widget _buildActionsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading:
          Icon(icon, color: iconColor ?? const Color(0xFF2563EB), size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textColor ?? const Color(0xFF1E293B),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: const Icon(Icons.chevron_left, size: 20),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Text(
          'DiabPredict',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '© 2025 - UCAS University',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha:0.08),
          spreadRadius: 1,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  String _formatDate(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return timestamp;
    }
  }
}
