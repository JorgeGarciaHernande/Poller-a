import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DispositivosService {
  final CollectionReference dispositivos = FirebaseFirestore.instance.collection('dispositivos_autorizados');

  // Obtener todos los dispositivos desde Firestore
  Future<List<Map<String, dynamic>>> obtenerDispositivos() async {
    try {
      QuerySnapshot snapshot = await dispositivos.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data;
      }).toList();
    } catch (e) {
      print("Error al obtener dispositivos: $e");
      return [];
    }
  }

  // Agregar un nuevo dispositivo
  Future<void> agregarDispositivo({required String nombre, required String id}) async {
    try {
      await dispositivos.add({
        'nombre': nombre,
        'id': id,
      });
      print("Dispositivo agregado exitosamente.");
    } catch (e) {
      print("Error al agregar dispositivo: $e");
    }
  }

  // Editar un dispositivo existente
  Future<void> editarDispositivo({required String docId, required String nombre}) async {
    try {
      await dispositivos.doc(docId).update({
        'nombre': nombre,
      });
      print("Dispositivo editado exitosamente.");
    } catch (e) {
      print("Error al editar dispositivo: $e");
    }
  }

  // Eliminar un dispositivo
  Future<void> eliminarDispositivo(String docId) async {
    try {
      await dispositivos.doc(docId).delete();
      print("Dispositivo eliminado exitosamente.");
    } catch (e) {
      print("Error al eliminar dispositivo: $e");
    }
  }

  // Generar un QR con el enlace de descarga de la aplicación
  Widget generarQrParaDescarga(String appLink) {
    return QrImageView(
      data: appLink,
      version: QrVersions.auto,
      size: 200.0,
    );
  }
}
