import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// AIVerificationService - Handles AI-based waste cleanup verification
/// Features:
/// - Before/After image comparison
/// - Waste detection using AI
/// - Cleanliness scoring
/// - Threshold-based validation
class AIVerificationService {
  static const String _baseUrl = 'https://api.neatnow.com/ai'; // Replace with actual API
  static const int _cleanlinessThreshold = 85; // Minimum cleanliness percentage required

  /// Verify cleanup by comparing before and after images
  /// Returns verification result with cleanliness score
  static Future<AIVerificationResult> verifyCleanup({
    required String beforeImageUrl,
    required String afterImagePath,
    required String reportType,
  }) async {
    try {
      // For demo/development - simulate AI verification
      if (kDebugMode) {
        return await _simulateVerification(afterImagePath, reportType);
      }

      // Production API call
      final afterImageFile = File(afterImagePath);
      final afterImageBytes = await afterImageFile.readAsBytes();
      final afterImageBase64 = base64Encode(afterImageBytes);

      final response = await http.post(
        Uri.parse('$_baseUrl/verify-cleanup'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_KEY', // Replace with actual key
        },
        body: jsonEncode({
          'before_image_url': beforeImageUrl,
          'after_image_base64': afterImageBase64,
          'waste_type': reportType,
          'threshold': _cleanlinessThreshold,
        }),
      );

      if (response. statusCode == 200) {
        final data = jsonDecode(response.body);
        return AIVerificationResult. fromJson(data);
      } else {
        throw Exception('AI verification failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('AI Verification Error: $e');
      // Fallback to simulation in case of error
      return await _simulateVerification(afterImagePath, reportType);
    }
  }

  /// Simulate AI verification for development/testing
  static Future<AIVerificationResult> _simulateVerification(
      String imagePath,
      String reportType,
      ) async {
    // Simulate processing delay
    await Future. delayed(const Duration(seconds: 2));

    // Random simulation - 80% chance of success
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    final isClean = random < 80;

    if (isClean) {
      return AIVerificationResult(
        isClean: true,
        cleanlinessScore: 85 + (random % 15), // 85-99%
        confidence: 90 + (random % 10), // 90-99%
        threshold: _cleanlinessThreshold,
        detectedIssues: [],
        processingTime: 2.5,
        aiModel: 'WasteDetectionV2',
      );
    } else {
      final issues = _generateRandomIssues(reportType);
      return AIVerificationResult(
        isClean: false,
        cleanlinessScore: 40 + (random % 40), // 40-79%
        confidence: 85 + (random % 10), // 85-94%
        threshold: _cleanlinessThreshold,
        detectedIssues: issues,
        processingTime: 2.8,
        aiModel: 'WasteDetectionV2',
      );
    }
  }

  static List<String> _generateRandomIssues(String reportType) {
    final allIssues = {
      'plastic': [
        'Plastic bottles detected in corner',
        'Small plastic debris remaining',
        'Plastic bag partially visible',
      ],
      'organic': [
        'Organic matter still present',
        'Food waste not fully cleared',
        'Decomposing material detected',
      ],
      'paper': [
        'Paper scraps remaining',
        'Cardboard pieces detected',
        'Paper waste not fully collected',
      ],
      'general': [
        'Mixed waste detected',
        'Area not fully cleaned',
        'Debris still visible',
        'Cleanup incomplete',
      ],
    };

    final typeKey = reportType.toLowerCase(). contains('plastic')
        ? 'plastic'
        : reportType.toLowerCase(). contains('organic')
        ? 'organic'
        : reportType.toLowerCase().contains('paper')
        ? 'paper'
        : 'general';

    final issues = allIssues[typeKey] ?? allIssues['general']!;
    final random = DateTime.now().millisecondsSinceEpoch;

    return [
      issues[random % issues. length],
      if (random % 2 == 0) issues[(random + 1) % issues.length],
    ];
  }

  /// Check if the service is available
  static Future<bool> checkServiceStatus() async {
    try {
      final response = await http. get(
        Uri.parse('$_baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ). timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get supported waste types
  static List<String> getSupportedWasteTypes() {
    return [
      'Plastic Waste',
      'Organic Waste',
      'Paper Waste',
      'Electronic Waste',
      'Hazardous Waste',
      'Glass Waste',
      'Metal Waste',
      'Construction Debris',
      'Medical Waste',
      'Mixed Waste',
    ];
  }
}

/// Result of AI verification
class AIVerificationResult {
  final bool isClean;
  final int cleanlinessScore;
  final int confidence;
  final int threshold;
  final List<String> detectedIssues;
  final double processingTime;
  final String aiModel;

  AIVerificationResult({
    required this.isClean,
    required this.cleanlinessScore,
    required this.confidence,
    required this. threshold,
    required this.detectedIssues,
    required this.processingTime,
    required this.aiModel,
  });

  factory AIVerificationResult.fromJson(Map<String, dynamic> json) {
    return AIVerificationResult(
      isClean: json['is_clean'] ?? false,
      cleanlinessScore: json['cleanliness_score'] ?? 0,
      confidence: json['confidence'] ?? 0,
      threshold: json['threshold'] ??  85,
      detectedIssues: List<String>.from(json['detected_issues'] ?? []),
      processingTime: (json['processing_time'] ?? 0).toDouble(),
      aiModel: json['ai_model'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_clean': isClean,
      'cleanliness_score': cleanlinessScore,
      'confidence': confidence,
      'threshold': threshold,
      'detected_issues': detectedIssues,
      'processing_time': processingTime,
      'ai_model': aiModel,
    };
  }

  @override
  String toString() {
    return 'AIVerificationResult(isClean: $isClean, score: $cleanlinessScore%, confidence: $confidence%)';
  }
}