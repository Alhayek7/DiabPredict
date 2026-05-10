"""
app.py - الملف الرئيسي لتطبيق DiabPredict
نسخة احترافية مع حفظ تلقائي للبيانات محلياً وقائمة جانبية محسنة
"""

import streamlit as st
import atexit
from datetime import datetime
from PIL import Image
import os

# ============================================
# استيراد أدوات الحفظ المحلي
# ============================================
from utils.storage import load_user_data, save_user_data, clear_user_data

# ============================================
# تحميل البيانات المحفوظة عند بدء التشغيل
# ============================================
load_user_data()

# ============================================
# تسجيل حفظ البيانات عند إغلاق التطبيق
# ============================================
atexit.register(save_user_data)

# إعدادات الصفحة
st.set_page_config(
    page_title="DiabPredict - نظام التنبؤ بالسكري",
    page_icon="🩺",
    layout="wide",
    initial_sidebar_state="expanded",
    menu_items={
        'Get Help': None,
        'Report a bug': None,
        'About': None
    }
)
st.markdown("""
<style>
    /* توسيط الشعار في القائمة الجانبية بشكل ثابت */
    [data-testid="stSidebar"] .stImage {
        display: flex !important;
        justify-content: center !important;
        align-items: center !important;
        width: 100% !important;
        text-align: center !important;
    }
    
    [data-testid="stSidebar"] .stImage img {
        margin: 0 auto !important;
        display: block !important;
    }
    
    /* توسيط العناصر الأخرى في القائمة الجانبية */
    [data-testid="stSidebar"] .stMarkdown {
        text-align: center !important;
    }
</style>
""", unsafe_allow_html=True)

# ============================================
# CSS لتوسيط المحتوى وتحسين المظهر
# ============================================
st.markdown("""
<style>
    .main > div {
        max-width: 1000px;
        margin: 0 auto;
        padding: 1rem;
    }
    .element-container {
        width: 100%;
    }
    .row-widget.stHorizontal {
        gap: 1rem;
    }
[data-testid="stSidebar"] {
    background: linear-gradient(#F8FAFC 0%, #BFDBFE 100%, #DBEAFE 100%) !important;
    backdrop-filter: blur(10px);
    border-left: 1px solid rgba(226, 232, 240, 0.5);
    box-shadow: -2px 0 10px rgba(0,0,0,0.05);
}
    [data-testid="stSidebar"] .stButton button {
        background: transparent;
        color: #334155;
        text-align: right;
        justify-content: flex-start;
        border-radius: 12px;
        transition: all 0.2s ease;
    }
    [data-testid="stSidebar"] .stButton button:hover {
        background: #f1f5f9;
        color: #2563eb;
        transform: translateX(-4px);
    }
    /* تحسين شريط التمرير */
    ::-webkit-scrollbar {
        width: 6px;
    }
    ::-webkit-scrollbar-track {
        background: #f1f1f1;
        border-radius: 10px;
    }
    ::-webkit-scrollbar-thumb {
        background: #cbd5e1;
        border-radius: 10px;
    }
    ::-webkit-scrollbar-thumb:hover {
        background: #94a3b8;
    }
</style>
""", unsafe_allow_html=True)

# استيراد المكتبات
import time
from utils.theme import apply_theme, get_colors
from utils.config import APP_NAME, APP_VERSION
from utils.model import get_predictor

# تطبيق الثيم المحسن
apply_theme()
colors = get_colors()

# ============================================
# تهيئة حالة الجلسة (القيم الافتراضية إذا لم تكن موجودة)
# ============================================
if 'predictions_history' not in st.session_state:
    st.session_state.predictions_history = []
if 'last_risk' not in st.session_state:
    st.session_state.last_risk = None
if 'last_importance' not in st.session_state:
    st.session_state.last_importance = None
if 'last_features' not in st.session_state:
    st.session_state.last_features = None
if 'app_version' not in st.session_state:
    st.session_state.app_version = APP_VERSION
if 'current_page' not in st.session_state:
    st.session_state.current_page = "home"
if 'user_name' not in st.session_state:
    st.session_state.user_name = ""
if 'chat_history' not in st.session_state:
    st.session_state.chat_history = []
if 'last_prediction_date' not in st.session_state:
    st.session_state.last_prediction_date = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
if 'last_input_values' not in st.session_state:
    st.session_state.last_input_values = {
        'pregnancies': 0, 'glucose': 120, 'blood_pressure': 70,
        'skin_thickness': 20, 'insulin': 80, 'bmi': 25.0,
        'dpf': 0.5, 'age': 30
    }

# ============================================
# تهيئة النموذج
# ============================================
@st.cache_resource
def init_model():
    with st.spinner("🔄 جاري تحميل نموذج التنبؤ..."):
        return get_predictor()

predictor = init_model()

# حساب متوسط الخطر للعرض في الشريط الجانبي
avg_risk = 0
if st.session_state.predictions_history:
    avg_risk = sum(p.get('risk', 0) for p in st.session_state.predictions_history) / len(st.session_state.predictions_history)

    
# ============================================
# الشريط الجانبي - شعار في المنتصف
# ============================================
with st.sidebar:
    # الشعار
    logo_path = "assets/images/logo6.png"
    
    # استخدام أعمدة لتوسيط الشعار
    col1, col2, col3 = st.columns([1, 2, 1])
    with col2:
        # التحقق من وجود الصورة
        if os.path.exists(logo_path):
            st.image(logo_path, width=80)
        else:
            # أيقونة بديلة إذا لم توجد الصورة
            st.markdown(f"""
            <div style="
                width: 75px;
                height: 75px;
                background: linear-gradient(135deg, {colors['primary']}, {colors['secondary']});
                border-radius: 25px;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto;
                box-shadow: 0 8px 20px {colors['primary']}50;
            ">
                <span style="font-size: 38px;">🩺</span>
            </div>
            """, unsafe_allow_html=True)
    
    st.markdown(f"""
    <div style="text-align: center;">
        <h2 style="margin: 0; background: linear-gradient(135deg, {colors['primary']}, {colors['secondary']}); 
                   -webkit-background-clip: text; -webkit-text-fill-color: transparent;
                   font-size: 24px;
                   font-weight: 800;">
           DiabPredict
        </h2>
        <p style="color: {colors['outline']}; font-size: 12px; margin-top: 5px;">
            نظام ذكي للتنبؤ بالسكري
        </p>
    </div>
    """, unsafe_allow_html=True)
    
    st.markdown("<br>", unsafe_allow_html=True)
    
    # ============================================
    # أزرار التنقل بتصميم عصري
    # ============================================
    nav_items = [
        {"icon": "🏠", "label": "الرئيسية", "id": "home", "desc": "الصفحة الرئيسية"},
        {"icon": "🔮", "label": "التنبؤ", "id": "predict", "desc": "تقييم المخاطر"},
        {"icon": "🤖", "label": "المساعد الذكي", "id": "assistant", "desc": "اسأل ونحن نجيب"},
        {"icon": "📊", "label": "السجل", "id": "history", "desc": "تتبع تطورك"},
        {"icon": "ℹ️", "label": "عن النظام", "id": "about", "desc": "تعرف علينا"}
    ]
    
    current_page = st.session_state.get("current_page", "home")
    
    for item in nav_items:
        is_active = current_page == item["id"]
        
        if is_active:
            # الزر النشط - تصميم مميز
            st.markdown(f"""
            <div style="
                background: linear-gradient(90deg, {colors['primary']}20 0%, {colors['primary']}05 100%);
                border-right: 4px solid {colors['primary']};
                border-radius: 0 16px 16px 0;
                margin: 8px 0;
                padding: 10px 16px;
                transition: all 0.3s ease;
            ">
                <div style="display: flex; align-items: center; gap: 14px;">
                    <div style="
                        width: 36px;
                        height: 36px;
                        background: linear-gradient(135deg, {colors['primary']}, {colors['secondary']});
                        border-radius: 12px;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        box-shadow: 0 2px 8px {colors['primary']}40;
                    ">
                        <span style="font-size: 18px; color: white;">{item['icon']}</span>
                    </div>
                    <div style="flex: 1;">
                        <div style="font-weight: 700; color: {colors['primary']}; font-size: 15px;">{item['label']}</div>
                        <div style="font-size: 10px; color: {colors['outline']};">{item['desc']}</div>
                    </div>
                    <div style="width: 6px; height: 6px; background: {colors['primary']}; border-radius: 50%;"></div>
                </div>
            </div>
            """, unsafe_allow_html=True)
        else:
            # الزر العادي - تصميم نظيف مع تأثير hover
            if st.button(f"{item['icon']}  {item['label']}", key=f"nav_{item['id']}", width='stretch'):
                st.session_state.current_page = item['id']
                save_user_data()
                st.rerun()
    
    st.divider()
    
    # ============================================
    # بطاقة إحصائيات مصغرة وجميلة
    # ============================================
    # تنسيق عرض متوسط الخطر
    if st.session_state.predictions_history:
        if avg_risk < 1:
            avg_display = f"{avg_risk:.2f}%"
        elif avg_risk < 10:
            avg_display = f"{avg_risk:.1f}%"
        else:
            avg_display = f"{avg_risk:.0f}%"
    else:
        avg_display = "—"
    
    st.markdown(f"""
    <div style="
        background: linear-gradient(135deg, {colors['surface_container']}, {colors['surface_container_low']});
        border-radius: 20px;
        padding: 15px;
        margin: 10px 0;
        text-align: center;
        border: 1px solid {colors['outline_variant']};
    ">
        <div style="display: flex; justify-content: space-around; align-items: center;">
            <div>
                <div style="font-size: 28px;">📝</div>
                <div style="font-size: 20px; font-weight: 700; color: {colors['primary']};">{len(st.session_state.predictions_history)}</div>
                <div style="font-size: 10px; color: {colors['outline']};">تنبؤ</div>
            </div>
            <div style="width: 1px; height: 40px; background: {colors['outline_variant']};"></div>
            <div>
                <div style="font-size: 28px;">📈</div>
                <div style="font-size: 20px; font-weight: 700; color: {colors['primary']};">{avg_display}</div>
                <div style="font-size: 10px; color: {colors['outline']};">متوسط الخطر</div>
            </div>
        </div>
    </div>
    """, unsafe_allow_html=True)
    
    st.divider()
    
    # ============================================
    # حالة النموذج مع أيقونة
    # ============================================
    if predictor.is_trained:
        st.markdown(f"""
        <div style="
            background: {colors['tertiary']}10;
            border-radius: 16px;
            padding: 12px;
            margin: 10px 0;
            text-align: center;
            border: 1px solid {colors['tertiary']}30;
        ">
            <div style="display: flex; align-items: center; justify-content: center; gap: 8px;">
                <span style="font-size: 18px;">✅</span>
                <span style="font-weight: 600; color: {colors['tertiary']};">النموذج جاهز</span>
            </div>
            <div style="font-size: 10px; color: {colors['outline']}; margin-top: 4px;">📁 models/diabetes_model.pkl</div>
        </div>
        """, unsafe_allow_html=True)
    else:
        st.warning("⚠️ جاري تحضير النموذج...")
    
    st.divider()
    
    # ============================================
    # أزرار إدارة البيانات بتصميم جميل
    # ============================================
    st.markdown(f"""
    <div style="margin: 15px 0 10px 0;">
        <div style="font-size: 13px; font-weight: 600; color: {colors['outline']}; margin-bottom: 10px;">💾 إدارة البيانات</div>
    </div>
    """, unsafe_allow_html=True)
    
    col_save, col_clear = st.columns(2)
    with col_save:
        if st.button("💾 حفظ", width='stretch'):
            if save_user_data():
                st.toast("✅ تم حفظ البيانات", icon="💾",)
            else:
                st.toast("❌ فشل الحفظ", icon="⚠️")
    
    with col_clear:
        if st.button("🗑️ مسح الكل", width='stretch'):
            clear_user_data()
            st.toast("🗑️ تم مسح جميع البيانات", icon="🔄")
            st.rerun()
    
    # ============================================
    # ترحيب بالمستخدم في الأسفل
    # ============================================
    if st.session_state.get('user_name'):
        st.markdown(f"""
        <div style="
            margin-top: 20px;
            padding: 12px;
            background: {colors['primary']}08;
            border-radius: 16px;
            text-align: center;
            border: 1px dashed {colors['primary']}30;
        ">
            <div style="display: flex; align-items: center; justify-content: center; gap: 6px;">
                <span>👤</span>
                <span style="font-weight: 500;">{st.session_state.user_name}</span>
            </div>
        </div>
        """, unsafe_allow_html=True)

# ============================================
# التنقل بين الصفحات
# ============================================
current_page = st.session_state.get("current_page", "home")

if current_page == "home":
    from app_pages.Home import show
    show()
elif current_page == "predict":
    from app_pages.Predict import show
    show()
elif current_page == "assistant":
    from app_pages.AI_Assistant import show
    show()
elif current_page == "history":
    from app_pages.History import show
    show()
elif current_page == "about":
    from app_pages.About import show
    show()

# ============================================
# تذييل الصفحة
# ============================================
st.markdown("---")
st.markdown(f"""
<div style="text-align: center; color: {colors['outline']}; font-size: 11px; padding: 20px; direction: rtl;">
    <div>⚠️ هذا التطبيق لأغراض تعليمية وتوعوية فقط - ليس بديلاً عن استشارة الطبيب</div>
    <div style="margin-top: 8px;"> DiabPredict © {APP_VERSION} | جميع الحقوق محفوظة</div>
</div>
""", unsafe_allow_html=True)