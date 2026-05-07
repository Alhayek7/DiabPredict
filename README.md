# 🩺 DiabPredict - نظام ذكي للتنبؤ المبكر بخطر السكري

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/FastAPI-009688?style=flat&logo=fastapi&logoColor=white"/>
  <img src="https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white"/>
  <img src="https://img.shields.io/badge/XGBoost-FF6B6B?style=flat&logo=xgboost&logoColor=white"/>
  <img src="https://img.shields.io/badge/Gemini_AI-4285F4?style=flat&logo=google&logoColor=white"/>
  <br>
  <img src="https://img.shields.io/badge/version-1.0.0-blue.svg"/>
  <img src="https://img.shields.io/badge/license-MIT-green.svg"/>
  <img src="https://img.shields.io/badge/Flutter-3.13+-blue.svg"/>
  <img src="https://img.shields.io/badge/Python-3.10+-blue.svg"/>
</div>

<br>

## 📖 نبذة عن المشروع

**DiabPredict** هو تطبيق ذكي متكامل للكشف المبكر عن خطر الإصابة بمرض السكري باستخدام تقنيات تعلم الآلة والذكاء الاصطناعي.

---

## ✨ الميزات الرئيسية

| الميزة | الوصف |
|--------|-------|
| 🎯 **تنبؤ دقيق** | استخدام نموذج XGBoost المدرب على بيانات PIMA Indians |
| 📊 **تفسير النتائج** | عرض أهم العوامل المؤثرة باستخدام SHAP values |
| 🤖 **مساعد ذكي** | إجابات ذكية على الأسئلة الصحية باستخدام Gemini AI |
| 📱 **Offline-First** | يعمل بدون إنترنت مع مزامنة تلقائية |
| 📈 **رسوم بيانية** | تتبع تطور نسبة الخطر عبر الزمن |
| 🏥 **سجل التنبؤات** | حفظ جميع التنبؤات السابقة مع تفاصيلها |
| 🕌 **واجهة عربية** | دعم كامل للغة العربية |

---

## 🛠️ التقنيات المستخدمة

### الواجهة الأمامية (Frontend)
- **Flutter 3.13+** - إطار العمل الرئيسي
- **Dart 3.0+** - لغة البرمجة
- **Hive** - تخزين محلي
- **Fl Chart** - الرسوم البيانية

### الخادم الخلفي (Backend)
- **FastAPI** - إطار العمل الرئيسي
- **Python 3.10+** - لغة البرمجة
- **XGBoost** - نموذج التنبؤ
- **SHAP** - تفسير النتائج
- **Google Gemini AI** - المساعد الذكي

---

## 🚀 كيفية التشغيل

### 1. تشغيل الخادم الخلفي
```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### 2. تشغيل تطبيق Flutter
```bash
cd mobile_app
flutter pub get
flutter run
```

### 3. بناء APK للتثبيت
```bash
flutter build apk --release
```

---

## 📊 نموذج التنبؤ

- **البيانات**: PIMA Indians Diabetes Database (768 عينة)
- **الميزات**: العمر، BMI، السكر التراكمي، سكر الدم، ضغط الدم، الكوليسترول
- **الدقة**: ~92%

---

## 🤖 أسئلة المساعد الذكي المدعومة

| الفئة | أمثلة الأسئلة |
|-------|---------------|
| 🥗 الغذاء | "ما هي الأطعمة التي تقلل السكري؟" |
| 🏃 الرياضة | "كم مرة يجب أن أمارس الرياضة؟" |
| ⚠️ الأعراض | "ما هي أعراض السكري المبكرة؟" |
| 📉 التحاليل | "كيف أخفض السكر التراكمي؟" |

---

## 📁 هيكل المشروع

```
DiabPredict/
├── backend/          # FastAPI + XGBoost + Gemini
├── mobile_app/       # Flutter تطبيق الموبايل
└── web_app/          # تطبيق الويب (Streamlit)
```

---

## 🔧 المتطلبات الأساسية

- Flutter SDK 3.13+
- Python 3.10+
- Android Studio / VS Code

---

## 📝 التحديثات المستقبلية

- [ ] دعم اللغة الإنجليزية
- [ ] تكامل مع Google Fit
- [ ] تطبيق Apple Watch

---

## 📄 الترخيص

MIT License

---

## 👨‍💻 المطور

**Ahmed Wesam Alhayek** - Full Stack Developer

---

<div align="center">
  <br>
  <p>⭐ إذا أعجبك المشروع، لا تنسى أن تترك نجمة ⭐</p>
  <p>بُني بـ ❤️</p>
</div>
