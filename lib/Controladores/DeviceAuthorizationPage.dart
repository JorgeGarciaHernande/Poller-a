import 'package:flutter/material.dart';
import 'AuthService.dart'; // Ruta correcta al servicio AuthService

class DeviceAuthorizationPage extends StatefulWidget {
  const DeviceAuthorizationPage({super.key});

  @override
  _DeviceAuthorizationPageState createState() => _DeviceAuthorizationPageState();
}

class _DeviceAuthorizationPageState extends State<DeviceAuthorizationPage> {
  final AuthService _authService = AuthService();
  bool _isAuthorized = false;

  @override
  void initState() {
    super.initState();
    _verificarDispositivo();
  }

  // Función para verificar si el dispositivo está autorizado
  Future<void> _verificarDispositivo() async {
    String deviceId = await _authService.getOrCreateDeviceId();
    bool autorizado = await _authService.verificarAutorizacion(deviceId);

    setState(() {
      _isAuthorized = autorizado;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificación de Dispositivo')),
      body: Center(
        child: _isAuthorized
            ? const Text('Dispositivo autorizado. Accediendo a la app...')
            : const Text('Dispositivo no autorizado. Acceso denegado.'),
      ),
    );
  }
}
