"""
الصفحة الرئيسية - DiabPredict
نسخة احترافية مع تصميم Bento Grid وتأثيرات حركة - منسقة بالكامل
"""

import streamlit as st
from utils.theme import get_colors, COLORS, get_theme
from components.cards import stat_card, feature_card

def render_header_glass(page_title: str = "الرئيسية"):
    """ترويسة عصرية بتأثير الزجاج"""
    colors = get_colors()
    user_name = st.session_state.get('user_name', 'زائر')
    last_risk = st.session_state.get('last_risk')
    
    # تنسيق نسبة الخطر
    if last_risk is not None:
        if last_risk < 1:
            risk_display = f"{last_risk:.2f}%"
        else:
            risk_display = f"{last_risk:.1f}%"
    else:
        risk_display = "—"
    
    gradient_start = colors['primary']
    gradient_end = colors['secondary']
    
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
                    background: linear-gradient(135deg, {gradient_start}, {gradient_end});
                    border-radius: 12px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                ">
                    <span style="font-size: 24px;">🩺</span>
                </div>
                <div>
                    <h2 style="margin: 0; font-size: 20px; background: linear-gradient(135deg, {gradient_start}, {gradient_end}); -webkit-background-clip: text; -webkit-text-fill-color: transparent;">
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
    """عرض الصفحة الرئيسية"""
    render_header_glass("🏠 الرئيسية")
    colors = get_colors()

    
    # ============================================
    # Hero Section مع تأثير Glassmorphism
    # ============================================
    st.markdown(f"""
    <div style="
        background: linear-gradient(135deg, {colors['primary']} 0%, {colors['secondary']} 100%);
        border-radius: 28px;
        padding: 60px 40px;
        margin-bottom: 48px;
        position: relative;
        overflow: hidden;
        box-shadow: 0 10px 30px rgba(0,0,0,0.1);
    ">
        <div style="
            position: absolute;
            top: -50px;
            left: -50px;
            width: 200px;
            height: 200px;
            background: rgba(255,255,255,0.1);
            border-radius: 50%;
            animation: float 6s ease-in-out infinite;
        "></div>
        <div style="
            position: absolute;
            bottom: -30px;
            right: -30px;
            width: 150px;
            height: 150px;
            background: rgba(255,255,255,0.05);
            border-radius: 50%;
            animation: float 8s ease-in-out infinite reverse;
        "></div>
        <div style="position: relative; z-index: 1; text-align: center;">
            <div style="
                width: 90px;
                height: 90px;
                background: rgba(255,255,255,0.2);
                border-radius: 28px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                margin-bottom: 24px;
                backdrop-filter: blur(10px);
                animation: fadeInUp 0.6s ease;
                box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            ">
                <span style="font-size: 45px;">🩺</span>
            </div>
            <h1 style="color: white; margin-bottom: 16px; font-size: 42px; animation: fadeInUp 0.6s ease 0.1s both; font-weight: 800;">
                نظام ذكي للتنبؤ المبكر بخطر السكري
            </h1>
            <p style="color: rgba(255,255,255,0.95); font-size: 18px; max-width: 650px; margin: 0 auto 32px; animation: fadeInUp 0.6s ease 0.2s both; line-height: 1.6;">
                بتقنيات الذكاء الاصطناعي والتفسير الشفاف لضمان دقة النتائج 
                وفهم مسببات الخطر الشخصية
            </p>
        </div>
    </div>
    
    <style>
        @keyframes float {{
            0%, 100% {{ transform: translateY(0px); }}
            50% {{ transform: translateY(-20px); }}
        }}
        @keyframes fadeInUp {{
            from {{
                opacity: 0;
                transform: translateY(30px);
            }}
            to {{
                opacity: 1;
                transform: translateY(0);
            }}
        }}
    </style>
    """, unsafe_allow_html=True)
    
    # زر التنبؤ الرئيسي - تم التعديل هنا
    col1, col2, col3 = st.columns([1, 2, 1])
    with col2:
        if st.button("🔮 ابدأ التنبؤ الآن", use_container_width=True, type="primary"):
            st.session_state.current_page = "predict"
            st.rerun()
    
    # ============================================
    # إحصائيات عالمية - داخل بطاقات منسقة
    # ============================================
    st.markdown(f"""
    <div style="text-align: center; margin: 60px 0 30px 0;">
        <h2 style="font-size: 32px; font-weight: 700; color: {colors['on_background']}; margin-bottom: 10px;">
            📊 إحصائيات عالمية
        </h2>
        <p style="color: {colors['outline']}; font-size: 16px;">
            أرقام وحقائق عن مرض السكري حول العالم
        </p>
        <div style="width: 80px; height: 4px; background: linear-gradient(90deg, {colors['primary']}, {colors['secondary']}); margin: 15px auto 30px auto; border-radius: 2px;"></div>
    </div>
    """, unsafe_allow_html=True)

    # بطاقات الإحصائيات بشكل منسق
    col1, col2, col3, col4 = st.columns(4)

    with col1:
        st.markdown(f"""
        <div style="
            background: linear-gradient(135deg, {colors['surface_container_lowest']}, {colors['surface_container']});
            border-radius: 24px;
            padding: 25px 15px;
            text-align: center;
            border: 1px solid {colors['outline_variant']};
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
        ">
            <div style="
                width: 55px;
                height: 55px;
                background: {colors['error']}15;
                border-radius: 18px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                margin-bottom: 15px;
            ">
                <span style="font-size: 28px;">👥</span>
            </div>
            <h3 style="
                font-size: 32px;
                font-weight: 800;
                margin: 10px 0 5px 0;
                color: {colors['error']};
            ">537M</h3>
            <p style="
                font-weight: 600;
                margin: 0;
                color: {colors['on_surface']};
                font-size: 15px;
            ">مصاب حالياً</p>
            <p style="
                font-size: 12px;
                color: {colors['outline']};
                margin-top: 5px;
            ">حول العالم</p>
        </div>
        """, unsafe_allow_html=True)

    with col2:
        st.markdown(f"""
        <div style="
            background: linear-gradient(135deg, {colors['surface_container_lowest']}, {colors['surface_container']});
            border-radius: 24px;
            padding: 25px 15px;
            text-align: center;
            border: 1px solid {colors['outline_variant']};
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
        ">
            <div style="
                width: 55px;
                height: 55px;
                background: #f59e0b15;
                border-radius: 18px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                margin-bottom: 15px;
            ">
                <span style="font-size: 28px;">📈</span>
            </div>
            <h3 style="
                font-size: 32px;
                font-weight: 800;
                margin: 10px 0 5px 0;
                color: #f59e0b;
            ">783M</h3>
            <p style="
                font-weight: 600;
                margin: 0;
                color: {colors['on_surface']};
                font-size: 15px;
            ">متوقع بحلول 2045</p>
            <p style="
                font-size: 12px;
                color: {colors['outline']};
                margin-top: 5px;
            ">مصاب متوقع</p>
        </div>
        """, unsafe_allow_html=True)

    with col3:
        st.markdown(f"""
        <div style="
            background: linear-gradient(135deg, {colors['surface_container_lowest']}, {colors['surface_container']});
            border-radius: 24px;
            padding: 25px 15px;
            text-align: center;
            border: 1px solid {colors['outline_variant']};
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
        ">
            <div style="
                width: 55px;
                height: 55px;
                background: {colors['tertiary']}15;
                border-radius: 18px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                margin-bottom: 15px;
            ">
                <span style="font-size: 28px;">✅</span>
            </div>
            <h3 style="
                font-size: 32px;
                font-weight: 800;
                margin: 10px 0 5px 0;
                color: {colors['tertiary']};
            ">80%</h3>
            <p style="
                font-weight: 600;
                margin: 0;
                color: {colors['on_surface']};
                font-size: 15px;
            ">قابلة للوقاية</p>
            <p style="
                font-size: 12px;
                color: {colors['outline']};
                margin-top: 5px;
            ">من الحالات</p>
        </div>
        """, unsafe_allow_html=True)

    with col4:
        st.markdown(f"""
        <div style="
            background: linear-gradient(135deg, {colors['surface_container_lowest']}, {colors['surface_container']});
            border-radius: 24px;
            padding: 25px 15px;
            text-align: center;
            border: 1px solid {colors['outline_variant']};
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
        ">
            <div style="
                width: 55px;
                height: 55px;
                background: {colors['primary']}15;
                border-radius: 18px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                margin-bottom: 15px;
            ">
                <span style="font-size: 28px;">🎯</span>
            </div>
            <h3 style="
                font-size: 32px;
                font-weight: 800;
                margin: 10px 0 5px 0;
                color: {colors['primary']};
            ">94%</h3>
            <p style="
                font-weight: 600;
                margin: 0;
                color: {colors['on_surface']};
                font-size: 15px;
            ">دقة النظام</p>
            <p style="
                font-size: 12px;
                color: {colors['outline']};
                margin-top: 5px;
            ">في التنبؤ</p>
        </div>
        """, unsafe_allow_html=True)
    # ============================================
    # مميزات النظام - تصميم بطاقات احترافي مع أيقونات في المنتصف
    # ============================================
    st.markdown(f"""
    <div style="text-align: center; margin: 60px 0 30px 0;">
        <h2 style="font-size: 32px; font-weight: 700; color: {colors['on_background']}; margin-bottom: 10px;">
            ✨ مميزات النظام
        </h2>
        <p style="color: {colors['outline']}; font-size: 16px;">
            تقنيات متطورة لخدمتك
        </p>
        <div style="width: 80px; height: 4px; background: linear-gradient(90deg, {colors['primary']}, {colors['secondary']}); margin: 15px auto 30px auto; border-radius: 2px;"></div>
    </div>
    """, unsafe_allow_html=True)

    # مميزات النظام - مع أيقونات في المنتصف
    features = [
        {
            "icon": "🧠",
            "title": "محرك XGBoost",
            "desc": "خوارزمية تعلم آلي متقدمة توفر دقة عالية في التنبؤ بناءً على المؤشرات الحيوية",
            "color": colors["primary"]
        },
        {
            "icon": "👁️",
            "title": "تفسيرات SHAP",
            "desc": "شفافية كاملة في النتائج، لمعرفة العوامل الدقيقة المؤثرة على مستوى الخطر لديك",
            "color": colors["secondary"]
        },
        {
            "icon": "💬",
            "title": "مساعد ذكي",
            "desc": "مساعد افتراضي ذكي للإجابة على استفساراتك الصحية وتقديم نصائح مخصصة",
            "color": colors["tertiary"]
        },
        {
            "icon": "🔬",
            "title": "محاكي السيناريوهات",
            "desc": "أداة تفاعلية لاختبار كيف يمكن أن تؤثر تغييرات نمط الحياة على خطر الإصابة",
            "color": colors["primary"]
        },
        {
            "icon": "📱",
            "title": "تطبيق سهل",
            "desc": "تطبيق متكامل لمتابعة صحتك على مدار الساعة من أي مكان وبكل سهولة",
            "color": colors["secondary"]
        },
        {
            "icon": "📊",
            "title": "تتبع زمني",
            "desc": "سجل تاريخي يوضح التطور في مؤشراتك الصحية ومستوى الخطر عبر الزمن",
            "color": colors["tertiary"]
        },
    ]

    # عرض البطاقات في شبكة 3x2 مع أيقونات في المنتصف
    cols = st.columns(3)
    for i, feature in enumerate(features):
        with cols[i % 3]:
            st.markdown(f"""
            <div style="
                background: linear-gradient(135deg, {colors['surface_container_lowest']}, {colors['surface_container']});
                border-radius: 24px;
                padding: 30px 20px;
                margin-bottom: 24px;
                border: 1px solid {colors['outline_variant']};
                transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
                cursor: pointer;
                height: 100%;
                text-align: center;
                box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            ">
                <div style="
                    width: 70px;
                    height: 70px;
                    background: {feature['color']}10;
                    border-radius: 25px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    margin: 0 auto 20px auto;
                ">
                    <span style="font-size: 36px;">{feature['icon']}</span>
                </div>
                <h3 style="
                    font-size: 20px;
                    font-weight: 700;
                    margin-bottom: 12px;
                    color: {feature['color']};
                    text-align: center;
                ">{feature['title']}</h3>
                <p style="
                    font-size: 14px;
                    line-height: 1.6;
                    color: {colors['on_surface_variant']};
                    margin: 0;
                    text-align: center;
                ">{feature['desc']}</p>
            </div>
            """, unsafe_allow_html=True)


    # ============================================
    # كيف يعمل النظام - تصميم أفقى (Horizontal Cards)
    # ============================================
    st.markdown(f"""
    <div style="text-align: center; margin: 60px 0 30px 0;">
        <h2 style="font-size: 32px; font-weight: 700; color: {colors['on_background']}; margin-bottom: 10px;">
            📋 كيف يعمل النظام
        </h2>
        <div style="width: 80px; height: 4px; background: linear-gradient(90deg, {colors['primary']}, {colors['secondary']}); margin: 15px auto 30px auto; border-radius: 2px;"></div>
    </div>
    """, unsafe_allow_html=True)

    # بطاقات أفقية
    steps = [
        {"num": "1", "icon": "📝", "title": "إدخال البيانات", 
        "desc": "أدخل بياناتك الطبية والمؤشرات الحيوية الأساسية في نموذج آمن وسهل الاستخدام"},
        {"num": "2", "icon": "🧠", "title": "تحليل ذكي", 
        "desc": "تقوم خوارزميات الذكاء الاصطناعي بتحليل البيانات بدقة وفائقة السرعة"},
        {"num": "3", "icon": "📋", "title": "احصل على النتائج", 
        "desc": "عرض تقرير مفصل مع مستوى الخطر والتوصيات والحلول المقترحة"}
    ]

    for step in steps:
        st.markdown(f"""
        <div style="
            background: {colors['surface_container_lowest']};
            border-radius: 20px;
            padding: 20px 25px;
            margin-bottom: 20px;
            border: 1px solid {colors['outline_variant']};
            display: flex;
            align-items: center;
            gap: 25px;
            transition: all 0.3s ease;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        ">
            <div style="
                width: 60px;
                height: 60px;
                min-width: 60px;
                background: linear-gradient(135deg, {colors['primary']}, {colors['secondary']});
                border-radius: 18px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 28px;
                color: white;
            ">
                {step['icon']}
            </div>
            <div style="flex: 1;">
                <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 8px;">
                    <div style="
                        width: 28px;
                        height: 28px;
                        background: {colors['primary']}15;
                        color: {colors['primary']};
                        border-radius: 50%;
                        display: inline-flex;
                        align-items: center;
                        justify-content: center;
                        font-weight: 700;
                        font-size: 14px;
                    ">{step['num']}</div>
                    <h3 style="font-size: 20px; margin: 0; font-weight: 700; color: {colors['on_surface']};">{step['title']}</h3>
                </div>
                <p style="font-size: 14px; color: {colors['on_surface_variant']}; margin: 0; line-height: 1.6;">
                    {step['desc']}
                </p>
            </div>
        </div>
        """, unsafe_allow_html=True)


    # ============================================
    # CTA Section - دعوة للعمل
    # ============================================
    st.markdown(f"""
    <div style="
        background: linear-gradient(135deg, {colors['primary']} 0%, {colors['secondary']} 100%);
        border-radius: 28px;
        padding: 60px 40px;
        text-align: center;
        margin-top: 50px;
        margin-bottom: 20px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        position: relative;
        overflow: hidden;
    ">
        <div style="position: relative; z-index: 1;">
            <div style="font-size: 50px; margin-bottom: 15px;">🛡️</div>
            <h2 style="color: white; margin-bottom: 16px; font-size: 34px; font-weight: 800;">
                هل أنت جاهز لتأمين صحتك؟
            </h2>
            <p style="color: rgba(255,255,255,0.95); font-size: 18px; max-width: 550px; margin: 0 auto 35px; line-height: 1.6;">
                خطوة واحدة بسيطة قد تكون الفارق في مسارك الصحي. استخدم تقنياتنا المتطورة للحصول على تقييم دقيق اليوم.
            </p>
        </div>
    </div>
    """, unsafe_allow_html=True)
    
    # زر التقييم الثاني - تم التعديل هنا
    col1, col2, col3 = st.columns([1, 2, 1])
    with col2:
        if st.button("🚀 ابدأ تقييمك الآن", use_container_width=True, type="primary"):
            st.session_state.current_page = "predict"
            st.rerun()
    
    # ============================================
    # شهادات أو ثقة - اختياري
    # ============================================
    st.markdown(f"""
    <div style="text-align: center; margin-top: 40px; padding: 20px;">
        <div style="display: flex; justify-content: center; gap: 30px; flex-wrap: wrap;">
            <span style="color: {colors['outline']}; font-size: 13px;">✓ دقة عالية</span>
            <span style="color: {colors['outline']}; font-size: 13px;">✓ تفسير شفاف</span>
            <span style="color: {colors['outline']}; font-size: 13px;">✓ مجاني للاستخدام</span>
            <span style="color: {colors['outline']}; font-size: 13px;">✓ آمن وخاص</span>
        </div>
    </div>
    """, unsafe_allow_html=True)
