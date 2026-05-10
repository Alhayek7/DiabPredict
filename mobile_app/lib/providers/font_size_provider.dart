import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSizeProvider extends ChangeNotifier {
  double _fontSize = 14.0; // الحجم الافتراضي (متوسط)
  
  double get fontSize => _fontSize;
  
  Future<void> loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    final size = prefs.getString('font_size') ?? 'متوسط';
    
    switch (size) {
      case 'صغير':
        _fontSize = 12.0;
        break;
      case 'كبير':
        _fontSize = 18.0;
        break;
      default:
        _fontSize = 14.0;
    }
    notifyListeners();
  }
  
  Future<void> setFontSize(String size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('font_size', size);
    
    switch (size) {
      case 'صغير':
        _fontSize = 12.0;
        break;
      case 'كبير':
        _fontSize = 18.0;
        break;
      default:
        _fontSize = 14.0;
    }
    notifyListeners();
  }
}