import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  // Test translation API
  const text = 'Connected Devices';
  const targetLang = 'he';

  try {
    final response = await http.get(
      Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=$targetLang&dt=t&q=${Uri.encodeComponent(text)}',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      if (data.isNotEmpty && data[0] is List) {
        final translations = (data[0] as List)
            .where((item) => item is List && item.isNotEmpty)
            .map((item) => item[0] as String)
            .toList();
        final _ = translations.join('');
      }
    } else {
      // HTTP error occurred
    }
  } catch (e) {
    // Handle translation errors silently
  }
}
