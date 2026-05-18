#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class AutoTranslator {
  static const String _baseUrl =
      'https://translate.googleapis.com/translate_a/single';

  static Future<String?> translate(String text, String targetLanguage) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl?client=gtx&sl=en&tl=$targetLanguage&dt=t&q=${Uri.encodeComponent(text)}',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        if (data.isNotEmpty && data[0] is List) {
          final translations = (data[0] as List)
              .where((item) => item is List && item.isNotEmpty)
              .map((item) => item[0] as String)
              .toList();
          return translations.join('');
        }
      }
    } catch (e) {
      // Translation failed silently
    }
    return null;
  }
}

void main(List<String> args) async {
  const l10nDir = 'lib/l10n';
  const sourceFile = 'app_en.arb';
  bool autoTranslate = args.contains('--auto-translate');

  final sourcePath = path.join(l10nDir, sourceFile);

  if (!File(sourcePath).existsSync()) {
    exit(1);
  }

  // Read source file
  final sourceContent = await File(sourcePath).readAsString();
  final sourceData = jsonDecode(sourceContent) as Map<String, dynamic>;

  // Get all ARB files in the directory
  final l10nDirectory = Directory(l10nDir);
  final arbFiles = l10nDirectory
      .listSync()
      .where((entity) => entity is File && entity.path.endsWith('.arb'))
      .cast<File>()
      .where((file) => path.basename(file.path) != sourceFile)
      .toList();

  for (final _ in arbFiles) {}

  if (autoTranslate) {}

  // int totalAdded = 0;
  // int totalTranslated = 0;

  for (final targetFile in arbFiles) {
    final targetPath = targetFile.path;
    final targetFilename = path.basename(targetPath);

    // Extract language code from filename (e.g., app_he.arb -> he)
    final languageCode = targetFilename.replaceAll(
      RegExp(r'^app_(.+)\.arb$'),
      r'\1',
    );

    // Read target file
    Map<String, dynamic> targetData;
    try {
      final targetContent = await targetFile.readAsString();
      targetData = jsonDecode(targetContent) as Map<String, dynamic>;
    } catch (e) {
      continue;
    }

    // Find missing strings
    final missingKeys = <String>[];
    final addedEntries = <String, dynamic>{};

    for (final entry in sourceData.entries) {
      final key = entry.key;
      final value = entry.value;

      if (!targetData.containsKey(key)) {
        missingKeys.add(key);

        // Add the key with appropriate value
        if (key.startsWith('@')) {
          // For metadata entries (@key), copy as-is
          addedEntries[key] = value;
        } else {
          String translationValue = '';

          if (autoTranslate && value is String && value.isNotEmpty) {
            final translated = await AutoTranslator.translate(
              value,
              languageCode,
            );
            if (translated != null) {
              translationValue = translated;
              // totalTranslated++;
            } else {}
          }

          addedEntries[key] = translationValue;
        }
      }
    }

    if (missingKeys.isEmpty) {
      continue;
    }

    for (final key in missingKeys) {
      if (key.startsWith('@')) {
      } else {
        final value = addedEntries[key];
        if (value.toString().isEmpty) {
        } else {}
      }
    }

    // Merge the data
    final updatedData = Map<String, dynamic>.from(targetData);
    updatedData.addAll(addedEntries);

    // Sort keys for consistent ordering
    final sortedKeys = updatedData.keys.toList()..sort();
    final sortedData = <String, dynamic>{};
    for (final key in sortedKeys) {
      sortedData[key] = updatedData[key];
    }

    // Write back to file with pretty formatting
    final jsonString = const JsonEncoder.withIndent('  ').convert(sortedData);
    await targetFile.writeAsString('$jsonString\n');

    // totalAdded += missingKeys.length;
  }

  if (autoTranslate) {
  } else {}
}
