import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

/// نموذج المستخدم
class UserModel {
  final String id;
  final String username;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLogin;
  final bool isGuest;
  final bool isActive;
  final Map<String, dynamic>? preferences;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    required this.lastLogin,
    this.isGuest = false,
    this.isActive = true,
    this.preferences,
  });

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'photoUrl': photoUrl,
    'createdAt': createdAt.toIso8601String(),
    'lastLogin': lastLogin.toIso8601String(),
    'isGuest': isGuest,
    'isActive': isActive,
    'preferences': preferences,
  };

  /// إنشاء من JSON
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    username: json['username'],
    email: json['email'],
    photoUrl: json['photoUrl'],
    createdAt: DateTime.parse(json['createdAt']),
    lastLogin: DateTime.parse(json['lastLogin']),
    isGuest: json['isGuest'] ?? false,
    isActive: json['isActive'] ?? true,
    preferences: json['preferences'],
  );

  /// نسخة محدثة
  UserModel copyWith({
    String? username,
    String? photoUrl,
    bool? isActive,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      lastLogin: DateTime.now(),
      isGuest: isGuest,
      isActive: isActive ?? this.isActive,
      preferences: preferences ?? this.preferences,
    );
  }
}

/// خدمة المصادقة - احترافية ومتزامنة
class AuthService {
  static const String _keyUsers = 'app_users';
  static const String _keyCurrentUserId = 'current_user_id';
  static const String _keyGuestId = 'guest_id';
  
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  
  AuthService._();
  
  UserModel? _currentUser;
  Map<String, UserModel> _usersCache = {};
  bool _isInitialized = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null && !_currentUser!.isGuest;
  bool get isGuest => _currentUser != null && _currentUser!.isGuest;
  bool get isInitialized => _isInitialized;

  /// تهيئة الخدمة
  Future<AuthService> init() async {
    if (_isInitialized) return this;
    
    await _loadUsers();
    await _loadCurrentUser();
    _isInitialized = true;
    
    return this;
  }

  /// تحميل جميع المستخدمين
  Future<void> _loadUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_keyUsers);
      
      if (usersJson != null && usersJson.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(usersJson);
        _usersCache = {};
        decoded.forEach((key, value) {
          _usersCache[key] = UserModel.fromJson(value);
        });
      }
    } catch (e) {
      print('Error loading users: $e');
      _usersCache = {};
    }
  }

  /// حفظ المستخدمين
  Future<void> _saveUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> toSave = {};
      _usersCache.forEach((key, value) {
        toSave[key] = value.toJson();
      });
      await prefs.setString(_keyUsers, jsonEncode(toSave));
    } catch (e) {
      print('Error saving users: $e');
    }
  }

  /// تحميل المستخدم الحالي
  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString(_keyCurrentUserId);
      
      if (userId == null || userId.isEmpty) {
        userId = prefs.getString(_keyGuestId);
      }
      
      if (userId != null && _usersCache.containsKey(userId)) {
        _currentUser = _usersCache[userId];
        await _updateLastLogin(_currentUser!.id);
      } else {
        await _createGuestUser();
      }
    } catch (e) {
      print('Error loading current user: $e');
      await _createGuestUser();
    }
  }

  /// إنشاء مستخدم زائر
  Future<void> _createGuestUser() async {
    final guestId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
    final guest = UserModel(
      id: guestId,
      username: 'زائر',
      email: 'guest_${DateTime.now().millisecondsSinceEpoch}@temp.local',
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
      isGuest: true,
    );
    
    _usersCache[guestId] = guest;
    _currentUser = guest;
    await _saveUsers();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyGuestId, guestId);
  }

  /// تحديث آخر تسجيل دخول
  Future<void> _updateLastLogin(String userId) async {
    if (_usersCache.containsKey(userId)) {
      final user = _usersCache[userId]!;
      _usersCache[userId] = user.copyWith();
      await _saveUsers();
    }
  }

  /// تسجيل مستخدم جديد
  Future<AuthResult> register({
    required String username,
    required String email,
    required String password,
    String? photoUrl,
  }) async {
    try {
      // التحقق من صحة البريد الإلكتروني
      if (!_isValidEmail(email)) {
        return AuthResult.error('البريد الإلكتروني غير صالح');
      }
      
      // التحقق من قوة كلمة المرور
      if (!_isStrongPassword(password)) {
        return AuthResult.error('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      }
      
      // التحقق من وجود المستخدم
      final existingUser = _usersCache.values.any(
        (user) => user.email.toLowerCase() == email.toLowerCase() && !user.isGuest
      );
      
      if (existingUser) {
        return AuthResult.error('البريد الإلكتروني مستخدم مسبقاً');
      }
      
      // إنشاء مستخدم جديد
      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      final hashedPassword = _hashPassword(password);
      
      final newUser = UserModel(
        id: userId,
        username: username,
        email: email.toLowerCase(),
        photoUrl: photoUrl,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        isGuest: false,
        preferences: {
          'language': 'ar',
          'notifications': true,
          'darkMode': false,
        },
      );
      
      _usersCache[userId] = newUser;
      _currentUser = newUser;
      
      // حفظ كلمة المرور المشفرة (في SharedPreferences منفصلة)
      await _saveUserPassword(userId, hashedPassword);
      await _saveUsers();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyCurrentUserId, userId);
      await prefs.remove(_keyGuestId);
      
      return AuthResult.success(newUser);
    } catch (e) {
      return AuthResult.error('حدث خطأ أثناء إنشاء الحساب');
    }
  }

  /// تسجيل الدخول
  Future<AuthResult> login(String email, String password) async {
    try {
      final user = _usersCache.values.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase() && !user.isGuest,
        orElse: () => throw Exception(),
      );
      
      final storedPassword = await _getUserPassword(user.id);
      
      if (storedPassword != _hashPassword(password)) {
        return AuthResult.error('كلمة المرور غير صحيحة');
      }
      
      _currentUser = user;
      await _updateLastLogin(user.id);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyCurrentUserId, user.id);
      await prefs.remove(_keyGuestId);
      
      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.error('البريد الإلكتروني أو كلمة المرور غير صحيحة');
    }
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrentUserId);
    
    await _createGuestUser();
    await _saveUsers();
  }

  /// تحديث الملف الشخصي
  Future<AuthResult> updateProfile({
    String? username,
    String? photoUrl,
    Map<String, dynamic>? preferences,
  }) async {
    if (_currentUser == null) {
      return AuthResult.error('لا يوجد مستخدم نشط');
    }
    
    try {
      final updatedUser = _currentUser!.copyWith(
        username: username,
        photoUrl: photoUrl,
        preferences: preferences,
      );
      
      _usersCache[_currentUser!.id] = updatedUser;
      _currentUser = updatedUser;
      await _saveUsers();
      
      return AuthResult.success(updatedUser);
    } catch (e) {
      return AuthResult.error('حدث خطأ أثناء تحديث الملف الشخصي');
    }
  }

  /// تغيير كلمة المرور
  Future<AuthResult> changePassword(String oldPassword, String newPassword) async {
    if (_currentUser == null || _currentUser!.isGuest) {
      return AuthResult.error('لا يمكن تغيير كلمة المرور لحساب الزائر');
    }
    
    if (!_isStrongPassword(newPassword)) {
      return AuthResult.error('كلمة المرور الجديدة يجب أن تكون 6 أحرف على الأقل');
    }
    
    final storedPassword = await _getUserPassword(_currentUser!.id);
    
    if (storedPassword != _hashPassword(oldPassword)) {
      return AuthResult.error('كلمة المرور الحالية غير صحيحة');
    }
    
    await _saveUserPassword(_currentUser!.id, _hashPassword(newPassword));
    return AuthResult.success(_currentUser!);
  }

  /// حذف الحساب
  Future<AuthResult> deleteAccount() async {
    if (_currentUser == null || _currentUser!.isGuest) {
      return AuthResult.error('لا يمكن حذف حساب الزائر');
    }
    
    try {
      _usersCache.remove(_currentUser!.id);
      await _saveUsers();
      await _deleteUserPassword(_currentUser!.id);
      await logout();
      
      return AuthResult.success(null);
    } catch (e) {
      return AuthResult.error('حدث خطأ أثناء حذف الحساب');
    }
  }

  // ========== دوال مساعدة خاصة ==========

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<void> _saveUserPassword(String userId, String hashedPassword) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pass_$userId', hashedPassword);
  }

  Future<String?> _getUserPassword(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('pass_$userId');
  }

  Future<void> _deleteUserPassword(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pass_$userId');
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _isStrongPassword(String password) {
    return password.length >= 6;
  }

  /// الحصول على مفتاح التخزين للمستخدم الحالي
String getCurrentStorageKey() {
  if (isLoggedIn && currentUser != null) {
    return 'user_${currentUser!.id}';  // ✅ بيانات المستخدم المسجل
  }
  return 'guest_${currentUser!.id}';   // ✅ بيانات الزائر
}
}

/// نتيجة عملية المصادقة
class AuthResult {
  final bool success;
  final String? errorMessage;
  final UserModel? user;

  AuthResult._({required this.success, this.errorMessage, this.user});

  factory AuthResult.success(UserModel? user) {
    return AuthResult._(success: true, user: user);
  }

  factory AuthResult.error(String message) {
    return AuthResult._(success: false, errorMessage: message);
  }
}