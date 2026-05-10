"""
صفحة المساعد الذكي - DiabPredict
نسخة احترافية متزامنة مع منطق مبرمج + Gemini API
"""

import streamlit as st
from datetime import datetime
import os
import random
from dotenv import load_dotenv
from utils.theme import get_colors, get_theme
from components.gauge import render_gauge
from utils.storage import save_user_data
# تحميل مفتاح API
load_dotenv()
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

# محاولة استيراد Gemini API (المكتبة القديمة)
GEMINI_AVAILABLE = False
GEMINI_MODEL = None

try:
    import google.generativeai as genai
    if GEMINI_API_KEY:
        genai.configure(api_key=GEMINI_API_KEY)
        GEMINI_AVAILABLE = True
        print("✅ Gemini API initialized successfully")
except ImportError:
    print("⚠️ google-generativeai package not installed. Run: pip install google-generativeai")
except Exception as e:
    print(f"⚠️ Error initializing Gemini API: {e}")
        
        # استدعاء الدالة لرؤية النماذج (اختياري)
        # list_available_models()
        
except ImportError:
    print("⚠️ google-generativeai package not installed. Run: pip install google-generativeai")
except Exception as e:
    print(f"⚠️ Error initializing Gemini API: {e}")



def analyze_user_data(risk_percentage: float, features: dict, importance: dict) -> dict:
    """تحليل بيانات المستخدم وإرجاع رؤى واضحة"""
    
    if not features or risk_percentage is None:
        return None
    
    analysis = {
        "risk_level": "مرتفع" if risk_percentage > 70 else "متوسط" if risk_percentage > 30 else "منخفض",
        "risk_color": "#ef4444" if risk_percentage > 70 else "#f59e0b" if risk_percentage > 30 else "#10b981",
        "main_risk_factors": [],
        "critical_readings": [],
        "normal_readings": [],
        "improvement_rate": 0
    }
    
    # تحليل المؤشرات الحيوية
    glucose = features.get('Glucose', 0)
    bmi = features.get('BMI', 0)
    age = features.get('Age', 0)
    bp = features.get('BloodPressure', 0)
    
    # تحديد القراءات الحرجة
    if glucose > 140:
        analysis["critical_readings"].append(f"🩸 السكر: {glucose} mg/dL (الطبيعي أقل من 100)")
        analysis["main_risk_factors"].append({"factor": "ارتفاع السكر", "value": glucose, "normal": "<100"})
    elif glucose > 100:
        analysis["critical_readings"].append(f"⚠️ السكر: {glucose} mg/dL (مرتفع قليلاً، الطبيعي أقل من 100)")
    else:
        analysis["normal_readings"].append(f"✅ السكر: {glucose} mg/dL (طبيعي)")
    
    if bmi > 30:
        analysis["critical_readings"].append(f"⚖️ BMI: {bmi} (الطبيعي 18.5-24.9)")
        analysis["main_risk_factors"].append({"factor": "زيادة الوزن", "value": bmi, "normal": "18.5-24.9"})
    elif bmi > 25:
        analysis["critical_readings"].append(f"⚠️ BMI: {bmi} (زيادة وزن، الطبيعي أقل من 25)")
    else:
        analysis["normal_readings"].append(f"✅ BMI: {bmi} (طبيعي)")
    
    if bp > 140:
        analysis["critical_readings"].append(f"❤️ ضغط الدم: {bp} mmHg (مرتفع، الطبيعي أقل من 120)")
        analysis["main_risk_factors"].append({"factor": "ارتفاع الضغط", "value": bp, "normal": "<120"})
    elif bp > 120:
        analysis["critical_readings"].append(f"⚠️ ضغط الدم: {bp} mmHg (مرتفع قليلاً، الطبيعي أقل من 120)")
    else:
        analysis["normal_readings"].append(f"✅ ضغط الدم: {bp} mmHg (طبيعي)")
    
    if age > 60:
        analysis["main_risk_factors"].append({"factor": "العمر المتقدم", "value": age, "normal": "<60"})
    elif age > 45:
        analysis["main_risk_factors"].append({"factor": "العمر", "value": age, "normal": "<45"})
    
    # تحليل SHAP values إذا وجدت
    if importance:
        for factor, value in importance.items():
            if value > 0.1:
                analysis["main_risk_factors"].append({"factor": factor, "impact": value})
    
    # حساب نسبة التحسن
    if len(st.session_state.get('predictions_history', [])) > 1:
        prev_risk = st.session_state.predictions_history[-2]['risk']
        analysis["improvement_rate"] = round(prev_risk - risk_percentage, 1)
    
    return analysis


def get_fast_response(question_lower: str, user_data: dict) -> str:
    """ردود سريعة بمنطق مبرمج"""
    
    risk = user_data.get("risk_percentage", 0)
    analysis = user_data.get("analysis", {})
    features = user_data.get("features", {})
    
    glucose = features.get('Glucose', 0)
    bmi = features.get('BMI', 0)
    age = features.get('Age', 0)
    
    # ============================================
    # سؤال نسبة الخطر
    # ============================================
    if any(word in question_lower for word in ['نسبة', 'خطر', 'نتيجة', 'توقع', 'تقييم', 'تحليل']):
        if risk > 70:
            return f"""🔴 **نسبة الخطر لديك {risk:.0f}% (مرتفعة)**

📊 **تحليل سريع لبياناتك:**
{chr(10).join([f'{c}' for c in analysis.get("critical_readings", [])])}

⚠️ **إجراءات فورية مطلوبة:**
1. 🏥 راجع طبيب الغدد الصماء خلال أيام
2. 🥗 ابدأ بتعديل نظامك الغذائي اليوم
3. 📊 قس مستوى السكر يومياً
4. 💧 اشرب 3 لتر ماء يومياً

💡 **هل تريد خطة تفصيلية مخصصة لحالتك؟** (اطرح سؤالاً مفصلاً)"""
        
        elif risk > 30:
            return f"""⚠️ **نسبة الخطر لديك {risk:.0f}% (متوسطة)**

📊 **عوامل الخطر الرئيسية:**
{chr(10).join([f'• {f["factor"]}: {f["value"]} (الطبيعي {f["normal"]})' for f in analysis.get("main_risk_factors", [])])}

💡 **نصائح للتحسين:**
• 🥗 قلل الكربوهيدرات والسكريات
• 🏃 امشِ 30 دقيقة يومياً
• 😴 نم 7-8 ساعات يومياً

📌 **الهدف:** الوصول إلى أقل من 30% خلال 3 أشهر
🔍 **هل تريد تفاصيل أكثر عن أي عامل؟**"""
        
        else:
            return f"""✅ **نسبة الخطر لديك {risk:.0f}% (منخفضة)**

📊 **مؤشراتك الطبيعية:**
{chr(10).join([f'{n}' for n in analysis.get("normal_readings", [])])}

🎉 **أحسنت! للحفاظ على هذه النتيجة:**
• استمر في نظامك الغذائي الحالي
• حافظ على نشاطك البدني
• تابع فحوصاتك الدورية كل 6-12 شهراً

🌟 **فخور بك! استمر في العناية بصحتك**"""

    # ============================================
    # سؤال مستوى السكر
    # ============================================
    if any(word in question_lower for word in ['سكر', 'glucose', 'السكر', 'نسبة السكر']):
        if glucose > 140:
            return f"""🔴 **نسبة السكر لديك {glucose} mg/dL - مرتفعة وخطيرة!**

📊 **المقارنة مع المعدلات الطبيعية:**
| المستوى | القيمة |
|---------|--------|
| مستواك الحالي | {glucose} |
| المعدل الطبيعي | أقل من 100 |
| مرتفع قليلاً | 100-125 |
| مرتفع (سكري) | أكثر من 126 |

🚨 **إجراءات عاجلة:**
1. 🚶 امشِ 20-30 دقيقة فوراً
2. 💧 اشرب كوب ماء كل ساعة
3. 🥗 وجبتك القادمة: بروتين + خضار فقط
4. 📊 قس السكر بعد ساعتين

⚠️ **إذا تكرر هذا الارتفاع، استشر طبيبك فوراً!**"""
        
        elif glucose > 100:
            return f"""⚠️ **نسبة السكر لديك {glucose} mg/dL - أعلى من الطبيعي**

📊 **المقارنة:**
• مستواك: {glucose}
• المعدل الطبيعي: أقل من 100
• الفرق: +{glucose - 100}

💡 **خطة تحسين لمدة أسبوعين:**
• 🥗 قلل الكربوهيدرات إلى النصف
• 🏃 زد المشي إلى 30 دقيقة يومياً
• 🍵 استبدل المشروبات السكرية بالشاي الأخضر
• 😴 نم 7-8 ساعات يومياً

🎯 **هدفك:** الوصول إلى أقل من 100 خلال أسبوعين"""
        
        else:
            return f"""✅ **نسبة السكر لديك {glucose} mg/dL - ممتازة!**

📊 **أنت ضمن المعدل الطبيعي (أقل من 100)**

💪 **للحفاظ على هذا المستوى:**
• استمر في نظامك الغذائي المتوازن
• حافظ على نشاطك البدني
• تابع قياساتك دورياً

🎉 **أحسنت! هذه نتيجة رائعة**"""

    # ============================================
    # سؤال الوزن وBMI
    # ============================================
    if any(word in question_lower for word in ['وزن', 'bmi', 'كتلة', 'سمنة']):
        if bmi > 30:
            return f"""🔴 **مؤشر كتلة جسمك {bmi} - سمنة مفرطة**

📊 **التصنيف:**
| النطاق | التصنيف |
|--------|---------|
| أقل من 18.5 | نحافة |
| 18.5 - 24.9 | وزن طبيعي |
| 25 - 29.9 | زيادة وزن |
| 30 فأكثر | **سمنة (أنت هنا)** |

📉 **خطة إنقاص الوزن:**
• الهدف: خسارة 5-10% من وزنك الحالي
• المدة: 3-6 أشهر
• الطريقة: تقليل 500 سعرة يومياً + رياضة

💪 **ابدأ اليوم:** مشي 30 دقيقة + استبدال وجبة واحدة بصحية"""
        
        elif bmi > 25:
            return f"""⚠️ **مؤشر كتلة جسمك {bmi} - زيادة وزن**

📊 **الوزن المثالي لك:**
• وزنك الحالي: BMI {bmi}
• الوزن المثالي: BMI أقل من 25
• الفرق: تحتاج لخسارة حوالي {round((bmi - 24) * 3, 0)} كجم

💡 **خطة بسيطة:**
• 🥗 قلل 300 سعرة يومياً
• 🏃 امشِ 30 دقيقة يومياً
• 📊 سجل وزنك أسبوعياً

🎯 **هدفك:** الوصول إلى BMI أقل من 25 خلال 3 أشهر"""
        
        else:
            return f"""✅ **مؤشر كتلة جسمك {bmi} - وزن مثالي!**

📊 **أنت ضمن النطاق الصحي (18.5 - 24.9)**

💪 **للحفاظ على وزنك:**
• استمر في نظامك الغذائي المتوازن
• حافظ على نشاطك البدني
• زن نفسك أسبوعياً للمتابعة

🎉 **رائع! هذا يساهم بشكل كبير في صحتك**"""

    return None

def get_gemini_response(question: str, user_data: dict) -> str:
    """ردود ذكية باستخدام Gemini API"""
    
    if not GEMINI_AVAILABLE or not GEMINI_API_KEY:
        return None
    
    try:
        model = genai.GenerativeModel('gemini-2.5-flash')
        
        risk = user_data.get('risk_percentage', 0)
        features = user_data.get('features', {})
        analysis = user_data.get('analysis', {})
        
        glucose = features.get('Glucose', 'غير معروف')
        bmi = features.get('BMI', 'غير معروف')
        age = features.get('Age', 'غير معروف')
        bp = features.get('BloodPressure', 'غير معروف')
        
        critical_readings = '\n'.join(analysis.get('critical_readings', [])) if analysis else 'لا توجد قراءات حرجة'
        
        prompt = f"""أنت مساعد طبي متخصص في مرض السكري والتغذية. أجب بصراحة واحترافية ودقة.

بيانات المستخدم الحقيقية:
- نسبة الخطر الإجمالية: {risk}%
- مستوى السكر: {glucose} mg/dL
- مؤشر كتلة الجسم (BMI): {bmi}
- العمر: {age} سنة
- ضغط الدم: {bp} mmHg

القراءات الحرجة في تحليل المستخدم:
{critical_readings}

سؤال المستخدم: {question}

تعليمات صارمة للإجابة:
1. اربط إجابتك مباشرة ببيانات المستخدم الفعلية المذكورة أعلاه
2. كن صريحاً وواقعياً - لا تجمّل الحقائق
3. إذا كانت البيانات تشير إلى خطر، أخبره بصراحة
4. قدم نصائح عملية وقابلة للتنفيذ
5. استخدم أرقاماً واضحة ومقارنات مع المعدلات الطبيعية
6. أضف تحذيراً واضحاً: "هذا تحليل آلي وليس بديلاً عن استشارة الطبيب"
7. اجب باللغة العربية الفصحى الواضحة

الإجابة:"""

        response = model.generate_content(prompt)
        return response.text
        
    except Exception as e:
        return f"⚠️ عذراً، حدث خطأ في الاتصال بالمساعد الذكي.\n\nالخطأ: {str(e)}"
    

def show_toast(message: str):
    """عرض إشعار منبثق"""
    st.toast(message, icon="✅")

def render_header_glass(page_title: str = "🤖 المساعد الذكي"):
    """ترويسة عصرية بتأثير الزجاج"""
    colors = get_colors()
    user_name = st.session_state.get('user_name', 'زائر')
    last_risk = st.session_state.get('last_risk')
    
    # تنسيق نسبة الخطر
    if last_risk is not None:
        if last_risk < 1:
            risk_display = f"{last_risk:.2f}%"
        elif last_risk < 10:
            risk_display = f"{last_risk:.1f}%"
        else:
            risk_display = f"{last_risk:.0f}%"
    else:
        risk_display = "—"
    
    st.markdown(f"""
<div style="
        background: linear-gradient(135deg, #EFF6FF, #93C5FD);
        backdrop-filter: blur(12px);
        border-bottom: 1px solid {colors['outline_variant']};
        border-radius: 20px;
        padding: 15px 25px;
        margin-bottom: 30px;
        position: sticky;
        top: 0;
        z-index: 100;
        direction: rtl;
        box-shadow: 0 2px 10px rgba(0,0,0,0.05);
    ">
        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap;">
            <div style="display: flex; align-items: center; gap: 12px;">
                <div style="
                    width: 45px;
                    height: 45px;
                    background: linear-gradient(135deg, {colors['primary']}, {colors['secondary']});
                    border-radius: 12px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                ">
                    <span style="font-size: 24px;">🩺</span>
                </div>
                <div>
                    <h2 style="margin: 0; font-size: 20px; background: linear-gradient(135deg, {colors['primary']}, {colors['secondary']}); -webkit-background-clip: text; -webkit-text-fill-color: transparent;">
                       DiabPredict
                    </h2>
                    <p style="margin: 0; font-size: 11px; color: {colors['outline']};">{page_title}</p>
                </div>
            </div>
            <div style="display: flex; align-items: center; gap: 12px;">
                <div style="
                    background: {colors['surface_container']};
                    border-radius: 20px;
                    padding: 5px 12px;
                    font-size: 13px;
                ">
                    📊 {risk_display}
                </div>
                <div style="
                    width: 32px;
                    height: 32px;
                    background: {colors['surface_container']};
                    border-radius: 50%;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                ">
                    <span style="font-size: 16px;">👤</span>
                </div>
            </div>
        </div>
    </div>
    """, unsafe_allow_html=True)


def show():
    render_header_glass(" 🤖 المساعد الذكي")
    """عرض صفحة المساعد الذكي"""
    
    colors = get_colors()
    
    # ============================================
    # التحقق من وجود تنبؤ مسبق
    # ============================================
    has_prediction = st.session_state.get('last_risk') is not None and st.session_state.get('last_risk') > 0
    
    if not has_prediction:
        st.markdown(f"""
        <div style="text-align: center; padding: 60px 20px;">
            <div style="font-size: 80px; margin-bottom: 20px;">🔮</div>
            <h2 style="color: {colors['primary']};">لم تقم بإجراء أي تنبؤ بعد!</h2>
            <p style="color: {colors['outline']}; margin: 20px 0;">
                للحصول على إجابات دقيقة ومخصصة 100% لحالتك، يرجى إجراء تنبؤ صحياً أولاً.
            </p>
            <div style="margin-top: 30px;">
        """, unsafe_allow_html=True)
        
        col1, col2, col3 = st.columns([1, 2, 1])
        with col2:
            if st.button("🔮 اذهب إلى صفحة التنبؤ", width='stretch', type="primary"):
                st.session_state.current_page = "predict"
                save_user_data()
                st.rerun()
        
        st.markdown("</div></div>", unsafe_allow_html=True)
        return
    
    # ============================================
    # جلب بيانات المستخدم
    # ============================================
    user_data = {
        "risk_percentage": st.session_state.get('last_risk', 0),
        "features": st.session_state.get('last_features', {}),
        "importance": st.session_state.get('last_importance', {}),
        "analysis": analyze_user_data(
            st.session_state.get('last_risk', 0),
            st.session_state.get('last_features', {}),
            st.session_state.get('last_importance', {})
        )
    }
    
    # ============================================
    # تخصيص المستخدم مع زر تأكيد
    # ============================================
    if 'user_name' not in st.session_state:
        st.session_state.user_name = ""

    if not st.session_state.user_name:
        col1, col2, col3 = st.columns([1, 2, 1])
        with col2:
            st.markdown(f"""
            <div style="text-align: center; padding: 40px;">
                <div style="font-size: 60px;">👋</div>
                <h2>مرحباً بك في المساعد الذكي!</h2>
                <p>ما اسمك لأتمكن من مخاطبتك بشكل شخصي؟</p>
            </div>
            """, unsafe_allow_html=True)
            
            # صف يحتوي على حقل الإدخال والزر
            col_name, col_btn = st.columns([3, 1])
            
            with col_name:
                name_input = st.text_input(
                    "اسمك", 
                    placeholder="اكتب اسمك هنا...", 
                    label_visibility="collapsed",
                    key="user_name_input"
                )
            
            with col_btn:
                if st.button("✅ تأكيد", width='stretch', key="confirm_name_btn"):
                    if name_input and name_input.strip():
                        st.session_state.user_name = name_input.strip()
                        show_toast(f"مرحباً {st.session_state.user_name}!")
                        save_user_data()
                        st.rerun()
                    else:
                        st.warning("⚠️ الرجاء إدخال اسمك أولاً")
            
            # إمكانية الضغط على Enter
            if name_input and not st.session_state.user_name:
                if st.session_state.get('name_enter_pressed', False):
                    st.session_state.user_name = name_input.strip()
                    show_toast(f"مرحباً {st.session_state.user_name}!")
                    save_user_data()
                    st.rerun()
        
        return
    
    # ============================================
    # تهيئة المحادثة
    # ============================================
    if "chat_history" not in st.session_state:
        risk = user_data["risk_percentage"]
        name = st.session_state.user_name
        
        if risk > 70:
            welcome = f"🔴 **مرحباً {name}!** نسبة الخطر لديك {risk:.0f}% (مرتفعة). سأكون صريحاً معك: تحتاج إلى تحرك فوري. كيف يمكنني مساعدتك اليوم؟"
        elif risk > 30:
            welcome = f"⚠️ **مرحباً {name}!** نسبة الخطر لديك {risk:.0f}% (متوسطة). هذا هو الوقت المناسب للتحسين. ماذا تريد أن تعرف بالضبط؟"
        else:
            welcome = f"✅ **مرحباً {name}!** نسبة الخطر لديك {risk:.0f}% (منخفضة). أحسنت! كيف يمكنني مساعدتك في الحفاظ على صحتك؟"
        
        st.session_state.chat_history = [
            {"role": "assistant", "content": welcome, "time": datetime.now().strftime("%H:%M")}
        ]
    
    # ============================================
    # واجهة العمودين
    # ============================================
    col_chat, col_info = st.columns([2.5, 1.2])
    
    # ============================================
    # العمود الأيمن: معلومات المستخدم
    # ============================================
    with col_info:
        # بطاقة المستخدم
        st.markdown(f"""
        <div style="
            background: linear-gradient(135deg, {colors['primary']}, {colors['secondary']}); 
            border-radius: 20px; 
            padding: 20px; 
            color: white; 
            text-align: center;
            margin-bottom: 20px;
        ">
            <div style="font-size: 48px;">👤</div>
            <h3 style="margin: 5px 0;">{st.session_state.user_name}</h3>
            <p style="margin: 0; opacity: 0.9;">آخر تحليل</p>
            <p style="font-size: 28px; font-weight: bold; margin: 10px 0 0 0;">
                {user_data['risk_percentage']:.0f}%
            </p>
        </div>
        """, unsafe_allow_html=True)
        
        # مؤشر الخطر
        render_gauge(user_data['risk_percentage'], "نسبة الخطر الحالية")
        
        # عرض القراءات الحرجة
        if user_data['analysis'] and user_data['analysis'].get('critical_readings'):
            with st.expander("⚠️ قراءات تحتاج انتباهك", expanded=True):
                for reading in user_data['analysis']['critical_readings']:
                    st.warning(reading)
        
        # عرض التحسن
        if user_data['analysis'] and user_data['analysis'].get('improvement_rate') != 0:
            improvement = user_data['analysis']['improvement_rate']
            if improvement > 0:
                st.success(f"📈 تحسنت بنسبة {improvement:.1f}% عن آخر مرة!")
            elif improvement < 0:
                st.error(f"📉 تدهورت بنسبة {abs(improvement):.1f}% عن آخر مرة")
        
        # حالة Gemini API
        if GEMINI_AVAILABLE and GEMINI_API_KEY:
            st.caption("🤖 مدعوم بـ Gemini AI - إجابات ذكية")
        else:
            st.caption("⚡ وضع الاستجابة السريعة")
            if not GEMINI_API_KEY:
                st.info("💡 للحصول على إجابات أذكى، أضف مفتاح Gemini API في ملف .env")
    
    # ============================================
    # العمود الأيسر: المحادثة
    # ============================================
    with col_chat:
        # رأس المحادثة
        st.markdown(f"""
        <div style="
            background: linear-gradient(135deg, {colors['primary']}, {colors['secondary']}); 
            border-radius: 20px 20px 0 0; 
            padding: 15px 20px; 
            color: white;
        ">
            <div style="display: flex; align-items: center; gap: 12px;">
                <div style="
                    width: 40px; 
                    height: 40px; 
                    background: rgba(255,255,255,0.2); 
                    border-radius: 12px; 
                    display: flex; 
                    align-items: center; 
                    justify-content: center;
                ">
                    <span style="font-size: 22px;">🤖</span>
                </div>
                <div>
                    <h3 style="margin: 0;">المساعد الطبي الذكي</h3>
                    <p style="margin: 2px 0 0 0; opacity: 0.8; font-size: 12px;">
                        متصل | نسبة خطرك {user_data['risk_percentage']:.0f}%
                    </p>
                </div>
            </div>
        </div>
        """, unsafe_allow_html=True)
        
        # عرض المحادثة
        chat_container = st.container(height=400)
        
        with chat_container:
            for msg in st.session_state.chat_history:
                if msg["role"] == "user":
                    st.markdown(f"""
                    <div style="display: flex; justify-content: flex-end; margin-bottom: 12px;">
                        <div style="
                            background: {colors['primary']}; 
                            color: white; 
                            padding: 10px 16px; 
                            border-radius: 18px; 
                            border-top-left-radius: 4px; 
                            max-width: 80%;
                            font-size: 14px;
                        ">
                            {msg['content']}
                        </div>
                    </div>
                    """, unsafe_allow_html=True)
                else:
                    st.markdown(f"""
                    <div style="display: flex; justify-content: flex-start; margin-bottom: 12px;">
                        <div style="
                            background: {colors['surface_container']}; 
                            padding: 10px 16px; 
                            border-radius: 18px; 
                            border-top-right-radius: 4px; 
                            max-width: 80%;
                            font-size: 14px;
                            border: 1px solid {colors['outline_variant']};
                        ">
                            {msg['content']}
                        </div>
                    </div>
                    <div style="font-size: 10px; color: {colors['outline']}; margin-top: -8px; margin-bottom: 12px;">
                        {msg.get('time', '')}
                    </div>
                    """, unsafe_allow_html=True)
        
        # أسئلة سريعة
        st.markdown("**⚡ أسئلة سريعة**")
        quick_cols = st.columns(4)
        quick_qs = [
            ("📊", "نسبة الخطر"),
            ("🩸", "مستوى السكر"),
            ("⚖️", "الوزن BMI"),
            ("🍽️", "نظام غذائي"),
        ]
        
        for i, (icon, label) in enumerate(quick_qs):
            with quick_cols[i]:
                if st.button(f"{icon} {label}", key=f"quick_{i}", width='stretch'):
                    st.session_state.chat_history.append({
                        "role": "user", 
                        "content": label, 
                        "time": datetime.now().strftime("%H:%M")
                    })
                    
                    # محاولة الرد السريع أولاً
                    response = get_fast_response(label.lower(), user_data)
                    
                    # إذا لم يجد، استخدم Gemini
                    if not response and GEMINI_AVAILABLE and GEMINI_API_KEY:
                        with st.spinner("🧠 جاري تحليل سؤالك..."):
                            response = get_gemini_response(label, user_data)
                    
                    if not response:
                        response = "عذراً، لم أتمكن من فهم سؤالك. هل يمكنك إعادة صياغته بشكل أوضح؟"
                    
                    st.session_state.chat_history.append({
                        "role": "assistant", 
                        "content": response, 
                        "time": datetime.now().strftime("%H:%M")
                    })
                    save_user_data()
                    st.rerun()
        
        # حقل الإدخال
        st.markdown("---")
        
        with st.form(key="chat_form", clear_on_submit=True):
            col_input, col_send = st.columns([5, 1])
            
            with col_input:
                user_input = st.text_input("💬 سؤالك", placeholder="اسألني أي شيء عن صحتك...", label_visibility="collapsed")
            
            with col_send:
                submit = st.form_submit_button("📤 إرسال", width='stretch')
            
            if submit and user_input:
                st.session_state.chat_history.append({
                    "role": "user", 
                    "content": user_input, 
                    "time": datetime.now().strftime("%H:%M")
                })
                
                # محاولة الرد السريع أولاً
                response = get_fast_response(user_input.lower(), user_data)
                
                # إذا لم يجد، استخدم Gemini
                if not response and GEMINI_AVAILABLE and GEMINI_API_KEY:
                    with st.spinner("🧠 جاري التفكير..."):
                        response = get_gemini_response(user_input, user_data)
                
                if not response:
                    response = "عذراً، لم أتمكن من فهم سؤالك. هل يمكنك إعادة صياغته بشكل أوضح؟"
                
                st.session_state.chat_history.append({
                    "role": "assistant", 
                    "content": response, 
                    "time": datetime.now().strftime("%H:%M")
                })
                save_user_data()
                st.rerun()
        
        # أزرار إضافية
        col_clear, col_refresh = st.columns(2)
        
        with col_clear:
            if st.button("🗑️ مسح المحادثة", width='stretch'):
                risk = user_data["risk_percentage"]
                name = st.session_state.user_name
                
                if risk > 70:
                    welcome = f"🔴 مرحباً {name}! تم مسح المحادثة. نسبة الخطر {risk:.0f}%. كيف يمكنني مساعدتك؟"
                elif risk > 30:
                    welcome = f"⚠️ مرحباً {name}! تم مسح المحادثة. نسبة الخطر {risk:.0f}%. كيف يمكنني مساعدتك؟"
                else:
                    welcome = f"✅ مرحباً {name}! تم مسح المحادثة. كيف يمكنني مساعدتك؟"
                
                st.session_state.chat_history = [{
                    "role": "assistant", 
                    "content": welcome, 
                    "time": datetime.now().strftime("%H:%M")
                }]
                show_toast("🗑️ تم مسح المحادثة")
                save_user_data()
                st.rerun()
        
        with col_refresh:
            if st.button("🔄 تحديث البيانات", width='stretch'):
                show_toast("🔄 جاري تحديث البيانات من آخر تحليل")
                save_user_data()
                st.rerun()
    
    # ============================================
    # تذييل أمان
    # ============================================
    st.markdown(f"""
    <div style="
        text-align: center; 
        font-size: 11px; 
        color: {colors['outline']}; 
        padding: 15px; 
        margin-top: 20px;
        border-top: 1px solid {colors['outline_variant']};
    ">
        ⚠️ هذا التحليل آلي وليس بديلاً عن استشارة الطبيب المختص.<br>
        للتشخيص الدقيق والعلاج المناسب، يرجى استشارة الطبيب.
    </div>
    """, unsafe_allow_html=True)