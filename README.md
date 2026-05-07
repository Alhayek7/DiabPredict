# DiabPredict
نظام ذكي للتنبؤ المبكر بخطر السكري باستخدام Flutter و FastAPI و XGBoost
# DiabPredict - نظام للتنبؤ المبكر بخطر السكري 🩺

## 📱 عن المشروع
تطبيق ذكي يستخدم تقنيات تعلم الآلة والذكاء الاصطناعي للتنبؤ المبكر بخطر الإصابة بمرض السكري.

## 🛠️ التقنيات المستخدمة
- **Flutter** - تطوير واجهة المستخدم
- **FastAPI** - بناء الـ Backend
- **XGBoost** - نموذج التنبؤ
- **SHAP** - تفسير النتائج
- **Gemini AI** - المساعد الذكي

## 🔧 متطلبات التشغيل
- Flutter SDK 3.x
- Python 3.10+
- Android Studio / VS Code

## 🚀 تشغيل التطبيق
```bash
# تشغيل الـ Backend
cd backend
pip install -r requirements.txt
uvicorn main:app --reload

# تشغيل تطبيق Flutter
cd mobile_app
flutter pub get
flutter run
