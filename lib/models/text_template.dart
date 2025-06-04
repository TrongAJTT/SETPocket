import 'package:logger/logger.dart';

class Template {
  final String id;
  final String title;
  final String content;

  Template({
    required this.id,
    required this.title,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
      };

  factory Template.fromJson(Map<String, dynamic> json) => Template(
        id: json['id'],
        title: json['title'],
        content: json['content'],
      );

  Template copyWith({String? id, String? title, String? content}) {
    return Template(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }

  @override
  String toString() => 'Template(id: $id, title: $title)';
}

class TemplateElement {
  final String type; // text, largetext, number, date, time, datetime
  final String title;
  final String id;
  final String?
      loopId; // ID của vòng lặp mà phần tử này thuộc về, null nếu không thuộc vòng lặp nào

  TemplateElement({
    required this.type,
    required this.title,
    required this.id,
    this.loopId,
  });

  factory TemplateElement.parse(String elementString, {String? loopId}) {
    // Format: <elm:type:title:id>
    final regex = RegExp(
        r'<elm:(text|largetext|number|date|time|datetime):([^:]+):([^>]+)>');
    final match = regex.firstMatch(elementString);

    if (match != null) {
      return TemplateElement(
        type: match.group(1)!,
        title: match.group(2)!,
        id: match.group(3)!,
        loopId: loopId,
      );
    }

    throw FormatException('Invalid template element format: $elementString');
  }

  String toElementString() {
    return '<elm:$type:$title:$id>';
  }

  @override
  String toString() => toElementString();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is TemplateElement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class DataLoop {
  final String id;
  final String title;

  DataLoop({
    required this.id,
    required this.title,
  });

  // Format: {{loop:TITLE:ID:
  factory DataLoop.parse(String loopStartString) {
    final regex = RegExp(r'\{\{loop:([^:]+):([^:]+):');
    final match = regex.firstMatch(loopStartString);

    if (match != null) {
      return DataLoop(
        title: match.group(1)!,
        id: match.group(2)!,
      );
    }

    throw FormatException('Invalid data loop format: $loopStartString');
  }

  String toLoopStartString() {
    return '{{loop:$title:$id:';
  }

  String toLoopEndString() {
    return '}}';
  }

  @override
  String toString() => 'DataLoop(id: $id, title: $title)';
}

class TemplateManager {
  static final RegExp _elementRegex = RegExp(
      r'<elm:(text|largetext|number|date|time|datetime):([^:]+):([^>]+)>');
  static final RegExp _loopStartRegex = RegExp(r'\{\{loop:([^:]+):([^:]+):');
  static final RegExp _loopEndRegex = RegExp(r'\}\}');

  static List<TemplateElement> findElementsInContent(String content) {
    // Find all elements not in loop
    final elements = _findElementsNotInLoop(content);

    // Find loops
    final loops = findDataLoopsInContent(content);

    // Find elements in each loop
    for (var loop in loops) {
      final loopElements = _findElementsInLoop(content, loop.id);
      elements.addAll(loopElements);
    }

    return elements;
  }

  static List<TemplateElement> _findElementsNotInLoop(String content) {
    // Split the content by loop blocks to isolate non-loop content
    List<String> contentParts = [];
    int startIndex = 0;

    // Find all loops
    RegExp loopRegex =
        RegExp(r'\{\{loop:[^:]+:[^:]+:[\s\S]*?\}\}', multiLine: true);
    final loopMatches = loopRegex.allMatches(content);

    // Extract content between loops
    for (final match in loopMatches) {
      if (match.start > startIndex) {
        contentParts.add(content.substring(startIndex, match.start));
      }
      startIndex = match.end;
    }

    // Add remaining content
    if (startIndex < content.length) {
      contentParts.add(content.substring(startIndex));
    }

    // Find elements in non-loop content parts
    List<TemplateElement> elements = [];
    for (final part in contentParts) {
      final matches = _elementRegex.allMatches(part);
      elements.addAll(matches.map((match) => TemplateElement(
            type: match.group(1)!,
            title: match.group(2)!,
            id: match.group(3)!,
          )));
    }

    return elements;
  }

  static List<TemplateElement> _findElementsInLoop(
      String content, String loopId) {
    // Find the specific loop with the given ID
    final loopRegex =
        RegExp(r'\{\{loop:[^:]+:' + loopId + r':[\s\S]*?\}\}', multiLine: true);
    final loopMatch = loopRegex.firstMatch(content);

    if (loopMatch == null) {
      return [];
    }

    // Extract the loop content
    final loopContent = content.substring(loopMatch.start, loopMatch.end);

    // Find all elements within this loop
    final matches = _elementRegex.allMatches(loopContent);
    return matches
        .map((match) => TemplateElement(
              type: match.group(1)!,
              title: match.group(2)!,
              id: match.group(3)!,
              loopId: loopId,
            ))
        .toList();
  }

  static List<DataLoop> findDataLoopsInContent(String content) {
    List<DataLoop> loops = [];

    // Find all loop start tags
    final loopStartMatches = _loopStartRegex.allMatches(content);

    for (final match in loopStartMatches) {
      final loopStartString = content.substring(match.start, match.end);
      try {
        final loop = DataLoop.parse(loopStartString);
        loops.add(loop);
      } catch (e) {
        // Skip invalid loop formats
        var logger = Logger(printer: PrettyPrinter());
        logger.e('Error parsing loop: $e',
            error: e, stackTrace: StackTrace.current);
      }
    }

    return loops;
  }

  static bool validateLoops(String content) {
    // Check if each loop start has a corresponding end
    final loopStartMatches = _loopStartRegex.allMatches(content);
    final loopEndMatches = _loopEndRegex.allMatches(content);

    return loopStartMatches.length == loopEndMatches.length;
  }

  static bool hasDuplicateIds(List<TemplateElement> elements) {
    final idGroups = groupElementsById(elements);

    // Kiểm tra xem mỗi nhóm ID có chứa các element giống nhau không
    for (var elements in idGroups.values) {
      if (elements.length > 1) {
        final firstElement = elements.first;
        for (var i = 1; i < elements.length; i++) {
          // Nếu có trường element cùng ID nhưng khác type hoặc title -> lỗi
          if (elements[i].type != firstElement.type ||
              elements[i].title != firstElement.title) {
            return true;
          }
        }
      }
    }
    return false;
  }

  static Map<String, List<TemplateElement>> findDuplicateIds(
      List<TemplateElement> elements) {
    final idGroups = groupElementsById(elements);

    // Lọc ra các nhóm có cùng ID nhưng khác type hoặc title
    Map<String, List<TemplateElement>> inconsistentGroups = {};

    for (var entry in idGroups.entries) {
      final elements = entry.value;
      if (elements.length > 1) {
        final firstElement = elements.first;
        bool hasInconsistency = false;

        for (var i = 1; i < elements.length; i++) {
          if (elements[i].type != firstElement.type ||
              elements[i].title != firstElement.title) {
            hasInconsistency = true;
            break;
          }
        }

        if (hasInconsistency) {
          inconsistentGroups[entry.key] = elements;
        }
      }
    }

    return inconsistentGroups;
  }

  static Map<String, List<TemplateElement>> groupElementsById(
      List<TemplateElement> elements) {
    final idGroups = <String, List<TemplateElement>>{};
    for (var element in elements) {
      if (!idGroups.containsKey(element.id)) {
        idGroups[element.id] = [];
      }
      idGroups[element.id]!.add(element);
    }
    return idGroups;
  }
}
