import 'package:flutter/material.dart';

class GraphingFunction {
  final String id;
  String expression;
  bool isVisible;
  Color color;
  String? errorMessage;
  DateTime createdAt;
  DateTime? lastModified;

  GraphingFunction({
    required this.id,
    required this.expression,
    this.isVisible = true,
    required this.color,
    this.errorMessage,
    DateTime? createdAt,
    this.lastModified,
  }) : createdAt = createdAt ?? DateTime.now();

  GraphingFunction copyWith({
    String? id,
    String? expression,
    bool? isVisible,
    Color? color,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? lastModified,
  }) {
    return GraphingFunction(
      id: id ?? this.id,
      expression: expression ?? this.expression,
      isVisible: isVisible ?? this.isVisible,
      color: color ?? this.color,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expression': expression,
      'isVisible': isVisible,
      'color': color.toARGB32(),
      'errorMessage': errorMessage,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified?.toIso8601String(),
    };
  }

  factory GraphingFunction.fromJson(Map<String, dynamic> json) {
    return GraphingFunction(
      id: json['id'],
      expression: json['expression'],
      isVisible: json['isVisible'] ?? true,
      color: Color(json['color']),
      errorMessage: json['errorMessage'],
      createdAt: DateTime.parse(json['createdAt']),
      lastModified: json['lastModified'] != null
          ? DateTime.parse(json['lastModified'])
          : null,
    );
  }

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GraphingFunction &&
        other.id == id &&
        other.expression == expression &&
        other.isVisible == isVisible &&
        other.color == color;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        expression.hashCode ^
        isVisible.hashCode ^
        color.hashCode;
  }

  @override
  String toString() {
    return 'GraphingFunction(id: $id, expression: $expression, isVisible: $isVisible, color: $color)';
  }
}
