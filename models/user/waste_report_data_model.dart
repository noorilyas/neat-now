class WasteReportDataModel {
  final String imagePath;
  final double?  latitude;
  final double? longitude;
  final String address;
  final String wasteType;
  final String description;
  final String?  timestamp;
  final String status;
  final String? userId;
  final String imageSource;

  const WasteReportDataModel({
    required this.imagePath,
    this.latitude,
    this.longitude,
    required this.address,
    required this.wasteType,
    required this.description,
    this.timestamp,
    required this.status,
    this.userId,
    required this. imageSource,
  });

  Map<String, dynamic> toMap() {
    return {
      'imagePath': imagePath,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'wasteType': wasteType,
      'description': description,
      'timestamp': timestamp,
      'status': status,
      'userId':  userId,
      'imageSource':  imageSource,
    };
  }
}