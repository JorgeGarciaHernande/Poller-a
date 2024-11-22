import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final CollectionReference dispositivos = FirebaseFirestore.instance.collection('dispositivos_autorizados');

  // Generar o cargar el UUID desde almacenamiento local
  Future<String> getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');

    if (deviceId == null) {
      deviceId = const Uuid().v4(); // Generar nuevo UUID
      await prefs.setString('device_id', deviceId);
    }

    return deviceId;
  }

  // Verificar si el dispositivo está autorizado
  Future<bool> verificarAutorizacion(String deviceId) async {
    final snapshot = await dispositivos.where('deviceId', isEqualTo: deviceId).get();

    // Verifica si el snapshot no está vacío y el campo "autorizado" es verdadero
    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data() as Map<String, dynamic>;
      return data['autorizado'] ?? false; // Retorna "false" si el campo no está presente
    }

    return false; // Si no hay documentos, retorna "false"
  }

  // Agregar un nuevo dispositivo autorizado (opcional, para administradores)
  Future<void> agregarDispositivoAutorizado(String deviceId) async {
    await dispositivos.add({
      'deviceId': deviceId,
      'autorizado': true,
      'descripcion': 'Dispositivo agregado manualmente',
    });
  }
}
