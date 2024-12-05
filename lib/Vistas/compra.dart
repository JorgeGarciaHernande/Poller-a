import 'package:flutter/material.dart';
import '/Controladores/Ventascontrolador.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/Controladores/clientes_controller.dart';
import '/Vistas/Menu.dart';

class CheckoutPage extends StatefulWidget {
  
  final List<Map<String, dynamic>> productos;
  final String atendio; // Usuario que realizó la venta
  final String usuario;
  final String role;
  // Removed initialization of ventas from here
  static final CollectionReference ventas = FirebaseFirestore.instance.collection('ventas');

  const CheckoutPage({
    Key? key,
    required this.productos,
    required this.atendio,
    required this.usuario,
    required this.role,
  }) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController clienteController = TextEditingController();
  final TextEditingController pagoController = TextEditingController();
  final ClientesController _clientesController = ClientesController();
  final VentaController _ventaController = VentaController();

  final CollectionReference ventas = FirebaseFirestore.instance.collection('ventas');
  double totalPagar = 0.0;
  double pago = 0.0;
  String metodoDePago = 'efectivo'; // Por defecto, efectivo
  double cambio = 0.0;

  List<Map<String, dynamic>> sugerenciasClientes = [];
  Map<String, dynamic>? clienteSeleccionado;

  @override
  void initState() {
    super.initState();
    totalPagar = widget.productos.fold(0.0, (sum, producto) {
      return sum + (producto['precioProducto'] * producto['cantidad']);
    });
  }

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

  void seleccionarCliente(Map<String, dynamic> cliente) {
    setState(() {
      clienteSeleccionado = cliente;
      clienteController.text = cliente['nombre'];
      sugerenciasClientes = [];
    });
  }

 Future<void> registrarVenta() async {
  if (clienteSeleccionado == null) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Debe seleccionar un cliente antes de finalizar la compra'),
      backgroundColor: Colors.red,
    ));
    return;
  }

  // Agregar los productos a la venta temporal
  for (var producto in widget.productos) {
    _ventaController.agregarProductoTemporal(
      idProducto: producto['idProducto'],
      nombreProducto: producto['nombreProducto'],
      precioProducto: producto['precioProducto'],
      cantidad: producto['cantidad'],
    );
  }

  // Confirmar la venta
  await _ventaController.confirmarVenta(
    context: context,
    atendio: widget.atendio,
    role: widget.role,
    usuario: widget.usuario,
    metodoDePago: metodoDePago, // Método de pago
  );

  // Obtener el ID del ticket más nuevo después de confirmar la venta
  int nuevoIdTicket = await obtenerIdTicketMasNuevo(ventas);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Venta Registrada'),
        content: Text('ID del ticket más nuevo: $nuevoIdTicket'),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );

  // Resetear los estados
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

  // Navegar al menú de tickets
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => TicketsMenu(usuario: widget.usuario, role: widget.role),
    ),
  );
}


  @override
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
                                buscarCliente();
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
                          ],
                        ),
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
                    physics: const NeverScrollableScrollPhysics(),
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
                      DropdownButton<String>(
                        isExpanded: true,
                        value: metodoDePago,
                        items: const [
                          DropdownMenuItem(
                            value: 'efectivo',
                            child: Text('Efectivo'),
                          ),
                          DropdownMenuItem(
                            value: 'terminal',
                            child: Text('Tarjeta'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            metodoDePago = value!;
                          });
                        },
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
              ElevatedButton(
                onPressed: registrarVenta,
                child: const Text('Finalizar Compra'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
Future<int> obtenerIdTicketMasNuevo(CollectionReference ventas) async {
  try {
    QuerySnapshot snapshot = await ventas.orderBy('fecha', descending: true).limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      final nuevoId = int.parse(snapshot.docs.first.id);
      return nuevoId;
    } else {
      return 0; // Si no hay tickets, devolver 0
    }
  } catch (e) {
    print("Error al obtener el ID del ticket más nuevo: $e");
    return 0;
  }
}