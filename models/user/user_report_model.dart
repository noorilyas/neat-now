class UserReportModel {
  final String id;
  final String type;
  final String location;
  final String status;
  final String?  beforeImageUrl;
  final String? afterImageUrl;
  final String? description;
  final DateTime submittedAt;
  final String? workerName;
  final String? workerPhone;
  final String? workerImage;
  final DateTime? resolvedAt;
  final Duration?  cleanupDuration;
  final double? latitude;
  final double? longitude;
  final int? rating;
  final String? feedback;

  const UserReportModel({
    required this.id,
    required this.type,
    required this. location,
    required this.status,
    this.beforeImageUrl,
    this.afterImageUrl,
    this.description,
    required this.submittedAt,
    this.workerName,
    this.workerPhone,
    this.workerImage,
    this.resolvedAt,
    this.cleanupDuration,
    this.latitude,
    this. longitude,
    this.rating,
    this.feedback,
  });

  // Computed properties
  bool get isResolved => status == 'resolved';
  bool get hasAfterImage => afterImageUrl != null;
  bool get needsRating => isResolved && rating == null;
  bool get hasWorker => workerName != null;

  UserReportModel copyWith({
    String? id,
    String?  type,
    String? location,
    String? status,
    String? beforeImageUrl,
    String? afterImageUrl,
    String? description,
    DateTime?  submittedAt,
    String? workerName,
    String? workerPhone,
    String? workerImage,
    DateTime? resolvedAt,
    Duration? cleanupDuration,
    double? latitude,
    double?  longitude,
    int? rating,
    String? feedback,
  }) {
    return UserReportModel(
      id: id ??  this.id,
      type: type ?? this.type,
      location: location ?? this.location,
      status: status ?? this. status,
      beforeImageUrl:  beforeImageUrl ?? this.beforeImageUrl,
      afterImageUrl:  afterImageUrl ?? this.afterImageUrl,
      description: description ??  this.description,
      submittedAt: submittedAt ??  this.submittedAt,
      workerName: workerName ?? this.workerName,
      workerPhone: workerPhone ?? this.workerPhone,
      workerImage: workerImage ?? this.workerImage,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      cleanupDuration: cleanupDuration ?? this.cleanupDuration,
      latitude: latitude ??  this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      feedback: feedback ?? this. feedback,
    );
  }
}