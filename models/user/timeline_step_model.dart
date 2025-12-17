import 'package:flutter/material.dart';

class TimelineStepModel {
  final String label;
  final DateTime?  timestamp;
  final bool isCompleted;
  final IconData icon;

  const TimelineStepModel({
    required this.label,
    this.timestamp,
    required this.isCompleted,
    required this.icon,
  });
}