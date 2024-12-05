import 'package:cloud_firestore/cloud_firestore.dart';

class ClientesController {
  final CollectionReference clientes =
      FirebaseFirestore.instance.collection('clientes');

  /// Obtener todos los clientes desde Firestore
  Future<List<Map<String, dynamic>>> obtenerClientes() async {
    try {
      QuerySnapshot snapshot = await clientes.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Agregar ID del documento
        return data;
      }).toList();
    } catch (e) {
      print("Error al obtener clientes: $e");
      return [];
    }
  }

  /// Agregar un nuevo cliente a Firestore
  Future<void> agregarCliente({
    required String nombre,
    required String numeroTelefono,
    required String direccion,
  }) async {
    try {
      await clientes.add({
        'nombre': nombre,
        'numero_telefono': numeroTelefono,
        'direccion': direccion,
      });
      print("Cliente agregado exitosamente.");
    } catch (e) {
      print("Error al agregar cliente: $e");
    }
  }

  /// Editar un cliente en Firestore
  Future<void> editarCliente({
    required String id,
    required String nombre,
    required String numeroTelefono,
    required String direccion,
  }) async {
    try {
      await clientes.doc(id).update({
        'nombre': nombre,
        'numero_telefono': numeroTelefono,
        'direccion': direccion,
      });
      print("Cliente actualizado exitosamente.");
    } catch (e) {
      print("Error al actualizar cliente: $e");
    }
  }

  /// Eliminar un cliente de Firestore
  Future<void> eliminarCliente(String id) async {
    try {
      await clientes.doc(id).delete();
      print("Cliente eliminado exitosamente.");
    } catch (e) {
      print("Error al eliminar cliente: $e");
    }
  }

  /// Buscar clientes por número de teléfono
  Future<List<Map<String, dynamic>>> buscarClientePorTelefono(String telefono) async {
    try {
      QuerySnapshot snapshot = await clientes
          .where('numero_telefono', isGreaterThanOrEqualTo: telefono)
          .where('numero_telefono', isLessThanOrEqualTo: telefono + '\uf8ff')
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Agregar ID del documento
        return data;
      }).toList();
    } catch (e) {
      print("Error al buscar cliente: $e");
      return [];
    }
  }
}
