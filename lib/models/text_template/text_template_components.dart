/// Represents a single data field element within a template.
class TemplateElement {
  final String id;
  final String title;
  final String type; // 'text', 'number', 'date', etc.
  String? loopId; // The ID of the loop this element belongs to, if any.

  TemplateElement({
    required this.id,
    required this.title,
    required this.type,
    this.loopId,
  });

  /// Converts the element to its string representation for template content.
  String toElementString() {
    return '{{$id:$title:$type}}';
  }
}

/// Represents a data loop block within a template.
class DataLoop {
  final String id;
  final String title;
  final List<TemplateElement> elements;
  final String rawContent;

  DataLoop({
    required this.id,
    required this.title,
    required this.elements,
    required this.rawContent,
  });

  /// Converts the loop to its start tag string representation.
  String toLoopStartString() {
    return '[[LOOP:$id:$title]]';
  }

  /// Converts the loop to its end tag string representation.
  String toLoopEndString() {
    return '[[/LOOP:$id]]';
  }
}
