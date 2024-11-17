import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

class SensorGraphView extends StatefulWidget {
  final String deviceId;

  const SensorGraphView({Key? key, required this.deviceId}) : super(key: key);

  @override
  _SensorGraphViewState createState() => _SensorGraphViewState();
}

class _SensorGraphViewState extends State<SensorGraphView> {
  List<dynamic> _data = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistoricalData();
  }

  Future<void> _fetchHistoricalData() async {
    try {
      final response = await ApiService.obtenerDatosHistoricos(widget.deviceId);
      if (response['status'] == 'success') {
        setState(() {
          _data = response['data'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Error al cargar datos históricos')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al conectar con el servidor')),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  List<FlSpot> _getSpots(String key) {
    return _data
        .asMap()
        .entries
        .map((entry) => FlSpot(
              entry.key.toDouble(),
              entry.value[key].toDouble(),
            ))
        .toList();
  }

  Widget _buildChart(String title, String key, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getSpots(key),
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.5), color],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      barWidth: 4,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico - ${widget.deviceId}',
          style: const TextStyle(fontSize: 20),),
          ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildChart('Velocidad', 'velocidad', Colors.blue),
                    _buildChart('Temperatura', 'temperatura', Colors.red),
                    _buildChart('Presión', 'presion', Colors.green),
                    _buildChart('Combustible', 'combustible', Colors.orange),
                  ],
                ),
              ),
            ),
    );
  }
}
