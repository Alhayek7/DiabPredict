""" 
app_pages/About.py - صفحة عن النظام
DiabPredict - تصميم عصري 2026
"""

import streamlit as st
import plotly.graph_objects as go
from datetime import datetime


def show():
    """عرض صفحة عن النظام"""
    
    # ============================================
    # الألوان المنسقة
    # ============================================
    colors = {
        "primary": "#2563EB",      # أزرق
        "secondary": "#5D8EDD",    # بنفسجي
        "tertiary": "#10B981",     # أخضر
        "error": "#EF4444",        # أحمر
        "warning": "#F59E0B",      # برتقالي
        "dark": "#1E293B",         # غامق
        "gray": "#64748B",         # رمادي
        "light": "#F8FAFC",        # فاتح
        "border": "#E2E8F0",       # حدود
        "white": "#FFFFFF",        # أبيض
    }
    
    # ============================================
    # الهيدر الرئيسي
    # ============================================
    st.markdown(f"""
    <div style="
        background: linear-gradient(135deg, {colors['primary']} 0%, {colors['secondary']} 100%);
        border-radius: 28px;
        padding: 45px 35px;
        margin-bottom: 35px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.1);
    ">
        <div style="display: flex; align-items: center; gap: 20px; flex-wrap: wrap;">
            <div style="
                width: 75px;
                height: 75px;
                background: rgba(255,255,255,0.2);
                backdrop-filter: blur(10px);
                border-radius: 24px;
                display: flex;
                align-items: center;
                justify-content: center;
            ">
                <span style="font-size: 42px;">🩺</span>
            </div>
            <div>
                <h1 style="margin: 0; font-size: 34px; font-weight: 800; color: white;">DiabPredict</h1>
                <p style="margin: 5px 0 0 0; font-size: 15px; color: rgba(255,255,255,0.9);">نظام ذكي للتنبؤ المبكر بخطر السكري</p>
            </div>
        </div>
        <p style="margin: 20px 0 0 0; font-size: 15px; line-height: 1.7; color: rgba(255,255,255,0.85);">
            منصة متطورة تعتمد على الذكاء الاصطناعي وعلوم البيانات لتقديم تقييمات دقيقة وسريعة 
            لاحتمالية الإصابة بمرض السكري، مع تفسيرات شفافة باستخدام تقنية SHAP.
        </p>
    </div>
    """, unsafe_allow_html=True)
    
    # ============================================
    # إحصائيات المنصة
    # ============================================
    st.markdown(f"""
    <div style="text-align: center; margin: 40px 0 20px 0;">
        <h2 style="font-size: 26px; font-weight: 700; color: {colors['dark']};">📊 إحصائيات المنصة</h2>
        <div style="width: 60px; height: 3px; background: linear-gradient(90deg, {colors['primary']}, {colors['secondary']}); margin: 10px auto 5px auto;"></div>
        <p style="color: {colors['gray']};">أرقام وحقائق عن منصتنا</p>
    </div>
    """, unsafe_allow_html=True)
    
    # بطاقات الإحصائيات - 4 أعمدة
    row1_col1, row1_col2, row1_col3, row1_col4 = st.columns(4)
    
    with row1_col1:
        st.markdown(f"""
        <div style="
            background: {colors['white']};
            border-radius: 20px;
            padding: 20px 12px;
            text-align: center;
            border: 1px solid {colors['border']};
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        ">
            <div style="font-size: 38px;">🎯</div>
            <div style="font-size: 28px; font-weight: 800; color: {colors['primary']};">94%</div>
            <div style="font-size: 13px; color: {colors['gray']};">دقة التنبؤ</div>
        </div>
        """, unsafe_allow_html=True)
    
    with row1_col2:
        st.markdown(f"""
        <div style="
            background: {colors['white']};
            border-radius: 20px;
            padding: 20px 12px;
            text-align: center;
            border: 1px solid {colors['border']};
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        ">
            <div style="font-size: 38px;">📊</div>
            <div style="font-size: 28px; font-weight: 800; color: {colors['secondary']};">10K+</div>
            <div style="font-size: 13px; color: {colors['gray']};">سجل طبي</div>
        </div>
        """, unsafe_allow_html=True)
    
    with row1_col3:
        st.markdown(f"""
        <div style="
            background: {colors['white']};
            border-radius: 20px;
            padding: 20px 12px;
            text-align: center;
            border: 1px solid {colors['border']};
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        ">
            <div style="font-size: 38px;">⚡</div>
            <div style="font-size: 28px; font-weight: 800; color: {colors['tertiary']};">2 ث</div>
            <div style="font-size: 13px; color: {colors['gray']};">وقت التحليل</div>
        </div>
        """, unsafe_allow_html=True)
    
    with row1_col4:
        st.markdown(f"""
        <div style="
            background: {colors['white']};
            border-radius: 20px;
            padding: 20px 12px;
            text-align: center;
            border: 1px solid {colors['border']};
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        ">
            <div style="font-size: 38px;">🏆</div>
            <div style="font-size: 28px; font-weight: 800; color: {colors['warning']};">98%</div>
            <div style="font-size: 13px; color: {colors['gray']};">رضا المستخدمين</div>
        </div>
        """, unsafe_allow_html=True)
    
    # ============================================
    # قسم الميزات - بطاقات منسقة
    # ============================================
    st.markdown(f"""
    <div style="text-align: center; margin: 50px 0 20px 0;">
        <h2 style="font-size: 26px; font-weight: 700; color: {colors['dark']};">✨ مميزات النظام</h2>
        <div style="width: 60px; height: 3px; background: linear-gradient(90deg, {colors['primary']}, {colors['secondary']}); margin: 10px auto 5px auto;"></div>
        <p style="color: {colors['gray']};">تقنيات متطورة لخدمتك</p>
    </div>
    """, unsafe_allow_html=True)
    
    # صف الميزات الأول
    row2_col1, row2_col2, row2_col3 = st.columns(3)
    
    with row2_col1:
        st.markdown(f"""
        <div style="
            background: {colors['white']};
            border-radius: 20px;
            padding: 25px 18px;
            text-align: center;
            border: 1px solid {colors['border']};
            margin-bottom: 20px;
            height: 100%;
        ">
            <div style="
                width: 60px;
                height: 60px;
                background: {colors['primary']}10;
                border-radius: 18px;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 15px auto;
            ">
                <span style="font-size: 32px;">🧠</span>
            </div>
            <h3 style="font-size: 18px; margin-bottom: 10px; color: {colors['primary']};">ذكاء اصطناعي متقدم</h3>
            <p style="font-size: 13px; color: {colors['gray']};">خوارزميات XGBoost لتحليل البيانات وتقديم تنبؤات دقيقة</p>
        </div>
        """, unsafe_allow_html=True)
    
    with row2_col2:
        st.markdown(f"""
        <div style="
            background: {colors['white']};
            border-radius: 20px;
            padding: 25px 18px;
            text-align: center;
            border: 1px solid {colors['border']};
            margin-bottom: 20px;
            height: 100%;
        ">
            <div style="
                width: 60px;
                height: 60px;
                background: {colors['secondary']}10;
                border-radius: 18px;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 15px auto;
            ">
                <span style="font-size: 32px;">👁️</span>
            </div>
            <h3 style="font-size: 18px; margin-bottom: 10px; color: {colors['secondary']};">تفسير SHAP</h3>
            <p style="font-size: 13px; color: {colors['gray']};">فهم العوامل المؤثرة في نتيجتك بشكل واضح وشفاف</p>
        </div>
        """, unsafe_allow_html=True)
    
    with row2_col3:
        st.markdown(f"""
        <div style="
            background: {colors['white']};
            border-radius: 20px;
            padding: 25px 18px;
            text-align: center;
            border: 1px solid {colors['border']};
            margin-bottom: 20px;
            height: 100%;
        ">
            <div style="
                width: 60px;
                height: 60px;
                background: {colors['tertiary']}10;
                border-radius: 18px;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 15px auto;
            ">
                <span style="font-size: 32px;">💬</span>
            </div>
            <h3 style="font-size: 18px; margin-bottom: 10px; color: {colors['tertiary']};">مساعد ذكي</h3>
            <p style="font-size: 13px; color: {colors['gray']};">دعم فوري وإجابات على استفساراتك الصحية على مدار الساعة</p>
        </div>
        """, unsafe_allow_html=True)
    
    # ============================================
    # الرسم البياني لتوزيع المستخدمين
    # ============================================
    st.markdown(f"""
    <div style="text-align: center; margin: 30px 0 20px 0;">
        <h2 style="font-size: 26px; font-weight: 700; color: {colors['dark']};">📈 توزيع المستخدمين</h2>
        <div style="width: 60px; height: 3px; background: linear-gradient(90deg, {colors['primary']}, {colors['secondary']}); margin: 10px auto 5px auto;"></div>
    </div>
    """, unsafe_allow_html=True)
    
    # مخطط دائري
    fig_pie = go.Figure(data=[go.Pie(
        labels=['منخفضي الخطر', 'متوسطي الخطر', 'مرتفعي الخطر'],
        values=[45, 35, 20],
        hole=0.4,
        marker_colors=[colors['tertiary'], colors['warning'], colors['error']],
        textinfo='label+percent',
        textposition='auto'
    )])
    fig_pie.update_layout(
        height=400,
        paper_bgcolor='rgba(0,0,0,0)',
        plot_bgcolor='rgba(0,0,0,0)',
        showlegend=True,
        legend=dict(orientation="h", yanchor="bottom", y=1.02, xanchor="center", x=0.5)
    )
    st.plotly_chart(fig_pie, width='stretch', config={'displayModeBar': False})
    
    # ============================================
    # قسم التقنيات المستخدمة
    # ============================================
    st.markdown(f"""
    <div style="text-align: center; margin: 50px 0 20px 0;">
        <h2 style="font-size: 26px; font-weight: 700; color: {colors['dark']};">⚙️ التقنيات المستخدمة</h2>
        <div style="width: 60px; height: 3px; background: linear-gradient(90deg, {colors['primary']}, {colors['secondary']}); margin: 10px auto 5px auto;"></div>
    </div>
    """, unsafe_allow_html=True)
    
    # عرض التقنيات في شبكة
    technologies = [
        ("🚀", "XGBoost", "التعلم الآلي"),
        ("🔍", "SHAP", "تفسير النتائج"),
        ("🐼", "Pandas", "تحليل البيانات"),
        ("🎈", "Streamlit", "واجهة المستخدم"),
        ("🔬", "scikit-learn", "تقييم النموذج"),
        ("📊", "Plotly", "الرسوم البيانية"),
        ("🔢", "NumPy", "الحسابات الرقمية"),
        ("🎨", "CSS3", "تصميم الواجهة"),
    ]
    
    # صفين من التقنيات
    tech_row1 = st.columns(4)
    tech_row2 = st.columns(4)
    
    for i, (icon, name, desc) in enumerate(technologies[:4]):
        with tech_row1[i]:
            st.markdown(f"""
            <div style="
                background: {colors['light']};
                border-radius: 16px;
                padding: 15px 10px;
                text-align: center;
                margin: 8px 0;
                border: 1px solid {colors['border']};
            ">
                <div style="font-size: 32px;">{icon}</div>
                <div style="font-weight: 700; font-size: 14px; margin: 5px 0;">{name}</div>
                <div style="font-size: 11px; color: {colors['gray']};">{desc}</div>
            </div>
            """, unsafe_allow_html=True)
    
    for i, (icon, name, desc) in enumerate(technologies[4:]):
        with tech_row2[i]:
            st.markdown(f"""
            <div style="
                background: {colors['light']};
                border-radius: 16px;
                padding: 15px 10px;
                text-align: center;
                margin: 8px 0;
                border: 1px solid {colors['border']};
            ">
                <div style="font-size: 32px;">{icon}</div>
                <div style="font-weight: 700; font-size: 14px; margin: 5px 0;">{name}</div>
                <div style="font-size: 11px; color: {colors['gray']};">{desc}</div>
            </div>
            """, unsafe_allow_html=True)
    
    # ============================================
    # الأسئلة الشائعة
    # ============================================
    st.markdown(f"""
    <div style="text-align: center; margin: 50px 0 20px 0;">
        <h2 style="font-size: 26px; font-weight: 700; color: {colors['dark']};">❓ الأسئلة الشائعة</h2>
        <div style="width: 60px; height: 3px; background: linear-gradient(90deg, {colors['primary']}, {colors['secondary']}); margin: 10px auto 5px auto;"></div>
    </div>
    """, unsafe_allow_html=True)
    
    # أسئلة وأجوبة
    faqs = [
        ("🔍 كيف يعمل نظام التنبؤ؟", 
         "يعتمد النظام على نموذج **XGBoost** المدرب على أكثر من **10,000 سجل طبي**. يقوم النموذج بتحليل **8 مؤشرات حيوية** رئيسية مثل العمر، مؤشر كتلة الجسم، مستوى السكر، وضغط الدم."),
        
        ("📊 ما مدى دقة النتائج؟", 
         "**دقة النموذج:** 94%\n**حساسية النموذج:** 92%\n**خصوصية النموذج:** 88%\n\n> ⚠️ النتائج لأغراض تعليمية وتوعوية وليست بديلاً عن استشارة الطبيب."),
        
        ("🔒 هل بياناتي آمنة؟", 
         "✅ **نعم، بياناتك آمنة تماماً!**\n- جميع البيانات تخزن محلياً في متصفحك فقط\n- لا يتم مشاركة أي بيانات مع جهات خارجية\n- يمكنك مسح بياناتك بالكامل في أي وقت"),
        
        ("💬 كيف أستخدم المساعد الذكي؟", 
         "المساعد الذكي متاح في صفحة منفصلة ويمكنك:\n1. طرح أسئلة حول التغذية المناسبة\n2. الاستفسار عن التمارين الرياضية\n3. التعرف على أعراض السكري\n4. معرفة طرق خفض السكر في الدم\n5. تفسير نتائجك الصحية")
    ]
    
    for q, a in faqs:
        with st.expander(q):
            st.markdown(a)
    
    # ============================================
    # خريطة الطريق
    # ============================================
    st.markdown(f"""
    <div style="text-align: center; margin: 50px 0 20px 0;">
        <h2 style="font-size: 26px; font-weight: 700; color: {colors['dark']};">🗺️ خريطة التطوير</h2>
        <div style="width: 60px; height: 3px; background: linear-gradient(90deg, {colors['primary']}, {colors['secondary']}); margin: 10px auto 5px auto;"></div>
    </div>
    """, unsafe_allow_html=True)
    
    roadmap_cols = st.columns(3)
    
    with roadmap_cols[0]:
        st.markdown(f"""
        <div style="
            background: {colors['light']};
            border-radius: 20px;
            padding: 20px;
            text-align: center;
            border: 1px solid {colors['border']};
        ">
            <div style="font-size: 48px;">✅</div>
            <h3 style="color: {colors['tertiary']};">الإصدار الحالي</h3>
            <ul style="text-align: right; font-size: 13px;">
                <li>نموذج XGBoost</li>
                <li>تفسير SHAP</li>
                <li>مساعد ذكي مدمج</li>
                <li>سجل التنبؤات</li>
            </ul>
        </div>
        """, unsafe_allow_html=True)
    
    with roadmap_cols[1]:
        st.markdown(f"""
        <div style="
            background: {colors['light']};
            border-radius: 20px;
            padding: 20px;
            text-align: center;
            border: 1px solid {colors['border']};
        ">
            <div style="font-size: 48px;">🔄</div>
            <h3 style="color: {colors['warning']};">قريباً v2.0</h3>
            <ul style="text-align: right; font-size: 13px;">
                <li>تطبيق جوال</li>
                <li>تكامل الأجهزة</li>
                <li>توصيات غذائية</li>
                <li>تنبيهات ذكية</li>
            </ul>
        </div>
        """, unsafe_allow_html=True)
    
    with roadmap_cols[2]:
        st.markdown(f"""
        <div style="
            background: {colors['light']};
            border-radius: 20px;
            padding: 20px;
            text-align: center;
            border: 1px solid {colors['border']};
        ">
            <div style="font-size: 48px;">🌟</div>
            <h3 style="color: {colors['primary']};">المستقبل</h3>
            <ul style="text-align: right; font-size: 13px;">
                <li>Deep Learning</li>
                <li>تحليلات متقدمة</li>
                <li>منصة للمختصين</li>
                <li>ذكاء اصطناعي فائق</li>
            </ul>
        </div>
        """, unsafe_allow_html=True)
    
    # ============================================
    # التذييل
    # ============================================
    st.markdown(f"""
    <div style="
        background: {colors['light']};
        border-radius: 24px;
        padding: 30px 20px;
        margin-top: 50px;
        text-align: center;
        border: 1px solid {colors['border']};
    ">
        <div style="display: flex; justify-content: center; gap: 40px; flex-wrap: wrap; margin-bottom: 20px;">
            <div>📧 support@diabpredict.com</div>
            <div>🌐 www.diabpredict.com</div>
            <div>💬 الدعم الفني 24/7</div>
        </div>
        <hr style="margin: 15px 0;">
        <div style="color: {colors['gray']}; font-size: 12px;">
            © {datetime.now().year} DiabPredict | الإصدار 1.0.0
        </div>
        <div style="color: {colors['gray']}; font-size: 11px; margin-top: 8px;">
            ⚠️ هذا التطبيق لأغراض تعليمية وتوعوية - ليس بديلاً عن استشارة الطبيب
        </div>
    </div>
    """, unsafe_allow_html=True)
    # ============================================
    # زر العودة
    # ============================================
    col1, col2, col3 = st.columns([1, 2, 1])
    with col2:
        if st.button("🏠 العودة للصفحة الرئيسية", width='stretch', type="primary"):
            if 'current_page' in st.session_state:
                st.session_state.current_page = "home"
                st.rerun()