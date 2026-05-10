import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/local_storage_service.dart';
import '../models/health_data.dart';
import 'package:share_plus/share_plus.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final LocalStorageService _storageService = LocalStorageService();
  List<Map<String, dynamic>> _history = [];
  List<Map<String, dynamic>> _filteredHistory = [];
  bool _isLoading = true;
  bool _showChart = true;
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  // ✅ 2️⃣ إضافة الفلترة والبحث
  String _filterLevel = 'الكل'; // 'الكل', 'منخفض', 'متوسط', 'مرتفع'
  String _searchQuery = '';
  bool _isSearching = false;

  // ✅ 3️⃣ متغيرات المخطط الدائري
  int _lowCount = 0;
  int _mediumCount = 0;
  int _highCount = 0;
  int _touchedIndex = -1;

  void _goBack(BuildContext context) {
    // العودة إلى الصفحة الرئيسية مباشرة
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    // ✅ الحصول على جميع التنبؤات من Hive
    final allPredictions = _storageService.getAllPredictions();

    // تحويل HealthData إلى Map (لتوافق الكود الحالي)
    final history = allPredictions.reversed.map((data) {
      final risk = data.localRisk ?? data.calculateRiskLocally();
      return {
        'timestamp': data.timestamp.toIso8601String(),
        'risk_percentage': risk,
        'risk_level': risk < 30 ? 'منخفض' : (risk < 60 ? 'متوسط' : 'مرتفع'),
        'health_data': data.toJson(),
        'waist_circumference': data.waistCircumference,
        'hba1c_detailed': data.hba1cDetailed,
      };
    }).toList();

      setState(() {
        _history = history;
        _filteredHistory = history;
        _isLoading = false;
      });
      _updateStats();
  }

  // ✅ 2️⃣ تطبيق الفلترة والبحث
  void _applyFilters() {
    List<Map<String, dynamic>> result = List.from(_history);

    // فلترة حسب مستوى الخطر
    if (_filterLevel != 'الكل') {
      result = result.where((e) => e['risk_level'] == _filterLevel).toList();
    }

    // بحث حسب التاريخ أو النسبة
    if (_searchQuery.isNotEmpty) {
      result = result.where((e) {
        final date = _formatDateTime(e['timestamp']).toLowerCase();
        final risk = e['risk_percentage'].toString();
        final query = _searchQuery.toLowerCase();
        return date.contains(query) || risk.contains(query);
      }).toList();
    }

    setState(() {
      _filteredHistory = result;
      _currentPage = 0;
      _updateStats(); // ✅ تحديث الإحصائيات للمخطط الدائري
    });
  }

  // ✅ 3️⃣ تحديث إحصائيات المخطط الدائري
  void _updateStats() {
    _lowCount =
        _filteredHistory.where((e) => e['risk_level'] == 'منخفض').length;
    _mediumCount =
        _filteredHistory.where((e) => e['risk_level'] == 'متوسط').length;
    _highCount =
        _filteredHistory.where((e) => e['risk_level'] == 'مرتفع').length;
  }

  // ✅ 7️⃣ حذف عنصر واحد
  Future<void> _deletePrediction(Map<String, dynamic> record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف التنبؤ'),
        content: const Text('هل أنت متأكد من حذف هذا التنبؤ؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('حذف')),
        ],
      ),
    );

    if (confirm == true) {
      // البحث عن العنصر في Hive
      final allPredictions = _storageService.getAllPredictions();
      final toDelete = allPredictions.firstWhere(
        (item) => item.timestamp.toIso8601String() == record['timestamp'],
        orElse: () => throw Exception('Not found'),
      );

      await _storageService.deletePrediction(toDelete);
      await _loadHistory();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✅ تم حذف التنبؤ بنجاح'),
              backgroundColor: Colors.green),
        );
      }
    }
  }

  // ✅ حذف السجل بالكامل (موجود)
  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح السجل'),
        content:
            const Text('هل أنت متأكد من رغبتك في مسح جميع التنبؤات السابقة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('مسح الكل'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _storageService.clearAll();
      await _loadHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم مسح السجل بنجاح'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showPredictionDetails(Map<String, dynamic> record) {
    try {
      final riskPercentage = record['risk_percentage'];
      final riskLevel = record['risk_level'];
      final timestamp = record['timestamp'];

      // ✅ الحصول على health_data بشكل آمن
      Map<String, dynamic>? healthData;
      try {
        healthData = record['health_data'] as Map<String, dynamic>?;
      } catch (e) {
        debugPrint('خطأ في قراءة health_data: $e');
        healthData = null;
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => SafeArea(
          // ✅ إضافة SafeArea
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) => SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // شريط السحب
                    Center(
                      child: Container(
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // العنوان
                    Row(
                      children: [
                        _buildRiskIcon(riskLevel),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'تفاصيل التنبؤ',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _sharePrediction(record),
                          icon:
                              const Icon(Icons.share, color: Color(0xFF2563EB)),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // بطاقة نسبة الخطر
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: _getRiskGradient(riskLevel),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'نسبة الخطر',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                          Text(
                            '${(riskPercentage ?? 0).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'مستوى ${riskLevel ?? "غير محدد"}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // معلومات إضافية
                    const Text(
                      '📋 معلومات إضافية',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.calendar_today, 'التاريخ',
                        _formatDate(timestamp)),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                        Icons.access_time, 'الوقت', _formatTime(timestamp)),

                    // ✅ إضافة البيانات الصحية بشكل آمن
                    if (healthData != null && healthData.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        '🩺 البيانات الصحية',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildHealthDataGrid(healthData),
                    ] else ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.grey),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'لا توجد بيانات صحية إضافية لهذا التنبؤ',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ).catchError((error) {
        // ✅ في حالة حدوث خطأ، عرض رسالة بسيطة
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $error'),
            duration: const Duration(seconds: 2),
          ),
        );
      });
    } catch (e) {
      // ✅ معالجة أي خطأ غير متوقع
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لا يمكن عرض التفاصيل: ${e.toString()}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ✅ 4️⃣ مشاركة النتيجة
  Future<void> _sharePrediction(Map<String, dynamic> record) async {
    final text = """
📊 **DiabPredict - تقرير التنبؤ**

📅 التاريخ: ${_formatDateTime(record['timestamp'])}
🎯 نسبة الخطر: ${record['risk_percentage']}%
📈 المستوى: ${record['risk_level']}

💡 نصيحة: ${record['risk_level'] == 'منخفض' ? 'حافظ على نمط حياتك الصحي' : (record['risk_level'] == 'متوسط' ? 'يمكنك تحسين صحتك بتغييرات بسيطة' : 'يرجى استشارة الطبيب فوراً')}

---
تم إنشاء هذا التقرير بواسطة DiabPredict
""";

    await Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _applyFilters();
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'بحث عن تاريخ أو نسبة...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 16),
              )
            : const Text(
                'سجل التنبؤات',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: true,
        // ✅ إضافة سهم رجوع دائم
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            // العودة إلى الصفحة الرئيسية وإزالة جميع الصفحات السابقة
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          },
          tooltip: 'العودة إلى الرئيسية',
        ),
        actions: [
          // زر البحث
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _applyFilters();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          // زر الفلترة
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterLevel = value;
                _applyFilters();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'الكل', child: Text('الكل')),
              const PopupMenuItem(value: 'منخفض', child: Text('منخفض')),
              const PopupMenuItem(value: 'متوسط', child: Text('متوسط')),
              const PopupMenuItem(value: 'مرتفع', child: Text('مرتفع')),
            ],
          ),
          // تبديل العرض
          IconButton(
            icon: Icon(_showChart ? Icons.view_list : Icons.show_chart),
            onPressed: () => setState(() => _showChart = !_showChart),
          ),
          if (_filteredHistory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearHistory,
            ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _filteredHistory.isEmpty
              ? _buildEmptyState()
              : _showChart && _filteredHistory.length >= 2
                  ? _buildChartView()
                  : _buildListView(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(height: 16),
          Text('جاري تحميل السجل...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.history, size: 50, color: Color(0xFF2563EB)),
          ),
          const SizedBox(height: 24),
          const Text(
            'لا توجد تنبؤات سابقة',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          const Text(
            'قم بإجراء تنبؤ أولاً لرؤية التاريخ هنا',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/predict'),
            icon: const Icon(Icons.analytics),
            label: const Text('الذهاب إلى التنبؤ',
                style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartView() {
    if (_filteredHistory.length < 2) {
      // ✅ 6️⃣ مؤشر "بدون بيانات" في الرسم البياني
      return Center(
        child: Container(
          height: 280,
          margin: const EdgeInsets.all(16),
          decoration: _buildCardDecoration(),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.show_chart, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'قم بإجراء تنبؤين على الأقل',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                Text(
                  'لعرض الرسم البياني',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final List<FlSpot> spots = [];
    final List<String> labels = [];

    for (int i = 0; i < _filteredHistory.length; i++) {
      final record = _filteredHistory[i];
      spots.add(FlSpot(i.toDouble(), record['risk_percentage']));
      labels.add(_formatShortDate(record['timestamp']));
    }

    // ✅ تحديد عدد النقاط التي تظهر في المحور X
    final int labelCount = labels.length;
    final int interval = labelCount > 10 ? (labelCount / 6).ceil() : 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ✅ 5️⃣ المخطط الدائري
          _buildPieChart(),
          const SizedBox(height: 20),

          // بطاقة الإحصائيات
          _buildStatsCard(),
          const SizedBox(height: 20),

          // الرسم البياني الخطي
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _buildCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.show_chart, size: 20, color: Color(0xFF2563EB)),
                    SizedBox(width: 8),
                    Text(
                      'تطور نسبة الخطر',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 280,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}%',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50, // ✅ زيادة المساحة لعرض النصوص
                            interval:
                                interval.toDouble(), // ✅ عرض النقاط بشكل متباعد
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < labels.length) {
                                // ✅ تحسين عرض النص: تدويره إذا كان طويلاً
                                return Transform.rotate(
                                  angle: -0.5, // ✅ إمالة النصوص قليلاً
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      labels[index],
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: const Color(0xFF2563EB),
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color:
                                const Color(0xFF2563EB).withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                      minY: 0,
                      maxY: 100,
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots
                                .map((spot) => LineTooltipItem(
                                    '${spot.y.toStringAsFixed(1)}%',
                                    const TextStyle(color: Colors.white)))
                                .toList();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // ✅ إضافة أزرار للتحكم في العرض
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLevelIndicator('منخفض', const Color(0xFF10B981)),
                      const SizedBox(width: 16),
                      _buildLevelIndicator('متوسط', const Color(0xFFF59E0B)),
                      const SizedBox(width: 16),
                      _buildLevelIndicator('مرتفع', const Color(0xFFEF4444)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildListView(),
        ],
      ),
    );
  }

  // ✅ 5️⃣ مخطط دائري (Pie Chart)
Widget _buildPieChart() {
  final total = _lowCount + _mediumCount + _highCount;
  
  // ✅ حتى لو كان 0، اعرض رسالة بدلاً من إخفاء المخطط
  if (total == 0) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _buildCardDecoration(),
      child: const Column(
        children: [
          Icon(Icons.pie_chart, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            'لا توجد تنبؤات بعد',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          Text(
            'قم بإجراء تنبؤ لعرض الإحصائيات',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: _buildCardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📊 توزيع التنبؤات حسب المستوى',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (event is FlLongPressEnd || event is FlPanEndEvent) {
                          _touchedIndex = -1;
                        } else if (pieTouchResponse != null &&
                            pieTouchResponse.touchedSection != null) {
                          _touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        }
                      });
                    },
                  ),
                  sections: [
                    // منخفض
                    PieChartSectionData(
                      color: const Color(0xFF10B981),
                      value: _lowCount.toDouble(),
                      title: _touchedIndex == 0
                          ? '${(_lowCount / total * 100).toStringAsFixed(0)}%'
                          : '',
                      radius: _touchedIndex == 0 ? 60 : 50,
                      titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    // متوسط
                    PieChartSectionData(
                      color: const Color(0xFFF59E0B),
                      value: _mediumCount.toDouble(),
                      title: _touchedIndex == 1
                          ? '${(_mediumCount / total * 100).toStringAsFixed(0)}%'
                          : '',
                      radius: _touchedIndex == 1 ? 60 : 50,
                      titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    // مرتفع
                    PieChartSectionData(
                      color: const Color(0xFFEF4444),
                      value: _highCount.toDouble(),
                      title: _touchedIndex == 2
                          ? '${(_highCount / total * 100).toStringAsFixed(0)}%'
                          : '',
                      radius: _touchedIndex == 2 ? 60 : 50,
                      titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$total',
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B)),
                  ),
                  const Text('تنبؤ',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLegendItem('🟢', 'منخفض', _lowCount),
            _buildLegendItem('🟠', 'متوسط', _mediumCount),
            _buildLegendItem('🔴', 'مرتفع', _highCount),
          ],
        ),
      ],
    ),
  );
}

  Widget _buildLegendItem(String icon, String label, int count) {
    return Row(
      children: [
        Text(icon),
        const SizedBox(width: 4),
        Text('$label ($count)',
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildStatsCard() {
    if (_filteredHistory.isEmpty) return const SizedBox();

    final latestRisk = _filteredHistory.first['risk_percentage'];
    final earliestRisk = _filteredHistory.last['risk_percentage'];
    final avgRisk = _filteredHistory
            .map((e) => e['risk_percentage'] as double)
            .reduce((a, b) => a + b) /
        _filteredHistory.length;
    final change = latestRisk - earliestRisk;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _buildCardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Text('المتوسط',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text('${avgRisk.toStringAsFixed(1)}%',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B))),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade200),
          Expanded(
            child: Column(
              children: [
                const Text('الأخير',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text(
                  '${latestRisk.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: change < 0
                        ? const Color(0xFF10B981)
                        : (change > 0
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF1E293B)),
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade200),
          Expanded(
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(
                      change < 0
                          ? Icons.trending_down
                          : (change > 0
                              ? Icons.trending_up
                              : Icons.trending_flat),
                      size: 16,
                      color: change < 0
                          ? const Color(0xFF10B981)
                          : (change > 0
                              ? const Color(0xFFEF4444)
                              : Colors.grey)),
                  const SizedBox(width: 4),
                  const Text('التغير',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ]),
                Text('${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: change < 0
                            ? const Color(0xFF10B981)
                            : (change > 0
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF1E293B)))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    final totalPages = (_filteredHistory.length / _itemsPerPage).ceil();
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage) < _filteredHistory.length
        ? startIndex + _itemsPerPage
        : _filteredHistory.length;
    final currentHistory = _filteredHistory.sublist(startIndex, endIndex);

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: currentHistory.length,
          itemBuilder: (context, index) {
            final record = currentHistory[index];
            final riskPercentage = record['risk_percentage'];
            final riskLevel = record['risk_level'];
            final timestamp = record['timestamp'];

            final Color color = riskLevel == 'منخفض'
                ? const Color(0xFF10B981)
                : (riskLevel == 'متوسط'
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFFEF4444));

            // ✅ 7️⃣ Swipe to delete
            return Dismissible(
              key: Key(record['timestamp']),
              direction: DismissDirection.endToStart,
              background: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white, size: 28),
              ),
              onDismissed: (_) => _deletePrediction(record),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: _buildCardDecoration(),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showPredictionDetails(record),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              gradient: _getRiskGradient(riskLevel),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${riskPercentage.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'نسبة الخطر: ${riskPercentage.toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B))),
                                const SizedBox(height: 4),
                                Text('المستوى: $riskLevel',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: color,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                Text(_formatDateTime(timestamp),
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                shape: BoxShape.circle),
                            child: Icon(Icons.arrow_forward_ios,
                                size: 16, color: color),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (totalPages > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage > 0
                        ? () => setState(() => _currentPage--)
                        : null),
                Text('${_currentPage + 1} / $totalPages',
                    style: const TextStyle(fontSize: 14)),
                IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage < totalPages - 1
                        ? () => setState(() => _currentPage++)
                        : null),
              ],
            ),
          ),
      ],
    );
  }

  // ========== دوال مساعدة ==========

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: const Color(0xFF2563EB)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthDataGrid(Map<String, dynamic> data) {
    // تأكد من وجود البيانات المطلوبة
    final items = [
      {'icon': '🎂', 'label': 'العمر', 'value': '${data['age'] ?? '-'} سنة'},
      {
        'icon': '⚖️',
        'label': 'BMI',
        'value':
            data['bmi'] != null ? (data['bmi'] as num).toStringAsFixed(1) : '-'
      },
      {'icon': '🩸', 'label': 'HbA1c', 'value': '${data['hba1c'] ?? '-'}%'},
      {
        'icon': '🍬',
        'label': 'سكر الدم',
        'value': '${data['glucose'] ?? '-'} mg/dL'
      },
      {
        'icon': '❤️',
        'label': 'الضغط',
        'value':
            '${data['blood_pressure_systolic'] ?? '-'}/${data['blood_pressure_diastolic'] ?? '-'}'
      },
      {
        'icon': '🩺',
        'label': 'الكوليسترول',
        'value': '${data['cholesterol'] ?? '-'} mg/dL'
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.5,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Text(item['icon']!, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item['label']!,
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey)),
                    Text(
                      item['value']!,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLevelIndicator(String label, Color color) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2)),
      ],
    );
  }

  Gradient _getRiskGradient(String level) {
    if (level == 'منخفض') {
      return const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)]);
    } else if (level == 'متوسط') {
      return const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)]);
    } else {
      return const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)]);
    }
  }

  Widget _buildRiskIcon(String level) {
    IconData icon;
    Color color;

    if (level == 'منخفض') {
      icon = Icons.verified;
      color = const Color(0xFF10B981);
    } else if (level == 'متوسط') {
      icon = Icons.warning_amber;
      color = const Color(0xFFF59E0B);
    } else {
      icon = Icons.error;
      color = const Color(0xFFEF4444);
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration:
          BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 28),
    );
  }

  String _formatDateTime(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return '${date.day}/${date.month}/${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  String _formatDate(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return timestamp;
    }
  }

  String _formatTime(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  String _formatShortDate(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return '${date.day}/${date.month}';
    } catch (e) {
      return '-';
    }
  }
}
