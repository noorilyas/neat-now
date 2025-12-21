class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String?  profileImage;
  final int totalReports;
  final int verifiedReports;
  final int pendingReports;
  final int rank;
  final int points;
  final String?  badge;
  final String memberSince;
  final String joinedDate;

  const UserModel({
    required this. id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    required this.totalReports,
    required this.verifiedReports,
    required this.pendingReports,
    required this. rank,
    required this.points,
    this.badge,
    required this. memberSince,
    required this.joinedDate,
  });

  // Default user for demo purposes
  static UserModel get defaultUser => const UserModel(
    id: '1',
    name: 'Demo User',
    email: 'demo@neatnow.com',
    phone: '+1234567890',
    profileImage: null,
    totalReports: 15,
    verifiedReports:  12,
    pendingReports:  3,
    rank: 5,
    points: 1250,
    badge: null,
    memberSince: 'Jan 2024',
    joinedDate: '2024-01-15',
  );

  // Create from Map (for compatibility with existing code)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id:  map['id']?. toString() ?? '1',
      name: map['name']?.toString() ?? 'Demo User',
      email: map['email']?.toString() ?? 'demo@neatnow.com',
      phone: map['phone']?.toString() ?? '+1234567890',
      profileImage: map['profileImage']?.toString(),
      totalReports: map['totalReports'] as int?  ?? 0,
      verifiedReports:  map['verifiedReports'] as int? ?? 0,
      pendingReports: map['pendingReports'] as int? ??  0,
      rank: map['rank'] as int? ?? 0,
      points: map['points'] as int? ?? 0,
      badge: map['badge']?.toString(),
      memberSince: map['memberSince']?.toString() ?? 'Jan 2024',
      joinedDate: map['joinedDate']?.toString() ?? '2024-01-15',
    );
  }


  // Convert to Map (for compatibility)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name':  name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'totalReports':  totalReports,
      'verifiedReports': verifiedReports,
      'pendingReports': pendingReports,
      'rank': rank,
      'points': points,
      'badge': badge,
      'memberSince': memberSince,
      'joinedDate': joinedDate,
    };
  }

  // CopyWith for immutability
  UserModel copyWith({
    String? id,
    String? name,
    String?  email,
    String? phone,
    String? profileImage,
    int? totalReports,
    int? verifiedReports,
    int? pendingReports,
    int? rank,
    int? points,
    String? badge,
    String? memberSince,
    String? joinedDate,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      totalReports:  totalReports ?? this.totalReports,
      verifiedReports: verifiedReports ?? this. verifiedReports,
      pendingReports: pendingReports ?? this.pendingReports,
      rank: rank ?? this. rank,
      points: points ??  this.points,
      badge: badge ?? this.badge,
      memberSince: memberSince ??  this.memberSince,
      joinedDate: joinedDate ??  this.joinedDate,
    );
  }


}