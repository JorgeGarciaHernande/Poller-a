import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'Vistas/loginview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Llama a la función para crear la colección 'productos' si no existe
  await verificarOCrearColeccionProductos();
  
  runApp(const MainApp());
}

// Función para verificar y crear la colección 'productos' si está vacía
Future<void> verificarOCrearColeccionProductos() async {
  CollectionReference productos = FirebaseFirestore.instance.collection('productos');

  // Verifica si la colección 'productos' ya tiene documentos
  QuerySnapshot querySnapshot = await productos.limit(1).get();
  if (querySnapshot.docs.isEmpty) {
    // Si la colección está vacía, agrega un producto inicial con imagen de marcador de posición
    await productos.add({
      'Nombre': 'Producto de Ejemplo',
      'precio': 0.0,
      'id': 1,
      'imagen': 'https://via.placeholder.com/150' // URL de marcador de posición
    });
    print("Colección 'productos' creada con un documento inicial y campo de imagen.");
  } else {
    print("La colección 'productos' ya existe.");
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginPage(), // Llama a la pantalla de inicio de sesión
    );
  }
}
