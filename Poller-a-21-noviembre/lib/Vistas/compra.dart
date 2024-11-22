import 'package:flutter/material.dart';
import 'package:polleriaproyecto/Controladores/Ventascontrolador.dart';
import 'package:polleriaproyecto/Controladores/clientes_controller.dart';
import 'package:polleriaproyecto/Vistas/Menu.dart';
 
class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> productos;

  const CheckoutPage({Key? key, required this.productos}) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController clienteController = TextEditingController();
  final TextEditingController pagoController = TextEditingController();
  final ClientesController _clientesController = ClientesController();
  final VentaController _ventaController = VentaController();

  double totalPagar = 0.0;
  double pago = 0.0;
  String metodoDePago = 'efectivo'; // Por defecto efectivo
  double cambio = 0.0;

  List<Map<String, dynamic>> sugerenciasClientes = []; // Lista de sugerencias
  Map<String, dynamic>? clienteSeleccionado;

  @override
  void initState() {
    super.initState();
    // Calcular el total a pagar con los productos
    totalPagar = widget.productos.fold(0.0, (sum, producto) {
      return sum + (producto['precioProducto'] * producto['cantidad']);
    });
  }

  // Función para buscar clientes por nombre o teléfono
  Future<void> buscarCliente() async {
    String query = clienteController.text.trim();
    if (query.isNotEmpty) {
      List<Map<String, dynamic>> result = await _clientesController.buscarClientePorTelefono(query);
      setState(() {
        sugerenciasClientes = result;
      });
    } else {
      setState(() {
        sugerenciasClientes = [];
      });
    }
  }

  // Función para seleccionar un cliente de la lista de sugerencias
  void seleccionarCliente(Map<String, dynamic> cliente) {
    setState(() {
      clienteSeleccionado = cliente;
      clienteController.text = cliente['nombre']; // Mostrar el nombre del cliente en el campo de texto
      sugerenciasClientes = []; // Limpiar las sugerencias después de seleccionar un cliente
    });
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
                  decoration: const InputDecoration(labelText: 'Número de Teléfono'),
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
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo sin hacer nada
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  // Agregar cliente a Firestore
                  await _clientesController.agregarCliente(
                    nombre: _nombreController.text,
                    numeroTelefono: _telefonoController.text,
                    direccion: _direccionController.text,
                  );
                  Navigator.of(context).pop(); // Cerrar el cuadro de diálogo después de agregar
                  setState(() {
                    // Actualizar la lista de clientes
                    clienteController.clear();
                    clienteSeleccionado = null;
                  });
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  // Función para registrar la venta usando el controlador
 Future<void> registrarVenta() async {
  if (clienteSeleccionado == null) {
    // Si no se seleccionó un cliente, mostrar mensaje de error
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Debe seleccionar un cliente antes de finalizar la compra'),
      backgroundColor: Colors.red,
    ));
    return;
  }

  // Añadir los productos seleccionados al carrito en el controlador de ventas
  for (var producto in widget.productos) {
    _ventaController.agregarProductoTemporal(
      idProducto: producto['idProducto'],
      nombreProducto: producto['nombreProducto'],
      precioProducto: producto['precioProducto'],
      cantidad: producto['cantidad'],
    );
  }

  // Confirmar y registrar la venta en Firestore
  await _ventaController.confirmarVenta();

  // Limpiar la vista después de registrar la venta
  setState(() {
    clienteSeleccionado = null;
    pagoController.clear();
    pago = 0.0;
    cambio = 0.0;
  });

  // Mostrar mensaje de éxito
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    content: Text('Venta registrada exitosamente'),
    backgroundColor: Colors.green,
  ));

  // Redirigir al Menú Principal
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const Menu()),
  );
}

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Punto de Venta'),
        backgroundColor: const Color.fromARGB(255, 255, 146, 21),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Buscar Cliente
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: clienteController,
                              decoration: const InputDecoration(
                                labelText: 'Buscar Cliente',
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (text) {
                                buscarCliente(); // Buscar mientras se escribe
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: buscarCliente,
                            child: const Text('Buscar'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Sugerencias de clientes
                      if (sugerenciasClientes.isNotEmpty)
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ListView.builder(
                            itemCount: sugerenciasClientes.length,
                            itemBuilder: (context, index) {
                              var cliente = sugerenciasClientes[index];
                              return ListTile(
                                title: Text(cliente['nombre']),
                                subtitle: Text(cliente['numero_telefono']),
                                onTap: () => seleccionarCliente(cliente),
                              );
                            },
                          ),
                        ),
                      // Mostrar información del cliente seleccionado
                      if (clienteSeleccionado != null)
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Nombre: ${clienteSeleccionado!['nombre']}'),
                                  Text('Dirección: ${clienteSeleccionado!['direccion']}'),
                                  Text('Teléfono: ${clienteSeleccionado!['numero_telefono']}'),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _mostrarFormularioAgregarCliente,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: const Text('Agregar Cliente'),
                            ),
                          ],
                        ),
                      // Si no hay cliente seleccionado
                      if (clienteSeleccionado == null)
                        const Text('Cliente no encontrado o no seleccionado.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Resumen de compra
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    shrinkWrap: true, 
                    physics: NeverScrollableScrollPhysics(), 
                    children: widget.productos.isEmpty
                        ? [const ListTile(title: Text('No hay productos en el carrito'))]
                        : widget.productos.map((producto) {
                            return ListTile(
                              title: Text(producto['nombreProducto']),
                              subtitle: Text('Cantidad: ${producto['cantidad']}'),
                              trailing: Text('\$${(producto['precioProducto'] * producto['cantidad']).toStringAsFixed(2)}'),
                            );
                          }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Formas de Pago
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Forma de Pago',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: DropdownButton<String>( 
                          isExpanded: true,
                          value: metodoDePago,
                          items: const [
                            DropdownMenuItem(
                              value: 'efectivo',
                              child: Text('Efectivo'),
                            ),
                            DropdownMenuItem(
                              value: 'terminal',
                              child: Text('Terminal'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              metodoDePago = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Total y Cambio
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text('Total a Pagar:'),
                          const Spacer(),
                          Text('\$${totalPagar.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (metodoDePago == 'efectivo') ...[
                        const Text('Paga con:'),
                        TextField(
                          controller: pagoController,
                          decoration: const InputDecoration(
                            labelText: 'Monto Pagado',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              pago = double.tryParse(value) ?? 0.0;
                              cambio = pago - totalPagar;
                            });
                          },
                        ),
                      ],
                      if (metodoDePago == 'terminal') ...[
                        const Text('Paga con: Terminal'),
                        const SizedBox(height: 8),
                        Text('Cambio: \$0.00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                      Row(
                        children: [
                          const Text('Cambio:'),
                          const Spacer(),
                          Text('\$${cambio.toStringAsFixed(2)}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Botón de finalizar compra
              ElevatedButton(
                onPressed: registrarVenta, // Llamar a la función para registrar la venta
                child: const Text('Finalizar Compra'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
