  import 'dart:convert';
  import 'package:http/http.dart' as http;
  import '../models/health_data.dart';
  import 'package:shared_preferences/shared_preferences.dart';


  class ApiService {
    // للمحاكي Android 
    // static const String baseUrl = 'http://10.0.2.2:8000';

    // للجهاز الحقيقي ولكن يشترط وجودهما بنفس الشبكة 
    // static const String baseUrl = 'http://192.168.1.100:8000';
      // static const String baseUrl = 'http://192.168.152.1:8000';
      // static const String baseUrl = 'http://192.168.152.1:8000';
      static const String baseUrl = 'https://diabpredict-api.onrender.com';

    // للويب
    // static const String baseUrl = 'http://localhost:8000';
    // ✅ استخدم الرابط الذي تحصل عليه من ngrok
    // static const String baseUrl = 'https://uninvited-street-facsimile.ngrok-free.dev -> http://localhost:8000.ngrok-free.dev';

    Future<PredictionResult?> predict(HealthData data) async {
    try {
      print('📡 Connecting to: $baseUrl/predict');
      print('📤 Data: ${data.toJson()}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data.toJson()),
      ).timeout(const Duration(seconds: 30));

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = PredictionResult.fromJson(jsonDecode(response.body));
        print('✅ Success! Risk: ${result.riskPercentage}%');
        return result;
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Exception: $e');
      return null;
    }
  }
    Future<Map<String, dynamic>?> checkHealth() async {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/health'),
        ).timeout(const Duration(seconds: 5));
        
        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        }
        return null;
      } catch (e) {
        return null;
      }
    }

    Future<Map<String, dynamic>?> getAssistantAdvice(
      double riskPercentage,
      Map<String, double> shapValues,
      HealthData data, {
      String? question,
    }) async {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/assistant'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'risk_percentage': riskPercentage,
            'shap_values': shapValues,
            'health_data': data.toJson(),
            'question': question,
          }),
        ).timeout(const Duration(seconds: 45));

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        }
        return null;
      } catch (e) {
        print('Exception: $e');
        return null;
      }
    }
  }