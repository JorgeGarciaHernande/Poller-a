import 'package:flutter/foundation.dart';

class CarritoController extends ChangeNotifier {
  final List<Map<String, dynamic>> _productosSeleccionados = [];

  // Obtener la lista de productos seleccionados en el carrito
  List<Map<String, dynamic>> obtenerProductosSeleccionados() {
    return _productosSeleccionados;
  }

  // Agregar un producto al carrito
  void agregarProductoAlCarrito({
    required String idProducto,
    required String nombreProducto,
    required double precioProducto,
    required int cantidad,
    String? imagen,
     
  }) {
    // Verificar si el producto ya existe en el carrito
    final index = _productosSeleccionados.indexWhere((producto) => producto['idProducto'] == idProducto);
    if (index != -1) {
      // Si ya existe, incrementar la cantidad
      _productosSeleccionados[index]['cantidad'] += cantidad;
    } else {
      // Si no existe, agregar un nuevo producto
      _productosSeleccionados.add({
        'idProducto': idProducto,
        'nombreProducto': nombreProducto,
        'precioProducto': precioProducto,
        'cantidad': cantidad,
        'imagen': imagen ?? '', // Imagen opcional
         
      });
    }
    notifyListeners(); // Notificar a la vista para que se actualice
    print("Producto agregado al carrito: $nombreProducto");
  }

  // Aumentar la cantidad de un producto específico en el carrito
  void aumentarCantidadProducto(int index) {
    if (index >= 0 && index < _productosSeleccionados.length) {
      _productosSeleccionados[index]['cantidad']++;
      notifyListeners(); // Notificar a la vista para que se actualice
      print("Cantidad incrementada del producto: ${_productosSeleccionados[index]['nombreProducto']}");
    }
  }

  // Disminuir la cantidad de un producto específico en el carrito
  void disminuirCantidadProducto(int index) {
    if (index >= 0 && index < _productosSeleccionados.length) {
      if (_productosSeleccionados[index]['cantidad'] > 1) {
        _productosSeleccionados[index]['cantidad']--;
      } else {
        eliminarProductoDelCarrito(index); // Si la cantidad es 1, eliminar el producto
      }
      notifyListeners(); // Notificar a la vista para que se actualice
      print("Cantidad disminuida del producto: ${_productosSeleccionados[index]['nombreProducto']}");
    }
  }

  // Eliminar un producto del carrito
  void eliminarProductoDelCarrito(int index) {
    if (index >= 0 && index < _productosSeleccionados.length) {
      print("Producto eliminado del carrito: ${_productosSeleccionados[index]['nombreProducto']}");
      _productosSeleccionados.removeAt(index);
      notifyListeners(); // Notificar a la vista para que se actualice
    }
  }

  // Limpiar el carrito
  void vaciarCarrito() {
    _productosSeleccionados.clear();
    notifyListeners(); // Notificar a la vista para que se actualice
    print("Carrito vaciado.");
  }

  // Obtener el total del carrito
  double obtenerTotalCarrito() {
    double total = 0;
    for (var producto in _productosSeleccionados) {
      total += producto['precioProducto'] * producto['cantidad'];
    }
    return total;
  }
}