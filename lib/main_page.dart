import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hackathon/services/thingspeak_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ThingSpeakService _service = ThingSpeakService();

  int heartRate = 0;
  int breathRate = 0;
  List<FlSpot> heartRateData = [];
  List<FlSpot> breathRateData = [];

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _fetchVitalsData();
    _startDataFetching();
  }

  Future<void> _fetchVitalsData() async {
    final data = await _service.fetchVitals();
    if (data != null) {
      setState(() {
        heartRate = data['heartRate'] ?? 0;
        breathRate = data['breathRate'] ?? 0;

        // Add data to chart (keep last 20 points)
        heartRateData.add(FlSpot(heartRateData.length.toDouble(), heartRate.toDouble()));
        breathRateData.add(FlSpot(breathRateData.length.toDouble(), breathRate.toDouble()));

        if (heartRateData.length > 20) heartRateData.removeAt(0);
        if (breathRateData.length > 20) breathRateData.removeAt(0);
      });
    }
  }

  void _startDataFetching() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchVitalsData();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
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
            _buildLegend(),
            const SizedBox(height: 10),
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

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.show_chart, color: Colors.red, size: 20),
        SizedBox(width: 4),
        Text("Heart Rate", style: TextStyle(color: Colors.white)),
        SizedBox(width: 16),
        Icon(Icons.show_chart, color: Colors.blue, size: 20),
        SizedBox(width: 4),
        Text("Breathing Rate", style: TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildGraph() {
    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.white, width: 1),
          ),
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
