# utils/helpers.py

import streamlit as st
from datetime import datetime

def get_risk_level(risk_percent):
    """تحديد مستوى الخطر بناءً على النسبة"""
    if risk_percent < 30:
        return "منخفض", "🟢", "#10b981"
    elif risk_percent < 70:
        return "متوسط", "🟠", "#f59e0b"
    else:
        return "مرتفع", "🔴", "#ef4444"

def get_recommendation(risk_percent, top_factor, hba1c, bmi, glucose):
    """توليد توصيات سريرية مخصصة"""
    if risk_percent < 30:
        return """
        ✅ **مستوى خطر منخفض - ممتاز!** 
        - استمر في نمط الحياة الصحي
        - قم بفحص دوري كل 6-12 شهراً
        - حافظ على وزن صحي ونشاط بدني منتظم
        """
    elif risk_percent < 70:
        return f"""
        ⚠️ **مستوى خطر متوسط - يحتاج إلى متابعة**
        
        **الإجراءات الموصى بها:**
        - 🩺 استشارة طبيب الأسرة لإجراء فحوصات تأكيدية
        - 🥗 تعديل النظام الغذائي: تقليل السكريات والكربوهيدرات
        - 🏃 زيادة النشاط البدني (30 دقيقة يومياً)
        - 📊 إعادة التقييم خلال 3 أشهر
        
        **العامل الأكثر تأثيراً:** {top_factor}
        """
    else:
        recommendations = []
        if hba1c > 7:
            recommendations.append("🔴 استشارة أخصائي الغدد الصماء خلال أسبوع")
        if bmi > 30:
            recommendations.append("🥗 برنامج إنقاص وزن تحت إشراف أخصائي تغذية")
        if glucose > 140:
            recommendations.append("📊 تثبيت جهاز قياس سكر منزلي ومتابعة يومية")
        
        return f"""
        🔴 **مستوى خطر مرتفع - تدخل طبي فوري**
        
        **الإجراءات العاجلة:**
        - {" - ".join(recommendations) if recommendations else "🩺 مراجعة طبية فورية"}
        - 💊 قد تحتاج إلى بدء علاج دوائي تحت إشراف طبي
        - 📋 إجراء فحوصات شاملة (HbA1c، تحمل الجلوكوز، ملف دهني)
        
        **نسبة الخطر الحالية:** {risk_percent:.0f}%
        **العامل الرئيسي:** {top_factor}
        """

def show_toast(message, type="success"):
    """عرض إشعار منبثق"""
    icons = {"success": "✅", "error": "❌", "warning": "⚠️", "info": "ℹ️"}
    colors = {
        "success": "#10b981",
        "error": "#ef4444", 
        "warning": "#f59e0b",
        "info": "#3b82f6"
    }
    
    toast_html = f"""
    <div style="position: fixed; bottom: 20px; right: 20px; 
                background: {colors[type]}; color: white; 
                padding: 12px 20px; border-radius: 12px;
                box-shadow: 0 4px 12px rgba(0,0,0,0.15);
                z-index: 9999; animation: slideIn 0.3s ease;">
        {icons[type]} {message}
    </div>
    <style>
        @keyframes slideIn {{
            from {{ transform: translateX(100px); opacity: 0; }}
            to {{ transform: translateX(0); opacity: 1; }}
        }}
    </style>
    """
    st.markdown(toast_html, unsafe_allow_html=True)

def save_prediction(predictions_list, data, risk, importance):
    """حفظ التنبؤ في السجل"""
    prediction = {
        'id': len(predictions_list) + 1,
        'date': datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        'risk': risk,
        'level': get_risk_level(risk)[0],
        'hba1c': data.get('hba1c'),
        'bmi': data.get('bmi'),
        'glucose': data.get('fasting_glucose'),
        'age': data.get('age'),
        'top_factor': max(importance, key=importance.get) if importance else "غير محدد"
    }
    predictions_list.append(prediction)
    return predictions_list

import streamlit as st
from PIL import Image
import os

def get_logo_html(width=35):
    logo_path = "assets/images/logo6.png"
    if os.path.exists(logo_path):
        logo = Image.open(logo_path)
        return st.image(logo, width=width)
    else:
        return f'<span style="font-size: {width}px;">🩺</span>'
    