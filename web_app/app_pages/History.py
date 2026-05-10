"""
pages/4_History.py - صفحة السجل والتاريخ
DiabPredict - نظام ذكي للتنبؤ المبكر بخطر السكري
نسخة احترافية متكاملة مع فلاتر، رسوم بيانية، وتحليلات متقدمة
"""

import streamlit as st
import pandas as pd
import plotly.graph_objects as go
import plotly.express as px
from datetime import datetime, timedelta
from utils.theme import get_colors, get_theme
from utils.storage import save_user_data

def render_header_glass(page_title: str = "السجل"):
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
    render_header_glass("📊 السجل")
    """عرض صفحة السجل والتاريخ المحسنة"""
    
    colors = get_colors()
    is_dark = get_theme() == "dark"
    history = st.session_state.get('predictions_history', [])
    
    # ============================================
    # عنوان الصفحة مع تأثير بصري
    # ============================================
    st.markdown(f"""
    <div style="margin-bottom: 32px;">
        <h1 style="
            background: linear-gradient(135deg, {colors['primary']}, {colors['secondary']}); 
            -webkit-background-clip: text; 
            -webkit-text-fill-color: transparent;
            margin-bottom: 8px;
            font-size: 36px;
        ">
            📊 السجل الصحي
        </h1>
        <p style="color: {colors['outline']}; font-size: 16px;">
            تتبع تطور نسبة الخطر عبر الزمن وتحليل اتجاهات صحتك
        </p>
    </div>
    """, unsafe_allow_html=True)
    
    # ============================================
    # التحقق من وجود بيانات
    # ============================================
    if not history:
        st.info("📭 لا توجد تنبؤات مسجلة بعد. قم بزيارة صفحة التنبؤ لإجراء أول تقييم لك.")
        
        col1, col2, col3 = st.columns([1, 2, 1])
        with col2:
            if st.button("🔮 ابدأ التنبؤ الآن", width='stretch', type="primary"):
                st.session_state.current_page = "predict"
                st.rerun()
        return
    
    # ============================================
    # تحويل البيانات إلى DataFrame
    # ============================================
    df = pd.DataFrame(history)
    
    # معالجة التواريخ
    if 'date' in df.columns:
        df['date'] = pd.to_datetime(df['date'])
    else:
        df['date'] = pd.date_range(end=datetime.now(), periods=len(df), freq='D')
    
    df = df.sort_values('date', ascending=False)
    df['risk'] = df['risk'].astype(float)
    
    # إضافة عمود مستوى الخطر النصي
    def get_risk_text(risk):
        if risk < 30:
            return "منخفض"
        elif risk < 70:
            return "متوسط"
        else:
            return "مرتفع"
    
    df['risk_text'] = df['risk'].apply(get_risk_text)
    df['risk_color'] = df['risk'].apply(lambda x: colors['tertiary'] if x < 30 else ('#f59e0b' if x < 70 else colors['error']))
    
    # ============================================
    # فلاتر البحث والتصفية (جديدة)
    # ============================================
    st.markdown("### 🔍 تصفية البيانات")
    
    col_filter1, col_filter2, col_filter3, col_filter4 = st.columns(4)
    
    with col_filter1:
        risk_filter = st.selectbox("🎯 مستوى الخطر", ["الكل", "منخفض", "متوسط", "مرتفع"])
    
    with col_filter2:
        date_filter = st.selectbox("📅 الفترة", ["الكل", "آخر 7 أيام", "آخر 30 يوم", "آخر 3 أشهر", "آخر سنة"])
    
    with col_filter3:
        sort_by = st.selectbox("📊 ترتيب حسب", ["الأحدث أولاً", "الأقدم أولاً", "أعلى خطر", "أقل خطر"])
    
    with col_filter4:
        search_term = st.text_input("🔎 بحث", placeholder="ابحث في السجل...")
    
    # ============================================
    # تطبيق الفلاتر
    # ============================================
    filtered_df = df.copy()
    
    # فلتر مستوى الخطر
    if risk_filter != "الكل":
        filtered_df = filtered_df[filtered_df['risk_text'] == risk_filter]
    
    # فلتر التاريخ
    if date_filter != "الكل":
        today = datetime.now()
        if date_filter == "آخر 7 أيام":
            start_date = today - timedelta(days=7)
        elif date_filter == "آخر 30 يوم":
            start_date = today - timedelta(days=30)
        elif date_filter == "آخر 3 أشهر":
            start_date = today - timedelta(days=90)
        elif date_filter == "آخر سنة":
            start_date = today - timedelta(days=365)
        filtered_df = filtered_df[filtered_df['date'] >= start_date]
    
    # فلتر البحث
    if search_term:
        filtered_df = filtered_df[filtered_df['risk_text'].str.contains(search_term, na=False) | 
                                   filtered_df['date'].astype(str).str.contains(search_term, na=False)]
    
    # ترتيب البيانات
    if sort_by == "الأحدث أولاً":
        filtered_df = filtered_df.sort_values('date', ascending=False)
    elif sort_by == "الأقدم أولاً":
        filtered_df = filtered_df.sort_values('date', ascending=True)
    elif sort_by == "أعلى خطر":
        filtered_df = filtered_df.sort_values('risk', ascending=False)
    elif sort_by == "أقل خطر":
        filtered_df = filtered_df.sort_values('risk', ascending=True)
    
    # عرض عدد النتائج
    st.caption(f"📊 عرض {len(filtered_df)} من {len(df)} تنبؤ")
    
    # ============================================
    # بطاقات الإحصائيات المتقدمة مع تحسينات
    # ============================================
    st.markdown("### 📈 نظرة عامة")
    
    col1, col2, col3, col4, col5, col6 = st.columns(6)
    
    with col1:
        total_predictions = len(df)
        st.markdown(f"""
        <div style="background: linear-gradient(135deg, {colors['surface_container_lowest']}, {colors['surface_container']}); border-radius: 16px; padding: 15px; text-align: center; border: 1px solid {colors['outline_variant']};">
            <div style="font-size: 24px; margin-bottom: 5px;">📝</div>
            <div style="font-size: 24px; font-weight: 700; color: {colors['primary']};">{total_predictions}</div>
            <div style="font-size: 11px; color: {colors['outline']};">إجمالي التنبؤات</div>
        </div>
        """, unsafe_allow_html=True)
    
    with col2:
        avg_risk = df['risk'].mean()
        risk_color = colors['error'] if avg_risk > 70 else (colors['tertiary'] if avg_risk < 30 else "#f59e0b")
        st.markdown(f"""
        <div style="background: linear-gradient(135deg, {colors['surface_container_lowest']}, {colors['surface_container']}); border-radius: 16px; padding: 15px; text-align: center; border: 1px solid {colors['outline_variant']};">
            <div style="font-size: 24px; margin-bottom: 5px;">📊</div>
            <div style="font-size: 24px; font-weight: 700; color: {risk_color};">{avg_risk:.0f}<span style="font-size: 14px;">%</span></div>
            <div style="font-size: 11px; color: {colors['outline']};">متوسط الخطر</div>
        </div>
        """, unsafe_allow_html=True)
    
    with col3:
        if len(df) >= 2:
            change = df.iloc[0]['risk'] - df.iloc[1]['risk']
            change_text = f"{change:+.0f}%"
            change_color = colors['tertiary'] if change < 0 else (colors['error'] if change > 0 else colors['outline'])
            change_icon = "📉" if change < 0 else "📈" if change > 0 else "➡️"
        else:
            change_text, change_color, change_icon = "أول تنبؤ", colors['primary'], "🆕"
        st.markdown(f"""
        <div style="background: linear-gradient(135deg, {colors['surface_container_lowest']}, {colors['surface_container']}); border-radius: 16px; padding: 15px; text-align: center; border: 1px solid {colors['outline_variant']};">
            <div style="font-size: 24px; margin-bottom: 5px;">{change_icon}</div>
            <div style="font-size: 24px; font-weight: 700; color: {change_color};">{change_text}</div>
            <div style="font-size: 11px; color: {colors['outline']};">آخر تغيير</div>
        </div>
        """, unsafe_allow_html=True)
    
    with col4:
        best_risk = df['risk'].min()
        st.markdown(f"""
        <div style="background: linear-gradient(135deg, {colors['surface_container_lowest']}, {colors['surface_container']}); border-radius: 16px; padding: 15px; text-align: center; border: 1px solid {colors['outline_variant']};">
            <div style="font-size: 24px; margin-bottom: 5px;">🏆</div>
            <div style="font-size: 24px; font-weight: 700; color: {colors['tertiary']};">{best_risk:.0f}<span style="font-size: 14px;">%</span></div>
            <div style="font-size: 11px; color: {colors['outline']};">أفضل نتيجة</div>
        </div>
        """, unsafe_allow_html=True)
    
    with col5:
        high_risk = len(df[df['risk'] >= 70])
        st.markdown(f"""
        <div style="background: linear-gradient(135deg, {colors['surface_container_lowest']}, {colors['surface_container']}); border-radius: 16px; padding: 15px; text-align: center; border: 1px solid {colors['outline_variant']};">
            <div style="font-size: 24px; margin-bottom: 5px;">⚠️</div>
            <div style="font-size: 24px; font-weight: 700; color: {colors['error']};">{high_risk}</div>
            <div style="font-size: 11px; color: {colors['outline']};">خطر مرتفع</div>
        </div>
        """, unsafe_allow_html=True)
    
    with col6:
        low_risk = len(df[df['risk'] < 30])
        st.markdown(f"""
        <div style="background: linear-gradient(135deg, {colors['surface_container_lowest']}, {colors['surface_container']}); border-radius: 16px; padding: 15px; text-align: center; border: 1px solid {colors['outline_variant']};">
            <div style="font-size: 24px; margin-bottom: 5px;">✅</div>
            <div style="font-size: 24px; font-weight: 700; color: {colors['tertiary']};">{low_risk}</div>
            <div style="font-size: 11px; color: {colors['outline']};">خطر منخفض</div>
        </div>
        """, unsafe_allow_html=True)
    
    # ============================================
    # رسم بياني لتطور التحسن (جديد)
    # ============================================
    if len(df) >= 2:
        improvement = df.iloc[0]['risk'] - df.iloc[-1]['risk']
        st.markdown(f"""
        <div style="background: {colors['surface_container']}; border-radius: 16px; padding: 15px; text-align: center; margin: 20px 0;">
            <div style="font-size: 14px; margin-bottom: 5px;">📈 التحسن الإجمالي</div>
            <div style="font-size: 28px; font-weight: 700; color: {colors['tertiary'] if improvement < 0 else colors['error']};">
                {improvement:+.1f}%
            </div>
            <div style="font-size: 12px; color: {colors['outline']};">من أول تنبؤ إلى آخر تنبؤ</div>
        </div>
        """, unsafe_allow_html=True)
    
    # ============================================
    # رسمين بيانيين: Line Chart + Bar Chart
    # ============================================
    st.markdown("### 📈 تطور نسبة الخطر")
    
    col_chart1, col_chart2 = st.columns(2)
    
    with col_chart1:
        # Line Chart
        fig_line = go.Figure()
        fig_line.add_trace(go.Scatter(
            x=filtered_df['date'],
            y=filtered_df['risk'],
            mode='lines+markers',
            name='نسبة الخطر',
            line=dict(color=colors['primary'], width=3),
            marker=dict(size=8, color=filtered_df['risk'], colorscale='RdYlGn_r', showscale=True),
            hovertemplate='<b>%{x|%Y-%m-%d}</b><br>الخطر: %{y:.1f}%<extra></extra>'
        ))
        fig_line.add_hrect(y0=70, y1=100, line_width=0, fillcolor="red", opacity=0.1, annotation_text="خطر مرتفع")
        fig_line.add_hrect(y0=30, y1=70, line_width=0, fillcolor="orange", opacity=0.1, annotation_text="خطر متوسط")
        fig_line.add_hrect(y0=0, y1=30, line_width=0, fillcolor="green", opacity=0.1, annotation_text="خطر منخفض")
        fig_line.update_layout(height=350, template='plotly_white', title="📊 رسم بياني خطي")
        st.plotly_chart(fig_line, width='stretch', config={'displayModeBar': False})
    
    with col_chart2:
        # Bar Chart لآخر 10 تنبؤات
        top10 = filtered_df.head(10).copy()
        fig_bar = px.bar(
            top10,
            x='date',
            y='risk',
            color='risk_text',
            color_discrete_map={'منخفض': colors['tertiary'], 'متوسط': '#f59e0b', 'مرتفع': colors['error']},
            title="📊 آخر 10 تنبؤات",
            labels={'date': 'التاريخ', 'risk': 'نسبة الخطر (%)', 'risk_text': 'المستوى'}
        )
        fig_bar.update_layout(height=350, template='plotly_white')
        st.plotly_chart(fig_bar, width='stretch', config={'displayModeBar': False})
    
    # ============================================
    # تنبيه التدهور المستمر (جديد)
    # ============================================
    if len(df) >= 3:
        last_3 = df.head(3)['risk'].tolist()
        if last_3[0] > last_3[1] > last_3[2]:
            st.error("🔴 **تنبيه:** نسبة الخطر في تدهور مستمر في آخر 3 تنبؤات! يُنصح بمراجعة الطبيب فوراً")
        elif last_3[0] < last_3[1] < last_3[2]:
            st.success("🟢 **ممتاز:** نسبة الخطر في تحسن مستمر! استمر في نمط حياتك الصحي")
    
    # ============================================
    # تحليل الاتجاهات والتوزيع
    # ============================================
    st.markdown("### 📊 تحليلات متقدمة")
    
    col_analysis1, col_analysis2 = st.columns(2)
    
    with col_analysis1:
        st.markdown(f"<div style='background: {colors['surface_container']}; border-radius: 16px; padding: 20px; height: 100%;'><h4>📈 تحليل الاتجاه</h4>", unsafe_allow_html=True)
        
        if len(filtered_df) >= 3:
            recent = filtered_df.head(3)['risk'].mean()
            older = filtered_df.tail(3)['risk'].mean()
            trend = recent - older
            
            if trend < -10:
                trend_text, trend_color, trend_advice = "تحسن كبير 📉", colors['tertiary'], "ممتاز! استمر"
            elif trend < -5:
                trend_text, trend_color, trend_advice = "تحسن ملحوظ 📉", colors['tertiary'], "جيد جداً! واصل"
            elif trend < 0:
                trend_text, trend_color, trend_advice = "تحسن طفيف 📉", colors['tertiary'], "أحسنت! استمر"
            elif trend > 10:
                trend_text, trend_color, trend_advice = "تدهور كبير 📈", colors['error'], "راجع طبيبك فوراً"
            elif trend > 5:
                trend_text, trend_color, trend_advice = "تدهور ملحوظ 📈", colors['error'], "راجع طبيبك"
            elif trend > 0:
                trend_text, trend_color, trend_advice = "تدهور طفيف 📈", "#f59e0b", "انتبه! حاول التحسين"
            else:
                trend_text, trend_color, trend_advice = "ثبات ➡️", colors['outline'], "استمر في المتابعة"
            
            st.markdown(f"""
            <div style="text-align: center;">
                <div style="font-size: 48px;">{trend_text.split()[0]}</div>
                <div style="font-size: 18px; font-weight: 700; color: {trend_color};">{trend_text}</div>
                <div style="font-size: 13px; color: {colors['outline']};">التغيير: {trend:+.1f}%</div>
                <div style="font-size: 12px; margin-top: 12px; padding: 8px; background: {colors['surface_container_low']}; border-radius: 8px;">💡 {trend_advice}</div>
            </div>
            """, unsafe_allow_html=True)
        else:
            st.info("📊 يلزم 3 تنبؤات على الأقل لتحليل الاتجاه")
        
        st.markdown("</div>", unsafe_allow_html=True)
    
    with col_analysis2:
        st.markdown(f"<div style='background: {colors['surface_container']}; border-radius: 16px; padding: 20px; height: 100%;'><h4>🎯 توزيع المستويات</h4>", unsafe_allow_html=True)
        
        low_count = len(filtered_df[filtered_df['risk'] < 30])
        medium_count = len(filtered_df[(filtered_df['risk'] >= 30) & (filtered_df['risk'] < 70)])
        high_count = len(filtered_df[filtered_df['risk'] >= 70])
        
        fig_pie = go.Figure(data=[go.Pie(
            labels=['🟢 منخفض', '🟠 متوسط', '🔴 مرتفع'],
            values=[low_count, medium_count, high_count],
            marker_colors=[colors['tertiary'], '#f59e0b', colors['error']],
            hole=0.4, textinfo='percent+label', textfont_size=12
        )])
        fig_pie.update_layout(height=280, margin=dict(t=0, b=0, l=0, r=0), paper_bgcolor='rgba(0,0,0,0)', showlegend=False)
        st.plotly_chart(fig_pie, width='stretch', config={'displayModeBar': False})
        st.markdown("</div>", unsafe_allow_html=True)
    
    # ============================================
    # جدول التنبؤات المحسن مع تفاصيل
    # ============================================
    st.markdown("### 📋 سجل التنبؤات التفصيلي")
    
    col_btn1, col_btn2, col_btn3, col_btn4 = st.columns([1, 1, 1, 2])
    
    with col_btn1:
        export_df = filtered_df[['date', 'risk', 'risk_text']].copy()
        export_df['date'] = export_df['date'].dt.strftime('%Y-%m-%d %H:%M:%S')
        export_df.columns = ['التاريخ', 'نسبة الخطر', 'المستوى']
        csv = export_df.to_csv(index=False).encode('utf-8-sig')
        st.download_button("📥 تصدير CSV", csv, file_name=f"history_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv", mime="text/csv", width='stretch')
    
    with col_btn2:
        if st.button("🔄 تحديث البيانات", width='stretch'):
            st.rerun()
    
    with col_btn3:
        if st.button("🗑️ مسح السجل", width='stretch'):
            st.session_state.predictions_history = []
            save_user_data()
            st.rerun()
    
    with col_btn4:
        st.markdown("")
    
    # عرض الجدول
    display_df = filtered_df[['date', 'risk', 'risk_text']].head(50).copy()
    display_df['date'] = display_df['date'].dt.strftime('%Y-%m-%d %H:%M')
    display_df['risk'] = display_df['risk'].apply(lambda x: f"{x:.1f}%")
    display_df.columns = ['📅 التاريخ', '📊 نسبة الخطر', '🎯 المستوى']
    
    # تلوين الصفوف حسب المستوى
    def color_risk_row(row):
        if 'منخفض' in str(row['🎯 المستوى']):
            return ['background-color: #10b98120'] * len(row)
        elif 'متوسط' in str(row['🎯 المستوى']):
            return ['background-color: #f59e0b20'] * len(row)
        elif 'مرتفع' in str(row['🎯 المستوى']):
            return ['background-color: #ef444420'] * len(row)
        return [''] * len(row)
    
    styled_df = display_df.style.apply(color_risk_row, axis=1)
    st.dataframe(styled_df, width='stretch', hide_index=True, height=400)
    
    # ============================================
    # أفضل وأسوأ النتائج
    # ============================================
    if len(filtered_df) >= 2:
        st.markdown("### ⭐ أبرز النتائج")
        col_best, col_worst = st.columns(2)
        
        best_record = filtered_df.loc[filtered_df['risk'].idxmin()]
        worst_record = filtered_df.loc[filtered_df['risk'].idxmax()]
        
        with col_best:
            st.markdown(f"""
            <div style="background: linear-gradient(135deg, {colors['tertiary']}10, transparent); border-radius: 16px; padding: 16px; border-right: 4px solid {colors['tertiary']};">
                <div style="display: flex; align-items: center; gap: 12px;">
                    <div style="font-size: 32px;">🏆</div>
                    <div>
                        <div style="font-size: 12px; color: {colors['outline']};">أفضل نتيجة</div>
                        <div style="font-size: 18px; font-weight: 700; color: {colors['tertiary']};">{best_record['risk']:.1f}%</div>
                        <div style="font-size: 12px; color: {colors['outline']};">{best_record['date'].strftime('%Y-%m-%d %H:%M')}</div>
                    </div>
                </div>
            </div>
            """, unsafe_allow_html=True)
        
        with col_worst:
            st.markdown(f"""
            <div style="background: linear-gradient(135deg, {colors['error']}10, transparent); border-radius: 16px; padding: 16px; border-right: 4px solid {colors['error']};">
                <div style="display: flex; align-items: center; gap: 12px;">
                    <div style="font-size: 32px;">⚠️</div>
                    <div>
                        <div style="font-size: 12px; color: {colors['outline']};">أسوأ نتيجة</div>
                        <div style="font-size: 18px; font-weight: 700; color: {colors['error']};">{worst_record['risk']:.1f}%</div>
                        <div style="font-size: 12px; color: {colors['outline']};">{worst_record['date'].strftime('%Y-%m-%d %H:%M')}</div>
                    </div>
                </div>
            </div>
            """, unsafe_allow_html=True)
    
    # ============================================
    # نصائح مخصصة
    # ============================================
    if len(filtered_df) >= 2:
        st.markdown("### 💡 توصيات مخصصة")
        latest = filtered_df.iloc[0]['risk']
        previous = filtered_df.iloc[1]['risk'] if len(filtered_df) > 1 else latest
        
        if latest < previous:
            st.success("🎉 **تهانينا! نسبة الخطر في تحسن مستمر!**\n\n- ✅ استمر في اتباع نمط الحياة الصحي\n- 🏃 حافظ على النشاط البدني المنتظم\n- 🥗 تابع نظامك الغذائي المتوازن\n- 📅 استمر في الفحوصات الدورية")
        elif latest > previous:
            st.warning("⚠️ **نسبة الخطر في ارتفاع - انتبه!**\n\n- 🩺 راجع طبيبك لإجراء فحوصات إضافية\n- 🥗 حلل نظامك الغذائي وقلل السكريات\n- 🏃 زد من نشاطك البدني تدريجياً\n- 📊 تابع ضغط الدم ومستوى السكر بانتظام")
        else:
            st.info("📊 **نسبة الخطر مستقرة - جيد!**\n\n- 📅 استمر في العادات الصحية الحالية\n- 🩺 قم بفحص دوري كل 3-6 أشهر\n- ⚖️ حافظ على وزن صحي\n- 🥗 تابع التوصيات الغذائية")
    
    # ============================================
    # سجل التغييرات
    # ============================================
    with st.expander("📜 سجل التغييرات", expanded=False):
        st.markdown(f"""
        <div style="font-size: 14px; line-height: 1.8;">
            ✅ <strong>{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</strong> - آخر تحديث للسجل<br>
            📊 <strong>{len(df)}</strong> تنبؤ مسجل حتى الآن<br>
            📈 <strong>متوسط الخطر: {avg_risk:.1f}%</strong><br>
            🏆 <strong>أفضل نتيجة: {best_risk:.1f}%</strong><br>
            ⚠️ <strong>عدد التنبؤات عالية الخطر: {high_risk}</strong><br>
            ✅ <strong>عدد التنبؤات منخفضة الخطر: {low_risk}</strong>
        </div>
        """, unsafe_allow_html=True)
    
    # ============================================
    # زر العودة للتنبؤ
    # ============================================
    st.markdown("---")
    col1, col2, col3 = st.columns([1, 2, 1])
    with col2:
        if st.button("🔮 إجراء تنبؤ جديد", width='stretch', type="primary"):
            st.session_state.current_page = "predict"
            st.rerun()