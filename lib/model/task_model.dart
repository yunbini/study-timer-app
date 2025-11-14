import 'package:flutter/material.dart';

class Task {
  final int? id;                 // DB auto increment
  final Color color;
  final String title;
  final int hours;
  final int minutes;
  final int seconds;

  Task({
    this.id,
    required this.color,
    required this.title,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  // Convert Map → Task
  factory Task.fromMap(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int?,
      color: Color(json['color'] as int),
      title: json['title'] as String,
      hours: json['hours'] as int,
      minutes: json['minutes'] as int,
      seconds: json['seconds'] as int,
    );
  }

  // Convert Task → Map (DB 저장용)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'color': color.value,
      'title': title,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
    };
  }
}
