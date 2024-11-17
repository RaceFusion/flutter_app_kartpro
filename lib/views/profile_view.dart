import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'membership_details_view.dart'; // Nueva vista para mostrar los detalles

class ProfileView extends StatefulWidget {
  final int usuarioId;

  const ProfileView({Key? key, required this.usuarioId}) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Map<String, dynamic>? _userProfile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final response = await ApiService.obtenerPerfil(widget.usuarioId);
      if (response['status'] == 'success') {
        setState(() {
          _userProfile = response['data'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Error al obtener perfil')),
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

  void _viewMembership() async {
    final response = await ApiService.checkMembership(widget.usuarioId);

    if (response['status'] == 'success') {
      final membershipData = response['data']['membresia'];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MembershipDetailsView(membershipData: membershipData),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'No se encontró membresía activa')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator(color: Colors.white)
            : _userProfile == null
                ? const Text(
                    'No se pudo cargar el perfil.',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  )
                : SingleChildScrollView(
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
                            const Text(
                              'Información del Perfil',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildProfileField('Usuario', _userProfile!['usuario']),
                            _buildProfileField('Nombres', _userProfile!['nombres']),
                            _buildProfileField('Apellidos', _userProfile!['apellidos']),
                            _buildProfileField('Correo', _userProfile!['correo']),
                            _buildProfileField('Rol', _userProfile!['rol']),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity, // Botón más ancho
                              child: ElevatedButton(
                                onPressed: _viewMembership,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                child: const Text(
                                  'Ver Membresía',
                                  style: TextStyle(color: Colors.white),
                                ),
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

  Widget _buildProfileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
