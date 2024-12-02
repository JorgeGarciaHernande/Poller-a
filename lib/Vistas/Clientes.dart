import 'package:flutter/material.dart';
import 'package:polleriaproyecto/Controladores/clientes_controller.dart';

class ClientesApp extends StatelessWidget {
  const ClientesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ClientesPage(),
    );
  }
}

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  final ClientesController _clientesController = ClientesController();
  List<Map<String, dynamic>> _clientes = [];
  List<Map<String, dynamic>> _clientesFiltrados = [];
  TextEditingController _busquedaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  // Cargar todos los clientes
  Future<void> _cargarClientes() async {
    List<Map<String, dynamic>> clientes =
        await _clientesController.obtenerClientes();
    setState(() {
      _clientes = clientes;
      _clientesFiltrados =
          clientes; // Inicializamos la lista de filtrados con todos los clientes
    });
  }

  // Función para buscar clientes por teléfono
  Future<void> _buscarCliente() async {
    String telefono = _busquedaController.text.trim();
    if (telefono.isNotEmpty) {
      List<Map<String, dynamic>> clientes =
          await _clientesController.buscarClientePorTelefono(telefono);
      setState(() {
        _clientesFiltrados =
            clientes; // Filtramos los clientes según la búsqueda
      });
    } else {
      setState(() {
        _clientesFiltrados =
            _clientes; // Si no hay búsqueda, mostramos todos los clientes
      });
    }
  }

  // Función para agregar un cliente
  Future<void> _agregarCliente(
      String nombre, String numeroTelefono, String direccion) async {
    if (nombre.isEmpty || numeroTelefono.isEmpty || direccion.isEmpty) {
      return;
    }
    await _clientesController.agregarCliente(
      nombre: nombre,
      numeroTelefono: numeroTelefono,
      direccion: direccion,
    );
    await _cargarClientes(); // Recargamos los clientes después de agregar
  }

  // Función para mostrar el formulario de agregar cliente
  void _mostrarFormularioAgregarCliente() {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _nombreController = TextEditingController();
    final TextEditingController _telefonoController = TextEditingController();
    final TextEditingController _direccionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Cliente'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _telefonoController,
                  decoration:
                      const InputDecoration(labelText: 'Número de Teléfono'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _direccionController,
                  decoration: const InputDecoration(labelText: 'Dirección'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Cerrar el cuadro de diálogo sin hacer nada
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  _agregarCliente(
                    _nombreController.text,
                    _telefonoController.text,
                    _direccionController.text,
                  );
                  Navigator.of(context)
                      .pop(); // Cerrar el cuadro de diálogo después de agregar
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pop(context); // Regresar al menú principal
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Campo de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _busquedaController,
              onChanged: (text) => _buscarCliente(),
              decoration: InputDecoration(
                labelText: 'Buscar por Teléfono',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _buscarCliente,
                ),
              ),
            ),
          ),
          // Lista de clientes (filtrados o todos)
          Expanded(
            child: _clientesFiltrados.isEmpty
                ? const Center(child: Text('No se encontraron clientes'))
                : ListView.builder(
                    itemCount: _clientesFiltrados.length,
                    itemBuilder: (context, index) {
                      final cliente = _clientesFiltrados[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 10),
                        elevation: 5,
                        child: ListTile(
                          title: Text(cliente['nombre']),
                          subtitle: Text(
                              'Tel: ${cliente['numero_telefono']}, Dirección: ${cliente['direccion']}'),
                          leading: const Icon(Icons.account_circle,
                              color: Colors.blue, size: 40),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {
                                    // Lógica para editar cliente
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    // Lógica para eliminar cliente
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarFormularioAgregarCliente,
        child: const Icon(Icons.add),
      ),
    );
  }
}
