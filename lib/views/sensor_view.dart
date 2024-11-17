import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Asegúrate de agregar shared_preferences en pubspec.yaml.
import '../services/api_service.dart';
import 'widgets/sensor_card.dart';
import 'sensor_graph_view.dart';
import 'sensor_ai_analysis_view.dart';
import 'profile_view.dart';

class SensorView extends StatefulWidget {
  const SensorView({Key? key}) : super(key: key);

  @override
  _SensorViewState createState() => _SensorViewState();
}

class _SensorViewState extends State<SensorView> {
  final TextEditingController _deviceIdController = TextEditingController();
  List<Map<String, dynamic>> _sensors = [];
  bool _loading = false;
  int? _usuarioId;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _usuarioId = prefs.getInt('usuarioId');
    if (_usuarioId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Usuario no identificado')),
      );
    } else {
      _fetchDispositivos();
    }
  }

  void _fetchDispositivos() async {
    if (_usuarioId == null) return;

    setState(() {
      _loading = true;
    });

    try {
      final response = await ApiService.obtenerDispositivosUsuario(_usuarioId!);
      if (response['status'] == 'success') {
        setState(() {
          _sensors = List<Map<String, dynamic>>.from(response['dispositivos']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Error al cargar dispositivos')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al conectar con el servidor')),
      );
    }

    setState(() {
      _loading = false;
    });
  }

  void _addDispositivo() async {
    if (_usuarioId == null) return;

    final deviceId = _deviceIdController.text.trim();
    if (deviceId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingrese un ID de dispositivo')),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final response = await ApiService.asociarDispositivo(_usuarioId!, deviceId);
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dispositivo asociado exitosamente')),
        );
        _fetchDispositivos();
        _deviceIdController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Error al asociar dispositivo')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al conectar con el servidor')),
      );
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Dispositivos'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              if (_usuarioId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileView(usuarioId: _usuarioId!),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error: Usuario no identificado')),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0), // Espacio reducido
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 8.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Asociar Dispositivo',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _deviceIdController,
                        decoration: const InputDecoration(
                          labelText: 'ID del Dispositivo',
                          prefixIcon: Icon(Icons.device_hub, color: Colors.black),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                        cursorColor: Colors.black,
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 10), // Espacio reducido
                      ElevatedButton(
                        onPressed: _loading ? null : _addDispositivo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50.0,
                            vertical: 15.0,
                          ),
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Asociar',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _loading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : _sensors.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay sensores asociados.',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      )
                    : Container(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: PageView.builder(
                          itemCount: _sensors.length,
                          controller: PageController(viewportFraction: 1),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final sensor = _sensors[index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0), // Espacio reducido
                              child: SensorCard(
                                deviceId: sensor['device_id'] ?? 'Desconocido',
                                imagePath: 'assets/imagen_wokwi.png',
                                velocidad: sensor['velocidad'] ?? 0,
                                temperatura: sensor['temperatura'] ?? 0,
                                presion: sensor['presion'] ?? 0,
                                combustible: sensor['combustible'] ?? 0,
                                onMonitorizar: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SensorGraphView(
                                        deviceId: sensor['device_id']!,
                                      ),
                                    ),
                                  );
                                },
                                onAnalisisIA: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SensorAIAnalysisView(
                                        deviceId: sensor['device_id']!,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
