import 'package:setpocket/models/text_template/text_template_components.dart';

/// A utility class for parsing template content to extract structural elements.
/// This logic was previously part of the old TemplateManager.
class TemplateParser {
  // REGEX UPDATED: Matches {{id:title:type}}
  static final RegExp _elementRegExp =
      RegExp(r'\{\{([a-zA-Z0-9_.-]+):(.+?):(.+?)\}\}', dotAll: true);

  // REGEX UPDATED: Matches [[LOOP:id:title]]...[[/LOOP:id]]
  static final RegExp _loopRegExp = RegExp(
      r'\[\[LOOP:([a-zA-Z0-9_.-]+):(.*?)\]\](.*?)\[\[\/LOOP:\1\]\]',
      dotAll: true);

  /// Finds all template elements in the content, including those inside loops.
  static List<TemplateElement> findElementsInContent(String content) {
    final List<TemplateElement> elements = [];
    final elementMatches = _elementRegExp.allMatches(content);
    final loopMatches = _loopRegExp.allMatches(content);

    for (final elementMatch in elementMatches) {
      final elementId = elementMatch.group(1);
      final elementTitle = elementMatch.group(2);
      final elementType = elementMatch.group(3);

      if (elementId != null && elementTitle != null && elementType != null) {
        String? containingLoopId;

        // Check if this element is inside any of the found loops
        for (final loopMatch in loopMatches) {
          final loopContent = loopMatch.group(3)!;
          final loopContentStartIndex =
              loopMatch.start + loopMatch.group(0)!.indexOf(loopContent);

          // Check if the element match is within the loop's inner content boundaries
          if (elementMatch.start >= loopContentStartIndex &&
              elementMatch.end <= loopContentStartIndex + loopContent.length) {
            containingLoopId = loopMatch.group(1);
            break; // Found the containing loop, no need to check others
          }
        }

        elements.add(TemplateElement(
          id: elementId,
          title: elementTitle,
          type: elementType,
          loopId: containingLoopId,
        ));
      }
    }
    return elements;
  }

  /// Finds all data loop blocks in the content.
  static List<DataLoop> findDataLoopsInContent(String content) {
    final List<DataLoop> loops = [];
    final matches = _loopRegExp.allMatches(content);

    for (final match in matches) {
      final id = match.group(1);
      final title = match.group(2);
      final innerContent = match.group(3);

      if (id != null && title != null && innerContent != null) {
        // Find elements *within this specific loop's inner content*
        final elementMatchesInLoop = _elementRegExp.allMatches(innerContent);
        final List<TemplateElement> loopElements = [];
        for (final elementMatch in elementMatchesInLoop) {
          final elId = elementMatch.group(1);
          final elTitle = elementMatch.group(2);
          final elType = elementMatch.group(3);
          if (elId != null && elTitle != null && elType != null) {
            loopElements.add(TemplateElement(
              id: elId,
              title: elTitle,
              type: elType,
              loopId: id, // Assign loopId
            ));
          }
        }

        loops.add(DataLoop(
          id: id,
          title: title,
          elements: loopElements,
          rawContent: innerContent,
        ));
      }
    }
    return loops;
  }

  /// Finds duplicate element IDs.
  static Map<String, List<TemplateElement>> findDuplicateIds(
      List<TemplateElement> elements) {
    final idCounts = <String, List<TemplateElement>>{};
    for (final element in elements) {
      idCounts.update(
        element.id,
        (list) => list..add(element),
        ifAbsent: () => [element],
      );
    }
    idCounts.removeWhere((key, value) => value.length < 2);
    return idCounts;
  }

  /// Validates the loop structure in the content.
  /// Returns true if all loops are correctly opened and closed.
  static bool validateLoops(String content) {
    final loopStarts = _loopRegExp.allMatches(content).length;
    final loopEnds =
        RegExp(r'\[\[\/LOOP:[a-zA-Z0-9_.-]+\]\]').allMatches(content).length;
    return loopStarts == loopEnds;
  }
}
