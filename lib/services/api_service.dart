import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart'; // Ajusta según la ubicación real

class ApiService {
  // Verificar membresía activa

  static Future<Map<String, dynamic>> checkMembership(int usuarioId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/verificar_membresia/$usuarioId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': 'success',
          'data': data,
        };
      } else if (response.statusCode == 404) {
        return {
          'status': 'error',
          'message': 'El usuario no tiene una membresía activa',
        };
      } else {
        return {
          'status': 'error',
          'message': 'Error al verificar membresía: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error de conexión: $e',
      };
    }
  }

  // Crear membresía
  static Future<Map<String, dynamic>> createMembership(Map<String, String> data) async {
  try {
    final response = await http.post(
      Uri.parse("$baseUrl/api/v1/crear_membresia"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return {'status': 'success', ...jsonDecode(response.body)};
    } else {
      return {'status': 'error', 'message': jsonDecode(response.body)['error']};
    }
  } catch (e) {
    return {'status': 'error', 'message': 'Error de conexión: $e'};
  }
  }
  // Método para iniciar sesión
  // Método de inicio de sesión
  static Future<Map<String, dynamic>> login(String usuario, String contrasena) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/iniciar_sesion'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'usuario': usuario, 'contraseña': contrasena}),
      );

      if (response.statusCode == 200) {
        return {'status': 'success', ...jsonDecode(response.body)};
      } else if (response.statusCode == 401) {
        return {'status': 'error', 'message': 'Usuario o contraseña incorrectos'};
      } else {
        return {'status': 'error', 'message': 'Error al iniciar sesión: ${response.body}'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error de conexión: $e'};
    }
  }
  // Registro de usuario
  static Future<Map<String, dynamic>> register(Map<String, String> userData) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/registrarte"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        return {'status': 'success', ...jsonDecode(response.body)};
      } else if (response.statusCode == 400) {
        return {'status': 'error', 'message': 'El usuario o correo ya existe'};
      } else {
        return {'status': 'error', 'message': 'Error al registrar usuario: ${response.body}'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error de conexión: $e'};
    }
  }
  // Asociar dispositivo a usuario
  static Future<Map<String, dynamic>> asociarDispositivo(int usuarioId, String deviceId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/asociar_dispositivo'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'usuario_id': usuarioId, 'device_id': deviceId}),
      );

      if (response.statusCode == 201) {
        return {'status': 'success', 'message': 'Dispositivo asociado exitosamente'};
      } else if (response.statusCode == 400) {
        return {'status': 'error', 'message': 'El dispositivo ya está asociado al usuario'};
      } else {
        return {'status': 'error', 'message': 'Error al asociar dispositivo: ${response.body}'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error de conexión: $e'};
    }
  }

  // Obtener dispositivos asociados a un usuario
  static Future<Map<String, dynamic>> obtenerDispositivosUsuario(int usuarioId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/usuario/$usuarioId/dispositivos'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': 'success',
          'dispositivos': data['dispositivos'] ?? []
        };
      } else {
        return {
          'status': 'error',
          'message': 'Error al obtener dispositivos: ${response.body}'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error de conexión: $e'};
    }
  }

  // Obtener datos históricos de un dispositivo
  static Future<Map<String, dynamic>> obtenerDatosHistoricos(String deviceId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/datos_historicos?device_id=$deviceId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {
        'status': 'error',
        'message': 'Error al obtener datos históricos: ${response.body}'
      };
    }
  } catch (e) {
    return {'status': 'error', 'message': 'Error de conexión: $e'};
  }
  }
  // Obtener perfil del usuario
  static Future<Map<String, dynamic>> obtenerPerfil(int usuarioId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/perfil/$usuarioId'),
      );

      if (response.statusCode == 200) {
        return {
          'status': 'success',
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'status': 'error',
          'message': jsonDecode(response.body)['error'] ?? 'Error al obtener perfil',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error de conexión: $e'};
    }
  }
  // Analizar rendimiento post carrera
  static Future<Map<String, dynamic>> analizarRendimientoPostCarrera(String deviceId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/analizar_rendimiento_post_carrera'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'device_id': deviceId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        return {
          'status': 'error',
          'message': 'No hay datos para el dispositivo'
        };
      } else {
        return {
          'status': 'error',
          'message': 'Error al analizar rendimiento: ${response.body}'
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error de conexión: $e'
      };
    }
  }
  
}
