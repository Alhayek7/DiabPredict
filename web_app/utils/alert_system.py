"""
╔══════════════════════════════════════════════════════════════╗
║           نظام التنبيهات والتحذيرات — DiabPredict           ║
║         نافذة منبثقة احترافية باستخدام st.dialog            ║
╚══════════════════════════════════════════════════════════════╝
"""

import streamlit as st
from typing import Dict, List, Tuple
import random


# ================================================================
#  ⚙️  إعدادات مستويات الخطر
# ================================================================

RISK_LEVELS: Dict[str, Dict] = {
    "low": {
        "name":        "منخفض",
        "color":       "#0D9373",
        "bg":          "#ECFDF5",
        "border":      "#A7F3D0",
        "badge_bg":    "#D1FAE5",
        "badge_color": "#065F46",
        "emoji":       "✅",
        "icon":        "🟢",
        "gradient":    "linear-gradient(135deg,#ECFDF5 0%,#D1FAE5 100%)",
    },
    "medium": {
        "name":        "متوسط",
        "color":       "#B45309",
        "bg":          "#FFFBEB",
        "border":      "#FDE68A",
        "badge_bg":    "#FEF3C7",
        "badge_color": "#78350F",
        "emoji":       "⚠️",
        "icon":        "🟡",
        "gradient":    "linear-gradient(135deg,#FFFBEB 0%,#FEF3C7 100%)",
    },
    "high": {
        "name":        "مرتفع",
        "color":       "#B91C1C",
        "bg":          "#FFF1F2",
        "border":      "#FECDD3",
        "badge_bg":    "#FEE2E2",
        "badge_color": "#991B1B",
        "emoji":       "🚨",
        "icon":        "🔴",
        "gradient":    "linear-gradient(135deg,#FFF1F2 0%,#FEE2E2 100%)",
    },
}

ALERTS_DATA: Dict[str, Dict] = {
    "low": {
        "title":       "نتيجة ممتازة!",
        "subtitle":    "أنت بصحة جيدة، استمر على هذا المنوال",
        "badge":       "خطر منخفض",
        "message_tpl": "نسبة الخطر لديك {val:.1f}% — استمر في نمط حياتك الصحي الرائع!",
        "recs": [
            ("📅", "فحص دوري كل 6 إلى 12 شهراً"),
            ("🥗", "حافظ على نظام غذائي متوازن وصحي"),
            ("🏃", "استمر في ممارسة النشاط البدني المنتظم"),
            ("😴", "نم من 7 إلى 8 ساعات يومياً"),
            ("💧", "اشرب كميات كافية من الماء يومياً"),
        ],
    },
    "medium": {
        "title":       "تنبيه — انتبه لصحتك",
        "subtitle":    "مستوى الخطر متوسط، الوقت مناسب للتحسين",
        "badge":       "خطر متوسط",
        "message_tpl": "نسبة الخطر {val:.1f}% — هذا هو الوقت المناسب لاتخاذ إجراءات وقائية.",
        "recs": [
            ("🩺", "مراجعة طبيب الأسرة خلال الثلاثة أشهر القادمة"),
            ("🍬", "تقليل استهلاك السكريات والكربوهيدرات المكررة"),
            ("🏋️", "ممارسة الرياضة لمدة 30 دقيقة يومياً على الأقل"),
            ("📊", "مراقبة مستوى السكر في الدم بانتظام"),
            ("⚖️", "العمل على إنقاص الوزن الزائد بنسبة 5 إلى 10%"),
        ],
    },
    "high": {
        "title":       "تحذير — تصرف فوراً",
        "subtitle":    "مستوى الخطر مرتفع ويستدعي إجراءً عاجلاً",
        "badge":       "خطر مرتفع",
        "message_tpl": "نسبة الخطر {val:.1f}% — يجب مراجعة الطبيب المختص في أقرب وقت ممكن.",
        "recs": [
            ("🚑", "مراجعة طبيب الغدد الصماء أو السكري فوراً"),
            ("🩸", "إجراء فحوصات HbA1c وسكر الدم الصائم"),
            ("💊", "الالتزام بالعلاج الدوائي الموصوف إن وجد"),
            ("📈", "قياس مستوى السكر يومياً وتسجيل النتائج"),
            ("🥑", "استشارة أخصائي تغذية لوضع خطة غذائية"),
            ("🏃", "الانضمام لبرنامج رياضي تحت إشراف طبي"),
        ],
    },
}

DAILY_TIPS = [
    ("💧", "شرب 8 أكواب من الماء يومياً يساعد على تقليل تركيز السكر في الدم"),
    ("🚶", "المشي السريع 30 دقيقة يومياً يحسّن حساسية الجسم للأنسولين"),
    ("😴", "النوم الكافي 7–8 ساعات ينظم هرمونات الجسم ويقلل خطر السكري"),
    ("🥗", "الخضروات الورقية الداكنة تقلل خطر الإصابة بالسكري من النوع الثاني"),
    ("🍵", "الشاي الأخضر غني بمضادات الأكسدة ويساعد في تنظيم مستوى السكر"),
    ("🏋️", "تمارين المقاومة ثلاث مرات أسبوعياً تحسّن امتصاص الجلوكوز"),
    ("🍎", "تفضيل الفاكهة الطازجة على الحلويات المصنعة يقلل الرغبة في السكر"),
    ("🥑", "الأفوكادو غني بالدهون الصحية التي تبطئ امتصاص السكر في الدم"),
    ("🐟", "الأسماك الدهنية كالسلمون والتونة مفيدة لصحة القلب ومستوى السكر"),
    ("🥜", "حفنة من المكسرات غير المملحة وجبة خفيفة مثالية ومغذية"),
]


# ================================================================
#  🔧  دوال العرض الداخلية
# ================================================================

def get_risk_level(risk_percentage: float) -> Tuple[str, Dict]:
    """إرجاع مفتاح مستوى الخطر والبيانات المقابلة"""
    if risk_percentage < 30:
        return "low",    RISK_LEVELS["low"]
    elif risk_percentage < 60:
        return "medium", RISK_LEVELS["medium"]
    else:
        return "high",   RISK_LEVELS["high"]


def _render_meter(risk_percentage: float, level: Dict) -> None:
    """عداد النسبة مع شريط ثلاثي الألوان"""
    pct      = min(risk_percentage, 100)
    low_w    = min(pct, 30)
    medium_w = max(0, min(pct, 60) - 30)
    high_w   = max(0, pct - 60)

    st.markdown(f"""
    <div style="
        background:{level['gradient']};border:1px solid {level['border']};
        border-radius:16px;padding:20px 24px;text-align:center;
        margin-bottom:20px;font-family:'Segoe UI',Tahoma,Arial,sans-serif;direction:rtl;
    ">
        <p style="margin:0 0 4px;font-size:12px;color:#64748B;letter-spacing:.5px;">
            نسبة الخطر الحالية
        </p>
        <div style="font-size:60px;font-weight:700;line-height:1.1;color:{level['color']};">
            {risk_percentage:.1f}<span style="font-size:24px;font-weight:400;">%</span>
        </div>
        <div style="
            display:inline-block;background:{level['badge_bg']};color:{level['badge_color']};
            font-size:12px;font-weight:600;padding:4px 14px;border-radius:20px;
            margin-top:8px;letter-spacing:.3px;
        ">
            {level['icon']} مستوى {level['name']}
        </div>
        <div style="display:flex;height:10px;border-radius:5px;overflow:hidden;
                    margin:18px 0 8px;background:#E2E8F0;">
            <div style="width:{low_w}%;background:#0D9373;"></div>
            <div style="width:{medium_w}%;background:#F59E0B;"></div>
            <div style="width:{high_w}%;background:#EF4444;"></div>
        </div>
        <div style="display:flex;justify-content:space-between;font-size:11px;color:#94A3B8;">
            <span>منخفض (0–30%)</span><span>متوسط (30–60%)</span><span>مرتفع (60%+)</span>
        </div>
    </div>
    """, unsafe_allow_html=True)


def _render_improvement_inside(risk_percentage: float, previous_risk: float, color: str) -> None:
    """بانر التغيير داخل الـ dialog"""
    if not previous_risk or previous_risk <= 0:
        return
    change = risk_percentage - previous_risk
    if abs(change) < 2:
        return

    if change < 0:
        bg, border, tc = "#ECFDF5", "#10B981", "#065F46"
        icon, label = "📉", f"تحسُّن — انخفاض {abs(change):.1f}% مقارنةً بالفحص السابق"
    else:
        bg, border, tc = "#FFF1F2", color, "#9F1239"
        icon, label = "📈", f"ارتفاع {change:.1f}% مقارنةً بالفحص السابق"

    st.markdown(f"""
    <div style="
        display:flex;align-items:center;gap:12px;padding:12px 16px;
        border-radius:12px;background:{bg};border-right:4px solid {border};
        margin-bottom:16px;font-family:'Segoe UI',Tahoma,Arial,sans-serif;direction:rtl;
    ">
        <span style="font-size:22px;">{icon}</span>
        <span style="font-size:14px;color:{tc};font-weight:500;">{label}</span>
    </div>
    """, unsafe_allow_html=True)


def _render_recs(recs: List[Tuple[str, str]], level: Dict) -> None:
    """قائمة التوصيات المنسقة"""
    for emoji, text in recs:
        st.markdown(f"""
        <div style="
            display:flex;align-items:flex-start;gap:14px;
            padding:12px 16px;border-radius:12px;
            border:1px solid {level['border']};background:#FFFFFF;
            margin-bottom:10px;
            font-family:'Segoe UI',Tahoma,Arial,sans-serif;direction:rtl;
        ">
            <div style="
                width:36px;height:36px;border-radius:10px;
                background:{level['badge_bg']};
                display:flex;align-items:center;justify-content:center;
                font-size:18px;flex-shrink:0;
            ">{emoji}</div>
            <span style="font-size:14px;color:#1E293B;line-height:1.7;padding-top:6px;">
                {text}
            </span>
        </div>
        """, unsafe_allow_html=True)


def _render_factors(top_factors: List[Dict]) -> None:
    """قائمة العوامل المؤثرة المنسقة"""
    if not top_factors:
        st.info("لا توجد بيانات عوامل مؤثرة.")
        return

    for factor in top_factors[:6]:
        positive   = "يخفض" in factor.get("impact", "") or factor.get("positive", False)
        dot_color  = "#0D9373"  if positive else "#B91C1C"
        tag_bg     = "#D1FAE5"  if positive else "#FEE2E2"
        tag_color  = "#065F46"  if positive else "#991B1B"
        tag_icon   = "↓" if positive else "↑"
        importance = factor.get("importance", 0)

        bar_html = ""
        if importance:
            bar_w    = min(abs(importance) * 100, 100)
            bar_html = f"""
            <div style="height:4px;border-radius:2px;background:#E2E8F0;margin-top:8px;">
                <div style="width:{bar_w:.1f}%;height:100%;border-radius:2px;
                            background:{dot_color};"></div>
            </div>"""

        st.markdown(f"""
        <div style="
            padding:12px 16px;border-radius:12px;
            border:1px solid #E2E8F0;background:#FFFFFF;margin-bottom:10px;
            font-family:'Segoe UI',Tahoma,Arial,sans-serif;direction:rtl;
        ">
            <div style="display:flex;align-items:center;justify-content:space-between;gap:8px;">
                <div style="display:flex;align-items:center;gap:10px;">
                    <div style="width:10px;height:10px;border-radius:50%;
                                background:{dot_color};flex-shrink:0;"></div>
                    <span style="font-size:14px;color:#1E293B;font-weight:600;">
                        {factor.get('name','')}
                    </span>
                </div>
                <span style="
                    font-size:12px;padding:4px 12px;border-radius:20px;white-space:nowrap;
                    background:{tag_bg};color:{tag_color};font-weight:600;
                ">
                    {tag_icon} {factor.get('impact','')}
                </span>
            </div>
            {bar_html}
        </div>
        """, unsafe_allow_html=True)


# ================================================================
#  🪟  النافذة المنبثقة الرئيسية
# ================================================================

def show_alert_popup(
    risk_percentage: float,
    top_factors:     List[Dict] = None,
    previous_risk:   float      = None,
) -> None:
    """
    عرض نافذة منبثقة احترافية بالكامل باللغة العربية
    باستخدام st.dialog الأصلي في Streamlit.

    المعاملات
    ----------
    risk_percentage : نسبة الخطر (0 – 100)
    top_factors     : قائمة بالعوامل المؤثرة
                      كل عنصر: {'name': str, 'impact': str, 'positive': bool}
    previous_risk   : نسبة الخطر في الفحص السابق (اختياري)
    """
    level_key, level = get_risk_level(risk_percentage)
    alert            = ALERTS_DATA[level_key]
    dialog_title     = f"{level['emoji']}  {alert['title']}  —  {alert['badge']}"

    @st.dialog(dialog_title, width="large")
    def _popup() -> None:

        # ── رسالة المقدمة ─────────────────────────────────────
        st.markdown(f"""
        <div style="
            text-align:center;padding:4px 0 20px;
            border-bottom:1px solid {level['border']};margin-bottom:20px;
            font-family:'Segoe UI',Tahoma,Arial,sans-serif;direction:rtl;
        ">
            <p style="margin:0;font-size:15px;color:#475569;line-height:1.7;">
                {alert['message_tpl'].format(val=risk_percentage)}
            </p>
            <p style="margin:6px 0 0;font-size:13px;color:#94A3B8;">
                {alert['subtitle']}
            </p>
        </div>
        """, unsafe_allow_html=True)

        # ── عداد النسبة ───────────────────────────────────────
        _render_meter(risk_percentage, level)

        # ── بانر التغيير ──────────────────────────────────────
        _render_improvement_inside(risk_percentage, previous_risk or 0, level["color"])

        # ── التبويبات ─────────────────────────────────────────
        if top_factors:
            tab_recs, tab_factors = st.tabs([
                "📋  الإجراءات الموصى بها",
                "🎯  العوامل المؤثرة",
            ])
            with tab_recs:
                st.markdown("<div style='height:8px;'></div>", unsafe_allow_html=True)
                _render_recs(alert["recs"], level)
            with tab_factors:
                st.markdown("<div style='height:8px;'></div>", unsafe_allow_html=True)
                _render_factors(top_factors)
        else:
            st.markdown(
                f"<p style='font-size:15px;font-weight:600;color:{level['color']};"
                f"margin-bottom:12px;direction:rtl;font-family:Segoe UI,sans-serif;'>"
                f"📋 الإجراءات الموصى بها</p>",
                unsafe_allow_html=True,
            )
            _render_recs(alert["recs"], level)

        # ── إخلاء المسؤولية ───────────────────────────────────
        st.markdown(f"""
        <div style="
            text-align:center;font-size:12px;color:#94A3B8;
            padding:12px;margin-top:16px;
            border-top:1px solid {level['border']};
            border-radius:0 0 12px 12px;background:#F8FAFC;
            font-family:'Segoe UI',Tahoma,Arial,sans-serif;direction:rtl;
        ">
            ⚕️ هذه النتيجة تقديرية وليست تشخيصاً طبياً نهائياً —
            يُرجى استشارة الطبيب المختص للحصول على تقييم دقيق.
        </div>
        """, unsafe_allow_html=True)

        st.markdown("<div style='height:12px;'></div>", unsafe_allow_html=True)

        # ── زر الإغلاق ────────────────────────────────────────
        if st.button(
            f"{level['emoji']}  فهمت وتأكدت",
            type="primary",
            use_container_width=True,
        ):
            st.rerun()

    _popup()


# ================================================================
#  📌  دوال مساعدة عامة (Public API)
# ================================================================

def render_alert_card(
    risk_percentage: float,
    top_factors:     List[Dict] = None,
    previous_risk:   float      = None,
) -> None:
    """
    بطاقة التنبيه الرئيسية.
    اسم بديل لـ show_alert_popup للتوافق مع استيرادات Predict.py.
    """
    show_alert_popup(
        risk_percentage=risk_percentage,
        top_factors=top_factors,
        previous_risk=previous_risk,
    )


def render_emergency_alert(
    risk_percentage: float,
    threshold:       float = 80.0,
) -> None:
    """
    بانر تحذير طارئ يظهر فقط عند تجاوز نسبة الخطر العتبة المحددة.

    المعاملات
    ----------
    risk_percentage : نسبة الخطر الحالية
    threshold       : الحد الأدنى لتفعيل التنبيه (افتراضي 80%)
    """
    if risk_percentage < threshold:
        return

    st.markdown(f"""
    <div style="
        background:linear-gradient(135deg,#FFF1F2 0%,#FFE4E6 100%);
        border:2px solid #F43F5E;border-radius:16px;
        padding:20px 24px;margin:16px 0;
        font-family:'Segoe UI',Tahoma,Arial,sans-serif;direction:rtl;
    ">
        <div style="display:flex;align-items:flex-start;gap:16px;">
            <div style="
                width:48px;height:48px;background:#EF4444;border-radius:50%;
                display:flex;align-items:center;justify-content:center;
                font-size:24px;flex-shrink:0;
            ">🚨</div>
            <div style="flex:1;">
                <div style="font-size:16px;font-weight:700;color:#9F1239;margin-bottom:6px;">
                    تنبيه طارئ — نسبة الخطر {risk_percentage:.1f}%
                </div>
                <div style="font-size:13px;color:#881337;line-height:1.7;">
                    هذا المستوى يستدعي
                    <strong>مراجعة طبيب متخصص على الفور</strong> دون أي تأخير.<br>
                    يُرجى إجراء فحوصات <strong>HbA1c</strong>
                    وسكر الدم الصائم في أقرب وقت ممكن.
                </div>
            </div>
        </div>
    </div>
    """, unsafe_allow_html=True)


def render_improvement_alert(
    previous_risk: float,
    current_risk:  float,
    threshold:     float = 5.0,
) -> None:
    """
    بانر يوضح التغير بين التنبؤ الحالي والسابق.

    المعاملات
    ----------
    previous_risk : نسبة الخطر في الفحص السابق
    current_risk  : نسبة الخطر الحالية
    threshold     : الحد الأدنى للتغير لعرض البانر (افتراضي 5%)
    """
    if not previous_risk or previous_risk <= 0:
        return
    change = current_risk - previous_risk
    if abs(change) < threshold:
        return

    if change < 0:
        bg, border, color = "#ECFDF5", "#10B981", "#065F46"
        icon   = "📉"
        title  = f"تحسُّن ملحوظ — انخفاض {abs(change):.1f}%"
        detail = "أنت على الطريق الصحيح، استمر في اتباع نمط حياتك الصحي!"
    else:
        bg, border, color = "#FFF1F2", "#F43F5E", "#9F1239"
        icon   = "📈"
        title  = f"تدهور ملحوظ — ارتفاع {change:.1f}%"
        detail = "يُنصح بمراجعة طبيبك لمناقشة هذا الارتفاع واتخاذ الإجراءات المناسبة."

    st.markdown(f"""
    <div style="
        background:{bg};border-right:5px solid {border};border-radius:12px;
        padding:16px 20px;margin:12px 0;
        font-family:'Segoe UI',Tahoma,Arial,sans-serif;direction:rtl;
    ">
        <div style="display:flex;align-items:flex-start;gap:14px;">
            <span style="font-size:26px;flex-shrink:0;">{icon}</span>
            <div>
                <div style="font-size:15px;font-weight:700;color:{color};margin-bottom:4px;">
                    {title}
                </div>
                <div style="font-size:13px;color:{color};opacity:.85;line-height:1.6;">
                    {detail}
                </div>
            </div>
        </div>
    </div>
    """, unsafe_allow_html=True)


def render_daily_tip() -> None:
    """عرض نصيحة صحية يومية عشوائية"""
    emoji, text = random.choice(DAILY_TIPS)

    st.markdown(f"""
    <div style="
        background:linear-gradient(135deg,#EFF6FF 0%,#DBEAFE 100%);
        border-radius:14px;padding:16px 20px;margin:16px 0;
        border-right:5px solid #3B82F6;
        font-family:'Segoe UI',Tahoma,Arial,sans-serif;direction:rtl;
    ">
        <div style="display:flex;align-items:center;gap:14px;">
            <div style="
                width:44px;height:44px;background:#3B82F6;border-radius:12px;
                display:flex;align-items:center;justify-content:center;
                font-size:22px;flex-shrink:0;
            ">{emoji}</div>
            <div>
                <div style="font-size:12px;color:#1E40AF;font-weight:700;
                            letter-spacing:.4px;margin-bottom:4px;">
                    💡 نصيحة صحية اليوم
                </div>
                <div style="font-size:14px;color:#1E3A8A;line-height:1.6;">
                    {text}
                </div>
            </div>
        </div>
    </div>
    """, unsafe_allow_html=True)


def render_warning_banner(message: str, type: str = "warning") -> None:
    """
    لافتة إشعار ملوّنة.

    المعاملات
    ----------
    message : نص الرسالة
    type    : نوع اللافتة — warning | error | info | success
    """
    STYLES = {
        "warning": {
            "bg": "linear-gradient(135deg,#FFFBEB,#FEF3C7)",
            "border": "#F59E0B", "color": "#78350F", "icon": "⚠️",
        },
        "error": {
            "bg": "linear-gradient(135deg,#FFF1F2,#FEE2E2)",
            "border": "#EF4444", "color": "#9F1239", "icon": "🔴",
        },
        "info": {
            "bg": "linear-gradient(135deg,#EFF6FF,#DBEAFE)",
            "border": "#3B82F6", "color": "#1E3A8A", "icon": "ℹ️",
        },
        "success": {
            "bg": "linear-gradient(135deg,#ECFDF5,#D1FAE5)",
            "border": "#10B981", "color": "#065F46", "icon": "✅",
        },
    }
    s = STYLES.get(type, STYLES["info"])

    st.markdown(f"""
    <div style="
        background:{s['bg']};border-right:5px solid {s['border']};border-radius:12px;
        padding:14px 18px;margin:10px 0;
        display:flex;align-items:center;gap:12px;
        font-family:'Segoe UI',Tahoma,Arial,sans-serif;direction:rtl;
    ">
        <span style="font-size:20px;flex-shrink:0;">{s['icon']}</span>
        <span style="font-size:14px;color:{s['color']};line-height:1.6;">{message}</span>
    </div>
    """, unsafe_allow_html=True)


# ================================================================
#  🧪  صفحة اختبار مستقلة
#  التشغيل:  streamlit run alert_system.py
# ================================================================

if __name__ == "__main__":
    st.set_page_config(
        page_title="DiabPredict — اختبار التنبيهات",
        layout="centered",
        initial_sidebar_state="collapsed",
    )

    # ── ترويسة ────────────────────────────────────────────────
    st.markdown("""
    <div style="
        background:linear-gradient(135deg,#EFF6FF,#DBEAFE);
        border-radius:20px;padding:24px 28px;margin-bottom:28px;
        border-bottom:3px solid #3B82F6;direction:rtl;
        font-family:'Segoe UI',Tahoma,Arial,sans-serif;
    ">
        <h1 style="margin:0 0 6px;font-size:26px;color:#1E3A8A;">🩺 DiabPredict</h1>
        <p style="margin:0;font-size:14px;color:#3B82F6;">
            لوحة اختبار نظام التنبيهات والتحذيرات
        </p>
    </div>
    """, unsafe_allow_html=True)

    # ── أدوات التحكم ──────────────────────────────────────────
    col1, col2 = st.columns(2)
    with col1:
        risk = st.slider("📊 نسبة الخطر الحالية", 0.0, 100.0, 72.4, 0.5)
    with col2:
        prev = st.slider("📅 نسبة الفحص السابق", 0.0, 100.0, 55.0, 0.5)

    use_factors = st.checkbox("🎯 إظهار العوامل المؤثرة داخل النافذة", value=True)

    sample_factors = [
        {"name": "مستوى السكر في الدم",   "impact": "يزيد الخطر",  "positive": False, "importance": 0.85},
        {"name": "النشاط البدني اليومي",   "impact": "يخفض الخطر",  "positive": True,  "importance": 0.60},
        {"name": "تاريخ العائلة المرضي",   "impact": "يزيد الخطر",  "positive": False, "importance": 0.72},
        {"name": "مؤشر كتلة الجسم (BMI)", "impact": "يزيد الخطر",  "positive": False, "importance": 0.55},
        {"name": "جودة النوم",             "impact": "يخفض الخطر",  "positive": True,  "importance": 0.40},
    ]

    st.divider()

    # ── معاينة المكوّنات ───────────────────────────────────────
    st.markdown("### 🔔 التنبيه الطارئ")
    render_emergency_alert(risk)

    st.markdown("### 📊 تنبيه التغيير")
    render_improvement_alert(prev, risk)

    st.markdown("### 💡 نصيحة اليوم")
    render_daily_tip()

    st.markdown("### 🏷️ اللافتات التحذيرية")
    render_warning_banner("يُرجى التحقق من البيانات المدخلة قبل المتابعة.", type="warning")
    render_warning_banner("تم حفظ النتائج بنجاح.", type="success")
    render_warning_banner("لا يوجد اتصال بالخادم، يُرجى المحاولة لاحقاً.", type="error")
    render_warning_banner("يمكنك الاطلاع على سجل الفحوصات من القائمة الجانبية.", type="info")

    st.divider()

    if st.button("🪟  فتح النافذة المنبثقة", type="primary", use_container_width=True):
        show_alert_popup(
            risk_percentage=risk,
            top_factors=sample_factors if use_factors else None,
            previous_risk=prev,
        )