import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'local_storage_service.dart';
import '../models/health_data.dart';

class SyncService {
  final LocalStorageService _storage = LocalStorageService();
  
  // ✅ رابط الـ Backend (سيتم تحديثه بعد النشر)
  static const String baseUrl = 'http://10.3.2.196:8000'; // مؤقت للاختبار
  
  // التحقق من الاتصال بالإنترنت
  Future<bool> hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }
  
  // مزامنة توقع واحد مع الـ Backend
  Future<bool> syncPrediction(HealthData data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data.toJson()),
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        await _storage.markAsSynced(data);
        print('✅ Synced: ${data.timestamp}');
        return true;
      } else {
        print('❌ Sync failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Sync error: $e');
      return false;
    }
  }
  
  // مزامنة جميع التوقعات غير المتزامنة
  Future<void> syncPendingPredictions() async {
    final hasConnection = await hasInternet();
    if (!hasConnection) {
      print('⚠️ No internet connection. Sync postponed.');
      return;
    }
    
    final unsynced = _storage.getUnsyncedPredictions();
    if (unsynced.isEmpty) {
      print('✅ No pending predictions to sync');
      return;
    }
    
    print('🔄 Syncing ${unsynced.length} predictions...');
    
    for (var data in unsynced) {
      await syncPrediction(data);
      // انتظار قصير بين الطلبات
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    print('✅ Sync completed');
  }
  
  // بدء المزامنة التلقائية عند استعادة الاتصال
  void startAutoSync() {
    Connectivity().onConnectivityChanged.listen((_) async {
      await syncPendingPredictions();
    });
    print('✅ Auto-sync service started');
  }
  
  // اختبار الاتصال بالـ Backend
  Future<bool> testBackendConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Backend connection test failed: $e');
      return false;
    }
  }
}