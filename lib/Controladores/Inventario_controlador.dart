import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class InventoryService {
  final CollectionReference productos = FirebaseFirestore.instance.collection('productos');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Función para seleccionar una imagen desde el dispositivo
  Future<File?> seleccionarImagen() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  // Función para subir la imagen a Firebase Storage y obtener la URL
  Future<String?> subirImagen(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('productos/$fileName');
      
      // Espera a que la imagen se suba a Firebase Storage
      await ref.putFile(image);
      
      // Obtén la URL de descarga
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error al subir imagen: $e");
      return null;
    }
  }

  // Función para agregar un nuevo producto a Firestore
  Future<void> agregarProducto({
    required String nombre,
    required double precio,
    File? imagen,
  }) async {
    try {
      String? imageUrl;
      
      // Solo intenta subir la imagen si fue seleccionada
      if (imagen != null) {
        imageUrl = await subirImagen(imagen);
      }

      // Asegúrate de que imageUrl no sea null antes de guardar
      await productos.add({
        'Nombre': nombre,
        'precio': precio,
        'id': await _obtenerNuevoId(),
        'imagen': imageUrl ?? 'https://via.placeholder.com/150', // Usa la URL obtenida o una URL por defecto
      });
      print("Producto agregado exitosamente con imagen.");
    } catch (e) {
      print("Error al agregar producto: $e");
    }
  }

  // Función privada para obtener un nuevo ID incremental
  Future<int> _obtenerNuevoId() async {
    final snapshot = await productos.orderBy('id', descending: true).limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      int maxId = snapshot.docs.first['id'] as int;
      return maxId + 1;
    } else {
      return 1;
    }
  }

  // Función para obtener todos los productos desde Firestore
  Future<List<Map<String, dynamic>>> obtenerProductos() async {
    try {
      QuerySnapshot snapshot = await productos.get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error al obtener productos: $e");
      return [];
    }
  }
}
