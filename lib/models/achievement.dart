class Achievement {
  final String icon;
  final String title;
  final String fullTitle;
  final bool unlocked;
  final String? description;
  final int? requiredCount;

  Achievement({
    required this.icon,
    required this.title,
    required this.fullTitle,
    required this.unlocked,
    this.description,
    this.requiredCount,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      icon: json['icon'] ?? '',
      title: json['title'] ?? '',
      fullTitle: json['fullTitle'] ?? json['title'] ?? '',
      unlocked: json['unlocked'] ?? false,
      description: json['description'],
      requiredCount: json['requiredCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'icon': icon,
      'title': title,
      'fullTitle': fullTitle,
      'unlocked': unlocked,
      'description': description,
      'requiredCount': requiredCount,
    };
  }

  Achievement copyWith({
    String? icon,
    String? title,
    String? fullTitle,
    bool? unlocked,
    String? description,
    int? requiredCount,
  }) {
    return Achievement(
      icon: icon ?? this.icon,
      title: title ?? this.title,
      fullTitle: fullTitle ?? this.fullTitle,
      unlocked: unlocked ?? this.unlocked,
      description: description ?? this.description,
      requiredCount: requiredCount ?? this.requiredCount,
    );
  }
}
