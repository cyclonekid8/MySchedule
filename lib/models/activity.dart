import 'package:flutter/material.dart';

// Free categories
const List<Category> freeCategories = [
  Category.work,
  Category.personal,
  Category.healthFitness,
];

enum Category {
  work, personal, healthFitness, social, errands, custom,
}

extension CategoryExtension on Category {
  String get label {
    switch (this) {
      case Category.work: return 'Work';
      case Category.personal: return 'Personal';
      case Category.healthFitness: return 'Health & Fitness';
      case Category.social: return 'Social';
      case Category.errands: return 'Errands';
      case Category.custom: return 'Custom';
    }
  }

  Color get color {
    switch (this) {
      case Category.work: return const Color(0xFF6C63FF);
      case Category.personal: return const Color(0xFFFF6B6B);
      case Category.healthFitness: return const Color(0xFF43E97B);
      case Category.social: return const Color(0xFFF7971E);
      case Category.errands: return const Color(0xFF4FACFE);
      case Category.custom: return const Color(0xFF6C63FF);
    }
  }

  String get emoji {
    switch (this) {
      case Category.work: return '💼';
      case Category.personal: return '🙋';
      case Category.healthFitness: return '🏃';
      case Category.social: return '👥';
      case Category.errands: return '🛒';
      case Category.custom: return '⭐';
    }
  }

  bool get isFree => freeCategories.contains(this);
}

enum RepeatType { none, daily, weekly, monthly }

extension RepeatTypeExtension on RepeatType {
  String get label {
    switch (this) {
      case RepeatType.none: return 'None';
      case RepeatType.daily: return 'Daily';
      case RepeatType.weekly: return 'Weekly';
      case RepeatType.monthly: return 'Monthly';
    }
  }
}

class Activity {
  final String id;
  String title;
  DateTime startTime;
  DateTime endTime;
  Category category;
  String customCategoryName;
  Color customCategoryColor;
  RepeatType repeat;
  bool hasCompletionTracking;
  bool isDone;
  bool hasReminder;
  int reminderMinutesBefore;

  Activity({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.category,
    this.customCategoryName = '',
    this.customCategoryColor = const Color(0xFF6C63FF),
    this.repeat = RepeatType.none,
    this.hasCompletionTracking = false,
    this.isDone = false,
    this.hasReminder = false,
    this.reminderMinutesBefore = 15,
  });

  String get displayCategory =>
      category == Category.custom ? customCategoryName : category.label;

  Color get displayColor =>
      category == Category.custom ? customCategoryColor : category.color;

  Activity copyWith({
    String? title, DateTime? startTime, DateTime? endTime,
    Category? category, String? customCategoryName,
    Color? customCategoryColor, RepeatType? repeat,
    bool? hasCompletionTracking, bool? isDone,
    bool? hasReminder, int? reminderMinutesBefore,
  }) {
    return Activity(
      id: id, title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
      customCategoryName: customCategoryName ?? this.customCategoryName,
      customCategoryColor: customCategoryColor ?? this.customCategoryColor,
      repeat: repeat ?? this.repeat,
      hasCompletionTracking: hasCompletionTracking ?? this.hasCompletionTracking,
      isDone: isDone ?? this.isDone,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'category': category.name,
    'customCategoryName': customCategoryName,
    'customCategoryColor': customCategoryColor.value,
    'repeat': repeat.index,
    'hasCompletionTracking': hasCompletionTracking,
    'isDone': isDone, 'hasReminder': hasReminder,
    'reminderMinutesBefore': reminderMinutesBefore,
  };

  factory Activity.fromJson(Map<String, dynamic> json) {
    // Support both old index-based and new name-based category format
    Category category;
    if (json['category'] is int) {
      // Legacy: map old indices to new categories
      const legacyMap = {
        0: Category.work,
        1: Category.personal,
        2: Category.healthFitness,
        3: Category.social,
        4: Category.errands,
        5: Category.custom, // prayer -> custom
        6: Category.custom, // tankMaintenance -> custom
        7: Category.custom, // crSupport -> custom
        8: Category.custom, // laundry -> custom
        9: Category.custom,
      };
      category = legacyMap[json['category']] ?? Category.custom;
    } else {
      category = Category.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => Category.custom,
      );
    }

    return Activity(
      id: json['id'], title: json['title'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      category: category,
      customCategoryName: json['customCategoryName'] ?? '',
      customCategoryColor: Color(json['customCategoryColor'] ?? 0xFF6C63FF),
      repeat: RepeatType.values[json['repeat']],
      hasCompletionTracking: json['hasCompletionTracking'] ?? false,
      isDone: json['isDone'] ?? false,
      hasReminder: json['hasReminder'] ?? false,
      reminderMinutesBefore: json['reminderMinutesBefore'] ?? 15,
    );
  }
}
