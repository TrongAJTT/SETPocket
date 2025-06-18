import 'package:flutter/material.dart';
import 'package:setpocket/models/graphing_function.dart';

class FunctionGroupHistory {
  final String id;
  final List<GraphingFunction> functions;
  final DateTime savedAt;
  final double aspectRatio;

  FunctionGroupHistory({
    required this.id,
    required this.functions,
    required this.savedAt,
    this.aspectRatio = 1.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'functions': functions
          .map((f) => {
                'id': f.id,
                'expression': f.expression,
                'isVisible': f.isVisible,
                'color': f.color.toARGB32(),
                'errorMessage': f.errorMessage,
                'createdAt': f.createdAt.toIso8601String(),
                'lastModified': f.lastModified?.toIso8601String(),
              })
          .toList(),
      'savedAt': savedAt.toIso8601String(),
      'aspectRatio': aspectRatio,
    };
  }

  factory FunctionGroupHistory.fromJson(Map<String, dynamic> json) {
    return FunctionGroupHistory(
      id: json['id'],
      functions: (json['functions'] as List)
          .map((f) => GraphingFunction(
                id: f['id'],
                expression: f['expression'],
                isVisible: f['isVisible'] ?? true,
                color: Color(f['color']),
                errorMessage: f['errorMessage'],
                createdAt: DateTime.parse(f['createdAt']),
                lastModified: f['lastModified'] != null
                    ? DateTime.parse(f['lastModified'])
                    : null,
              ))
          .toList(),
      savedAt: DateTime.parse(json['savedAt']),
      aspectRatio: json['aspectRatio']?.toDouble() ?? 1.0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FunctionGroupHistory &&
        other.id == id &&
        other.savedAt == savedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^ savedAt.hashCode;
  }
}
