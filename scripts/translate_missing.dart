#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<String?> translateText(String text, String targetLanguage) async {
  try {
    final response = await http.get(
      Uri.parse('https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=$targetLanguage&dt=t&q=${Uri.encodeComponent(text)}'),
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
    stderr.writeln('Translation error: $e');
  }
  return null;
}

void main() async {
  const hebrewFile = 'lib/l10n/app_he.arb';
  const englishFile = 'lib/l10n/app_en.arb';
  
  
  // Read English source
  final englishContent = await File(englishFile).readAsString();
  final englishData = jsonDecode(englishContent) as Map<String, dynamic>;
  
  // Read Hebrew target
  final hebrewContent = await File(hebrewFile).readAsString();
  final hebrewData = jsonDecode(hebrewContent) as Map<String, dynamic>;
  
  
  int translatedCount = 0;
  final updates = <String, dynamic>{};
  
  for (final entry in englishData.entries) {
    final key = entry.key;
    final value = entry.value;
    
    // Skip metadata entries
    if (key.startsWith('@')) continue;
    
    // Check if missing or empty in Hebrew
    if (!hebrewData.containsKey(key) || (hebrewData[key] as String).isEmpty) {
      if (value is String && value.isNotEmpty) {
        final translated = await translateText(value, 'he');
        
        if (translated != null) {
          updates[key] = translated;
          translatedCount++;
        } else {
          updates[key] = ''; // Keep empty if translation fails
        }
      }
    }
  }
  
  if (translatedCount > 0) {
    // Update Hebrew file with translations
    final updatedData = Map<String, dynamic>.from(hebrewData);
    updatedData.addAll(updates);
    
    // Sort keys
    final sortedKeys = updatedData.keys.toList()..sort();
    final sortedData = <String, dynamic>{};
    for (final key in sortedKeys) {
      sortedData[key] = updatedData[key];
    }
    
    // Write back
    final jsonString = const JsonEncoder.withIndent('  ').convert(sortedData);
    await File(hebrewFile).writeAsString('$jsonString\n');
    
  } else {
  }
}
