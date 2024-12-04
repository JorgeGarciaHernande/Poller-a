import 'package:flutter/material.dart';
import 'package:polleriaproyecto/Controladores/usuario_controller.dart';

class UsuarioApp extends StatelessWidget {
  const UsuarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UsuarioPage(),
    );
  }
}

class UsuarioPage extends StatefulWidget {
  const UsuarioPage({super.key});

  @override
  State<UsuarioPage> createState() => _UsuarioPageState();
}

class _UsuarioPageState extends State<UsuarioPage> {
  final UsuarioController _usuarioController = UsuarioController();
  List<Map<String, dynamic>> _usuarios = [];
  String _roleSeleccionado = 'empleado'; // Valor predeterminado

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    List<Map<String, dynamic>> usuarios = await _usuarioController.obtenerUsuarios();
    setState(() {
      _usuarios = usuarios;
    });
  }

  Future<void> _agregarUsuario(String username, String password, String role) async {
    if (username.isEmpty || password.isEmpty) {
      return;
    }
    await _usuarioController.agregarUsuario(username: username, password: password, role: role);
    await _cargarUsuarios();
  }

  Future<void> _editarUsuario(String docId, String username, String password, String role) async {
    if (username.isEmpty || password.isEmpty) {
      return;
    }
    await _usuarioController.editarUsuario(docId, username: username, password: password, role: role);
    await _cargarUsuarios();
  }

  Future<void> _eliminarUsuario(String docId) async {
    await _usuarioController.eliminarUsuario(docId);
    await _cargarUsuarios();
  }

  // Función para mostrar el formulario de agregar usuario
  void _mostrarFormularioAgregarUsuario() {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _usernameController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Usuario'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),
                // Campo de selección de role
                Row(
                  children: [
                    const Text('Role: '),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _roleSeleccionado,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Admin'),
                          ),
                          DropdownMenuItem(
                            value: 'empleado',
                            child: Text('Empleado'),
                          ),
                        ],
                        onChanged: (String? nuevoRole) {
                          setState(() {
                            _roleSeleccionado = nuevoRole ?? 'empleado';
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo sin hacer nada
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  _agregarUsuario(
                    _usernameController.text,
                    _passwordController.text,
                    _roleSeleccionado,
                  );
                  Navigator.of(context).pop(); // Cerrar el cuadro de diálogo después de agregar
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  // Función para mostrar el formulario de edición de usuario
  void _mostrarFormularioEditarUsuario(String docId, String username, String password, String role) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _usernameController = TextEditingController(text: username);
    final TextEditingController _passwordController = TextEditingController(text: password);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Usuario'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                ),
                // Campo de selección de role para la edición
                Row(
                  children: [
                    const Text('Role: '),
                    Expanded(
                      child: DropdownButton<String>(
                        value: role,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Admin'),
                          ),
                          DropdownMenuItem(
                            value: 'empleado',
                            child: Text('Empleado'),
                          ),
                        ],
                        onChanged: (String? nuevoRole) {
                          setState(() {
                            role = nuevoRole ?? 'empleado';
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo sin hacer nada
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  _editarUsuario(
                    docId,
                    _usernameController.text,
                    _passwordController.text,
                    role,
                  );
                  Navigator.of(context).pop(); // Cerrar el cuadro de diálogo después de editar
                }
              },
              child: const Text('Guardar Cambios'),
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
        title: const Text('Usuarios'),
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
      body: _usuarios.isEmpty
          ? const Center(child: CircularProgressIndicator()) // Cargando usuarios
          : ListView.builder(
              itemCount: _usuarios.length,
              itemBuilder: (context, index) {
                final usuario = _usuarios[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  elevation: 5,
                  child: ListTile(
                    title: Text(usuario['username'] ?? 'Sin nombre'),
                    subtitle: Text('ID: ${usuario['id']}, Role: ${usuario['role'] ?? 'Sin role'}'),
                    leading: const Icon(Icons.account_circle, color: Colors.blue, size: 40),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _mostrarFormularioEditarUsuario(
                                usuario['id'],
                                usuario['username'] ?? '',
                                usuario['password'] ?? '',
                                usuario['role'] ?? 'empleado',
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _eliminarUsuario(usuario['id']),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarFormularioAgregarUsuario,
        child: const Icon(Icons.add),
      ),
    );
  }
}
