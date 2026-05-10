// lib/models/prediction_result.dart

class PredictionResult {
  final double riskPercentage;
  final String riskLevel;
  final double probability;
  final String recommendation;
  final Map<String, double> shapValues;
  final List<Map<String, dynamic>> topFactors;
  final String timestamp;
  final double accuracy;

  PredictionResult({
    required this.riskPercentage,
    required this.riskLevel,
    required this.probability,
    required this.recommendation,
    required this.shapValues,
    required this.topFactors,
    required this.timestamp,
    required this.accuracy,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      riskPercentage: (json['risk_percentage'] as num).toDouble(),
      riskLevel: json['risk_level'],
      probability: (json['probability'] as num).toDouble(),
      recommendation: json['recommendation'],
      shapValues: Map<String, double>.from(json['shap_values']),
      topFactors: List<Map<String, dynamic>>.from(json['top_factors']),
      timestamp: json['timestamp'],
      accuracy: (json['accuracy'] ?? 0.73).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'risk_percentage': riskPercentage,
    'risk_level': riskLevel,
    'probability': probability,
    'recommendation': recommendation,
    'shap_values': shapValues,
    'top_factors': topFactors,
    'timestamp': timestamp,
    'accuracy': accuracy,
  };
}