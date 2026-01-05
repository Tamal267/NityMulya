class ComplaintModel {
  final int id;
  final String complaintNumber;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String? customerPhone;
  final String shopName;
  final String? productId;
  final String? productName;
  final String category;
  final String priority; // Low, Medium, High, Urgent
  final String severity; // Minor, Moderate, Major, Critical
  final String description;
  final String status; // Received, Forwarded, Solved
  final String? forwardedTo;
  final DateTime? forwardedAt;
  final DateTime? solvedAt;
  final DateTime submittedAt;
  final DateTime updatedAt;
  final String? resolutionComment;
  final String? fileUrl;
  
  // AI Analysis Fields
  final double? validityScore;
  final bool isValid;
  final List<String>? validityReasons;
  final double? aiPriorityScore;
  final String? aiPriorityLevel;
  final List<String>? priorityReasons;
  final double? sentimentScore;
  final String? sentiment;
  final String? emotionIntensity;
  final String? aiCategory;
  final String? aiCategoryConfidence;
  final int? matchedKeywords;
  final String? aiSummary;
  final String? detectedLanguage;
  final DateTime? aiAnalysisDate;
  final double? aiProcessingTimeMs;
  final Map<String, dynamic>? aiFullAnalysis;
  
  // Computed priority rank for sorting
  int get combinedPriorityRank {
    if (aiPriorityLevel == 'Urgent') return 1;
    if (aiPriorityLevel == 'High' || priority == 'High') return 2;
    if (aiPriorityLevel == 'Medium' || priority == 'Medium') return 3;
    return 4;
  }
  
  String get aiAnalysisStatus {
    if (validityScore != null && aiPriorityScore != null && sentimentScore != null) {
      return 'complete';
    } else if (validityScore != null) {
      return 'partial';
    }
    return 'none';
  }

  ComplaintModel({
    required this.id,
    required this.complaintNumber,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    this.customerPhone,
    required this.shopName,
    this.productId,
    this.productName,
    required this.category,
    required this.priority,
    required this.severity,
    required this.description,
    required this.status,
    this.forwardedTo,
    this.forwardedAt,
    this.solvedAt,
    required this.submittedAt,
    required this.updatedAt,
    this.resolutionComment,
    this.fileUrl,
    this.validityScore,
    this.isValid = true,
    this.validityReasons,
    this.aiPriorityScore,
    this.aiPriorityLevel,
    this.priorityReasons,
    this.sentimentScore,
    this.sentiment,
    this.emotionIntensity,
    this.aiCategory,
    this.aiCategoryConfidence,
    this.matchedKeywords,
    this.aiSummary,
    this.detectedLanguage,
    this.aiAnalysisDate,
    this.aiProcessingTimeMs,
    this.aiFullAnalysis,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'] as int,
      complaintNumber: json['complaint_number'] as String,
      customerId: json['customer_id'] as String,
      customerName: json['customer_name'] as String,
      customerEmail: json['customer_email'] as String,
      customerPhone: json['customer_phone'] as String?,
      shopName: json['shop_name'] as String,
      productId: json['product_id'] as String?,
      productName: json['product_name'] as String?,
      category: json['category'] as String,
      priority: json['priority'] as String,
      severity: json['severity'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      forwardedTo: json['forwarded_to'] as String?,
      forwardedAt: json['forwarded_at'] != null
          ? DateTime.parse(json['forwarded_at'])
          : null,
      solvedAt: json['solved_at'] != null
          ? DateTime.parse(json['solved_at'])
          : null,
      submittedAt: DateTime.parse(json['submitted_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      resolutionComment: json['resolution_comment'] as String?,
      fileUrl: json['file_url'] as String?,
      validityScore: json['validity_score'] != null 
          ? double.tryParse(json['validity_score'].toString()) 
          : null,
      isValid: json['is_valid'] ?? true,
      validityReasons: json['validity_reasons'] != null
          ? List<String>.from(json['validity_reasons'])
          : null,
      aiPriorityScore: json['ai_priority_score'] != null
          ? double.tryParse(json['ai_priority_score'].toString())
          : null,
      aiPriorityLevel: json['ai_priority_level'] as String?,
      priorityReasons: json['priority_reasons'] != null
          ? List<String>.from(json['priority_reasons'])
          : null,
      sentimentScore: json['sentiment_score'] != null
          ? double.tryParse(json['sentiment_score'].toString())
          : null,
      sentiment: json['sentiment'] as String?,
      emotionIntensity: json['emotion_intensity'] as String?,
      aiCategory: json['ai_category'] as String?,
      aiCategoryConfidence: json['ai_category_confidence'] as String?,
      matchedKeywords: json['matched_keywords'] as int?,
      aiSummary: json['ai_summary'] as String?,
      detectedLanguage: json['detected_language'] as String?,
      aiAnalysisDate: json['ai_analysis_date'] != null
          ? DateTime.parse(json['ai_analysis_date'])
          : null,
      aiProcessingTimeMs: json['ai_processing_time_ms'] != null
          ? double.tryParse(json['ai_processing_time_ms'].toString())
          : null,
      aiFullAnalysis: json['ai_full_analysis'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'complaint_number': complaintNumber,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'customer_phone': customerPhone,
      'shop_name': shopName,
      'product_id': productId,
      'product_name': productName,
      'category': category,
      'priority': priority,
      'severity': severity,
      'description': description,
      'status': status,
      'forwarded_to': forwardedTo,
      'forwarded_at': forwardedAt?.toIso8601String(),
      'solved_at': solvedAt?.toIso8601String(),
      'submitted_at': submittedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'resolution_comment': resolutionComment,
      'file_url': fileUrl,
      'validity_score': validityScore,
      'is_valid': isValid,
      'validity_reasons': validityReasons,
      'ai_priority_score': aiPriorityScore,
      'ai_priority_level': aiPriorityLevel,
      'priority_reasons': priorityReasons,
      'sentiment_score': sentimentScore,
      'sentiment': sentiment,
      'emotion_intensity': emotionIntensity,
      'ai_category': aiCategory,
      'ai_category_confidence': aiCategoryConfidence,
      'matched_keywords': matchedKeywords,
      'ai_summary': aiSummary,
      'detected_language': detectedLanguage,
      'ai_analysis_date': aiAnalysisDate?.toIso8601String(),
      'ai_processing_time_ms': aiProcessingTimeMs,
      'ai_full_analysis': aiFullAnalysis,
    };
  }

  ComplaintModel copyWith({
    int? id,
    String? complaintNumber,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? shopName,
    String? productId,
    String? productName,
    String? category,
    String? priority,
    String? severity,
    String? description,
    String? status,
    String? forwardedTo,
    DateTime? forwardedAt,
    DateTime? solvedAt,
    DateTime? submittedAt,
    DateTime? updatedAt,
    String? resolutionComment,
    String? fileUrl,
    double? validityScore,
    bool? isValid,
    List<String>? validityReasons,
    double? aiPriorityScore,
    String? aiPriorityLevel,
    List<String>? priorityReasons,
    double? sentimentScore,
    String? sentiment,
    String? emotionIntensity,
    String? aiCategory,
    String? aiCategoryConfidence,
    int? matchedKeywords,
    String? aiSummary,
    String? detectedLanguage,
    DateTime? aiAnalysisDate,
    double? aiProcessingTimeMs,
    Map<String, dynamic>? aiFullAnalysis,
  }) {
    return ComplaintModel(
      id: id ?? this.id,
      complaintNumber: complaintNumber ?? this.complaintNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      shopName: shopName ?? this.shopName,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      severity: severity ?? this.severity,
      description: description ?? this.description,
      status: status ?? this.status,
      forwardedTo: forwardedTo ?? this.forwardedTo,
      forwardedAt: forwardedAt ?? this.forwardedAt,
      solvedAt: solvedAt ?? this.solvedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolutionComment: resolutionComment ?? this.resolutionComment,
      fileUrl: fileUrl ?? this.fileUrl,
      validityScore: validityScore ?? this.validityScore,
      isValid: isValid ?? this.isValid,
      validityReasons: validityReasons ?? this.validityReasons,
      aiPriorityScore: aiPriorityScore ?? this.aiPriorityScore,
      aiPriorityLevel: aiPriorityLevel ?? this.aiPriorityLevel,
      priorityReasons: priorityReasons ?? this.priorityReasons,
      sentimentScore: sentimentScore ?? this.sentimentScore,
      sentiment: sentiment ?? this.sentiment,
      emotionIntensity: emotionIntensity ?? this.emotionIntensity,
      aiCategory: aiCategory ?? this.aiCategory,
      aiCategoryConfidence: aiCategoryConfidence ?? this.aiCategoryConfidence,
      matchedKeywords: matchedKeywords ?? this.matchedKeywords,
      aiSummary: aiSummary ?? this.aiSummary,
      detectedLanguage: detectedLanguage ?? this.detectedLanguage,
      aiAnalysisDate: aiAnalysisDate ?? this.aiAnalysisDate,
      aiProcessingTimeMs: aiProcessingTimeMs ?? this.aiProcessingTimeMs,
      aiFullAnalysis: aiFullAnalysis ?? this.aiFullAnalysis,
    );
  }
}
