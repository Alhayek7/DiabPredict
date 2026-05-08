
app_py = """
DiabPredict - نظام التنبؤ بالسكري
التطبيق الرئيسي - نقطة الدخول
"""

import streamlit as st
from utils.theme import apply_theme, COLORS

# ============================================
# إعدادات الصفحة الرئيسية
# ============================================
st.set_page_config(
    page_title="DiabPredict - نظام التنبؤ بالسكري",
    page_icon="🏥",
    layout="wide",
    initial_sidebar_state="expanded",
    menu_items={
        "Get Help": None,
        "Report a bug": None,
        "About": "DiabPredict - نظام ذكي للتنبؤ المبكر بخطر السكري",
    }
)

# ============================================
# تطبيق السمة والأنماط
# ============================================
apply_theme()

# ============================================
# تهيئة حالة الجلسة
# ============================================
if "current_page" not in st.session_state:
    st.session_state.current_page = "home"

if "predictions" not in st.session_state:
    st.session_state.predictions = []

if "chat_history" not in st.session_state:
    st.session_state.chat_history = []

if "user_data" not in st.session_state:
    st.session_state.user_data = {}

# ============================================
# المحتوى الرئيسي (الصفحة الرئيسية)
# ============================================
# العنوان الرئيسي
st.markdown(f"""
<div style="
    background: linear-gradient(135deg, {COLORS['primary']} 0%, {COLORS['secondary']} 100%);
    border-radius: 24px;
    padding: 64px 48px;
    margin-bottom: 32px;
    position: relative;
    overflow: hidden;
    direction: rtl;
    text-align: right;
">
    <!-- عناصر زخرفية -->
    <div style="
        position: absolute;
        top: -80px;
        left: -80px;
        width: 300px;
        height: 300px;
        background: rgba(255,255,255,0.08);
        border-radius: 50%;
    "></div>
    <div style="
        position: absolute;
        bottom: -60px;
        right: 10%;
        width: 200px;
        height: 200px;
        background: rgba(255,255,255,0.05);
        border-radius: 50%;
    "></div>
    <div style="
        position: absolute;
        top: 20%;
        right: -40px;
        width: 120px;
        height: 120px;
        background: rgba(255,255,255,0.06);
        border-radius: 50%;
    "></div>
    
    <div style="position: relative; z-index: 1; display: flex; align-items: center; gap: 48px;">
        <div style="flex: 1;">
            <div style="
                display: inline-flex;
                align-items: center;
                gap: 12px;
                background: rgba(255,255,255,0.15);
                padding: 8px 20px;
                border-radius: 9999px;
                margin-bottom: 24px;
                backdrop-filter: blur(10px);
            ">
                <span style="font-size: 20px;">🩺</span>
                <span style="color: white; font-size: 14px; font-weight: 500;">نظام طبي متطور</span>
            </div>
            
            <h1 style="
                margin: 0 0 16px 0;
                font-size: 42px;
                font-weight: 700;
                color: white;
                line-height: 1.2;
            ">
                نظام ذكي للتنبؤ المبكر<br>بخطر السكري
            </h1>
            
            <p style="
                margin: 0 0 32px 0;
                font-size: 18px;
                line-height: 1.8;
                color: rgba(255,255,255,0.85);
                max-width: 600px;
            ">
                بتقنيات الذكاء الاصطناعي والتفسير الشفاف لضمان دقة النتائج 
                وفهم مسببات الخطر الشخصية. نظام يعتمد على البيانات لتقديم 
                رؤية استباقية لصحتك.
            </p>
            
            <div style="display: flex; gap: 16px;">
                <a href="/التنبؤ" target="_self" style="
                    display: inline-flex;
                    align-items: center;
                    gap: 8px;
                    background: white;
                    color: {COLORS['primary']};
                    padding: 14px 32px;
                    border-radius: 9999px;
                    text-decoration: none;
                    font-size: 16px;
                    font-weight: 600;
                    transition: transform 0.2s, box-shadow 0.2s;
                    box-shadow: 0 4px 20px rgba(0,0,0,0.15);
                " onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 8px 30px rgba(0,0,0,0.2)';" 
                onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 4px 20px rgba(0,0,0,0.15)';">
                    <span>ابدأ الآن</span>
                    <span>←</span>
                </a>
                <a href="/عن_النظام" target="_self" style="
                    display: inline-flex;
                    align-items: center;
                    gap: 8px;
                    background: rgba(255,255,255,0.15);
                    color: white;
                    padding: 14px 32px;
                    border-radius: 9999px;
                    text-decoration: none;
                    font-size: 16px;
                    font-weight: 500;
                    border: 1px solid rgba(255,255,255,0.3);
                    backdrop-filter: blur(10px);
                    transition: background 0.2s;
                " onmouseover="this.style.background='rgba(255,255,255,0.25)';" 
                onmouseout="this.style.background='rgba(255,255,255,0.15)';">
                    <span>تعرف أكثر</span>
                </a>
            </div>
        </div>
        
        <div style="
            width: 280px;
            height: 280px;
            background: rgba(255,255,255,0.1);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255,255,255,0.2);
            flex-shrink: 0;
        ">
            <span style="font-size: 120px;">🏥</span>
        </div>
    </div>
</div>
""", unsafe_allow_html=True)

# ============================================
# إحصائيات عالمية
# ============================================
st.markdown(f"""
<div style="margin-bottom: 16px;">
    <h2 style="
        margin: 0;
        font-size: 24px;
        font-weight: 700;
        color: {COLORS['on_background']};
        direction: rtl;
        text-align: right;
    ">
        📊 إحصائيات عالمية
    </h2>
</div>
""", unsafe_allow_html=True)

stats = [
    ("👥", "537M", "مصاب حالياً حول العالم", "مرتفع", COLORS["error"], "#ffdad6"),
    ("📈", "783M", "مصاب متوقع بحلول 2045", "متوقع", "#f97316", "#ffedd5"),
    ("✅", "80%", "من الحالات قابلة للوقاية", "إيجابي", COLORS["tertiary"], "#bdffdb"),
    ("🎯", "94%", "دقة التنبؤ في النظام", "أداء", COLORS["primary"], "#dbe1ff"),
]

stats_cols = st.columns(4)
for i, (icon, value, label, badge, badge_color, badge_bg) in enumerate(stats):
    with stats_cols[i]:
        st.markdown(f"""
        <div class="card" style="
            padding: 24px;
            text-align: center;
            direction: rtl;
            position: relative;
            overflow: hidden;
        ">
            <div style="
                position: absolute;
                top: 16px;
                left: 16px;
                background: {badge_bg};
                color: {badge_color};
                padding: 4px 12px;
                border-radius: 9999px;
                font-size: 12px;
                font-weight: 600;
            ">{badge}</div>
            <div style="font-size: 32px; margin-bottom: 12px;">{icon}</div>
            <h3 style="
                margin: 0 0 4px 0;
                font-size: 28px;
                font-weight: 700;
                color: {COLORS['on_background']};
            ">{value}</h3>
            <p style="
                margin: 0;
                font-size: 14px;
                color: {COLORS['on_surface_variant']};
            ">{label}</p>
        </div>
        """, unsafe_allow_html=True)

# ============================================
# مميزات النظام
# ============================================
st.markdown("<div style='margin-top: 48px;'></div>", unsafe_allow_html=True)

st.markdown(f"""
<div style="margin-bottom: 24px;">
    <h2 style="
        margin: 0;
        font-size: 24px;
        font-weight: 700;
        color: {COLORS['on_background']};
        direction: rtl;
        text-align: right;
    ">
        ✨ مميزات النظام
    </h2>
</div>
""", unsafe_allow_html=True)

features = [
    ("🧠", "محرك XGBoost", "خوارزمية تعلم آلي متقدمة توفر دقة عالية في التنبؤ بناءً على المؤشرات الحيوية.", COLORS["primary"], "#dbe1ff"),
    ("🔍", "تفسيرات SHAP", "شفافية كاملة في النتائج، لمعرفة العوامل الدقيقة المؤثرة على مستوى الخطر لديك.", COLORS["secondary"], "#eaddff"),
    ("💬", "مساعد Gemini AI", "مساعد افتراضي ذكي للإجابة على استفساراتك الصحية وتقديم نصائح مخصصة.", COLORS["tertiary"], "#bdffdb"),
    ("🔬", "محاكي السيناريوهات", "أداة تفاعلية لاختبار كيف يمكن أن تؤثر تغييرات نمط الحياة على خطر الإصابة.", COLORS["error"], "#ffdad6"),
    ("📱", "تطبيق الجوال", "تطبيق متكامل لمتابعة صحتك على مدار الساعة من أي مكان وبكل سهولة.", COLORS["primary_fixed_variant"], "#b4c5ff"),
    ("📊", "تتبع زمني", "سجل تاريخي يوضح التطور في مؤشراتك الصحية ومستوى الخطر عبر الزمن.", COLORS["secondary_container"], "#d2bbff"),
]

feature_rows = [features[i:i+3] for i in range(0, len(features), 3)]

for row in feature_rows:
    cols = st.columns(3)
    for i, (icon, title, desc, color, bg) in enumerate(row):
        with cols[i]:
            st.markdown(f"""
            <div class="card" style="
                padding: 28px;
                height: 100%;
                direction: rtl;
                text-align: right;
                transition: transform 0.3s, box-shadow 0.3s;
            " onmouseover="this.style.transform='translateY(-4px)'; this.style.boxShadow='0 8px 30px rgba(0,0,0,0.12)';" 
            onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 4px 20px rgba(0,0,0,0.08)';">
                <div style="
                    width: 56px;
                    height: 56px;
                    background: {bg};
                    border-radius: 16px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 28px;
                    margin-bottom: 16px;
                    color: {color};
                ">{icon}</div>
                <h3 style="
                    margin: 0 0 8px 0;
                    font-size: 18px;
                    font-weight: 600;
                    color: {COLORS['on_background']};
                ">{title}</h3>
                <p style="
                    margin: 0;
                    font-size: 14px;
                    line-height: 1.7;
                    color: {COLORS['on_surface_variant']};
                ">{desc}</p>
            </div>
            """, unsafe_allow_html=True)
    st.markdown("<div style='margin-top: 16px;'></div>", unsafe_allow_html=True)

# ============================================
# كيف يعمل النظام
# ============================================
st.markdown("<div style='margin-top: 48px;'></div>", unsafe_allow_html=True)

st.markdown(f"""
<div class="card" style="padding: 48px; margin-bottom: 32px;">
    <h2 style="
        margin: 0 0 48px 0;
        font-size: 24px;
        font-weight: 700;
        color: {COLORS['on_background']};
        text-align: center;
        direction: rtl;
    ">
        ⚙️ كيف يعمل النظام
    </h2>
    
    <div style="
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        gap: 32px;
        position: relative;
        direction: rtl;
    ">
        <!-- خط الوصل -->
        <div style="
            position: absolute;
            top: 40px;
            right: 15%;
            left: 15%;
            height: 3px;
            background: linear-gradient(90deg, {COLORS['primary']} 0%, {COLORS['secondary']} 50%, {COLORS['tertiary']} 100%);
            z-index: 0;
        "></div>
        
        <!-- الخطوة 1 -->
        <div style="flex: 1; text-align: center; position: relative; z-index: 1;">
            <div style="
                width: 80px;
                height: 80px;
                background: white;
                border: 4px solid {COLORS['primary']};
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 32px;
                margin: 0 auto 16px auto;
                box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            ">📝</div>
            <div style="
                width: 32px;
                height: 32px;
                background: {COLORS['primary']};
                color: white;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: 700;
                font-size: 14px;
                margin: -56px auto 24px auto;
                position: relative;
                z-index: 2;
                border: 3px solid white;
            ">1</div>
            <h3 style="
                margin: 0 0 8px 0;
                font-size: 18px;
                font-weight: 600;
                color: {COLORS['on_background']};
            ">إدخال البيانات</h3>
            <p style="
                margin: 0;
                font-size: 14px;
                line-height: 1.6;
                color: {COLORS['on_surface_variant']};
            ">أدخل بياناتك الطبية والمؤشرات الحيوية الأساسية في النموذج الآمن.</p>
        </div>
        
        <!-- الخطوة 2 -->
        <div style="flex: 1; text-align: center; position: relative; z-index: 1;">
            <div style="
                width: 80px;
                height: 80px;
                background: white;
                border: 4px solid {COLORS['secondary']};
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 32px;
                margin: 0 auto 16px auto;
                box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            ">🤖</div>
            <div style="
                width: 32px;
                height: 32px;
                background: {COLORS['secondary']};
                color: white;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: 700;
                font-size: 14px;
                margin: -56px auto 24px auto;
                position: relative;
                z-index: 2;
                border: 3px solid white;
            ">2</div>
            <h3 style="
                margin: 0 0 8px 0;
                font-size: 18px;
                font-weight: 600;
                color: {COLORS['on_background']};
            ">تحليل ذكي</h3>
            <p style="
                margin: 0;
                font-size: 14px;
                line-height: 1.6;
                color: {COLORS['on_surface_variant']};
            ">تقوم خوارزميات الذكاء الاصطناعي بتحليل البيانات المعقدة بدقة فائقة.</p>
        </div>
        
        <!-- الخطوة 3 -->
        <div style="flex: 1; text-align: center; position: relative; z-index: 1;">
            <div style="
                width: 80px;
                height: 80px;
                background: white;
                border: 4px solid {COLORS['tertiary']};
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 32px;
                margin: 0 auto 16px auto;
                box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            ">📋</div>
            <div style="
                width: 32px;
                height: 32px;
                background: {COLORS['tertiary']};
                color: white;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: 700;
                font-size: 14px;
                margin: -56px auto 24px auto;
                position: relative;
                z-index: 2;
                border: 3px solid white;
            ">3</div>
            <h3 style="
                margin: 0 0 8px 0;
                font-size: 18px;
                font-weight: 600;
                color: {COLORS['on_background']};
            ">احصل على النتائج</h3>
            <p style="
                margin: 0;
                font-size: 14px;
                line-height: 1.6;
                color: {COLORS['on_surface_variant']};
            ">عرض تقرير مفصل يوضح مستوى الخطر مع تفسيرات واضحة وتوصيات.</p>
        </div>
    </div>
</div>
""", unsafe_allow_html=True)

# ============================================
# دعوة للعمل (CTA)
# ============================================
st.markdown(f"""
<div style="
    background: linear-gradient(135deg, {COLORS['secondary_container']} 0%, {COLORS['primary_container']} 100%);
    border-radius: 24px;
    padding: 64px 48px;
    text-align: center;
    direction: rtl;
    margin-bottom: 32px;
">
    <h2 style="
        margin: 0 0 16px 0;
        font-size: 32px;
        font-weight: 700;
        color: white;
    ">هل أنت جاهز لتأمين صحتك؟</h2>
    <p style="
        margin: 0 auto 32px auto;
        font-size: 16px;
        line-height: 1.8;
        color: rgba(255,255,255,0.9);
        max-width: 600px;
    ">
        خطوة واحدة بسيطة قد تكون الفارق في مسارك الصحي. استخدم تقنياتنا المتطورة 
        للحصول على تقييم دقيق اليوم.
    </p>
    <a href="/التنبؤ" target="_self" style="
        display: inline-flex;
        align-items: center;
        gap: 8px;
        background: white;
        color: {COLORS['primary_container']};
        padding: 16px 40px;
        border-radius: 9999px;
        text-decoration: none;
        font-size: 18px;
        font-weight: 700;
        box-shadow: 0 4px 20px rgba(0,0,0,0.15);
        transition: transform 0.2s, box-shadow 0.2s;
    " onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 8px 30px rgba(0,0,0,0.2)';" 
    onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 4px 20px rgba(0,0,0,0.15)';">
        <span>🛡️</span>
        <span>ابدأ التنبؤ الآن</span>
    </a>
</div>
""", unsafe_allow_html=True)

# ============================================
# الفوتر
# ============================================
st.markdown(f"""
<div style="
    border-top: 1px solid {COLORS['outline_variant']};
    padding-top: 24px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 16px;
    direction: rtl;
">
    <div style="display: flex; align-items: center; gap: 12px;">
        <div style="
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, {COLORS['primary']} 0%, {COLORS['secondary']} 100%);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 700;
            font-size: 16px;
        ">DP</div>
        <div>
            <div style="font-weight: 600; color: {COLORS['on_background']}; font-size: 14px;">DiabPredict</div>
            <div style="color: {COLORS['on_surface_variant']}; font-size: 12px;">نظام التنبؤ بالسكري</div>
        </div>
    </div>
    <div style="color: {COLORS['on_surface_variant']}; font-size: 14px;">
        © 2024 DiabPredict. جميع الحقوق محفوظة.
    </div>
    <div style="display: flex; gap: 24px;">
        <a href="#" style="
            color: {COLORS['primary']};
            text-decoration: none;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 4px;
        ">💻 GitHub</a>
        <a href="#" style="
            color: {COLORS['on_surface_variant']};
            text-decoration: none;
            font-size: 14px;
        ">سياسة الخصوصية</a>
        <a href="#" style="
            color: {COLORS['on_surface_variant']};
            text-decoration: none;
            font-size: 14px;
        ">الشروط والأحكام</a>
    </div>
</div>
""", unsafe_allow_html=True)
