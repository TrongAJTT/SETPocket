import 'package:isar/isar.dart';

part 'text_templates_data.g.dart';

// A simple FNV-1a hash function, consistent with other models in the app.
int fastHash(String string) {
  var hash = 0xcbf29ce484222325;
  for (var i = 0; i < string.length; i++) {
    hash ^= string.codeUnitAt(i);
    hash *= 0x100000001b3;
  }
  return hash;
}

/// A unified data model for text templates, supporting different states.
/// This single schema replaces the previous separate 'Template' and draft logic.
@collection
class TextTemplatesData {
  Id get isarId => fastHash(id);

  /// A unique identifier for the template, typically a UUID.
  @Index(unique: true, replace: true)
  late String id;

  /// The title of the template.
  late String title;

  /// The main content of the template, including placeholders.
  late String content;

  /// The current status of the template (e.g., draft, complete, deleted).
  @Index()
  @Enumerated(EnumType.name)
  late TemplateStatus status;

  /// The timestamp when the template was first created.
  @Index()
  late DateTime createdAt;

  /// The timestamp when the template was last updated.
  @Index()
  late DateTime updatedAt;

  TextTemplatesData();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TextTemplatesData.fromJson(Map<String, dynamic> json) {
    return TextTemplatesData()
      ..id = json['id'] as String
      ..title = json['title'] as String
      ..content = json['content'] as String
      ..status = TemplateStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'draft'),
        orElse: () => TemplateStatus.draft,
      )
      ..createdAt = DateTime.parse(json['createdAt'] as String)
      ..updatedAt = DateTime.parse(json['updatedAt'] as String);
  }
}

/// Defines the lifecycle status of a [TextTemplatesData] entry.
enum TemplateStatus {
  /// The template is a work-in-progress and not yet published for use.
  draft,

  /// The template is complete and available for use.
  complete,

  /// The template has been marked for deletion and is in the trash.
  /// This allows for recovery before permanent deletion.
  deleted,
}
