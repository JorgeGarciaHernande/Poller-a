import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class comida extends StatefulWidget {
  const comida({Key? key}) : super(key: key);

  @override
  _ComidaState createState() => _ComidaState();
}

class _ComidaState extends State<comida> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TabController _tabController;
  String _nombre = '';
  double _precio = 0.0;
  String _categoria = 'Platillos';
  String _imagenUrl = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this); // 5 pestañas
  }

  Future<void> _agregarComida() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await _firestore.collection('menu').add({
          'Nombre': _nombre,
          'precio': _precio,
          'categoria': _categoria,
          'imagen': _imagenUrl.isNotEmpty
              ? _imagenUrl
              : 'https://via.placeholder.com/150',
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comida agregada exitosamente.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar comida: $e')),
        );
      }
    }
  }

  Stream<QuerySnapshot> _obtenerComidasPorCategoria(String categoria) {
    return _firestore
        .collection('menu')
        .where('categoria', isEqualTo: categoria)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú de Comidas'),
        centerTitle: true,
        backgroundColor: Colors.orange,
        bottom: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Colors.white.withOpacity(0.5),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Platillos'),
            Tab(text: 'Pollos'),
            Tab(text: 'Hamburguesas'),
            Tab(text: 'Adicionales'),
            Tab(text: 'Promociones'), // Nueva pestaña de promociones
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orangeAccent, Colors.deepOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildGridProductos('Platillos'),
            _buildGridProductos('Pollos'),
            _buildGridProductos('Hamburguesas'),
            _buildGridProductos('Adicionales'),
            _buildGridProductos('Promociones'), // Nueva vista de promociones
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orangeAccent,
        onPressed: () => _mostrarFormularioAgregar(),
        label: const Text('Agregar'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGridProductos(String categoria) {
    return StreamBuilder<QuerySnapshot>(
      stream: _obtenerComidasPorCategoria(categoria),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No hay productos disponibles.',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          );
        }

        final productos = snapshot.data!.docs;

        return GridView.builder(
          padding: const EdgeInsets.all(8.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 3 / 4,
          ),
          itemCount: productos.length,
          itemBuilder: (context, index) {
            final producto = productos[index].data() as Map<String, dynamic>;
            return Card(
              elevation: 6.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15.0),
                      ),
                      child: Image.network(
                        producto['imagen'] ?? 'https://via.placeholder.com/150',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 6.0,
                    ),
                    child: Column(
                      children: [
                        Text(
                          producto['Nombre'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '\$${producto['precio'].toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _mostrarFormularioAgregar() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Comida'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa un nombre';
                      }
                      return null;
                    },
                    onSaved: (value) => _nombre = value!,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Precio',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa un precio';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Por favor, ingresa un número válido';
                      }
                      return null;
                    },
                    onSaved: (value) => _precio = double.parse(value!),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _categoria,
                    items: const [
                      DropdownMenuItem(
                          value: 'Platillos', child: Text('Platillos')),
                      DropdownMenuItem(value: 'Pollos', child: Text('Pollos')),
                      DropdownMenuItem(
                          value: 'Hamburguesas', child: Text('Hamburguesas')),
                      DropdownMenuItem(
                          value: 'Adicionales', child: Text('Adicionales')),
                      DropdownMenuItem(
                          value: 'Promociones', child: Text('Promociones')),
                    ],
                    onChanged: (value) => setState(() => _categoria = value!),
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'URL de la Imagen (opcional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onSaved: (value) => _imagenUrl = value ?? '',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                _agregarComida();
                Navigator.pop(context);
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }
}
