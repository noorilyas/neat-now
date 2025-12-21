import 'package:flutter/material.dart';

/// Employee user profile
class EmployeeUser {
  final String id;
  final String name;
  final String email;
  final String?   profileImage;
  final String?  phone;
  final String role;

  const EmployeeUser({
    required this.id,
    required this.name,
    required this.  email,
    this.profileImage,
    this. phone,
    this.role = 'employee',
  });

  factory EmployeeUser.fromMap(Map<String, dynamic> map) {
    return EmployeeUser(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? 'Employee',
      email: map['email'] ?? '',
      profileImage:  map['profile_image'] ?? map['profileImage'],
      phone:  map['phone'],
      role: map['role'] ?? 'employee',
    );
  }

  String get avatarInitial => name.isNotEmpty ? name[0]. toUpperCase() : 'E';
}

/// Overdue reports data
class OverdueData {
  final int count;
  final bool hasOverdue;
  final bool hasShownDialog;

  const OverdueData({
    required this.count,
    this.hasOverdue = false,
    this.hasShownDialog = false,
  });

  OverdueData copyWith({
    int? count,
    bool?  hasOverdue,
    bool?  hasShownDialog,
  }) {
    return OverdueData(
      count: count ??  this.count,
      hasOverdue: hasOverdue ?? this. hasOverdue,
      hasShownDialog: hasShownDialog ??  this.hasShownDialog,
    );
  }
}