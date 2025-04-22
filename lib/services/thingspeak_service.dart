import 'dart:convert';
import 'package:http/http.dart' as http;

class ThingSpeakService {
  final String channelId = '2927796';
  final String readApiKey = 'QDTVN2ZKN07AIYCM';

  Future<Map<String, int>?> fetchVitals() async {
    final url = Uri.parse(
        'https://api.thingspeak.com/channels/$channelId/feeds.json?api_key=$readApiKey&results=1');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final feeds = data['feeds'];

        if (feeds.isNotEmpty) {
          final latestFeed = feeds[0];
          final heartRate = double.tryParse(latestFeed['field1'] ?? '0')?.round() ?? 0;
          final breathRate = double.tryParse(latestFeed['field2'] ?? '0')?.round() ?? 0;

          return {'heartRate': heartRate, 'breathRate': breathRate};
        }
      } else {
        print('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
    return null;
  }
}
