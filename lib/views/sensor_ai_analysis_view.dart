import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Asegúrate de tener esta dependencia en pubspec.yaml.
import '../services/api_service.dart';

class SensorAIAnalysisView extends StatefulWidget {
  final String deviceId;

  const SensorAIAnalysisView({Key? key, required this.deviceId}) : super(key: key);

  @override
  _SensorAIAnalysisViewState createState() => _SensorAIAnalysisViewState();
}

class _SensorAIAnalysisViewState extends State<SensorAIAnalysisView> {
  bool _loading = true;
  double? _puntajeRendimiento;
  List<double> _puntajesDetallados = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchAIAnalysis();
  }

  Future<void> _fetchAIAnalysis() async {
    try {
      final result = await ApiService.analizarRendimientoPostCarrera(widget.deviceId);

      if (result['status'] == 'success') {
        setState(() {
          _puntajeRendimiento = result['puntaje_rendimiento'];
          _puntajesDetallados = List<double>.from(result['puntajes_detallados']);
          _loading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Error desconocido';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al obtener los datos de análisis IA';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( 'Análisis IA - ${widget.deviceId}',
          style: const TextStyle(fontSize: 20),),
          ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Puntaje Total: ${_puntajeRendimiento?.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawHorizontalLine: true,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: Colors.grey.withOpacity(0.5),
                                  strokeWidth: 0.5,
                                );
                              },
                              drawVerticalLine: false,
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  interval: 100, // Saltos de 100 en el eje Y
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toStringAsFixed(0),
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  interval: 1, // Mostrar cada punto en el eje X
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: const Border(
                                left: BorderSide(color: Colors.black, width: 0.5),
                                bottom: BorderSide(color: Colors.black, width: 0.5),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                isCurved: true, // Curva activada
                                curveSmoothness: 0.2, // Control de suavidad de la curva
                                spots: _puntajesDetallados.asMap().entries.map((entry) {
                                  return FlSpot(entry.key.toDouble(), entry.value);
                                }).toList(),
                                color: Colors.blue,
                                dotData: FlDotData(show: true), // Puntos visibles
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.blue.withOpacity(0.2),
                                ),
                              ),
                            ],
                            minX: 0,
                            maxX: _puntajesDetallados.length.toDouble() - 1,
                            minY: (_puntajesDetallados.reduce((a, b) => a < b ? a : b) - 100)
                                .floorToDouble(), // Ajuste dinámico para negativos
                            maxY: (_puntajesDetallados.reduce((a, b) => a > b ? a : b) + 100)
                                .ceilToDouble(), // Ajuste dinámico para positivos
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
