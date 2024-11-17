import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MembershipView extends StatefulWidget {
  final int usuarioId;
  final VoidCallback onMembershipPaid;

  const MembershipView({
    Key? key,
    required this.usuarioId,
    required this.onMembershipPaid,
  }) : super(key: key);

  @override
  _MembershipViewState createState() => _MembershipViewState();
}

class _MembershipViewState extends State<MembershipView> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  bool _loading = false;

  void _payMembership() async {
    final cardNumber = _cardNumberController.text.trim();
    final expiryDate = _expiryDateController.text.trim();
    final cvv = _cvvController.text.trim();
    final cardHolder = _cardHolderController.text.trim();

    if (cardNumber.isEmpty || expiryDate.isEmpty || cvv.isEmpty || cardHolder.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos')),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    final response = await ApiService.createMembership({
      'usuario_id': widget.usuarioId.toString(),
      'numero_tarjeta': cardNumber,
      'fecha_vencimiento': expiryDate,
      'cvv': cvv,
      'nombre_titular': cardHolder,
    });

    setState(() {
      _loading = false;
    });

    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Membresía pagada exitosamente')),
      );
      widget.onMembershipPaid();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Error al pagar la membresía')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membresía Premium'),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: const Text(
                      'Acceso a Membresía Premium',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Para utilizar la aplicación, es necesario adquirir una membresía premium. El costo es de S/200 por mes.',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  const Text(
                    'Detalles de Pago',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _cardNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Número de Tarjeta',
                      prefixIcon: Icon(Icons.credit_card),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _expiryDateController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha de Vencimiento (MM/AA)',
                      prefixIcon: Icon(Icons.date_range),
                    ),
                    keyboardType: TextInputType.datetime,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _cvvController,
                    decoration: const InputDecoration(
                      labelText: 'CVV',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _cardHolderController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Titular',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loading ? null : _payMembership,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Pagar',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
