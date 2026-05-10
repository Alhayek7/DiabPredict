import 'package:flutter/foundation.dart';  // ✅ إضافة هذا للـ debugPrint
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  /// تهيئة خدمة الإشعارات (يتم استدعاؤها في main.dart)
  static Future<void> init() async {
    // إعدادات Android
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // إعدادات iOS
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    // إعدادات المنصات
    const settings = InitializationSettings(
      android: android,
      iOS: ios,
    );
    
    await _notifications.initialize(settings);
    debugPrint('✅ Notification service initialized');
  }

  /// عرض إشعار عادي
  static Future<void> showNotification(
    String title,
    String body, {
    int id = 0,
  }) async {
    // تفاصيل الإشعار لنظام Android
    const androidDetails = AndroidNotificationDetails(
      'diabpredict_channel',
      'تذكيرات صحية',
      channelDescription: 'إشعارات تذكيرية وتنبيهات من تطبيق DiabPredict',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    
    // تفاصيل الإشعار لنظام iOS
    const iosDetails = DarwinNotificationDetails();
    
    // تجميع التفاصيل
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    // عرض الإشعار
    await _notifications.show(id, title, body, details);
    debugPrint('📢 Notification shown: $title');
  }

  /// عرض إشعار مع صورة (اختياري)
  static Future<void> showNotificationWithImage(
    String title,
    String body,
    String imagePath, {
    int id = 0,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'diabpredict_channel',
      'تذكيرات صحية',
      channelDescription: 'إشعارات تذكيرية وتنبيهات من تطبيق DiabPredict',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigPictureStyleInformation(
        FilePathAndroidBitmap(imagePath),
      ),
    );
    
    const iosDetails = DarwinNotificationDetails();
    
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(id, title, body, details);
  }

  /// إلغاء جميع الإشعارات
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
    debugPrint('🔕 All notifications cancelled');
  }
}