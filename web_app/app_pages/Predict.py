"""
صفحة التنبؤ - DiabPredict
نسخة احترافية مع SHAP values، تأثيرات حركة، وتحسينات تجربة المستخدم
"""

import streamlit as st
import pandas as pd
import random
import time
from utils.theme import get_colors, get_theme
from components.gauge import render_gauge, render_risk_bar
from components.cards import info_card
from utils.helpers import get_risk_level, get_recommendation, save_prediction
from utils.model import get_predictor
from utils.storage import save_user_data
from utils.alert_system import render_alert_card, render_daily_tip, render_warning_banner


def render_header_glass(page_title: str = "🔮 التنبؤ"):
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
    render_header_glass(" 🔮 التنبؤ")
    """عرض صفحة التنبؤ المحسنة"""
    
    colors = get_colors()
    is_dark = get_theme() == "dark"
    
    # تهيئة النموذج
    predictor = get_predictor()
    
    # تهيئة حالة الجلسة لتخزين آخر إدخال
    if 'last_input_values' not in st.session_state:
        st.session_state.last_input_values = {
            'pregnancies': 0,
            'glucose': 120,
            'blood_pressure': 70,
            'skin_thickness': 20,
            'insulin': 80,
            'bmi': 25.0,
            'dpf': 0.5,
            'age': 30,
            # الأعمدة الجديدة
            'hba1c': 5.7,
            'family_history': 0,
            'smoking': 0,
            'physical_activity': 1,
            'waist_circumference': 85.0
        }
    
    # ============================================
    # العنوان مع تأثير
    # ============================================
    st.markdown(f"""
    <div style="margin-bottom: 32px;">
        <h1 style="margin-bottom: 8px; background: linear-gradient(135deg, {colors['primary']}, {colors['secondary']}); -webkit-background-clip: text; -webkit-text-fill-color: transparent;">
            🔮 تقييم المخاطر السريرية
        </h1>
        <p style="color: {colors['outline']}; font-size: 16px;">
            أدخل البيانات الحيوية للمريض للحصول على تقييم دقيق لاحتمالية الإصابة بالسكري
        </p>
    </div>
    """, unsafe_allow_html=True)
    
    # ============================================
    # نصيحة اليوم - Random Tip
    # ============================================
    tips = [
        "💧 شرب الماء بكثرة يساعد على تقليل تركيز السكر في الدم",
        "🚶 المشي لمدة 30 دقيقة يومياً يحسن حساسية الأنسولين",
        "😴 النوم الكافي (7-8 ساعات) ينظم هرمونات الجسم",
        "🥗 تناول الخضروات الورقية يقلل خطر الإصابة بالسكري",
        "🍵 الشاي الأخضر مضاد للأكسدة ومفيد لمستوى السكر",
        "🏋️ تمارين المقاومة تحسن امتصاص الجلوكوز"
    ]
    st.info(f"💡 **نصيحة اليوم:** {random.choice(tips)}")
    
    # ============================================
    # قيم سريعة (Presets)
    # ============================================
    st.markdown(f"""
    <div style="margin: 10px 0 20px 0;">
        <h3 style="font-size: 16px; color: {colors['on_surface_variant']};">🎯 قيم سريعة</h3>
    </div>
    """, unsafe_allow_html=True)
    
    preset_cols = st.columns(4)
    with preset_cols[0]:
        if st.button("👤 شخص سليم", use_container_width=True):
            st.session_state.last_input_values = {
                'pregnancies': 0, 'glucose': 90, 'blood_pressure': 70,
                'skin_thickness': 20, 'insulin': 70, 'bmi': 22.0,
                'dpf': 0.3, 'age': 25,
                'hba1c': 5.2, 'family_history': 0, 'smoking': 0,
                'physical_activity': 2, 'waist_circumference': 75.0
            }
            st.rerun()
    
    with preset_cols[1]:
        if st.button("⚠️ خطر متوسط", use_container_width=True):
            st.session_state.last_input_values = {
                'pregnancies': 2, 'glucose': 140, 'blood_pressure': 85,
                'skin_thickness': 25, 'insulin': 120, 'bmi': 28.0,
                'dpf': 0.6, 'age': 45,
                'hba1c': 6.2, 'family_history': 1, 'smoking': 1,
                'physical_activity': 1, 'waist_circumference': 90.0
            }
            st.rerun()
    
    with preset_cols[2]:
        if st.button("🔴 خطر مرتفع", use_container_width=True):
            st.session_state.last_input_values = {
                'pregnancies': 5, 'glucose': 180, 'blood_pressure': 95,
                'skin_thickness': 35, 'insulin': 200, 'bmi': 32.0,
                'dpf': 1.2, 'age': 55,
                'hba1c': 7.5, 'family_history': 1, 'smoking': 2,
                'physical_activity': 0, 'waist_circumference': 105.0
            }
            st.rerun()
    
    with preset_cols[3]:
        if st.button("🔄 إعادة تعيين", use_container_width=True):
            st.session_state.last_input_values = {
                'pregnancies': 0, 'glucose': 120, 'blood_pressure': 70,
                'skin_thickness': 20, 'insulin': 80, 'bmi': 25.0,
                'dpf': 0.5, 'age': 30,
                'hba1c': 5.7, 'family_history': 0, 'smoking': 0,
                'physical_activity': 1, 'waist_circumference': 85.0
            }
            st.rerun()
    
    # ============================================
    # نموذج الإدخال والنتائج
    # ============================================
    col_form, col_result = st.columns([3, 2])
    
    with col_form:
        # المؤشرات الحيوية الأساسية
        st.markdown(f"""
        <div style="
            background: {colors['surface_container_lowest']};
            border-radius: 20px;
            padding: 20px;
            margin-bottom: 20px;
            border: 1px solid {colors['outline_variant']};
        ">
            <h3 style="margin-bottom: 20px; display: flex; align-items: center; gap: 8px;">
                <span>🩺</span> المؤشرات الحيوية الأساسية
            </h3>
        """, unsafe_allow_html=True)
        
        col1, col2 = st.columns(2)
        
        with col1:
            pregnancies = st.number_input(
                "عدد مرات الحمل", 
                min_value=0, max_value=20, 
                value=st.session_state.last_input_values['pregnancies'],
                help="للنساء فقط",
                format="%d"
            )
            glucose = st.number_input(
                "نسبة السكر في الدم (Glucose)", 
                min_value=50, max_value=300, 
                value=st.session_state.last_input_values['glucose'],
                help="mg/dL - المعدل الطبيعي أقل من 100"
            )
            blood_pressure = st.number_input(
                "ضغط الدم (Blood Pressure)", 
                min_value=50, max_value=200, 
                value=st.session_state.last_input_values['blood_pressure'],
                help="mmHg - المعدل الطبيعي أقل من 80"
            )
            skin_thickness = st.number_input(
                "سمك الجلد (Skin Thickness)", 
                min_value=0, max_value=100, 
                value=st.session_state.last_input_values['skin_thickness'],
                help="mm"
            )
        
        with col2:
            insulin = st.number_input(
                "الأنسولين (Insulin)", 
                min_value=0, max_value=900, 
                value=st.session_state.last_input_values['insulin'],
                help="mu U/ml"
            )
            bmi = st.number_input(
                "مؤشر كتلة الجسم (BMI)", 
                min_value=10.0, max_value=60.0, 
                value=st.session_state.last_input_values['bmi'],
                step=0.1, 
                help="kg/m² - المعدل الطبيعي 18.5-24.9"
            )
            dpf = st.number_input(
                "دالة النسب للسكري (DPF)", 
                min_value=0.0, max_value=3.0, 
                value=st.session_state.last_input_values['dpf'],
                step=0.01, 
                help="Diabetes Pedigree Function"
            )
            age = st.number_input(
                "العمر", 
                min_value=1, max_value=120, 
                value=st.session_state.last_input_values['age'],
                help="سنوات"
            )
        
        st.markdown("</div>", unsafe_allow_html=True)
        
        # ============================================
        # تحاليل متقدمة (جديدة)
        # ============================================
        st.markdown(f"""
        <div style="
            background: {colors['surface_container_lowest']};
            border-radius: 20px;
            padding: 20px;
            margin-bottom: 20px;
            border: 1px solid {colors['outline_variant']};
        ">
            <h3 style="margin-bottom: 20px; display: flex; align-items: center; gap: 8px;">
                <span>🔬</span> تحاليل متقدمة
            </h3>
        """, unsafe_allow_html=True)
        
        col1, col2 = st.columns(2)
        
        with col1:
            hba1c = st.number_input(
                "السكر التراكمي (HbA1c)", 
                min_value=4.0, max_value=15.0, 
                value=st.session_state.last_input_values.get('hba1c', 5.7),
                step=0.1,
                help="% - المعدل الطبيعي أقل من 5.7%"
            )
            waist_circumference = st.number_input(
                "محيط الخصر (Waist Circumference)", 
                min_value=50.0, max_value=200.0, 
                value=st.session_state.last_input_values.get('waist_circumference', 85.0),
                step=1.0,
                help="سم - للرجال أقل من 94 سم، للنساء أقل من 80 سم"
            )
        
        with col2:
            family_history = st.selectbox(
                "التاريخ العائلي للسكري",
                ["لا", "نعم"],
                index=st.session_state.last_input_values.get('family_history', 0)
            )
            smoking = st.selectbox(
                "التدخين",
                ["لا أدخن", "مدخن سابق", "مدخن حالياً"],
                index=st.session_state.last_input_values.get('smoking', 0)
            )
            physical_activity = st.selectbox(
                "النشاط البدني",
                ["قليل", "متوسط", "كثير"],
                index=st.session_state.last_input_values.get('physical_activity', 1)
            )
        
        st.markdown("</div>", unsafe_allow_html=True)
        
        # تحويل القيم
        family_history_value = 1 if family_history == "نعم" else 0
        smoking_value = ["لا أدخن", "مدخن سابق", "مدخن حالياً"].index(smoking)
        physical_activity_value = ["قليل", "متوسط", "كثير"].index(physical_activity)
        
        # زر التنبؤ
        predict_btn = st.button("🔍 تنبؤ", use_container_width=True, type="primary")
    
    # ============================================
    # نتائج التنبؤ
    # ============================================
    with col_result:
        if predict_btn:
            if not predictor.is_trained:
                st.error("⚠️ النموذج قيد التدريب... يرجى الانتظار قليلاً")
                return
            
            # حفظ القيم المدخلة
            st.session_state.last_input_values = {
                'pregnancies': pregnancies,
                'glucose': glucose,
                'blood_pressure': blood_pressure,
                'skin_thickness': skin_thickness,
                'insulin': insulin,
                'bmi': bmi,
                'dpf': dpf,
                'age': age,
                'hba1c': hba1c,
                'family_history': family_history_value,
                'smoking': smoking_value,
                'physical_activity': physical_activity_value,
                'waist_circumference': waist_circumference
            }
            
            # Progress bar للتحليل
            progress_bar = st.progress(0, text="🔄 جاري تحليل البيانات...")
            for i in range(100):
                time.sleep(0.008)
                progress_bar.progress(i + 1)
            progress_bar.empty()
            
            # تجميع البيانات للنموذج (الأساسية فقط)
            features = {
                'Pregnancies': pregnancies,
                'Glucose': glucose,
                'BloodPressure': blood_pressure,
                'SkinThickness': skin_thickness,
                'Insulin': insulin,
                'BMI': bmi,
                'DiabetesPedigreeFunction': dpf,
                'Age': age
            }
            
            # التنبؤ
            prediction, risk_percentage, shap_values = predictor.predict(features)
            
            # مستوى الخطر
            risk_level, risk_icon, risk_color = get_risk_level(risk_percentage)
            
            # أهم عامل مؤثر
            if shap_values:
                top_factor = max(shap_values, key=shap_values.get)
                top_impact = shap_values[top_factor]
            else:
                top_factor = "غير محدد"
                top_impact = 0
            
            # حفظ في session_state
            save_prediction(
                st.session_state.predictions_history,
                features,
                risk_percentage,
                shap_values
            )
            save_user_data()
            
            # تحديث آخر النتائج
            st.session_state.last_risk = risk_percentage
            st.session_state.last_importance = shap_values
            st.session_state.last_features = features
            
            # مقارنة مع آخر تنبؤ
            if len(st.session_state.predictions_history) > 1:
                prev_risk = st.session_state.predictions_history[-2]['risk']
                delta = risk_percentage - prev_risk
                if delta > 5:
                    st.warning(f"📈 ارتفاع {delta:.0f}% عن آخر تنبؤ")
                elif delta < -5:
                    st.success(f"📉 انخفاض {abs(delta):.0f}% عن آخر تنبؤ")
            
            # عرض النتيجة
            st.markdown(f"""
            <div style="
                text-align: center;
                margin-bottom: 24px;
                padding: 20px;
                background: linear-gradient(135deg, {risk_color}10, transparent);
                border-radius: 20px;
                animation: fadeInUp 0.5s ease;
            ">
                <p style="color: {colors['outline']}; font-size: 14px; margin-bottom: 8px;">
                    مستوى الخطر
                </p>
                <div style="
                    background: {risk_color}20;
                    color: {risk_color};
                    padding: 12px 24px;
                    border-radius: 50px;
                    display: inline-block;
                    font-weight: 700;
                    font-size: 20px;
                ">
                    {risk_icon} {risk_level} ({risk_percentage:.1f}%)
                </div>
            </div>
            """, unsafe_allow_html=True)
            
            # عرض العوامل الإضافية (التدخين، الوراثة، HbA1c، إلخ)
            st.markdown("### 📋 عوامل إضافية مؤثرة")
            
            col_extra1, col_extra2 = st.columns(2)
            
            with col_extra1:
                # HbA1c
                if hba1c > 6.5:
                    st.error(f"🔴 السكر التراكمي: {hba1c}% (مرتفع - يزيد الخطر)")
                elif hba1c > 5.7:
                    st.warning(f"🟡 السكر التراكمي: {hba1c}% (مرتفع قليلاً)")
                else:
                    st.success(f"🟢 السكر التراكمي: {hba1c}% (طبيعي)")
                
                # التاريخ العائلي
                if family_history_value == 1:
                    st.warning("⚠️ التاريخ العائلي: يوجد (يزيد الخطر)")
                else:
                    st.success("✅ التاريخ العائلي: لا يوجد")
                
                # التدخين
                if smoking_value == 2:
                    st.error("🔴 التدخين: مدخن حالياً (يزيد الخطر)")
                elif smoking_value == 1:
                    st.warning("🟡 التدخين: مدخن سابق")
                else:
                    st.success("✅ التدخين: لا يدخن")
            
            with col_extra2:
                # النشاط البدني
                if physical_activity_value == 0:
                    st.error("🔴 النشاط البدني: قليل (يزيد الخطر)")
                elif physical_activity_value == 1:
                    st.success("🟢 النشاط البدني: متوسط")
                else:
                    st.success("✅ النشاط البدني: كثير")
                
                # محيط الخصر
                if waist_circumference > 94:  # للرجال
                    st.error(f"🔴 محيط الخصر: {waist_circumference} سم (مرتفع)")
                elif waist_circumference > 80:  # للنساء
                    st.warning(f"🟡 محيط الخصر: {waist_circumference} سم (مرتفع قليلاً)")
                else:
                    st.success(f"🟢 محيط الخصر: {waist_circumference} سم (طبيعي)")
            
            # مؤشر دائري
            render_gauge(risk_percentage, "نسبة الخطر")
            
            # شريط الخطر
            render_risk_bar(risk_percentage)
            
            # توصية مخصصة
            recommendation = get_recommendation(
                risk_percentage,
                top_factor,
                features.get('Glucose', 0),
                features.get('BMI', 0),
                features.get('Glucose', 0)
            )
            
            info_card(
                title="📋 التوصية السريرية",
                content=recommendation,
                type="warning" if risk_level == "مرتفع" else "info"
            )
            
            # أهم العوامل المؤثرة (SHAP)
            if shap_values:
                st.markdown(f"""
                <div style="margin-top: 24px;">
                    <h3 style="margin-bottom: 16px; font-size: 18px; display: flex; align-items: center; gap: 8px;">
                        📊 أهم العوامل المؤثرة (SHAP)
                    </h3>
                </div>
                """, unsafe_allow_html=True)
                
                # ترتيب العوامل حسب الأهمية
                sorted_shap = sorted(shap_values.items(), key=lambda x: abs(x[1]), reverse=True)[:5]
                
                for factor, importance in sorted_shap:
                    importance_percent = min(abs(importance) * 100, 100)
                    color = colors["error"] if importance > 0 else colors["tertiary"]
                    direction = "⬆️ يزيد الخطر" if importance > 0 else "⬇️ يقلل الخطر"
                    
                    st.markdown(f"""
                    <div style="margin-bottom: 16px;">
                        <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
                            <span style="font-size: 14px; color: {colors['on_surface_variant']};">{factor}</span>
                            <span style="font-size: 13px; color: {color};">{direction}</span>
                        </div>
                        <div style="
                            height: 10px;
                            background: {colors['surface_container']};
                            border-radius: 5px;
                            overflow: hidden;
                        ">
                            <div style="
                                width: {importance_percent}%;
                                height: 100%;
                                background: linear-gradient(90deg, {color}, {color}80);
                                border-radius: 5px;
                                animation: slideIn 0.6s ease;
                            "></div>
                        </div>
                        <div style="text-align: left; margin-top: 4px;">
                            <span style="font-size: 11px; color: {colors['outline']};">القيمة: {importance:.3f}</span>
                        </div>
                    </div>
                    """, unsafe_allow_html=True)
            
            # زر تصدير النتيجة
            report = f"""نتيجة التنبؤ - DiabPredict
            ═══════════════════════════════
            📅 التاريخ: {time.strftime('%Y-%m-%d %H:%M:%S')}
            
            📊 نسبة الخطر: {risk_percentage:.1f}%
            🎯 مستوى الخطر: {risk_level}
            🔬 أهم عامل مؤثر: {top_factor}
            
            🩺 المؤشرات الحيوية الأساسية:
            - السكر: {glucose} mg/dL
            - BMI: {bmi}
            - العمر: {age}
            - ضغط الدم: {blood_pressure} mmHg
            
            🔬 التحاليل المتقدمة:
            - السكر التراكمي (HbA1c): {hba1c}%
            - محيط الخصر: {waist_circumference} سم
            - التاريخ العائلي: {'نعم' if family_history_value else 'لا'}
            - التدخين: {smoking}
            - النشاط البدني: {physical_activity}
            
            ⚠️ هذا التقييم لأغراض تعليمية فقط
            """
            
            st.download_button(
                "📥 تحميل التقرير", 
                report, 
                file_name=f"prediction_{time.strftime('%Y%m%d_%H%M%S')}.txt",
                width='stretch'
            )
            
            # أزرار الإجراءات بعد التنبؤ
            st.markdown("<div style='margin-top: 24px;'></div>", unsafe_allow_html=True)

            col_action1, col_action2, col_action3 = st.columns(3)

            with col_action1:
                if st.button("🤖 اسأل المساعد الذكي", width='stretch'):
                    st.session_state.current_page = "assistant"
                    st.session_state.last_risk = risk_percentage
                    st.session_state.last_features = features
                    save_user_data()
                    st.rerun()

            with col_action2:
                if st.button("📊 عرض السجل", width='stretch'):
                    st.session_state.current_page = "history"
                    save_user_data()
                    st.rerun()

            with col_action3:
                if st.button("💾 حفظ التوقع", width='stretch'):
                    save_user_data()
                    st.toast("✅ تم حفظ التوقع بنجاح", icon="💾")
                    
            # ============================================
            # ⚠️ نظام التنبيهات والتحذيرات
            # ============================================
            
            from utils.alert_system import (
                render_alert_card, 
                render_emergency_alert, 
                render_improvement_alert,
                render_daily_tip,
                render_warning_banner
            )
            
            # عرض قسم التنبيهات
            st.markdown("---")
            st.markdown("<h2 style='text-align: center;'>⚠️ التنبيهات والتوصيات</h2>", unsafe_allow_html=True)
            
            # تنبيه طارئ للحالات الخطيرة (نسبة خطر > 80%)
            render_emergency_alert(risk_percentage)
            
            # بطاقة التنبيه الرئيسية
            top_factors_list = []
            if shap_values:
                sorted_factors = sorted(shap_values.items(), key=lambda x: abs(x[1]), reverse=True)[:5]
                for factor, value in sorted_factors:
                    top_factors_list.append({
                        "name": factor,
                        "impact": "يزيد الخطر" if value > 0 else "يقلل الخطر",
                        "level": "قوي" if abs(value) > 0.5 else "متوسط"
                    })
            
            # إضافة العوامل الإضافية إلى التنبيهات
            if family_history_value == 1:
                top_factors_list.insert(0, {"name": "التاريخ العائلي", "impact": "يزيد الخطر", "level": "متوسط"})
            if smoking_value == 2:
                top_factors_list.insert(0, {"name": "التدخين", "impact": "يزيد الخطر", "level": "متوسط"})
            if hba1c > 6.5:
                top_factors_list.insert(0, {"name": "السكر التراكمي (HbA1c)", "impact": "يزيد الخطر", "level": "قوي"})
            
            render_alert_card(risk_percentage, top_factors=top_factors_list)
            
            # تنبيه التحسن/التدهور
            if len(st.session_state.predictions_history) > 1:
                prev_risk = st.session_state.predictions_history[-2]['risk']
                render_improvement_alert(prev_risk, risk_percentage)
            
            # نصيحة اليوم
            render_daily_tip()
            
            # تحذيرات إضافية حسب العوامل الجديدة
            if hba1c > 6.5:
                render_warning_banner(
                    f"🔴 السكر التراكمي {hba1c}% مرتفع جداً! يرجى مراجعة الطبيب فوراً",
                    type="error"
                )
            elif hba1c > 5.7:
                render_warning_banner(
                    f"🟡 السكر التراكمي {hba1c}% مرتفع قليلاً. ينصح بتحسين النظام الغذائي",
                    type="warning"
                )
            
            if smoking_value == 2:
                render_warning_banner(
                    "🚬 التدخين يزيد من خطر الإصابة بالسكري. يُنصح بالإقلاع عن التدخين",
                    type="warning"
                )
            
            if family_history_value == 1:
                render_warning_banner(
                    "👨‍👩‍👧 التاريخ العائلي يزيد من خطر الإصابة. احرص على الكشف المبكر والفحوصات المنتظمة",
                    type="info"
                )
            
            if physical_activity_value == 0:
                render_warning_banner(
                    "🚶 قلة النشاط البدني تزيد من خطر السكري. حاول ممارسة رياضة 30 دقيقة يومياً",
                    type="warning"
                )
            
            if risk_percentage > 70:
                render_warning_banner(
                    "⚠️ يرجى استشارة الطبيب المختص فوراً لإجراء الفحوصات اللازمة",
                    type="error"
                )
            elif risk_percentage > 50:
                render_warning_banner(
                    "📋 يوصى بمراجعة طبيب الأسرة خلال 3 أشهر لإجراء فحوصات وقائية",
                    type="warning"
                )

        else:
            # حالة قبل التنبؤ
            st.markdown(f"""
            <div style="
                background: linear-gradient(135deg, {colors['surface_container']}, transparent);
                border-radius: 24px;
                padding: 60px 20px;
                text-align: center;
                height: 100%;
                display: flex;
                flex-direction: column;
                justify-content: center;
                align-items: center;
                border: 1px dashed {colors['outline_variant']};
            ">
                <div style="
                    width: 80px;
                    height: 80px;
                    background: {colors['primary']}20;
                    border-radius: 40px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    margin-bottom: 20px;
                ">
                    <span style="font-size: 40px;">🔮</span>
                </div>
                <h3 style="margin-bottom: 8px;">أدخل البيانات للحصول على التقييم</h3>
                <p style="color: {colors['outline']}; font-size: 14px;">
                    املأ النموذج واضغط على زر التنبؤ
                </p>
                <p style="color: {colors['outline']}; font-size: 12px; margin-top: 15px;">
                    💡 يمكنك استخدام الأزرار السريعة أعلاه لتجربة قيم مختلفة
                </p>
            </div>
            """, unsafe_allow_html=True)
    
    # أنيميشن CSS
    st.markdown("""
    <style>
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        @keyframes slideIn {
            from {
                width: 0%;
            }
            to {
                width: var(--width);
            }
        }
        .stButton button {
            transition: all 0.2s ease;
        }
        .stButton button:hover {
            transform: translateY(-2px);
        }
    </style>
    """, unsafe_allow_html=True)
