import 'package:flutter/material.dart';
import 'screens/contact_screen.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/onboarding_screen.dart';
import 'screens/predict_screen.dart';
import 'screens/assistant_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/about_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'services/local_storage_service.dart';
import 'services/notification_service.dart';
import 'package:provider/provider.dart';
import 'providers/font_size_provider.dart';
import 'screens/login_screen.dart'; // ✅ أضف هذا
import 'screens/register_screen.dart'; // ✅ أضف هذا
// في بداية الملف بعد الاستيرادات

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ تهيئة الإشعارات
  await NotificationService.init();

  final storage = LocalStorageService();
  await storage.init();
  // ✅ تحميل حجم الخط قبل تشغيل التطبيق
  final fontSizeProvider = FontSizeProvider();
  await fontSizeProvider.loadFontSize();

  runApp(
    ChangeNotifierProvider(
      create: (context) => fontSizeProvider,
      child: const DiabPredictApp(),
    ),
  );
}

class DiabPredictApp extends StatelessWidget {
  const DiabPredictApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ الحصول على حجم الخط من Provider
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final baseFontSize = fontSizeProvider.fontSize;

    return MaterialApp(
      title: 'DiabPredict',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'SA'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'SA'),
        Locale('en', 'US'),
      ],
      theme: ThemeData(
        primaryColor: const Color(0xFF2563EB),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2563EB),
          secondary: Color(0xFF0284C7),
        ),
        useMaterial3: true,
        fontFamily: 'Cairo',
        scaffoldBackgroundColor: const Color(0xFFF0F9FF),
        // ✅ تطبيق حجم الخط على جميع النصوص
        textTheme: TextTheme(
          displayLarge: TextStyle(
              fontSize: baseFontSize + 8, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(
              fontSize: baseFontSize + 6, fontWeight: FontWeight.bold),
          displaySmall: TextStyle(
              fontSize: baseFontSize + 4, fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(
              fontSize: baseFontSize + 4, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(
              fontSize: baseFontSize + 2, fontWeight: FontWeight.bold),
          headlineSmall:
              TextStyle(fontSize: baseFontSize, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(
              fontSize: baseFontSize + 2, fontWeight: FontWeight.w600),
          titleMedium:
              TextStyle(fontSize: baseFontSize, fontWeight: FontWeight.w600),
          titleSmall: TextStyle(
              fontSize: baseFontSize - 2, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: baseFontSize),
          bodyMedium: TextStyle(fontSize: baseFontSize - 2),
          bodySmall: TextStyle(fontSize: baseFontSize - 4),
          labelLarge: TextStyle(fontSize: baseFontSize),
          labelMedium: TextStyle(fontSize: baseFontSize - 2),
          labelSmall: TextStyle(fontSize: baseFontSize - 4),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFF2563EB)),
          titleTextStyle: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/': (context) => const SplashScreen(),
        '/splash': (context) => const SplashScreen(),
        '/check': (context) => const CheckFirstTime(),
        '/home': (context) => const MainScreen(),
        '/predict': (context) => const PredictScreen(),
        '/assistant': (context) => const AssistantScreen(),
        '/history': (context) => const HistoryScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/about': (context) => const AboutScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/contact': (context) => const ContactScreen(),
      },
    );
  }
}

// ============================================================
// 🎨 شاشة البداية (Splash Screen)
// ============================================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/check');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LogoWithShadow(),
            SizedBox(height: 24),
            Text(
              'DiabPredict',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 8),
            _SubtitleText(),
            SizedBox(height: 40),
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xFF2563EB),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ فصل widgets لاستخدام const
class _LogoWithShadow extends StatelessWidget {
  const _LogoWithShadow();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB)
                .withValues(alpha: 0.3), // ✅ استخدام withValues
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo.png',
          width: 140,
          height: 140,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _SubtitleText extends StatelessWidget {
  const _SubtitleText();

  @override
  Widget build(BuildContext context) {
    return Text(
      'نظام ذكي للتنبؤ المبكر بخطر السكري',
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[600],
      ),
    );
  }
}

// ============================================================
// ✅ التحقق من أول مرة (Onboarding)
// ============================================================
class CheckFirstTime extends StatefulWidget {
  const CheckFirstTime({super.key});

  @override
  State<CheckFirstTime> createState() => _CheckFirstTimeState();
}

class _CheckFirstTimeState extends State<CheckFirstTime> {
  bool _isLoading = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    setState(() {
      _showOnboarding = !hasSeenOnboarding;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // ✅ نظيف، بسيط، يعمل
    return _showOnboarding ? const OnboardingScreen() : const MainScreen();
  }
}

// ============================================================
// 🏠 الصفحة الرئيسية (Main Screen) - مع قائمة سفلية وأعلى
// ============================================================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const PredictScreen(),
    const AssistantScreen(),
    const HistoryScreen(),
    const AboutScreen(),
  ];

  final List<String> _titles = [
    'الرئيسية',
    'التنبؤ',
    'المساعد الذكي',
    'السجل',
    'عن النظام',
  ];

  final List<IconData> _icons = [
    Icons.home_outlined,
    Icons.analytics_outlined,
    Icons.auto_awesome_outlined,
    Icons.history_outlined,
    Icons.info_outline,
  ];

  final List<IconData> _activeIcons = [
    Icons.home,
    Icons.analytics,
    Icons.auto_awesome,
    Icons.history,
    Icons.info,
  ];

  void _goBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context); // العودة للصفحة السابقة
    } else {
      // العودة إلى تبويب "الرئيسية" داخل التطبيق
      setState(() {
        _selectedIndex = 0; // الانتقال إلى تبويب الرئيسية
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      appBar: AppBar(
        // leading: IconButton(
        //     icon: const Icon(Icons.arrow_back_ios),
        //     onPressed: () => _goBack(context),
        //   ),
        automaticallyImplyLeading: false,
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          // زر الإشعارات
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              _showNotificationsDialog();
            },
            tooltip: 'الإشعارات',
          ),
          // زر الإعدادات
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              _showSettingsDialog();
            },
            tooltip: 'الإعدادات',
          ),
          // قائمة منسدلة للملف الشخصي
          PopupMenuButton<String>(
            icon: const Icon(Icons.person_outline),
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.pushNamed(context, '/profile');
              } else if (value == 'logout') {
                _showLogoutDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20),
                    SizedBox(width: 8),
                    Text('الملف الشخصي'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: List.generate(_titles.length, (index) {
          return NavigationDestination(
            icon: Icon(_icons[index]),
            selectedIcon: Icon(_activeIcons[index]),
            label: _titles[index],
          );
        }),
      ),
    );
  }

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الإشعارات'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  Icon(Icons.notifications_active, color: Color(0xFF2563EB)),
              title: Text('مرحباً بك في تطبيق DiabPredict'),
              subtitle: Text('ابدأ رحلتك نحو حياة أكثر صحة'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.analytics, color: Color(0xFF2563EB)),
              title: Text('قم بإجراء تنبؤك الأول'),
              subtitle: Text('استخدم الذكاء الاصطناعي لتقييم حالتك'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    Navigator.pushNamed(context, '/settings');
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.clear();

    // ✅ حذف حالة تسجيل الدخول (إضافي)
    // await prefs.setBool('is_logged_in', false);

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  // ✅ دالة لتغيير التبويبة من خارج الصفحة
  void changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    // التحقق من سبب الوصول إلى الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args == 'from_home') {
        setState(() {
          _selectedIndex = 1; // الانتقال إلى تبويبة التنبؤ
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == 'open_predict') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedIndex = 1; // الانتقال إلى تبويبة التنبؤ
        });
      });
    }
  }
}
