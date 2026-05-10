
# 3. components/sidebar.py - الشريط الجانبي

sidebar_code = """
الشريط الجانبي - DiabPredict
"""

import streamlit as st
from utils.theme import COLORS

def render_sidebar():
    """عرض الشريط الجانبي"""
    
    with st.sidebar:
        # الشعار
        st.markdown(f"""
        <div style="
            text-align: center;
            padding: 20px 0;
            border-bottom: 1px solid {COLORS['surface_container']};
            margin-bottom: 20px;
        ">
            <div style="
                width: 50px;
                height: 50px;
                background: linear-gradient(135deg, {COLORS['primary']} 0%, {COLORS['secondary']} 100%);
                border-radius: 12px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                margin-bottom: 12px;
            ">
                <span style="color: white; font-size: 24px; font-weight: bold;">DP</span>
            </div>
            <h2 style="
                margin: 0;
                font-size: 24px;
                background: linear-gradient(135deg, {COLORS['primary']} 0%, {COLORS['secondary']} 100%);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
                font-weight: 700;
            ">DiabPredict</h2>
            <p style="
                margin: 4px 0 0 0;
                color: {COLORS['outline']};
                font-size: 14px;
            ">نظام التنبؤ بالسكري</p>
        </div>
        """, unsafe_allow_html=True)
        
        # قائمة التنقل
        pages = [
            ("🏠", "الرئيسية", ""),
            ("🔮", "التنبؤ", "predict"),
            ("🤖", "المساعد الذكي", "assistant"),
            ("📊", "السجل", "history"),
            ("ℹ️", "عن النظام", "about"),
        ]
        
        # تحديد الصفحة الحالية
        current_page = st.session_state.get("current_page", "")
        
        for icon, label, page in pages:
            is_active = current_page == page
            
            bg_color = COLORS["surface_container"] if is_active else "transparent"
            text_color = COLORS["primary"] if is_active else COLORS["on_surface_variant"]
            border_right = f"4px solid {COLORS['primary']}" if is_active else "4px solid transparent"
            font_weight = "700" if is_active else "500"
            
            st.markdown(f"""
            <a href="/{page}" style="
                display: flex;
                align-items: center;
                gap: 12px;
                padding: 12px 16px;
                margin: 4px 0;
                border-radius: 12px;
                background-color: {bg_color};
                color: {text_color};
                text-decoration: none;
                border-right: {border_right};
                font-weight: {font_weight};
                transition: all 0.2s ease;
                direction: rtl;
                text-align: right;
            " onmouseover="this.style.backgroundColor='{COLORS['surface_container']}'" 
               onmouseout="this.style.backgroundColor='{bg_color}'">
                <span style="font-size: 20px;">{icon}</span>
                <span style="font-size: 16px;">{label}</span>
            </a>
            """, unsafe_allow_html=True)
        
        # زر الدعم
        st.markdown("<div style='margin-top: 40px;'></div>", unsafe_allow_html=True)
        
        st.markdown(f"""
        <div style="
            padding: 16px;
            background-color: {COLORS['surface_container']};
            border-radius: 12px;
            text-align: center;
        ">
            <p style="
                margin: 0 0 12px 0;
                color: {COLORS['on_surface_variant']};
                font-size: 14px;
            ">هل تحتاج مساعدة؟</p>
            <button style="
                width: 100%;
                padding: 10px;
                background-color: {COLORS['surface_container_high']};
                color: {COLORS['primary']};
                border: none;
                border-radius: 12px;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.2s ease;
            ">📞 اتصل بالدعم</button>
        </div>
        """, unsafe_allow_html=True)
        
        # معلومات المستخدم
        st.markdown("<div style='margin-top: 20px;'></div>", unsafe_allow_html=True)
        
        st.markdown(f"""
        <div style="
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px;
            border-top: 1px solid {COLORS['surface_container']};
        ">
            <div style="
                width: 40px;
                height: 40px;
                border-radius: 50%;
                background: linear-gradient(135deg, {COLORS['primary']} 0%, {COLORS['secondary']} 100%);
                display: flex;
                align-items: center;
                justify-content: center;
                color: white;
                font-weight: 600;
            ">أم</div>
            <div>
                <p style="margin: 0; font-weight: 600; color: {COLORS['on_surface']};">أحمد محمد</p>
                <p style="margin: 0; font-size: 12px; color: {COLORS['outline']};">مستخدم</p>
            </div>
        </div>
        """, unsafe_allow_html=True)
