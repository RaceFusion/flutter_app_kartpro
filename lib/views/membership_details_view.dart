import 'package:flutter/material.dart';

class MembershipDetailsView extends StatelessWidget {
  final Map<String, dynamic> membershipData;

  const MembershipDetailsView({Key? key, required this.membershipData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Membresía'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 8.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Detalles de la Membresía',
                      style: TextStyle(
                        fontSize: 20.0, // Ajustado para una mejor apariencia
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildMembershipDetail('Tipo', membershipData['tipo']),
                  _buildMembershipDetail('Fecha de Inicio', membershipData['fecha_inicio']),
                  _buildMembershipDetail('Fecha de Fin', membershipData['fecha_fin']),
                  _buildMembershipDetail('Titular', membershipData['nombre_titular']),
                  const SizedBox(height: 20),
                  const Text(
                    'Beneficios:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14, // Reducido para alinearse con el resto
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '- Acceso ilimitado a todas las funcionalidades.',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  const Text(
                    '- Soporte técnico 24/7.',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  const Text(
                    '- Análisis avanzado de datos.',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMembershipDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14, // Reducido para evitar desbordamiento
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14, // Reducido para evitar desbordamiento
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1, // Ajustado para mantener texto en una sola línea
            ),
          ),
        ],
      ),
    );
  }
}
