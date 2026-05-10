import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'user_model.g.dart';

/// 🧠 نموذج المستخدم المتقدم - يدعم التوثيق والتخزين المحلي
@HiveType(typeId: 1)
class UserModel {
  // ═══════════════════════════════════════════════════════════════
  // الحقول الأساسية
  // ═══════════════════════════════════════════════════════════════
  
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String username;
  
  @HiveField(2)
  final String email;
  
  @HiveField(3)
  final String passwordHash;
  
  @HiveField(4)
  final DateTime createdAt;
  
  @HiveField(5)
  final bool isGuest;
  
  // ═══════════════════════════════════════════════════════════════
  // الحقول الإضافية (اختيارية)
  // ═══════════════════════════════════════════════════════════════
  
  @HiveField(6)
  final String? photoUrl;
  
  @HiveField(7)
  final DateTime? lastLogin;
  
  @HiveField(8)
  final bool isActive;
  
  @HiveField(9)
  final Map<String, dynamic>? preferences;
  
  @HiveField(10)
  String? lastPredictionId;
  
  @HiveField(11)
  final int totalPredictions;
  
  @HiveField(12)
  final String? phoneNumber;
  
  @HiveField(13)
  final DateTime? dateOfBirth;

  // ═══════════════════════════════════════════════════════════════
  // المُنشئ الأساسي
  // ═══════════════════════════════════════════════════════════════
  
UserModel({
  required this.id,
  required this.username,
  required this.email,
  required this.passwordHash,
  required this.createdAt,
  this.isGuest = false,
  this.photoUrl,
  DateTime? lastLogin,
  this.isActive = true,
  this.preferences,
  this.lastPredictionId,
  this.totalPredictions = 0,
  this.phoneNumber,
  this.dateOfBirth,
}) : lastLogin = lastLogin ?? createdAt;
  // ═══════════════════════════════════════════════════════════════
  // تحويل الكائن إلى JSON
  // ═══════════════════════════════════════════════════════════════
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'passwordHash': passwordHash,
    'createdAt': createdAt.toIso8601String(),
    'isGuest': isGuest,
    'photoUrl': photoUrl,
    'lastLogin': lastLogin?.toIso8601String(),
    'isActive': isActive,
    'preferences': preferences,
    'lastPredictionId': lastPredictionId,
    'totalPredictions': totalPredictions,
    'phoneNumber': phoneNumber,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
  };

  // ═══════════════════════════════════════════════════════════════
  // إنشاء كائن من JSON
  // ═══════════════════════════════════════════════════════════════
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      passwordHash: json['passwordHash'],
      createdAt: DateTime.parse(json['createdAt']),
      isGuest: json['isGuest'] ?? false,
      photoUrl: json['photoUrl'],
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      isActive: json['isActive'] ?? true,
      preferences: json['preferences'],
      lastPredictionId: json['lastPredictionId'],
      totalPredictions: json['totalPredictions'] ?? 0,
      phoneNumber: json['phoneNumber'],
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // نسخة محدثة من الكائن (للتعديلات)
  // ═══════════════════════════════════════════════════════════════
  
  UserModel copyWith({
    String? username,
    String? photoUrl,
    bool? isActive,
    Map<String, dynamic>? preferences,
    String? lastPredictionId,
    int? totalPredictions,
    String? phoneNumber,
    DateTime? dateOfBirth,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      email: email,
      passwordHash: passwordHash,
      createdAt: createdAt,
      isGuest: isGuest,
      photoUrl: photoUrl ?? this.photoUrl,
      lastLogin: lastLogin ?? DateTime.now(),
      isActive: isActive ?? this.isActive,
      preferences: preferences ?? this.preferences,
      lastPredictionId: lastPredictionId ?? this.lastPredictionId,
      totalPredictions: totalPredictions ?? this.totalPredictions,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // دوال مساعدة
  // ═══════════════════════════════════════════════════════════════
  
  /// زيادة عدد التنبؤات بمقدار 1
  UserModel incrementPredictionCount() {
    return copyWith(totalPredictions: totalPredictions + 1);
  }

  /// تحديث آخر تنبؤ
  UserModel updateLastPrediction(String predictionId) {
    return copyWith(lastPredictionId: predictionId, lastLogin: DateTime.now());
  }

  /// هل المستخدم مكتمل البيانات؟
  bool get isProfileComplete {
    return phoneNumber != null && 
           phoneNumber!.isNotEmpty && 
           dateOfBirth != null;
  }

  /// الحصول على عمر المستخدم (إذا كان تاريخ الميلاد موجوداً)
  int? get age {
    if (dateOfBirth == null) return null;
    final today = DateTime.now();
    int age = today.year - dateOfBirth!.year;
    if (today.month < dateOfBirth!.month || 
        (today.month == dateOfBirth!.month && today.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  /// تنسيق تاريخ الميلاد
  String get formattedBirthDate {
    if (dateOfBirth == null) return 'غير محدد';
    return '${dateOfBirth!.day}/${dateOfBirth!.month}/${dateOfBirth!.year}';
  }

  /// الحصول على أيقونة المستخدم
  String get avatarIcon {
    if (photoUrl != null && photoUrl!.isNotEmpty) return '🖼️';
    if (isGuest) return '👤';
    return '👨‍⚕️';
  }

  /// الحصول على لون المستخدم
  Color get avatarColor {
    if (isGuest) return Colors.grey;
    return const Color(0xFF2563EB);
  }

  /// الحصول على اسم مختصر (للأحرف الأولى)
  String get initials {
    if (username.isEmpty) return '?';
    final parts = username.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// التحقق من صحة البريد الإلكتروني
  bool get isValidEmail {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// التحقق من صحة رقم الهاتف
  bool get isValidPhoneNumber {
    if (phoneNumber == null || phoneNumber!.isEmpty) return false;
    final phoneRegex = RegExp(r'^(\+[0-9]{1,3})?[0-9]{9,12}$');
    return phoneRegex.hasMatch(phoneNumber!);
  }
}

// ═══════════════════════════════════════════════════════════════
// كلاس إضافي: إعدادات المستخدم
// ═══════════════════════════════════════════════════════════════

@HiveType(typeId: 2)
class UserSettings {
  @HiveField(0)
  final String language;
  
  @HiveField(1)
  final bool notificationsEnabled;
  
  @HiveField(2)
  final bool darkMode;
  
  @HiveField(3)
  final double fontSize;
  
  @HiveField(4)
  final bool autoSaveResults;
  
  @HiveField(5)
  final String? themeColor;

  UserSettings({
    this.language = 'ar',
    this.notificationsEnabled = true,
    this.darkMode = false,
    this.fontSize = 14.0,
    this.autoSaveResults = true,
    this.themeColor,
  });

  Map<String, dynamic> toJson() => {
    'language': language,
    'notificationsEnabled': notificationsEnabled,
    'darkMode': darkMode,
    'fontSize': fontSize,
    'autoSaveResults': autoSaveResults,
    'themeColor': themeColor,
  };

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      language: json['language'] ?? 'ar',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      darkMode: json['darkMode'] ?? false,
      fontSize: (json['fontSize'] ?? 14.0).toDouble(),
      autoSaveResults: json['autoSaveResults'] ?? true,
      themeColor: json['themeColor'],
    );
  }

  UserSettings copyWith({
    String? language,
    bool? notificationsEnabled,
    bool? darkMode,
    double? fontSize,
    bool? autoSaveResults,
    String? themeColor,
  }) {
    return UserSettings(
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkMode: darkMode ?? this.darkMode,
      fontSize: fontSize ?? this.fontSize,
      autoSaveResults: autoSaveResults ?? this.autoSaveResults,
      themeColor: themeColor ?? this.themeColor,
    );
  }
}