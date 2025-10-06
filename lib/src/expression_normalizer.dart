/// Normalises expression strings prior to lexing.
///
/// Currently the normaliser converts vector and matrix literals written with
/// square bracket notation into function calls that can be handled by the
/// existing parser (`vector(...)` and `matrix(...)`). For example:
///
/// ```text
/// [1, 2, 3]          -> vector(1, 2, 3)
/// [[1,2],[3,4]]     -> matrix(vector(1, 2), vector(3, 4))
/// [1, 2; 3, 4]      -> matrix(vector(1, 2), vector(3, 4))
/// ```
class ExpressionNormalizer {
  /// Normalises matrix and vector literals in [expression].
  static String normalize(String expression) {
    if (!expression.contains('[')) return expression;

    final bufferStack = <StringBuffer>[];
    final output = StringBuffer();

    for (var i = 0; i < expression.length; i++) {
      final char = expression[i];

      if (char == '[') {
        bufferStack.add(StringBuffer());
        continue;
      }

      if (char == ']') {
        if (bufferStack.isEmpty) {
          throw const FormatException('Mismatched closing bracket ]');
        }

        final content = bufferStack.removeLast().toString();
        final converted = _convertList(content.trim());

        if (bufferStack.isEmpty) {
          output.write(converted);
        } else {
          bufferStack.last.write(converted);
        }
        continue;
      }

      if (bufferStack.isEmpty) {
        output.write(char);
      } else {
        bufferStack.last.write(char);
      }
    }

    if (bufferStack.isNotEmpty) {
      throw const FormatException('Unclosed matrix/vector literal');
    }

    return output.toString();
  }

  static String _convertList(String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Empty matrix/vector literal');
    }

    if (_hasTopLevelSeparator(trimmed, ';')) {
      final rows = _splitTopLevel(trimmed, ';');
      final convertedRows = rows.map(_convertRow).toList();

      return 'matrix(${convertedRows.join(', ')})';
    }

    final elements = _splitTopLevel(trimmed, ',');
    final convertedElements = elements
        .map((element) => element.trim())
        .where((element) => element.isNotEmpty)
        .toList();

    final isMatrix = convertedElements.isNotEmpty &&
        convertedElements.every((element) =>
            element.startsWith('vector(') || element.startsWith('matrix('));

    if (isMatrix) {
      return 'matrix(${convertedElements.join(', ')})';
    }

    return 'vector(${convertedElements.join(', ')})';
  }

  static String _convertRow(String row) {
    final elements = _splitTopLevel(row, ',');
    final values = elements
        .map((element) => element.trim())
        .where((element) => element.isNotEmpty)
        .toList();

    if (values.isEmpty) {
      throw const FormatException('Empty row in matrix literal');
    }

    return 'vector(${values.join(', ')})';
  }

  static bool _hasTopLevelSeparator(String input, String separator) {
    var depthParen = 0;
    var depthBracket = 0;

    for (var i = 0; i < input.length; i++) {
      final char = input[i];

      switch (char) {
        case '(':
          depthParen++;
        case ')':
          depthParen--;
        case '[':
          depthBracket++;
        case ']':
          depthBracket--;
        default:
          if (char == separator && depthParen == 0 && depthBracket == 0) {
            return true;
          }
      }
    }

    return false;
  }

  static List<String> _splitTopLevel(String input, String separator) {
    final parts = <String>[];
    var current = StringBuffer();
    var depthParen = 0;
    var depthBracket = 0;

    for (var i = 0; i < input.length; i++) {
      final char = input[i];

      switch (char) {
        case '(':
          depthParen++;
          current.write(char);
        case ')':
          depthParen--;
          current.write(char);
        case '[':
          depthBracket++;
          current.write(char);
        case ']':
          depthBracket--;
          current.write(char);
        default:
          if (char == separator && depthParen == 0 && depthBracket == 0) {
            parts.add(current.toString());
            current = StringBuffer();
          } else {
            current.write(char);
          }
      }
    }

    final tail = current.toString();
    if (tail.isNotEmpty) {
      parts.add(tail);
    }

    return parts;
  }
}
