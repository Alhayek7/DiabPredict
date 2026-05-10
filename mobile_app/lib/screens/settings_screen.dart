import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:restart_app/restart_app.dart';
import '../services/local_storage_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';  // ✅ لـ Clipboard
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/health_data.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/font_size_provider.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // إعدادات المستخدم
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'العربية';
  String _selectedFontSize = 'متوسط';
  bool _autoSaveResults = true;
  bool _shareDataAnonymously = false;
  String _backupFrequency = 'أسبوعي';

  // قوائم الاختيار
  final List<String> _languages = ['العربية', 'English', 'Français'];
  final List<String> _fontSizes = ['صغير', 'متوسط', 'كبير'];
  final List<String> _backupFrequencies = ['يومي', 'أسبوعي', 'شهري', 'يدوي'];
  final LocalStorageService _storageService = LocalStorageService();

@override
void initState() {
  super.initState();
  _loadSettings();
  _calculateCacheSize();  // ✅ حساب حجم الكاش
}

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
      _selectedLanguage = prefs.getString('language') ?? 'العربية';
      _selectedFontSize = prefs.getString('font_size') ?? 'متوسط';
      _autoSaveResults = prefs.getBool('auto_save_results') ?? true;
      _shareDataAnonymously = prefs.getBool('share_data_anonymously') ?? false;
      _backupFrequency = prefs.getString('backup_frequency') ?? 'أسبوعي';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

void _showRestartDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('تطبيق الإعدادات'),
      content: const Text('بعض الإعدادات تتطلب إعادة تشغيل التطبيق. هل تريد إعادة التشغيل الآن؟'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('لاحقاً'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Restart.restartApp();  // ✅ إعادة التشغيل الفعلية
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
          ),
          child: const Text('إعادة التشغيل'),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      appBar: AppBar(
        
        title: const Text(
          'الإعدادات',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: () => _showResetDialog(),
            tooltip: 'استعادة الإعدادات',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== قسم التفضيلات العامة ==========
            _buildSectionHeader('⚙️ التفضيلات العامة'),
            const SizedBox(height: 12),
            _buildSettingsCard(
              children: [
                _buildSwitchTile(
                  icon: Icons.notifications_active,
                  title: 'الإشعارات',
                  subtitle: 'تلقي تنبيهات وتذكيرات صحية',
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                    _saveSetting('notifications_enabled', value);
                    _showSnackBar('تم ${value ? "تفعيل" : "إيقاف"} الإشعارات');
                  },
                ),
                _buildDivider(),
                _buildSwitchTile(
                  icon: Icons.dark_mode,
                  title: 'الوضع المظلم',
                  subtitle: 'تغيير مظهر التطبيق',
                  value: _darkModeEnabled,
                  onChanged: (value) {
                    setState(() => _darkModeEnabled = value);
                    _saveSetting('dark_mode_enabled', value);
                    _showRestartDialog();
                  },
                ),
                _buildDivider(),
                _buildDropdownTile(
                  icon: Icons.language,
                  title: 'اللغة',
                  subtitle: 'اختر اللغة المفضلة',
                  value: _selectedLanguage,
                  items: _languages,
                  onChanged: (value) {
                    setState(() => _selectedLanguage = value);
                    _saveSetting('language', value);
                    _showRestartDialog();
                  },
                ),
                _buildDivider(),
                _buildDropdownTile(
                  icon: Icons.text_fields,
                  title: 'حجم الخط',
                  subtitle: 'تغيير حجم النصوص',
                  value: _selectedFontSize,
                  items: _fontSizes,
                  onChanged: (value) async {
                    setState(() => _selectedFontSize = value);
                    _saveSetting('font_size', value);
                    
                    // ✅ تطبيق حجم الخط فوراً (دون إعادة تشغيل)
                    final fontSizeProvider = Provider.of<FontSizeProvider>(context, listen: false);
                    await fontSizeProvider.setFontSize(value);
                    
                    _showSnackBar('تم تغيير حجم الخط إلى $value');
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ========== قسم الخصوصية والبيانات ==========
            _buildSectionHeader('🔒 الخصوصية والبيانات'),
            const SizedBox(height: 12),
            _buildSettingsCard(
              children: [
                _buildSwitchTile(
                  icon: Icons.save,
                  title: 'حفظ النتائج تلقائياً',
                  subtitle: 'حفظ نتائج التنبؤ بشكل تلقائي',
                  value: _autoSaveResults,
                  onChanged: (value) {
                    setState(() => _autoSaveResults = value);
                    _saveSetting('auto_save_results', value);
                    _showSnackBar('تم ${value ? "تفعيل" : "إيقاف"} الحفظ التلقائي');
                  },
                ),
                _buildDivider(),
                _buildSwitchTile(
                      icon: Icons.analytics,
                      title: 'مشاركة البيانات anonymously',
                      subtitle: 'مساعدة في تحسين النموذج',
                      value: _shareDataAnonymously,
                      onChanged: (value) async {
                        setState(() => _shareDataAnonymously = value);
                        _saveSetting('share_data_anonymously', value);
                        
                        if (value) {
                          _showAnonymousDataInfo();
                        } else {
                          _showSnackBar('تم إيقاف مشاركة البيانات');
                        }
                      },
                    ),
                    
                _buildDivider(),
                _buildDropdownTile(
                      icon: Icons.backup,
                      title: 'النسخ الاحتياطي',
                      subtitle: 'تحديد وتيرة النسخ الاحتياطي',
                      value: _backupFrequency,
                      items: _backupFrequencies,
                      onChanged: (value) {
                        setState(() => _backupFrequency = value);
                        _saveSetting('backup_frequency', value);
                        _showSnackBar('تم تغيير وتيرة النسخ الاحتياطي إلى $value');
                      },
                    ),
                    // ✅ إضافة أزرار النسخ الاحتياطي
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _backupData,
                            icon: const Icon(Icons.backup, size: 18),
                            label: const Text('نسخ احتياطي'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF2563EB),
                              side: const BorderSide(color: Color(0xFF2563EB)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _restoreBackup,
                            icon: const Icon(Icons.restore, size: 18),
                            label: const Text('استعادة'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF10B981),
                              side: const BorderSide(color: Color(0xFF10B981)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

              ],
            ),

            const SizedBox(height: 24),

            // ========== قسم البيانات والتخزين ==========
            _buildSectionHeader('💾 البيانات والتخزين'),
            const SizedBox(height: 12),
            _buildSettingsCard(
              children: [
                _buildInfoTile(
                  icon: Icons.storage,
                  title: 'مساحة التخزين المستخدمة',
                  value: '2.4 MB',
                  subtitle: 'آخر تحديث: اليوم',
                ),
                _buildDivider(),
                _buildActionTile(
                  icon: Icons.delete_sweep,
                  title: 'مسح البيانات المؤقتة',
                  subtitle: 'حذف الملفات المؤقتة والكاش',
                  onTap: () => _showClearCacheDialog(),
                  iconColor: Colors.orange,
                ),
                _buildDivider(),
                _buildActionTile(
                  icon: Icons.download,
                  title: 'تصدير البيانات',
                  subtitle: 'تصدير جميع بياناتك كملف CSV',
                  onTap: () => _showExportDialog(),
                ),
                _buildDivider(),
                _buildActionTile(
                  icon: Icons.restore,
                  title: 'استعادة الإعدادات الافتراضية',
                  subtitle: 'إعادة ضبط جميع الإعدادات',
                  onTap: () => _showResetDialog(),
                  iconColor: Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ========== قسم حول التطبيق ==========
            _buildSectionHeader('ℹ️ حول التطبيق'),
            const SizedBox(height: 12),
            _buildSettingsCard(
              children: [
                _buildInfoTile(
                  icon: Icons.info,
                  title: 'الإصدار',
                  value: '1.0.0',
                  subtitle: 'آخر تحديث: مايو 2026',
                ),
                _buildDivider(),
                _buildActionTile(
                  icon: Icons.privacy_tip,
                  title: 'سياسة الخصوصية',
                  subtitle: 'اقرأ سياسة الخصوصية الخاصة بنا',
                  onTap: () => _showPrivacyPolicy(), 
                  iconColor: const Color(0xFF2563EB),

                ),
                _buildDivider(),
                _buildActionTile(
                          icon: Icons.description,
                          title: 'شروط الاستخدام',
                          subtitle: 'اقرأ شروط وأحكام الاستخدام',
                          onTap: () => _showTermsOfUse(),  // ✅ استدعاء الدالة الجديدة
                          iconColor: const Color(0xFF7C3AED),  // لون بنفسجي
                        ),
                _buildDivider(),
                _buildActionTile(
                    icon: Icons.star,
                    title: 'قيم التطبيق',
                    subtitle: 'ساعدنا في تحسين التطبيق بتقييم 5 نجوم',
                    onTap: () => _showRateDialog(),
                    iconColor: const Color(0xFFF59E0B),  // لون برتقالي/ذهبي
                  ),
                _buildDivider(),
                _buildActionTile(
                  icon: Icons.share,
                  title: 'مشاركة التطبيق',
                  subtitle: 'أرسل التطبيق لأصدقائك',
                  onTap: () => _showShareDialog(),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // دوال مساعدة لبناء الواجهة
  // ============================================================

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: const Color(0xFF2563EB), size: 24),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1E293B),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF2563EB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2563EB), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: value,
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2563EB)),
          ),
        ],
      ),
    );
  }

Widget _buildActionTile({
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
  Color? iconColor,
}) {
  return ListTile(
    leading: Icon(icon, color: iconColor ?? const Color(0xFF2563EB), size: 24),
    title: Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1E293B),
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    ),
    subtitle: Text(
      subtitle,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
    ),
    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  );
}


Widget _buildInfoTile({
  required IconData icon,
  required String title,
  required String value,
  required String subtitle,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF2563EB), size: 24),
        const SizedBox(width: 16),
        // ✅ الجزء الأهم: النصوص كلها داخل Expanded
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E293B),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // ✅ القيمة داخل Flexible (وليس فقط Expanded) لمنع التجاوز
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2563EB),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,   // يمنع الالتفاف ويجبر على القص
          ),
        ),
      ],
    ),
  );
}

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[200],
      thickness: 1,
    );
  }

  // ============================================================
  // دوال الحوارات والإجراءات
  // ============================================================

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2563EB),
      ),
    );
  }

// ✅ متغير لعرض حجم الكاش
String _cacheSize = 'جاري الحساب...';

// ✅ دالة لحساب حجم الكاش
Future<void> _calculateCacheSize() async {
  try {
    final tempDir = await getTemporaryDirectory();
    final size = await _getDirectorySize(tempDir);
    final sizeInMB = size / (1024 * 1024);
    
    if (mounted) {
      setState(() {
        if (sizeInMB < 1) {
          _cacheSize = '${(sizeInMB * 1024).toInt()} KB';
        } else {
          _cacheSize = '${sizeInMB.toStringAsFixed(2)} MB';
        }
      });
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _cacheSize = 'غير معروف';
      });
    }
  }
}

// ✅ حساب حجم المجلد
Future<int> _getDirectorySize(Directory dir) async {
  int size = 0;
  try {
    final List<FileSystemEntity> entities = await dir.list().toList();
    for (var entity in entities) {
      if (entity is File) {
        size += await entity.length();
      } else if (entity is Directory) {
        size += await _getDirectorySize(entity);
      }
    }
  } catch (e) {
    print('Error calculating directory size: $e');
  }
  return size;
}

// ✅ مسح الكاش بالكامل
Future<void> _clearCache() async {
  try {
    _showSnackBar('🗑️ جاري مسح البيانات المؤقتة...');
    
    final tempDir = await getTemporaryDirectory();
    final deletedSize = await _deleteDirectoryContents(tempDir);
    final deletedSizeMB = deletedSize / (1024 * 1024);
    
    // تحديث حجم الكاش
    await _calculateCacheSize();
    
    if (mounted) {
      String sizeText = '';
      if (deletedSizeMB < 1) {
        sizeText = '${(deletedSizeMB * 1024).toInt()} KB';
      } else {
        sizeText = '${deletedSizeMB.toStringAsFixed(2)} MB';
      }
      
      // عرض نافذة النجاح المحسنة
      _showSuccessDialog(sizeText);
    }
  } catch (e) {
    if (mounted) {
      _showSnackBar('❌ فشل مسح البيانات المؤقتة: $e');
    }
  }
}

// ✅ حذف محتويات المجلد
Future<int> _deleteDirectoryContents(Directory dir) async {
  int totalSize = 0;
  try {
    final List<FileSystemEntity> entities = await dir.list().toList();
    for (var entity in entities) {
      if (entity is File) {
        totalSize += await entity.length();
        await entity.delete();
      } else if (entity is Directory) {
        totalSize += await _deleteDirectoryContents(entity);
        await entity.delete();
      }
    }
  } catch (e) {
    print('Error deleting directory contents: $e');
  }
  return totalSize;
}

// ✅ عرض حوار تأكيد مسح الكاش
void _showClearCacheDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      title: const Row(
        children: [
          Icon(Icons.cleaning_services, color: Colors.orange, size: 28),
          SizedBox(width: 8),
          Text(
            'مسح البيانات المؤقتة',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delete_sweep,
              color: Colors.orange,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'سيتم حذف جميع الملفات المؤقتة والكاش.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.storage, size: 20, color: Color(0xFF2563EB)),
                const SizedBox(width: 8),
                Text(
                  'حجم الكاش: $_cacheSize',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber, size: 14, color: Colors.red),
                SizedBox(width: 6),
                Text(
                  'لا يمكن استعادة الملفات بعد الحذف',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey.shade600,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Text('إلغاء'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            _clearCache();
          },
          icon: const Icon(Icons.delete_sweep, size: 18),
          label: const Text('مسح الآن'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    ),
  );
}


// ✅ عرض نافذة نجاح المسح
void _showSuccessDialog(String sizeText) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    backgroundColor: Colors.white,
    builder: (context) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // شريط السحب
          Container(
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          
          // أيقونة النجاح
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF10B981),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          
          // نص النجاح
          const Text(
            '✅ تم مسح البيانات المؤقتة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          
          // المساحة المحررة
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'تم تحرير مساحة $sizeText',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10B981),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // زر إغلاق
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('حسناً'),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}

void _showExportDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      title: const Row(
        children: [
          Icon(Icons.download, color: Color(0xFF2563EB), size: 28),
          SizedBox(width: 8),
          Text(
            'تصدير البيانات',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.file_download,
              color: Color(0xFF2563EB),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'سيتم تصدير جميع بياناتك كملف CSV',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 14, color: Color(0xFF10B981)),
                SizedBox(width: 6),
                Text(
                  'يمكن فتحه في Excel و Google Sheets',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey.shade600,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Text('إلغاء'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            _exportData();
          },
          icon: const Icon(Icons.download, size: 18),
          label: const Text('تصدير'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    ),
  );
}



void _showResetDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      title: const Row(
        children: [
          Icon(Icons.restore, color: Colors.red, size: 28),
          SizedBox(width: 8),
          Flexible(  // ✅ منع التجاوز
            child: Text(
              'استعادة الإعدادات الافتراضية',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber, color: Colors.orange, size: 48),
          const SizedBox(height: 16),
          const Flexible(  // ✅ منع التجاوز للنص الطويل
            child: Text(
              'سيتم إعادة ضبط جميع الإعدادات إلى قيمها الافتراضية.',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
          const SizedBox(height: 8),
          const Flexible(  // ✅ منع التجاوز
            child: Text(
              'سيتم إعادة تشغيل التطبيق تلقائياً.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.red),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey.shade600,
          ),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await _resetAllSettings();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text('إعادة ضبط'),
        ),
      ],
    ),
  );
}


Future<void> _resetAllSettings() async {
  // إعادة ضبط القيم
  setState(() {
    _notificationsEnabled = true;
    _darkModeEnabled = false;
    _selectedLanguage = 'العربية';
    _selectedFontSize = 'متوسط';
    _autoSaveResults = true;
    _shareDataAnonymously = false;
    _backupFrequency = 'أسبوعي';
  });
  
  // حفظ الإعدادات
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('notifications_enabled', true);
  await prefs.setBool('dark_mode_enabled', false);
  await prefs.setString('language', 'العربية');
  await prefs.setString('font_size', 'متوسط');
  await prefs.setBool('auto_save_results', true);
  await prefs.setBool('share_data_anonymously', false);
  await prefs.setString('backup_frequency', 'أسبوعي');
  
  // إظهار رسالة وإعادة التشغيل
  if (mounted) {
    _showSnackBar('🔄 تم إعادة ضبط الإعدادات بنجاح');
    Future.delayed(const Duration(milliseconds: 800), () {
      Restart.restartApp();
    });
  }
}

void _showShareDialog() {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    backgroundColor: Colors.white,
    builder: (context) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // شريط السحب
          Container(
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          
          // العنوان
          const Row(
            children: [
              Icon(Icons.share, color: Color(0xFF2563EB), size: 28),
              SizedBox(width: 12),
              Text(
                'مشاركة التطبيق',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFE2E8F0), thickness: 1),
          const SizedBox(height: 20),
          
          // نص الترحيب
          const Text(
            'شارك DiabPredict مع أصدقائك وعائلتك',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // خيارات المشاركة
          Row(
            children: [
              _buildShareOption(
                icon: Icons.qr_code,
                title: 'رمز QR',
                color: const Color(0xFF2563EB),
                onTap: () {
                  Navigator.pop(context);
                  _showQRCodeDialog();
                },
              ),
              const SizedBox(width: 16),
              _buildShareOption(
                icon: Icons.copy,
                title: 'نسخ الرابط',
                color: const Color(0xFF10B981),
                onTap: () {
                  Navigator.pop(context);
                  _copyLinkToClipboard();
                },
              ),
              const SizedBox(width: 16),
              _buildShareOption(
                icon: Icons.share,
                title: 'مشاركة',
                color: const Color(0xFFF59E0B),
                onTap: () {
                  Navigator.pop(context);
                  _shareAppLink();
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

// خيارات المشاركة
Widget _buildShareOption({
  required IconData icon,
  required String title,
  required Color color,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// نسخ الرابط إلى الحافظة
Future<void> _copyLinkToClipboard() async {
  const String appLink = 'https://play.google.com/store/apps/details?id=com.example.mobile_app';
  await Clipboard.setData(ClipboardData(text: appLink));
  
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('✅ تم نسخ رابط التطبيق'),
          ],
        ),
        backgroundColor: Color(0xFF10B981),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// مشاركة الرابط مباشرة
Future<void> _shareAppLink() async {
  const String shareText = '''
🌟 اكتشف تطبيق DiabPredict! 🌟

تطبيق ذكي للتنبؤ المبكر بخطر السكري باستخدام الذكاء الاصطناعي.

✨ المميزات:
• تنبؤ دقيق بنسبة 94%
• تفسير شفاف للنتائج
• مساعد ذكي للنصائح الصحية
• مجاني وآمن تماماً

📲 حمل التطبيق الآن:
https://play.google.com/store/apps/details?id=com.example.mobile_app

---
DiabPredict - صحتك تهمنا
''';
  
  await Share.share(shareText, subject: 'DiabPredict - تنبؤ ذكي للسكري');
}

// عرض رمز QR
void _showQRCodeDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      title: const Row(
        children: [
          Icon(Icons.qr_code, color: Color(0xFF2563EB), size: 28),
          SizedBox(width: 8),
          Text(
            'رمز QR للتطبيق',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.qr_code_scanner,
                size: 150,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'امسح الرمز لتحميل التطبيق',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 117, 117, 117),
          ),
          child: const Text('إغلاق'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            _shareAppLink();
          },
          icon: const Icon(Icons.share, size: 18),
          label: const Text('مشاركة'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,             // النص أبيض
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    ),
  );
}


  Future<void> _launchUrl(String url) async {
    // ✅ إذا كان الرابط تجريبياً، اعرض رسالة بدلاً من فتحه
    if (url == 'https://example.com/privacy' || url == 'https://example.com/terms') {
      _showSnackBar('سيتم إضافة الرابط قريباً');
      return;
    }
    
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('⚠️ لا يمكن فتح الرابط');
      }
    } catch (e) {
      _showSnackBar('⚠️ حدث خطأ في فتح الرابط');
    }
  }

  Future<void> _exportData() async {
  try {
    _showSnackBar('📁 جاري تحضير البيانات للتصدير...');
    
    final allPredictions = _storageService.getAllPredictions();
    
    if (allPredictions.isEmpty) {
      _showSnackBar('⚠️ لا توجد بيانات للتصدير');
      return;
    }
    
    // ✅ إنشاء محتوى CSV محسن
    String csvContent = _generateCSVContent(allPredictions);
    
    // ✅ حفظ الملف محلياً
    final String fileName = 'diabpredict_export_${DateTime.now().toString().substring(0, 19).replaceAll(':', '-')}.csv';
    final String filePath = await _saveCSVToFile(csvContent, fileName);
    
    // ✅ عرض خيارات المشاركة
    _showExportSuccessDialog(filePath, allPredictions.length);
    
  } catch (e) {
    _showSnackBar('❌ فشل التصدير: $e');
  }
}

// ✅ إنشاء محتوى CSV بتنسيق احترافي
String _generateCSVContent(List<HealthData> predictions) {
  // رأس الملف مع معلومات التصدير
  String header = "# تقرير التنبؤات - DiabPredict\n";
  header += "# تاريخ التصدير: ${DateTime.now().toLocal()}\n";
  header += "# عدد التنبؤات: ${predictions.length}\n";
  header += "# ================================================\n\n";
  
  // أعمدة CSV
  header += "التاريخ,نسبة الخطر (%),المستوى,العمر (سنة),BMI,HbA1c (%),سكر الدم (mg/dL),";
  header += "الضغط الانقباضي,الضغط الانبساطي,الكوليسترول (mg/dL),محيط الخصر (سم),التاريخ العائلي,التدخين,النشاط البدني\n";
  
  // ✅ أعلن المتغير هنا
  String csvContent = "";
  
  // البيانات
  for (var data in predictions) {
    final risk = data.localRisk ?? data.calculateRiskLocally();
    final level = risk < 30 ? 'منخفض' : (risk < 60 ? 'متوسط' : 'مرتفع');
    
    // ترجمة القيم الرقمية
    final familyHistory = data.familyHistory == 1 ? 'نعم' : 'لا';
    final smoking = {0: 'لا يدخن', 1: 'مدخن سابق', 2: 'مدخن حالياً'}[data.smoking] ?? 'لا يدخن';
    final activity = {0: 'قليل', 1: 'متوسط', 2: 'كثير'}[data.physicalActivity] ?? 'قليل';
    
    csvContent += "${data.timestamp},${risk.toStringAsFixed(2)},$level,"
        "${data.age},${data.bmi},${data.hba1c},${data.glucose},"
        "${data.bloodPressureSystolic},${data.bloodPressureDiastolic},${data.cholesterol},"
        "${data.waistCircumference},$familyHistory,$smoking,$activity\n";
  }
  
  return header + csvContent;
}

// ✅ حفظ الملف محلياً
Future<String> _saveCSVToFile(String content, String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/$fileName';
  final file = File(filePath);
  await file.writeAsString(content, encoding: utf8);
  return filePath;
}

// ✅ عرض نافذة نجاح التصدير مع خيارات المشاركة
void _showExportSuccessDialog(String filePath, int count) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    backgroundColor: Colors.white,
    builder: (context) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // شريط السحب
          Container(
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          
          // أيقونة النجاح
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF10B981),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          
          // النص
          Text(
            '✅ تم تصدير $count سجل بنجاح',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'تم حفظ الملف في مجلد المستندات',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          
          // خيارات المشاركة
          Row(
            children: [
              _buildExportOption(
                icon: Icons.share,
                title: 'مشاركة',
                color: const Color(0xFF2563EB),
                onTap: () {
                  Navigator.pop(context);
                  _shareExportedFile(filePath);
                },
              ),
              const SizedBox(width: 16),
              _buildExportOption(
                icon: Icons.folder_open,
                title: 'فتح الملف',
                color: const Color(0xFF10B981),
                onTap: () {
                  Navigator.pop(context);
                  _openExportedFile(filePath);
                },
              ),
              const SizedBox(width: 16),
              _buildExportOption(
                icon: Icons.close,
                title: 'إغلاق',
                color: const Color(0xFFEF4444),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

// ✅ خيارات التصدير
Widget _buildExportOption({
  required IconData icon,
  required String title,
  required Color color,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ✅ مشاركة الملف المصدر
Future<void> _shareExportedFile(String filePath) async {
  final XFile file = XFile(filePath);
  await Share.shareXFiles(
    [file],
    text: '📊 تقرير التنبؤات من تطبيق DiabPredict\nتم تصدير ${_storageService.getAllPredictions().length} سجل',
    subject: 'تقرير DiabPredict',
  );
}

// ✅ فتح الملف المصدر
Future<void> _openExportedFile(String filePath) async {
  try {
    final Uri uri = Uri.file(filePath);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    _showSnackBar('⚠️ لا يمكن فتح الملف');
  }
}


void _showPrivacyPolicy() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // شريط السحب
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          
          // العنوان
          const Row(
            children: [
              SizedBox(width: 16),
              Icon(Icons.privacy_tip, color: Color(0xFF2563EB), size: 28),
              SizedBox(width: 12),
              Text(
                '🔒 سياسة الخصوصية',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          
          // المحتوى القابل للتمرير
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPolicySection(
                    title: '📌 1. المعلومات التي نجمعها',
                    content: '''
لا نجمع أي معلومات شخصية تعريفية (مثل الاسم الكامل، العنوان، رقم الهاتف، البريد الإلكتروني).

المعلومات التي يتم تخزينها محلياً على جهازك فقط:
• البيانات الصحية التي تدخلها (العمر، الوزن، مستوى السكر، ضغط الدم، إلخ)
• نتائج التنبؤات السابقة
• تاريخ استخدام التطبيق

جميع هذه البيانات تبقى على جهازك ولا يتم مشاركتها مع أي طرف ثالث.
''',
                  ),
                  const SizedBox(height: 20),
                  
                  _buildPolicySection(
                    title: '📌 2. كيف نستخدم معلوماتك',
                    content: '''
بياناتك الصحية تستخدم فقط لـ:
• حساب نسبة خطر الإصابة بمرض السكري
• تقديم توصيات صحية مخصصة
• تحسين دقة النموذج (إذا وافقت على مشاركة البيانات)
• عرض سجل التنبؤات الخاص بك

نحن لا نستخدم بياناتك لأغراض تسويقية أو إعلانية.
''',
                  ),
                  const SizedBox(height: 20),
                  
                  _buildPolicySection(
                    title: '📌 3. التخزين والأمان',
                    content: '''
• يتم تخزين جميع بياناتك محلياً على جهازك باستخدام قاعدة بيانات Hive الآمنة
• لا يتم إرسال بياناتك إلى أي خادم خارجي (إلا إذا وافقت صراحةً)
• يمكنك مسح جميع بياناتك في أي وقت من خلال إعدادات التطبيق
• نستخدم تشفيراً محلياً لحماية بياناتك الحساسة
''',
                  ),
                  const SizedBox(height: 20),
                  
                  _buildPolicySection(
                    title: '📌 4. مشاركة البيانات (اختياري)',
                    content: '''
إذا قمت بتفعيل خيار "مشاركة البيانات" في الإعدادات:
• سيتم إرسال بياناتك الصحية بشكل مجهول وبدون هوية
• نستخدم هذه البيانات لتحسين دقة نموذج الذكاء الاصطناعي
• يمكنك إلغاء هذه الميزة في أي وقت
• مشاركة البيانات هي اختيارية تماماً وليست إجبارية
''',
                  ),
                  const SizedBox(height: 20),
                  
                  _buildPolicySection(
                    title: '📌 5. إخلاء المسؤولية الطبية',
                    content: '''
⚠️ تنبيه هام:

• هذا التطبيق هو أداة توعوية وليس بديلاً عن الاستشارة الطبية
• النتائج التي يقدمها هي تقديرات احتمالية تعتمد على البيانات المدخلة
• يجب عدم الاعتماد على نتائج التطبيق وحدها في اتخاذ القرارات الطبية
• يُرجى استشارة الطبيب المختص لتقييم حالتك الصحية بدقة
• نحن غير مسؤولين عن أي قرارات طبية تتخذ بناءً على نتائج التطبيق
''',
                  ),
                  const SizedBox(height: 20),
                  
                  _buildPolicySection(
                    title: '📌 6. حقوق الطفل',
                    content: '''
التطبيق مخصص للاستخدام من قبل البالغين (18 سنة فأكثر). إذا كان عمرك أقل من 18 سنة، يُرجى استخدام التطبيق تحت إشراف ولي الأمر.
''',
                  ),
                  const SizedBox(height: 20),
                  
                  _buildPolicySection(
                    title: '📌 7. التحديثات على السياسة',
                    content: '''
قد نقوم بتحديث سياسة الخصوصية من وقت لآخر. سيتم إعلامك بأي تغييرات جوهرية من خلال التطبيق. تاريخ آخر تحديث: مايو 2026.
''',
                  ),
                  const SizedBox(height: 20),
                  
                  _buildPolicySection(
                    title: '📌 8. اتصل بنا',
                    content: '''
إذا كان لديك أي أسئلة أو استفسارات حول سياسة الخصوصية، يمكنك التواصل معنا عبر:
📧 البريد الإلكتروني: diabpredict@ucas.edu.ps
🏫 جامعة UCAS - غزة، فلسطين
''',
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // زر إغلاق
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'إغلاق',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildPolicySection({required String title, required String content}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.description, color: Colors.white, size: 18),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void _showTermsOfUse() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // شريط السحب
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          
          // العنوان
          const Row(
            children: [
              SizedBox(width: 16),
              Icon(Icons.description, color: Color(0xFF7C3AED), size: 28),
              SizedBox(width: 12),
              Text(
                '📜 شروط الاستخدام',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          
          // المحتوى القابل للتمرير
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPolicySection(
                    title: '📌 1. قبول الشروط',
                    content: '''
باستخدامك لتطبيق DiabPredict، فإنك توافق على الالتزام بشروط الاستخدام هذه. إذا كنت لا توافق على أي جزء من هذه الشروط، يرجى عدم استخدام التطبيق.

نحتفظ بالحق في تعديل هذه الشروط في أي وقت. سيتم إعلامك بأي تغييرات جوهرية من خلال التطبيق.
''',
                  ),
                  const SizedBox(height: 20),
                  
                  _buildPolicySection(
                    title: '📌 2. الاستخدام المسموح به',
                    content: '''
يُسمح لك باستخدام التطبيق للأغراض التالية:
• تقييم نسبة خطر الإصابة بمرض السكري
• متابعة حالتك الصحية عبر الزمن
• الحصول على نصائح وتوصيات صحية
• تصدير بياناتك الشخصية

لا يُسمح بما يلي:
• استخدام التطبيق لأغراض تجارية دون إذن
• محاولة اختراق أو تعطيل التطبيق
• تحميل محتوى غير قانوني أو ضار
• مشاركة بيانات الآخرين دون موافقتهم
''',
                  ),
                  const SizedBox(height: 20),
                  
                  _buildPolicySection(
                    title: '📌 3. الحساب والبيانات',
                    content: '''
• لا تحتاج إلى إنشاء حساب لاستخدام التطبيق
• جميع بياناتك محفوظة محلياً على جهازك
• أنت وحدك المسؤول عن أمان جهازك وبياناتك
• يمكنك حذف جميع بياناتك في أي وقت من إعدادات التطبيق
• ننصح بعمل نسخة احتياطية من بياناتك بشكل دوري
''',
                  ),
                  const SizedBox(height: 20),
                  
                  _buildPolicySection(
                    title: '📌 4. دقة المعلومات',
                    content: '''
• نحرص على تقديم معلومات دقيقة وحديثة، لكننا لا نضمن خلوها من الأخطاء
• التطبيق يعتمد على خوارزميات الذكاء الاصطناعي التي قد لا تكون دقيقة بنسبة 100%
• أنت مسؤول عن صحة البيانات التي تدخلها في التطبيق
• النتائج هي تقديرات احتمالية وليست تشخيصاً طبياً مؤكداً
''',
                  ),
                  const SizedBox(height: 20),
                  
                  _buildPolicySection(
                    title: '📌 5. إخلاء المسؤولية الطبية',
                    content: '''
⚠️ تنبيه هام جداً:

• DiabPredict هو تطبيق توعوي وليس بديلاً عن الاستشارة الطبية
• نتائج التطبيق لا تغني عن رأي الطبيب المختص
• يجب عليك استشارة الطبيب قبل اتخاذ أي قرارات طبية
• نحن غير مسؤولين عن أي أضرار ناتجة عن الاعتماد على نتائج التطبيق
• في حالة الطوارئ الطبية، اتصل على رقم الطوارئ فوراً
''',
                  ),
                  const SizedBox(height: 20),
                  
                  _buildPolicySection(
                    title: '📌 6. حقوق الملكية الفكرية',
                    content: '''
• جميع حقوق التطبيق محفوظة لجامعة UCAS وفريق التطوير
• لا يجوز نسخ أو تعديل أو توزيع التطبيق أو أي جزء منه دون إذن
• الأيقونات والصور المستخدمة في التطبيق هي ملك لفريق التطوير أو مرخصة للاستخدام
• اسم DiabPredict والشعار هما علامتان تجاريتان مسجلتان
''',
                  ),
                  const SizedBox(height: 20),
                  
                  _buildPolicySection(
                    title: '📌 7. حدود المسؤولية',
                    content: '''
لن تكون جامعة UCAS أو فريق التطوير مسؤولين عن:
• أي أضرار مباشرة أو غير مباشرة ناتجة عن استخدام التطبيق
• فقدان البيانات بسبب عطل في الجهاز أو التطبيق
• قرارات طبية تتخذ بناءً على نتائج التطبيق
• أخطاء قد تحدث في الحسابات أو التوقعات

استخدامك للتطبيق يعني موافقتك على هذه الحدود.
''',
                  ),
                  const SizedBox(height: 20),
                  
                  _buildPolicySection(
                    title: '📌 8. الخدمات الخارجية',
                    content: '''
• التطبيق يستخدم خدمات Gemini AI من Google لتقديم النصائح
• بياناتك ترسل إلى Gemini فقط إذا قمت بتفعيل المساعد الذكي
• قد تخضع استخداماتك لخدمات Google لشروط الخدمة الخاصة بها
• نوصي بمراجعة سياسة خصوصية Google لمزيد من المعلومات
''',
                  ),
                  const SizedBox(height: 20),
                  
                  _buildPolicySection(
                    title: '📌 9. تعطيل الخدمة',
                    content: '''
نحتفظ بالحق في:
• تعطيل أو تقييد الوصول إلى التطبيق لأي مستخدم ينتهك هذه الشروط
• إجراء تحديثات أو صيانة تؤدي إلى توقف الخدمة مؤقتاً
• تغيير ميزات التطبيق أو إزالتها في أي وقت
• إنهاء خدمة التطبيق بالكامل مع إشعار مسبق
''',
                  ),
                  const SizedBox(height: 20),
                  
                  _buildPolicySection(
                    title: '📌 10. القانون الحاكم',
                    content: '''
تخضع هذه الشروط وتفسر وفقاً لقوانين فلسطين. أي نزاع ينشأ عن هذه الشروط يخضع للاختصاص القضائي الحصري لمحاكم فلسطين.

آخر تحديث: مايو 2026
''',
                  ),
                  const SizedBox(height: 20),
                  
                  _buildPolicySection(
                    title: '📌 11. اتصل بنا',
                    content: '''
للاستفسارات حول شروط الاستخدام، يمكنك التواصل معنا:

📧 البريد الإلكتروني: diabpredict@ucas.edu.ps
🏫 جامعة UCAS - غزة، فلسطين
📞 هاتف: (يمكن إضافة الرقم)
''',
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // زر إغلاق
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),  // لون بنفسجي للتمييز
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'إغلاق',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
void _showRateDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      title: const Row(
        children: [
          Icon(Icons.star, color: Colors.amber, size: 28),
          SizedBox(width: 8),
          Text(
            'قيم التطبيق',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'هل أعجبك تطبيق DiabPredict؟',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF334155),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStarIcon(0),
              _buildStarIcon(1),
              _buildStarIcon(2),
              _buildStarIcon(3),
              _buildStarIcon(4),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'تقييمك يساعدنا في تحسين التطبيق',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey.shade600,
          ),
          child: const Text('لاحقاً'),
        ),
        ElevatedButton(
          onPressed: () => _rateApp(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text('تقييم الآن'),
        ),
      ],
    ),
  );
}

Widget _buildStarIcon(int index) {
  return GestureDetector(
    onTap: () {
      _rateApp();
      Navigator.pop(context);
    },
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: const Icon(
        Icons.star,
        color: Colors.amber,
        size: 40,
      ),
    ),
  );
}



Future<void> _rateApp() async {
  // رابط التطبيق على Google Play (استبدل بمعرف تطبيقك الفعلي)
  const String appId = 'com.example.mobile_app';
  final Uri url = Uri.parse('https://play.google.com/store/apps/details?id=$appId');
  
  try {
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      // حفظ أن المستخدم قام بالتقييم لمنع ظهور الحوار مرة أخرى
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_rated', true);
    } else {
      _showSnackBar('⚠️ لا يمكن فتح متجر Google Play');
    }
  } catch (e) {
    // بديل: فتح الرابط في المتصفح
    try {
      final Uri fallbackUrl = Uri.parse('https://play.google.com/store/apps/details?id=$appId');
      if (await canLaunchUrl(fallbackUrl)) {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      _showSnackBar('⚠️ حدث خطأ في فتح المتجر');
    }
  }
}

// ✅ إنشاء نسخة احتياطية من جميع البيانات
Future<void> _backupData() async {
  try {
    _showSnackBar('📁 جاري إنشاء النسخة الاحتياطية...');
    
    final allPredictions = _storageService.getAllPredictions();
    
    if (allPredictions.isEmpty) {
      _showSnackBar('⚠️ لا توجد بيانات للنسخ الاحتياطي');
      return;
    }
    
    // إنشاء محتوى JSON للنسخ الاحتياطي
    final backupData = {
      'backup_date': DateTime.now().toIso8601String(),
      'app_version': '1.0.0',
      'predictions_count': allPredictions.length,
      'predictions': allPredictions.map((data) => data.toJson()).toList(),
      'settings': {
        'notifications_enabled': _notificationsEnabled,
        'dark_mode_enabled': _darkModeEnabled,
        'language': _selectedLanguage,
        'font_size': _selectedFontSize,
        'auto_save_results': _autoSaveResults,
        'share_data_anonymously': _shareDataAnonymously,
        'backup_frequency': _backupFrequency,
      },
    };
    
    final jsonContent = jsonEncode(backupData);
    final fileName = 'diabpredict_backup_${DateTime.now().toIso8601String().replaceAll(':', '-').substring(0, 19)}.json';
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsString(jsonContent, encoding: utf8);
    
    _showBackupSuccessDialog(filePath, allPredictions.length);
    
  } catch (e) {
    _showSnackBar('❌ فشل إنشاء النسخة الاحتياطية: $e');
  }
}

// ✅ استعادة البيانات من نسخة احتياطية
Future<void> _restoreBackup() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    
    if (result == null) return;
    
    final filePath = result.files.single.path;
    if (filePath == null) return;
    
    final file = File(filePath);
    final content = await file.readAsString();
    final backupData = jsonDecode(content);
    
    // استعادة التنبؤات
    final predictions = backupData['predictions'] as List;
    
    for (var pred in predictions) {
      final healthData = HealthData.fromJson(pred);
      await _storageService.savePrediction(healthData);
    }
    
    _showSnackBar('✅ تم استعادة ${predictions.length} سجل بنجاح');
    await _loadSettings();
    
  } catch (e) {
    _showSnackBar('❌ فشل استعادة النسخة الاحتياطية: $e');
  }
}

void _showBackupSuccessDialog(String filePath, int count) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    backgroundColor: Colors.white,
    builder: (context) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.backup, color: Color(0xFF10B981), size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            '✅ تم إنشاء النسخة الاحتياطية',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          Text(
            'تم حفظ $count سجل',
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _shareExportedFile(filePath);
                  },
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('مشاركة'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    side: const BorderSide(color: Color(0xFF2563EB)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('حسناً'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
// // ✅ إرسال البيانات مجهولة المصدر لتحسين النموذج
// Future<void> _sendAnonymousData() async {
//   if (!_shareDataAnonymously) return;
  
//   try {
//     final allPredictions = _storageService.getAllPredictions();
//     if (allPredictions.isEmpty) return;
    
//     // جمع آخر 10 تنبؤات فقط (لتقليل الحجم)
//     final recentPredictions = allPredictions.reversed.take(10).toList();
    
//     final anonymousData = {
//       'device_id': await _getDeviceId(),  // معرف فريد مجهول
//       'timestamp': DateTime.now().toIso8601String(),
//       'predictions': recentPredictions.map((data) => {
//         'risk': data.localRisk ?? data.calculateRiskLocally(),
//         'age': data.age,
//         'bmi': data.bmi,
//         'hba1c': data.hba1c,
//         'glucose': data.glucose,
//         // لا نرسل معلومات شخصية
//       }).toList(),
//     };
    
//     // إرسال إلى الخادم (اختياري)
//     // await http.post(
//     //   Uri.parse('$baseUrl/anonymous-data'),
//     //   body: jsonEncode(anonymousData),
//     // );
    
//     print('📊 تم إرسال ${recentPredictions.length} سجل مجهول لتحسين النموذج');
    
//   } catch (e) {
//     print('❌ فشل إرسال البيانات: $e');
//   }
// }

// // ✅ إنشاء معرف جهاز فريد ومجهول
// Future<String> _getDeviceId() async {
//   final prefs = await SharedPreferences.getInstance();
//   String? deviceId = prefs.getString('anonymous_device_id');
//   if (deviceId == null) {
//     deviceId = DateTime.now().millisecondsSinceEpoch.toString();
//     await prefs.setString('anonymous_device_id', deviceId);
//   }
//   return deviceId;
// }

// ✅ إرسال بيانات مجهولة لتحسين النموذج
Future<void> _sendAnonymousDataForImprovement(HealthData healthData, double riskPercentage) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final shareDataEnabled = prefs.getBool('share_data_anonymously') ?? false;
    
    if (!shareDataEnabled) return;
    
    // إنشاء معرف جهاز فريد ومجهول
    String? deviceId = prefs.getString('anonymous_device_id');
    if (deviceId == null) {
      deviceId = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString('anonymous_device_id', deviceId);
    }
    
    // تجهيز البيانات المجهولة (بدون معلومات شخصية)
    final anonymousData = {
      'device_id': deviceId,
      'timestamp': DateTime.now().toIso8601String(),
      'risk_percentage': riskPercentage,
      'health_data': {
        'age': healthData.age,
        'bmi': healthData.bmi,
        'hba1c': healthData.hba1c,
        'glucose': healthData.glucose,
        'blood_pressure_systolic': healthData.bloodPressureSystolic,
        'blood_pressure_diastolic': healthData.bloodPressureDiastolic,
        'cholesterol': healthData.cholesterol,
        'family_history': healthData.familyHistory,
        'smoking': healthData.smoking,
        'physical_activity': healthData.physicalActivity,
        'waist_circumference': healthData.waistCircumference,
        'hba1c_detailed': healthData.hba1cDetailed,
      },
    };
    
    // إرسال إلى الخادم (إذا كان متاحاً)
    // final response = await http.post(
    //   Uri.parse('$baseUrl/anonymous-feedback'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode(anonymousData),
    // );
    
    print('📊 تم إرسال بيانات مجهولة لتحسين النموذج (Risk: ${riskPercentage.toStringAsFixed(1)}%)');
    
  } catch (e) {
    print('⚠️ فشل إرسال البيانات المجهولة: $e');
  }
}
// ✅ رسالة توضيحية عند تفعيل مشاركة البيانات
void _showAnonymousDataInfo() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Row(
        children: [
          Icon(Icons.analytics, color: Color(0xFF2563EB), size: 28),
          SizedBox(width: 8),
          Text('مشاركة البيانات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.privacy_tip, size: 48, color: Color(0xFF10B981)),
          SizedBox(height: 16),
          Text(
            'سيتم إرسال بياناتك الصحية بشكل مجهول بالكامل',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            '✓ بدون اسم أو بريد إلكتروني\n'
            '✓ بدون معلومات تعريفية\n'
            '✓ تستخدم فقط لتحسين دقة النموذج\n'
            '✓ يمكنك إلغاء المشاركة في أي وقت',
            style: TextStyle(fontSize: 14, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('فهمت'),
        ),
      ],
    ),
  );
}


}