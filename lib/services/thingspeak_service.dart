import 'dart:convert';
import 'package:http/http.dart' as http;

class ThingSpeakService {
  // Replace these with your ThingSpeak Channel ID and Read API Key
  final String channelId = 'YOUR_CHANNEL_ID';
  final String readApiKey = 'YOUR_READ_API_KEY';

  Future<Map<String, int>?> fetchVitals() async {
    final url = Uri.parse(
        'https://api.thingspeak.com/channels/$channelId/feeds.json?api_key=$readApiKey&results=2');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final feeds = data['feeds'];

        if (feeds.isNotEmpty) {
          final heartRate = int.parse(feeds[0]['field1'] ?? '0');
          final breathRate = int.parse(feeds[0]['field2'] ?? '0');
          
          return {'heartRate': heartRate, 'breathRate': breathRate};
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
    return null;
  }
}
