import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.privacy_tip,
                            color: Color(0xFF2563EB), size: 28),
                        SizedBox(width: 12),
                        Text(
                          'سياسة الخصوصية',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildPolicySection(
                      title: '📌 1. المعلومات التي نجمعها',
                      content:
                          'لا نجمع أي معلومات شخصية. يتم تخزين بياناتك محلياً على جهازك فقط.',
                    ),
                    const SizedBox(height: 16),
                    _buildPolicySection(
                      title: '📌 2. كيف نستخدم معلوماتك',
                      content:
                          'بياناتك تستخدم فقط لحساب نسبة خطر الإصابة والتحليل الشخصي.',
                    ),
                    const SizedBox(height: 16),
                    _buildPolicySection(
                      title: '📌 3. الأمان',
                      content:
                          'نحن نحمي بياناتك باستخدام التخزين الآمن (Hive) والتشفير المحلي.',
                    ),
                    const SizedBox(height: 16),
                    _buildPolicySection(
                      title: '📌 4. إخلاء مسؤولية طبي',
                      content:
                          'هذا التطبيق ليس أداة تشخيص طبية. يُرجى استشارة الطبيب المختص.',
                    ),
                    const SizedBox(height: 16),
                    _buildPolicySection(
                      title: '📌 5. اتصل بنا',
                      content: 'للاستفسارات: diabpredict@ucas.edu.ps',
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('إغلاق',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  void _showMedicalDisclaimer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.medical_information,
                            color: Color(0xFFEF4444), size: 28),
                        SizedBox(width: 12),
                        Text(
                          '⚠️ إخلاء مسؤولية طبي',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: const Column(
                        children: [
                          _DisclaimerItem(
                              number: '1',
                              text:
                                  'هذا التطبيق هو أداة توعوية فقط وليس بديلاً عن الاستشارة الطبية.'),
                          SizedBox(height: 12),
                          _DisclaimerItem(
                              number: '2',
                              text:
                                  'النتائج التي يقدمها هي تقديرات احتمالية تعتمد على البيانات المدخلة.'),
                          SizedBox(height: 12),
                          _DisclaimerItem(
                              number: '3',
                              text:
                                  'يجب عدم الاعتماد على نتائج التطبيق وحدها في اتخاذ القرارات الطبية.'),
                          SizedBox(height: 12),
                          _DisclaimerItem(
                              number: '4',
                              text:
                                  'نوصي باستشارة الطبيب المختص لتقييم حالتك الصحية بدقة.'),
                          SizedBox(height: 12),
                          _DisclaimerItem(
                              number: '5',
                              text:
                                  'نحن غير مسؤولين عن أي قرارات طبية تتخذ بناءً على نتائج التطبيق.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('فهمت',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar(context, 'لا يمكن فتح الرابط');
      }
    } catch (e) {
      _showSnackBar(context, 'حدث خطأ في فتح الرابط');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الشعار
              _buildHeader(),
              const SizedBox(height: 28),

              // وصف المشروع
              _buildSection(
                title: '📖 عن المشروع',
                icon: Icons.description,
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DiabPredict هو نظام ذكي يستخدم تقنيات الذكاء الاصطناعي للتنبؤ المبكر بخطر الإصابة بمرض السكري من النوع الثاني، مع تقديم تفسيرات شفافة ونصائح صحية مخصصة.',
                      style: TextStyle(
                          fontSize: 14, height: 1.5, color: Color(0xFF334155)),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'يهدف المشروع إلى تمكين الأفراد من فهم حالتهم الصحية واتخاذ إجراءات وقائية، مما يساهم في تقليل عبء المرض على الفرد والمجتمع.',
                      style: TextStyle(
                          fontSize: 14, height: 1.5, color: Color(0xFF334155)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // أهداف المشروع
              _buildSection(
                title: '🎯 أهداف المشروع',
                icon: Icons.track_changes,
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
                ),
                child: const Column(
                  children: [
                    _GoalItem(
                        emoji: '🎯',
                        title: 'الكشف المبكر',
                        description: 'نسبة دقة 94% في التنبؤ بخطر الإصابة'),
                    Divider(
                        height: 24, thickness: 0.5, color: Color(0xFFE2E8F0)),
                    _GoalItem(
                        emoji: '📊',
                        title: 'شفافية النتائج',
                        description: 'تفسير العوامل المؤثرة باستخدام SHAP'),
                    Divider(
                        height: 24, thickness: 0.5, color: Color(0xFFE2E8F0)),
                    _GoalItem(
                        emoji: '💬',
                        title: 'نصائح مخصصة',
                        description:
                            'توصيات صحية مدعومة بالذكاء الاصطناعي Gemini'),
                    Divider(
                        height: 24, thickness: 0.5, color: Color(0xFFE2E8F0)),
                    _GoalItem(
                        emoji: '📱',
                        title: 'سهولة الوصول',
                        description: 'تطبيق موبايل وموقع ويب باللغة العربية'),
                    Divider(
                        height: 24, thickness: 0.5, color: Color(0xFFE2E8F0)),
                    _GoalItem(
                        emoji: '📈',
                        title: 'متابعة مستمرة',
                        description: 'تتبع تطور الحالة الصحية عبر الزمن'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // التقنيات المستخدمة
              _buildSection(
                title: '🛠️ التقنيات المستخدمة',
                icon: Icons.code,
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF34D399)],
                ),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: const [
                    _TechChip(
                        label: '🐍 Python',
                        color: Color(0xFF306998),
                        percentage: 0.9),
                    _TechChip(
                        label: '🤖 XGBoost',
                        color: Color(0xFFD45B20),
                        percentage: 0.85),
                    _TechChip(
                        label: '📊 SHAP',
                        color: Color(0xFF2C3E50),
                        percentage: 0.8),
                    _TechChip(
                        label: '🚀 FastAPI',
                        color: Color(0xFF009688),
                        percentage: 0.85),
                    _TechChip(
                        label: '🌐 Streamlit',
                        color: Color(0xFFFF4B4B),
                        percentage: 0.8),
                    _TechChip(
                        label: '💬 Gemini AI',
                        color: Color(0xFF4285F4),
                        percentage: 0.75),
                    _TechChip(
                        label: '📱 Flutter',
                        color: Color(0xFF02569B),
                        percentage: 0.9),
                    _TechChip(
                        label: '💾 Hive',
                        color: Color(0xFF00A896),
                        percentage: 0.85),
                    _TechChip(
                        label: '🐳 Docker',
                        color: Color(0xFF2496ED),
                        percentage: 0.7),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // إحصائيات المشروع
              _buildSection(
                title: '📊 إحصائيات المشروع',
                icon: Icons.analytics,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                ),
                child: const Row(
                  children: [
                    Expanded(
                        child: _StatItem(
                            emoji: '📈',
                            value: '10,000+',
                            label: 'سجل تدريبي')),
                    SizedBox(
                        width: 1,
                        height: 50,
                        child: VerticalDivider(color: Color(0xFFE2E8F0))),
                    Expanded(
                        child: _StatItem(
                            emoji: '🎯', value: '94%', label: 'دقة التنبؤ')),
                    SizedBox(
                        width: 1,
                        height: 50,
                        child: VerticalDivider(color: Color(0xFFE2E8F0))),
                    Expanded(
                        child: _StatItem(
                            emoji: '⚡', value: '< 1s', label: 'زمن الاستجابة')),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // فريق العمل
              _buildSection(
                title: '👥 فريق العمل',
                icon: Icons.people,
                gradient: const LinearGradient(
                  colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
                ),
                child: const Column(
                  children: [
                    _TeamMember(
                      name: 'Eid Ahmed Abo Baid',
                      role: 'Data Science & AI',
                      imagePath:
                          'assets/images/team/eid.jpg', // ✅ ضع الصورة هنا
                    ),
                    Divider(
                        height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
                    _TeamMember(
                      name: 'Ahmed Wesam AlHayek',
                      role: 'Full Stack Developer',
                      imagePath: 'assets/images/team/ahmed.jpg',
                    ),
                    Divider(
                        height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
                    _TeamMember(
                      name: 'Ahmed Mamon Osrofe',
                      role: 'Data Science & AI',
                      imagePath: 'assets/images/team/osrofe.jpg',
                    ),
                    Divider(
                        height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
                    _TeamMember(
                      name: 'Abdulrahman Salah',
                      role: 'Data Science & AI',
                      imagePath: 'assets/images/team/abdulrahman.jpeg',
                    ),
                    Divider(
                        height: 16, thickness: 0.5, color: Color(0xFFE2E8F0)),
                    _TeamMember(
                      name: 'Muhammad Mahani',
                      role: 'Computer Engineering',
                      imagePath: 'assets/images/team/mahani.jpeg',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // جهات الاتصال
              _buildSection(
                title: '📞 تواصل معنا',
                icon: Icons.contact_mail,
                gradient: const LinearGradient(
                  colors: [Color(0xFF06B6D4), Color(0xFF22D3EE)],
                ),
                child: const Column(
                  children: [
                    _ContactItem(
                        icon: Icons.school,
                        title: 'المشرف',
                        value: 'Thaer Sahmoud',
                        color: Color(0xFF2563EB)),
                    SizedBox(height: 12),
                    _ContactItem(
                        icon: Icons.location_on,
                        title: 'الجامعة',
                        value: 'UCAS University, Gaza',
                        color: Color(0xFF7C3AED)),
                    SizedBox(height: 12),
                    _ContactItem(
                        icon: Icons.calendar_today,
                        title: 'العام',
                        value: '2025 - 2026',
                        color: Color(0xFF10B981)),
                    SizedBox(height: 12),
                    _ContactItem(
                        icon: Icons.email,
                        title: 'البريد الإلكتروني',
                        value: 'aalhayek7@smail.ucas.edu.ps',
                        color: Color(0xFFEF4444)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // روابط
              _buildSection(
                title: '🔗 روابط',
                icon: Icons.link,
                gradient: const LinearGradient(
                  colors: [Color(0xFF1F2328), Color(0xFF404040)],
                ),
                child: Column(
                  children: [
                    _LinkButton(
                      icon: Icons.code,
                      title: 'GitHub Repository',
                      subtitle: 'الكود المصدري مفتوح المصدر',
                      url: 'https://github.com/Alhayek7/DiabPredict',
                      color: const Color(0xFF1F2328),
                    ),
                    const SizedBox(height: 12),
                    // ✅ جديد (صحيح)
                    _InfoButton(
                      icon: Icons.privacy_tip,
                      title: 'سياسة الخصوصية',
                      subtitle: 'كيف نحمي بياناتك',
                      color: const Color(0xFF2563EB),
                      onTap: () => _showPrivacyPolicy(
                          context), // ← يمرر context فقط للدالة
                    ),
                    const SizedBox(height: 12),
                    _InfoButton(
                      icon: Icons.medical_information,
                      title: 'إخلاء مسؤولية طبي',
                      subtitle: 'اقرأ قبل استخدام التطبيق',
                      color: const Color(0xFFEF4444),
                      onTap: () => _showMedicalDisclaimer(context), // ✅ صحيح
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // حقوق النشر
              const Center(
                child: Column(
                  children: [
                    Text(
                      '© 2025 - 2026 | UCAS University',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'جميع الحقوق محفوظة | DiabPredict',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'DiabPredict',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'نظام ذكي للتنبؤ المبكر بخطر السكري',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'الإصدار 2.0.0 | 2026',
              style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Gradient gradient,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 1,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }
}

// ============================================================
// مكونات مساعدة
// ============================================================

class _GoalItem extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;

  const _GoalItem({
    required this.emoji,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B))),
                Text(description,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamMember extends StatelessWidget {
  final String name;
  final String role;
  final String imagePath; // ✅ مسار الصورة

  const _TeamMember({
    required this.name,
    required this.role,
    this.imagePath = '', // إذا لم توجد صورة، استخدم الحرف الأول
  });

  @override
  Widget build(BuildContext context) {
    final String firstLetter = name.isNotEmpty ? name[0] : 'ع';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
              ),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: imagePath.isNotEmpty
                  ? Image.asset(
                      imagePath,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            firstLetter,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        firstLetter,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'UCAS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  final String label;
  final Color color;
  final double percentage;

  const _TechChip({
    required this.label,
    required this.color,
    this.percentage = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500, color: color)),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _StatItem(
      {required this.emoji, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B))),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _ContactItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B))),
            ],
          ),
        ),
      ],
    );
  }
}

class _LinkButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String url;
  final Color color;

  const _LinkButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.url,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        try {
          // ✅ استخدام canLaunch و launch بدلاً من canLaunchUrl و launchUrl
          if (await canLaunch(url)) {
            await launch(
              url,
              forceSafariVC: false, // iOS: يفتح في Safari
              forceWebView: false, // يفتح في المتصفح الخارجي
            );
          } else {
            _showErrorSnackBar(context, '❌ لا يمكن فتح الرابط');
          }
        } catch (e) {
          _showErrorSnackBar(context, '❌ حدث خطأ: ${e.toString()}');
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _InfoButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback
      onTap; // ✅ تغيير: من Function(BuildContext) إلى VoidCallback

  const _InfoButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // ✅ تغيير: مباشرة بدون context
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color)),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _DisclaimerItem extends StatelessWidget {
  final String number;
  final String text;

  const _DisclaimerItem({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(number,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
            child:
                Text(text, style: const TextStyle(fontSize: 13, height: 1.4))),
      ],
    );
  }
}
