import google.generativeai as genai
import os
import re
from dotenv import load_dotenv
from typing import Dict, Optional, List
from difflib import get_close_matches

load_dotenv()

class GeminiService:
    def __init__(self):
        # محاولة تهيئة Gemini API أولاً
        api_key = os.getenv("GEMINI_API_KEY")
        self.use_api = False
        
        if api_key and api_key != "your_api_key_here":
            try:
                genai.configure(api_key=api_key)

                # تجربة عدة نماذج حتى ينجح أحدها
                models_to_try = [
                    'gemini-2.0-flash-exp',      # الأحدث (تجريبي)
                    'gemini-1.5-flash',          # السريع
                    'gemini-1.5-pro',            # القوي
                    'gemini-pro',                # القديم المستقر
                ]

                for model_name in models_to_try:
                    try:
                        self.model = genai.GenerativeModel(model_name)
                        test_response = self.model.generate_content("Test")
                        if test_response:
                            self.model_name = model_name
                            self.use_api = True
                            print(f"✅ Gemini API initialized with model: {model_name}")
                            break
                    except:
                        continue

                if self.use_api:
                    print("✅ Gemini AI API initialized successfully!")
                else:
                    print("⚠️ No Gemini models available. Using smart local responses.")
                    
            except Exception as e:
                print(f"⚠️ Could not initialize Gemini API: {e}")
                print("✅ Falling back to local smart responses.")
        else:
            print("⚠️ GEMINI_API_KEY not found. Using local smart responses.")
    
    def get_health_advice(self, risk_percentage: float, shap_values: Dict, 
                           health_data: Dict, user_question: Optional[str] = None) -> Dict:
        """
        الحصول على نصائح صحية مخصصة - يحاول API أولاً، ثم الرجوع إلى الردود المحلية
        """
        # تحليل بيانات المستخدم للسياق
        context = self._build_user_context(risk_percentage, shap_values, health_data)
        
        # إذا كان هناك سؤال محدد، حاول استخدام API أولاً
        if user_question and self.use_api:
            try:
                result = self._get_api_response(risk_percentage, shap_values, health_data, user_question, context)
                if result:
                    return result
            except Exception as e:
                print(f"⚠️ API failed: {e}")
        
        # إذا فشل API أو لم يكن متاحاً، استخدم الردود المحلية الذكية
        return self._get_smart_local_response(risk_percentage, shap_values, health_data, user_question, context)
    
    def _build_user_context(self, risk_percentage: float, shap_values: Dict, health_data: Dict) -> Dict:
        """بناء سياق شامل عن المستخدم"""
        
        # ترتيب العوامل المؤثرة
        sorted_factors = sorted(shap_values.items(), key=lambda x: abs(x[1]), reverse=True)
        top_increasing = [f for f, v in sorted_factors if v > 0][:3]
        top_decreasing = [f for f, v in sorted_factors if v < 0][:3]
        
        # ترجمة أسماء العوامل
        factor_names_ar = {
            'age': 'العمر',
            'bmi': 'مؤشر كتلة الجسم',
            'hba1c': 'السكر التراكمي (HbA1c)',
            'glucose': 'سكر الدم الصائم',
            'blood_pressure_systolic': 'الضغط الانقباضي',
            'blood_pressure_diastolic': 'الضغط الانبساطي',
            'cholesterol': 'الكوليسترول الكلي',
            'family_history': 'التاريخ العائلي',
            'smoking': 'التدخين',
            'physical_activity': 'النشاط البدني'
        }
        
        return {
            'risk': risk_percentage,
            'risk_level': 'منخفض' if risk_percentage < 30 else ('متوسط' if risk_percentage < 60 else 'مرتفع'),
            'top_increasing': [factor_names_ar.get(f, f) for f in top_increasing],
            'top_decreasing': [factor_names_ar.get(f, f) for f in top_decreasing],
            'age': health_data.get('age'),
            'bmi': health_data.get('bmi'),
            'hba1c': health_data.get('hba1c'),
            'glucose': health_data.get('glucose'),
            'bp_sys': health_data.get('blood_pressure_systolic'),
            'bp_dias': health_data.get('blood_pressure_diastolic'),
            'cholesterol': health_data.get('cholesterol'),
            'family_history': 'نعم' if health_data.get('family_history') else 'لا',
            'smoking': {0: 'لا يدخن', 1: 'مدخن سابق', 2: 'مدخن حالياً'}.get(health_data.get('smoking', 0)),
            'physical_activity': {0: 'قليل', 1: 'متوسط', 2: 'كثير'}.get(health_data.get('physical_activity', 0))
        }
    
    def _get_api_response(self, risk: float, shap: Dict, data: Dict, question: str, context: Dict) -> Optional[Dict]:
        """محاولة الحصول على رد من Gemini API"""
        try:
            prompt = f"""
            أنت مساعد صحي متخصص باللغة العربية. المستخدم يسأل سؤالاً عن مرض السكري.
            
            **بيانات المستخدم الصحية:**
            - نسبة خطر السكري: {context['risk']:.1f}% (مستوى {context['risk_level']})
            - العمر: {context['age']} سنة
            - مؤشر كتلة الجسم: {context['bmi']}
            - السكر التراكمي: {context['hba1c']}%
            - سكر الدم: {context['glucose']} mg/dL
            - الضغط: {context['bp_sys']}/{context['bp_dias']} mmHg
            - الكوليسترول: {context['cholesterol']} mg/dL
            - التاريخ العائلي: {context['family_history']}
            - التدخين: {context['smoking']}
            - النشاط البدني: {context['physical_activity']}
            
            **سؤال المستخدم:** {question}
            
            قدم إجابة:
            1. بلغة عربية واضحة وسهلة
            2. مخصصة لبيانات المستخدم
            3. قصيرة ومفيدة (لا تزيد عن 150 كلمة)
            4. ابدأ بتحية قصيرة
            
            بعد الإجابة، قدم 3 نقاط مختصرة كنصائح عملية.
            """
            
            response = self.model.generate_content(prompt)
            if response and response.text:
                response_text = response.text
            else:
                raise Exception("Empty response from API")
            
            # استخراج النصائح
            suggestions = self._extract_suggestions(response_text)
            
            return {
                "response": response_text,
                "suggestions": suggestions
            }
        except Exception as e:
            print(f"⚠️ API Error with model {self.model_name}: {e}")
            print(f"🔄 Trying alternative model...")
            # محاولة استخدام نموذج بديل
            return self._try_alternative_model(prompt)

    
    def _get_smart_local_response(self, risk: float, shap: Dict, data: Dict, question: Optional[str], context: Dict) -> Dict:
        """ردود محلية ذكية تفهم سياق السؤال"""
        
        # إذا كان هناك سؤال محدد
        if question:
            return self._answer_specific_question(question, context)
        
        # إذا لم يكن هناك سؤال، قدم نصائح عامة
        return self._general_advice(context)
    
    def _answer_specific_question(self, question: str, context: Dict) -> Dict:
        """فهم السؤال وتقديم إجابة مخصصة"""
        q = question.lower()
        
        # كلمات مفتاحية للتصنيف
        categories = {
            'food': ['طعام', 'أكل', 'غذاء', 'اكل', 'وجبة', 'سكريات', 'نشويات', 'فواكه', 'خضروات', 'حلويات'],
            'exercise': ['رياضة', 'تمرين', 'تمارين', 'مشي', 'جري', 'حركة', 'نشاط', 'لياقة'],
            'symptoms': ['أعراض', 'علامات', 'اعراض', 'علامة', 'شعور', 'تعب', 'عطش', 'تبول', 'جوع'],
            'medication': ['دواء', 'علاج', 'ادوية', 'علاجات', 'انسولين', 'حبوب', 'وصفة'],
            'prevention': ['وقاية', 'حماية', 'تجنب', 'منع', 'احتمي', 'حمي'],
            'risk_factors': ['عامل', 'خطر', 'اسباب', 'أسباب', 'سبب', 'زيادة', 'ارتفاع'],
            'foods_to_eat': ['ماذا آكل', 'ماذا تناول', 'ما هي الأطعمة', 'الأطعمة المناسبة', 'اكل صحي'],
            'foods_to_avoid': ['ما لا آكل', 'تجنب', 'ابتعد', 'ممنوع', 'ضار'],
            'blood_sugar': ['سكر الدم', 'نسبة السكر', 'قياس السكر', 'glucose', 'تحليل سكر'],
            'hba1c': ['سكر تراكمي', 'hba1c', 'التراكمي', 'تحليل تراكمي'],
            'weight': ['وزن', 'سمنة', 'نحافة', 'كتلة الجسم', 'bmi'],
            'pressure': ['ضغط', 'ضغط الدم', 'hypertension', 'ضغط مرتفع'],
            'checkup': ['فحص', 'تحليل', 'طبيب', 'مستشفى', 'مراجعة', 'كشف'],
        }
        
        # تحديد فئة السؤال
        detected_category = None
        for category, keywords in categories.items():
            if any(keyword in q for keyword in keywords):
                detected_category = category
                break
        
        # ردود مخصصة حسب الفئة
        responses = {
            'food': self._get_food_response(context),
            'foods_to_eat': self._get_healthy_foods_response(context),
            'foods_to_avoid': self._get_foods_to_avoid_response(context),
            'exercise': self._get_exercise_response(context),
            'symptoms': self._get_symptoms_response(),
            'medication': self._get_medication_response(),
            'prevention': self._get_prevention_response(context),
            'risk_factors': self._get_risk_factors_response(context),
            'blood_sugar': self._get_blood_sugar_response(context),
            'hba1c': self._get_hba1c_response(context),
            'weight': self._get_weight_response(context),
            'pressure': self._get_pressure_response(context),
            'checkup': self._get_checkup_response(context),
        }
        
        if detected_category and detected_category in responses:
            result = responses[detected_category]
            result["response"] = f"📌 **سؤالك:** \"{question}\"\n\n" + result["response"]
            return result
        
        # إذا لم يتم التعرف على السؤال
        return self._get_fallback_response(question, context)
    
    def _general_advice(self, context: Dict) -> Dict:
        """نصائح عامة مخصصة حسب نسبة الخطر"""
        risk = context['risk']
        
        if risk < 30:
            response = f"""🌟 **مرحباً بك في المساعد الصحي لـ DiabPredict!**

📊 **بناءً على بياناتك:**
- نسبة خطر الإصابة: {risk:.1f}% (مستوى {context['risk_level']})
- عمرك: {context['age']} سنة
- مؤشر كتلة الجسم: {context['bmi']}
- السكر التراكمي: {context['hba1c']}%

✅ **أنت في حالة جيدة!** للمحافظة على صحتك:

1. استمر في نمط حياتك الصحي
2. مارس الرياضة بانتظام
3. حافظ على نظام غذائي متوازن
4. قم بفحوصات دورية كل 6 أشهر

💡 اسألني أي شيء عن الأكل الصحي، التمارين، أو أعراض السكري!"""
            
            suggestions = [
                "مارس الرياضة 30 دقيقة يومياً",
                "تناول الخضروات والفواكه الطازجة",
                "قلل من السكريات والمشروبات الغازية",
                "اشرب 8 أكواب ماء يومياً"
            ]
            
        elif risk < 60:
            response = f"""🩺 **مرحباً بك في المساعد الصحي لـ DiabPredict!**

📊 **بناءً على بياناتك:**
- نسبة خطر الإصابة: {risk:.1f}% (مستوى {context['risk_level']})
- مؤشر كتلة الجسم: {context['bmi']}
- السكر التراكمي: {context['hba1c']}%

⚠️ **نسبة الخطر متوسطة.** يمكنك تحسين صحتك بـ:

1. تعديل نظامك الغذائي (تقليل السكريات والنشويات)
2. زيادة النشاط البدني تدريجياً
3. متابعة وزنك ومحاولة إنقاص 5-10% منه
4. استشارة طبيبك لوضع خطة متابعة

💡 اسألني عن العوامل التي تزيد خطر السكري أو كيفية تحسينها!"""
            
            suggestions = [
                "قلل من السكريات والنشويات المكررة",
                "زد من النشاط البدني اليومي",
                "تابع وزنك بانتظام",
                "استشر طبيبك لمتابعة دورية"
            ]
            
        else:
            response = f"""🔴 **تنبيه هام - المساعد الصحي لـ DiabPredict**

📊 **بناءً على بياناتك:**
- نسبة خطر الإصابة: {risk:.1f}% (مستوى {context['risk_level']})
- السكر التراكمي: {context['hba1c']}%
- مؤشر كتلة الجسم: {context['bmi']}%

🚨 **يجب اتخاذ إجراءات فورية:**

1. **راجع طبيب الغدد الصماء فوراً**
2. قم بفحص السكر التراكمي (HbA1c) بشكل عاجل
3. ابدأ خطة غذائية تحت إشراف مختص
4. قم بقياس سكر الدم وضغط الدم بانتظام

💡 اسألني عن أعراض السكري أو كيفية التعامل مع الحالة!"""
            
            suggestions = [
                "راجع طبيب الغدد الصماء فوراً",
                "قم بفحص السكر التراكمي",
                "اتبع خطة غذائية تحت إشراف مختص",
                "راقب سكر وضغط الدم بانتظام"
            ]
        
        return {"response": response, "suggestions": suggestions}
    
    def _get_fallback_response(self, question: str, context: Dict) -> Dict:
        """رد عام عندما لا يفهم النظام السؤال"""
        response = f"""🤔 **عذراً، لم أفهم سؤالك بالكامل.**

سؤالك: "{question}"

💡 **يمكنني مساعدتك في الأسئلة التالية:**
• ما هي الأطعمة المفيدة والضارة للسكري؟
• ما هي التمارين الرياضية المناسبة؟
• ما هي أعراض السكري المبكرة؟
• كيف يمكن الوقاية من السكري؟
• ما هي العوامل التي تزيد خطر السكري؟

📊 **بناءً على حالتك** (نسبة الخطر {context['risk']:.1f}%)، أنصحك بالتركيز على تحسين نمط حياتك ومتابعة حالتك مع الطبيب.

اسألني بطريقة أخرى أو اختر أحد الأسئلة المقترحة أعلاه."""
        
        suggestions = [
            "ما هي الأطعمة المفيدة للسكري؟",
            "ما هي أعراض السكري؟",
            "كيف أحمي نفسي من السكري؟",
            "ما هي التمارين المناسبة لي؟"
        ]
        
        return {"response": response, "suggestions": suggestions}
    
    # ========== دوال الردود المخصصة ==========
    
    def _get_food_response(self, context: Dict) -> Dict:
        response = f"""🍎 **الأطعمة وتأثيرها على السكري**

📊 **حسب حالتك** (نسبة الخطر {context['risk']:.1f}%):

**✅ أطعمة مفيدة (تقلل خطر السكري):**
• الخضروات الورقية (سبانخ، خس، كرنب)
• الحبوب الكاملة (شوفان، قمح كامل، أرز بني)
• البقوليات (عدس، حمص، فول)
• المكسرات غير المملحة (لوز، جوز)
• الأسماك الدهنية (سلمون، تونة، سردين)
• الفواكه (توت، تفاح، إجاص) - باعتدال

**❌ أطعمة ضارة (تزيد خطر السكري):**
• السكريات والمشروبات الغازية
• الخبز الأبيض والمعجنات
• الأطعمة المصنعة والوجبات السريعة
• الدهون المشبعة والمتحولة

📌 **نصيحة:** ابدأ بتقليل السكريات تدريجياً واستبدالها ببدائل صحية."""
        
        suggestions = [
            "تناول الخضروات الورقية يومياً",
            "استبدل الخبز الأبيض بالأسمر",
            "قلل من المشروبات الغازية والعصائر المحلاة",
            "تناول وجبات صغيرة متعددة بدلاً من وجبات كبيرة"
        ]
        return {"response": response, "suggestions": suggestions}
    
    
    def _try_alternative_model(self, prompt):
        """محاولة استخدام نموذج بديل إذا فشل النموذج الحالي"""
        alternative_models = ['gemini-pro', 'gemini-1.0-pro']
        
        for model_name in alternative_models:
            try:
                alt_model = genai.GenerativeModel(model_name)
                response = alt_model.generate_content(prompt)
                if response and response.text:
                    print(f"✅ Alternative model {model_name} worked!")
                    self.model = alt_model
                    self.model_name = model_name
                    return response.text
            except:
                continue
        
        return None

    def _get_healthy_foods_response(self, context: Dict) -> Dict:
        response = f"""🥗 **أفضل الأطعمة للوقاية من السكري**

📊 **موصى بها لحالتك** (نسبة الخطر {context['risk']:.1f}%):

**المجموعة الأولى (تناول يومياً):**
- الخضروات غير النشوية (بروكلي، خيار، فلفل، كوسا)
- الخضروات الورقية (سبانخ، خس، ملفوف)
- الثوم والبصل (يساعدان في تحسين حساسية الأنسولين)

**المجموعة الثانية (تناول بانتظام):**
- الحبوب الكاملة (شوفان، كينوا، برغل)
- البقوليات (عدس، حمص، فاصوليا)
- المكسرات والبذور (لوز، جوز، بذور الشيا)

**المجموعة الثالثة (باعتدال):**
- الفواكه (تفاح، توت، كرز، إجاص)
- اللحوم البيضاء (دجاج، ديك رومي)
- الأسماك الدهنية (سلمون، تونة، ماكريل)

💡 **نصائح عملية:**
• ابدأ وجبتك بالخضروات
• اشرب الماء قبل الوجبات
• تناول الطعام ببطء"""
        
        suggestions = [
            "أضف الخضروات لكل وجبة",
            "تناول الشوفان على الإفطار",
            "استخدم زيت الزيتون بدلاً من الدهون",
            "تناول حفنة مكسرات يومياً"
        ]
        return {"response": response, "suggestions": suggestions}
    
    def _get_foods_to_avoid_response(self, context: Dict) -> Dict:
        response = f"""🚫 **أطعمة يجب تجنبها أو تقليلها**

📊 **لحالتك** (نسبة الخطر {context['risk']:.1f}%):

**❌ تجنب تماماً:**
• المشروبات الغازية والعصائر المحلاة
• الحلويات والسكريات المضافة
• الوجبات السريعة
• الأطعمة المقلية

**⚠️ قلل من:**
• الخبز الأبيض والمعجنات
• الأرز الأبيض والمعكرونة البيضاء
• اللحوم المصنعة (نقانق، لانشون)
• رقائق البطاطس والوجبات الخفيفة المالحة

**🔄 بدائل صحية:**
• استبدل الخبز الأبيض بالخبز الأسمر
• استبدل الأرز الأبيض بالأرز البني أو البرغل
• استبدل السكر الأبيض بالتمر أو العسل الطبيعي (بكميات قليلة)
• استبدل العصائر المحلاة بالماء أو الشاي الأخضر"""

        suggestions = [
            "تجنب المشروبات الغازية تماماً",
            "قلل من الحلويات إلى مرة أسبوعياً",
            "اختر الخبز الأسمر بدلاً من الأبيض",
            "تجنب الوجبات السريعة"
        ]
        return {"response": response, "suggestions": suggestions}
    
    def _get_exercise_response(self, context: Dict) -> Dict:
        response = f"""🏃 **التمارين الرياضية المناسبة**

📊 **حسب حالتك** (نسبة الخطر {context['risk']:.1f}%):

**🏆 أفضل التمارين للسكري:**
• المشي السريع (30-45 دقيقة يومياً)
• السباحة (ممتازة للمفاصل والقلب)
• ركوب الدراجة (هوائية أو ثابتة)
• تمارين المقاومة (أوزان خفيفة - مرتين أسبوعياً)
• اليوغا (تحسن المرونة وتقلل التوتر)

**📋 جدول مقترح أسبوعياً:**
• الإثنين: مشي 30 دقيقة
• الثلاثاء: تمارين مقاومة 20 دقيقة
• الأربعاء: سباحة أو ركوب دراجة
• الخميس: مشي 30 دقيقة
• الجمعة: يوغا أو تمدد
• السبت: مشي 45 دقيقة
• الأحد: راحة أو مشي خفيف

💡 **نصائح:**
• ابدأ ببطء وزد المدة تدريجياً
• استشر طبيبك قبل بدء برنامج رياضي جديد
• احمل معك حلوى سريعة في حال انخفاض السكر"""

        suggestions = [
            "امشِ 30 دقيقة يومياً على الأقل",
            "استخدم الدرج بدلاً من المصعد",
            "جرب السباحة مرتين أسبوعياً",
            "مارس تمارين الإطالة صباحاً"
        ]
        return {"response": response, "suggestions": suggestions}
    
    def _get_symptoms_response(self) -> Dict:
        response = """⚠️ **الأعراض المبكرة لمرض السكري**

**الأعراض الشائعة:**
• العطش الشديد وكثرة التبول
• الجوع المستمر رغم تناول الطعام
• فقدان الوزن غير المبرر
• التعب والإرهاق
• عدم وضوح الرؤية
• بطء التئام الجروح
• وخز أو تنميل في اليدين والقدمين
• التهابات متكررة (لثة، جلد، مسالك بولية)

**🚨 متى يجب استشارة الطبيب فوراً؟**
• إذا ظهرت لديك 3 أعراض أو أكثر
• إذا كان هناك تاريخ عائلي للسكري
• إذا كانت لديك عوامل خطر (سمنة، ضغط مرتفع)

📌 **تذكر:** التشخيص المبكر يمكن أن يمنع المضاعفات!"""

        suggestions = [
            "راقب أي أعراض غير طبيعية",
            "قم بفحص السكر إذا ظهرت أعراض",
            "استشر طبيبك للتقييم",
            "لا تتجاهل الأعراض المبكرة"
        ]
        return {"response": response, "suggestions": suggestions}
    
    def _get_medication_response(self) -> Dict:
        response = """💊 **تنبيه هام حول أدوية السكري**

🚨 **أنصحك باستشارة طبيبك قبل تناول أي دواء.**

**أنواع أدوية السكري الشائعة:**
1. **الميتفورمين** - عادة ما يكون الخط الأول للعلاج
2. **السلفونيل يوريا** - تحفز البنكرياس لإفراز الأنسولين
3. **مثبطات DPP-4** - تساعد في خفض السكر بعد الأكل
4. **مثبطات SGLT2** - تساعد الكلى في إخراج السكر
5. **الأنسولين** - للحالات المتقدمة

**⚠️ تذكر:**
• لا تتوقف عن أي دواء دون استشارة الطبيب
• تناول أدويتك في مواعيدها المحددة
• أخبر طبيبك عن أي آثار جانبية
• الأدوية وحدها لا تكفي - تحتاج إلى نظام غذائي ورياضة"""

        suggestions = [
            "استشر طبيبك قبل تناول أي دواء",
            "لا تتوقف عن العلاج دون استشارة",
            "التزم بمواعيد الأدوية",
            "تابع حالتك بانتظام مع طبيبك"
        ]
        return {"response": response, "suggestions": suggestions}
    
    def _get_prevention_response(self, context: Dict) -> Dict:
        response = f"""🛡️ **كيف تحمي نفسك من السكري**

📊 **حسب حالتك** (نسبة الخطر {context['risk']:.1f}%):

**7 خطوات للوقاية:**
1. **حافظ على وزن صحي** - إنقاص 5-10% من وزنك يقلل الخطر بنسبة 58%
2. **مارس الرياضة بانتظام** - 30 دقيقة يومياً، 5 أيام أسبوعياً
3. **تناول طعاماً صحياً** - الكثير من الخضروات والألياف، قليل من السكريات
4. **تجنب المشروبات السكرية** - استبدلها بالماء أو الشاي غير المحلى
5. **تحكم في التوتر** - التوتر يرفع سكر الدم
6. **نَمْ جيداً** - 7-8 ساعات يومياً
7. **أجرِ فحوصات دورية** - كل 6 أشهر إذا كان لديك عوامل خطر

✅ **ما يمكنك البدء به اليوم:**
• استبدل المشروبات الغازية بالماء
• امشِ 15 دقيقة بعد كل وجبة
• أضف الخضروات إلى كل وجبة"""

        suggestions = [
            "ابدأ بالمشي 30 دقيقة يومياً",
            "قلل من السكريات تدريجياً",
            "اشرب 8 أكواب ماء يومياً",
            "أجرِ فحص سكر كل 6 أشهر"
        ]
        return {"response": response, "suggestions": suggestions}
    
    def _get_risk_factors_response(self, context: Dict) -> Dict:
        response = f"""⚠️ **عوامل خطر الإصابة بالسكري**

📊 **في حالتك:**
نسبة الخطر الحالية: {context['risk']:.1f}%

**عوامل تزيد خطر السكري:**
1. **العمر** (فوق 45 سنة) - عمرك {context['age']} سنة
2. **الوزن الزائد** (BMI > 25) - BMI لديك {context['bmi']}
3. **التاريخ العائلي** - {context['family_history']}
4. **قلة النشاط البدني** - مستوى نشاطك: {context['physical_activity']}
5. **النظام الغذائي غير الصحي**
6. **ارتفاع ضغط الدم** ({context['bp_sys']}/{context['bp_dias']} mmHg)
7. **ارتفاع الكوليسترول** ({context['cholesterol']} mg/dL)
8. **التدخين** - {context['smoking']}

**عوامل تقلل الخطر (موجودة لديك):**
{chr(10).join([f'   • {f}' for f in context['top_decreasing']]) if context['top_decreasing'] else '   • تابع تحسين نمط حياتك'}

💡 **يمكنك التحكم في معظم هذه العوامل!**"""

        suggestions = [
            "حسن نظامك الغذائي تدريجياً",
            "زد من نشاطك البدني",
            "تابع وزنك وحاول إنقاصه",
            "أقلع عن التدخين إذا كنت مدخناً"
        ]
        return {"response": response, "suggestions": suggestions}
    
    def _get_blood_sugar_response(self, context: Dict) -> Dict:
        response = f"""🩸 **مستويات سكر الدم الطبيعية**

📊 **حالتك:** سكر الدم {context['glucose']} mg/dL

**المستويات الطبيعية:**
• **صائم (8 ساعات بدون أكل):** 70-100 mg/dL (طبيعي)
• **قبل الأكل:** 80-130 mg/dL
• **بعد الأكل بساعتين:** أقل من 180 mg/dL
• **مستوى السكري:** 126 mg/dL أو أكثر (صائم)

**📊 تحليل قياسك:**
{self._get_glucose_analysis(context['glucose'])}

**نصائح للحفاظ على سكر دم صحي:**
• تناول وجبات صغيرة متعددة
• تجنب السكريات البسيطة
• امشِ بعد الوجبات مباشرة
• حافظ على ترطيب جسمك بالماء

**⚠️ متى تقلق:**
• إذا تجاوز 200 mg/dL بعد الأكل
• إذا كان أقل من 70 mg/dL (انخفاض خطير)
• ظهور أعراض مثل الدوخة أو التعرق"""

        suggestions = [
            "راقب سكر الدم بانتظام",
            "تناول وجبات صغيرة متعددة",
            "امشِ 15 دقيقة بعد الوجبات",
            "اشرب الماء باستمرار"
        ]
        return {"response": response, "suggestions": suggestions}
    
    def _get_glucose_analysis(self, glucose: float) -> str:
        if glucose < 70:
            return "⚠️ **قليل (نقص سكر الدم)** - تناول وجبة خفيفة فوراً"
        elif glucose <= 100:
            return "✅ **ممتاز** - ضمن المستوى الطبيعي"
        elif glucose <= 125:
            return "⚠️ **مرتفع نسبياً (مقدمات السكري)** - يجب مراجعة نظامك الغذائي"
        else:
            return "🔴 **مرتفع** - استشر طبيبك فوراً"
    
    def _get_hba1c_response(self, context: Dict) -> Dict:
        response = f"""📊 **تحليل السكر التراكمي (HbA1c)**

**ما هو HbA1c؟**
يقيس متوسط سكر الدم خلال 2-3 أشهر الماضية.

**المستويات ومعناها:**
• أقل من 5.7%: طبيعي ✅
• 5.7% - 6.4%: مقدمات السكري ⚠️
• 6.5% أو أكثر: سكري 🔴

📊 **النتيجة لديك:** {context['hba1c']}%

{self._get_hba1c_analysis(context['hba1c'])}

**نصائح لتحسين HbA1c:**
• التزم بنظام غذائي صحي
• مارس الرياضة بانتظام
• تناول أدويتك إذا كان لديك
• تابع مع طبيبك بانتظام"""

        suggestions = [
            "حسن نظامك الغذائي تدريجياً",
            "مارس الرياضة 30 دقيقة يومياً",
            "تابع مع طبيبك كل 3 أشهر",
            "راقب سكر الدم بانتظام"
        ]
        return {"response": response, "suggestions": suggestions}
    
    def _get_hba1c_analysis(self, hba1c: float) -> str:
        if hba1c < 5.7:
            return "✅ **ممتاز** - أنت ضمن المستوى الطبيعي. استمر في نمط حياتك الصحي."
        elif hba1c <= 6.4:
            return "⚠️ **تحذير** - أنت في مرحلة مقدمات السكري. يمكنك عكس ذلك بتغيير نمط حياتك!"
        else:
            return "🔴 **تنبيه** - هذا المستوى يشير إلى وجود سكري. يرجى استشارة طبيبك فوراً."
    
    def _get_weight_response(self, context: Dict) -> Dict:
        response = f"""⚖️ **الوزن وصحة السكري**

📊 **مؤشر كتلة الجسم (BMI) لديك:** {context['bmi']}

**تصنيف BMI:**
• أقل من 18.5: نقص وزن
• 18.5 - 24.9: وزن طبيعي ✅
• 25 - 29.9: زيادة وزن ⚠️
• 30 فأكثر: سمنة 🔴

**تأثير الوزن على السكري:**
فقدان 5-10% من وزنك يمكن أن يقلل خطر السكري بنسبة 58%!

💡 **نصائح للتحكم بالوزن:**
• تناول وجبات صغيرة متعددة
• ابدأ وجبتك بالخضروات
• اشرب كوب ماء قبل الوجبات
• امشِ 30 دقيقة يومياً
• تجنب الأكل العاطفي"""

        suggestions = [
            "سجل وزنك أسبوعياً",
            "تناول الخضروات أولاً في الوجبة",
            "اشرب الماء قبل الأكل",
            "امشِ بانتظام"
        ]
        return {"response": response, "suggestions": suggestions}
    
    def _get_pressure_response(self, context: Dict) -> Dict:
        response = f"""🩺 **الضغط وصحة السكري**

📊 **الضغط لديك:** {context['bp_sys']}/{context['bp_dias']} mmHg

**المستويات الطبيعية:**
• مثالي: أقل من 120/80 mmHg ✅
• مرتفع نسبياً: 120-129/80-84 ⚠️
• ارتفاع: 130-139/85-89 ⚠️
• ارتفاع شديد: 140/90 فأكثر 🔴

**العلاقة بين الضغط والسكري:**
ارتفاع الضغط يزيد خطر السكري، والعكس صحيح.

💡 **لتحسين ضغط دمك:**
• قلل من الملح في الطعام
• مارس الرياضة بانتظام
• حافظ على وزن صحي
• قلل من التوتر
• تجنب الكحول والتدخين"""

        suggestions = [
            "قلل من الملح في طعامك",
            "مارس رياضة المشي يومياً",
            "تجنب الأطعمة المصنعة",
            "تعلم تقنيات الاسترخاء"
        ]
        return {"response": response, "suggestions": suggestions}
    
    def _get_checkup_response(self, context: Dict) -> Dict:
        response = f"""🩺 **الفحوصات الدورية الموصى بها**

📊 **حسب حالتك** (نسبة الخطر {context['risk']:.1f}%):

**الفحوصات الأساسية:**
• سكر الدم الصائم - كل 3-6 أشهر
• السكر التراكمي (HbA1c) - كل 3-6 أشهر
• ضغط الدم - كل زيارة للطبيب
• الكوليسترول والدهون - سنوياً
• وظائف الكلى - سنوياً

**فحوصات إضافية حسب الحاجة:**
• تحليل البول (للزلال)
• فحص العيون (شبكية العين)
• فحص القدمين (الأعصاب والدورة الدموية)

💡 **تذكر:** الكشف المبكر يمكن أن يمنع المضاعفات!"""

        suggestions = [
            "حدد موعداً لفحص السكر",
            "احتفظ بسجل للفحوصات",
            "ناقش نتائجك مع طبيبك",
            "لا تتأخر عن الفحوصات الدورية"
        ]
        return {"response": response, "suggestions": suggestions}
    
    def _extract_suggestions(self, text: str) -> List[str]:
        """استخراج النقاط المرقمة من النص"""
        pattern = r'(?:^|\n)[\s]*[\d\-\*•]+[\s]*\.?[\s]*(.*?)(?=[\n][\s]*[\d\-\*•]+|$)'
        matches = re.findall(pattern, text, re.DOTALL)
        
        suggestions = [m.strip() for m in matches if len(m.strip()) > 10][:4]
        
        if not suggestions:
            sentences = re.split(r'[.!?]\s+', text)
            suggestions = [s.strip() for s in sentences if len(s.strip()) > 15 and len(s.strip()) < 100][:4]
        
        return suggestions if suggestions else ["حافظ على نمط حياة صحي", "مارس الرياضة بانتظام", "تابع فحوصاتك دورياً", "استشر طبيبك لمتابعة حالتك"]


# إنشاء نسخة واحدة من الخدمة
gemini_service = GeminiService()