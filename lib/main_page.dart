import 'dart:async'; // Import Timer
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hackathon/services/thingspeak_service.dart';
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ThingSpeakService _service = ThingSpeakService();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  int heartRate = 0;
  int breathRate = 0;
  List<FlSpot> heartRateData = [];
  List<FlSpot> breathRateData = [];

  late Timer _timer; // Declare the Timer

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _fetchVitalsData(); // Fetch data initially
    _startDataFetching(); // Start periodic fetching every 10 seconds
  }

  void _initializeNotifications() {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettings =
        InitializationSettings(android: android);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _fetchVitalsData() async {
    final data = await _service.fetchVitals();
    if (data != null) {
      setState(() {
        heartRate = data['heartRate'] ?? 0;
        breathRate = data['breathRate'] ?? 0;

        // Add new data points to the graph
        heartRateData.add(FlSpot(heartRateData.length.toDouble(), heartRate.toDouble()));
        breathRateData.add(FlSpot(breathRateData.length.toDouble(), breathRate.toDouble()));
      });

      // Check if values exceed thresholds and show alert if necessary
      if (heartRate > 100) {
        _showAlert('High Heart Rate', 'Heart Rate is too high: $heartRate BPM');
      }
      if (breathRate > 25) {
        _showAlert('High Breathing Rate', 'Breathing Rate is too high: $breathRate BPM');
      }
    }
  }

  void _startDataFetching() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchVitalsData(); // Fetch data every 10 seconds
    });
  }

  Future<void> _showAlert(String title, String message) async {
    const androidDetails = AndroidNotificationDetails(
      'alert_channel', 
      'Alert Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    final details = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
      0, 
      title, 
      message, 
      details,
      payload: 'item x',
    );
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("RadarCare"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Live Vitals",
              style: TextStyle(
                fontSize: 24,
                color: Colors.tealAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            _buildVitalsCard("Heart Rate", "$heartRate BPM", Icons.favorite),
            const SizedBox(height: 20),
            _buildVitalsCard("Breathing Rate", "$breathRate bpm", Icons.air),
            const SizedBox(height: 30),
            _buildGraph(),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalsCard(String title, String value, IconData icon) {
    return Card(
      elevation: 6,
      color: Colors.teal.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.tealAccent, size: 32),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            color: Colors.tealAccent,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildGraph() {
    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: true, border: Border.all(color: Colors.white, width: 1)),
          lineBarsData: [
            LineChartBarData(
              spots: heartRateData,
              isCurved: true,
              color: Colors.red,
              barWidth: 4,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(show: false),
            ),
            LineChartBarData(
              spots: breathRateData,
              isCurved: true,
              color: Colors.blue,
              barWidth: 4,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
