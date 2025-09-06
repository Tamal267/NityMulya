class Complaint {
  final int id;
  final String complaintNumber;
  final int customerId;
  final String customerName;
  final String customerEmail;
  final String? customerPhone;
  final int shopId;
  final String shopName;
  final int? productId;
  final String? productName;
  final String category;
  final String priority;
  final String severity;
  final String description;
  final String status;
  final String? forwardedTo;
  final DateTime? forwardedAt;
  final DateTime? solvedAt;
  final DateTime submittedAt;
  final DateTime updatedAt;
  final String? resolutionComment;
  final int? dncrpOfficerId;
  final List<ComplaintFile>? files;

  Complaint({
    required this.id,
    required this.complaintNumber,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    this.customerPhone,
    required this.shopId,
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
    this.dncrpOfficerId,
    this.files,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'] as int,
      complaintNumber: json['complaint_number'] as String,
      customerId: json['customer_id'] as int,
      customerName: json['customer_name'] as String,
      customerEmail: json['customer_email'] as String,
      customerPhone: json['customer_phone'] as String?,
      shopId: json['shop_id'] as int,
      shopName: json['shop_name'] as String,
      productId: json['product_id'] as int?,
      productName: json['product_name'] as String?,
      category: json['category'] as String,
      priority: json['priority'] as String,
      severity: json['severity'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      forwardedTo: json['forwarded_to'] as String?,
      forwardedAt: json['forwarded_at'] != null 
          ? DateTime.parse(json['forwarded_at'] as String)
          : null,
      solvedAt: json['solved_at'] != null 
          ? DateTime.parse(json['solved_at'] as String)
          : null,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      resolutionComment: json['resolution_comment'] as String?,
      dncrpOfficerId: json['dncrp_officer_id'] as int?,
      files: json['files'] != null 
          ? (json['files'] as List)
              .map((f) => ComplaintFile.fromJson(f as Map<String, dynamic>))
              .toList()
          : null,
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
      'shop_id': shopId,
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
      'dncrp_officer_id': dncrpOfficerId,
      'files': files?.map((f) => f.toJson()).toList(),
    };
  }
}

class ComplaintFile {
  final int id;
  final int complaintId;
  final String fileName;
  final String fileUrl;
  final String fileType;
  final int? fileSize;
  final DateTime uploadedAt;

  ComplaintFile({
    required this.id,
    required this.complaintId,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    this.fileSize,
    required this.uploadedAt,
  });

  factory ComplaintFile.fromJson(Map<String, dynamic> json) {
    return ComplaintFile(
      id: json['id'] as int,
      complaintId: json['complaint_id'] as int,
      fileName: json['file_name'] as String,
      fileUrl: json['file_url'] as String,
      fileType: json['file_type'] as String,
      fileSize: json['file_size'] as int?,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'complaint_id': complaintId,
      'file_name': fileName,
      'file_url': fileUrl,
      'file_type': fileType,
      'file_size': fileSize,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }
}

class ComplaintHistory {
  final int id;
  final int complaintId;
  final String? oldStatus;
  final String newStatus;
  final String? comment;
  final int? changedBy;
  final String? changedByName;
  final DateTime timestamp;

  ComplaintHistory({
    required this.id,
    required this.complaintId,
    this.oldStatus,
    required this.newStatus,
    this.comment,
    this.changedBy,
    this.changedByName,
    required this.timestamp,
  });

  factory ComplaintHistory.fromJson(Map<String, dynamic> json) {
    return ComplaintHistory(
      id: json['id'] as int,
      complaintId: json['complaint_id'] as int,
      oldStatus: json['old_status'] as String?,
      newStatus: json['new_status'] as String,
      comment: json['comment'] as String?,
      changedBy: json['changed_by'] as int?,
      changedByName: json['changed_by_name'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'complaint_id': complaintId,
      'old_status': oldStatus,
      'new_status': newStatus,
      'comment': comment,
      'changed_by': changedBy,
      'changed_by_name': changedByName,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}