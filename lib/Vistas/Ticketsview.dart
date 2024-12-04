import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/Controladores/ticketscontroller.dart';

class TicketsPage extends StatefulWidget {
  const TicketsPage({Key? key}) : super(key: key);

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  final TicketsController _ticketsController = TicketsController();
  late Future<List<Map<String, dynamic>>> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _ticketsFuture = _ticketsController.leerTickets(); // Leer los tickets al iniciar
  }

  // Método para convertir DateTime a una cadena legible
  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year} '
        '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  // Método para mostrar detalles del ticket
  void _mostrarDetalles(BuildContext context, Map<String, dynamic> ticket) {
    final DateTime? fecha = (ticket['fecha'] != null && ticket['fecha'] is Timestamp)
        ? (ticket['fecha'] as Timestamp).toDate()
        : null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detalles del Ticket'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Atendido por: ${ticket['atendio'] ?? 'No especificado'}'),
                Text('Total: \$${ticket['total'] ?? '0.00'}'),
                if (fecha != null) Text('Fecha: ${_formatearFecha(fecha)}'),
                Text('Método de pago: ${ticket['metodoDePago']}'),
                const SizedBox(height: 10),
                const Text('Productos Comprados:', style: TextStyle(fontWeight: FontWeight.bold)),
                // Mostrar lista de productos usando carrito
                ...((ticket['carrito'] as List<dynamic>) ?? []).map((producto) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(
                        '- ${producto['nombreProducto']} x${producto['cantidad']} (\$${producto['subtotal']})'),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  // Método para eliminar un ticket
  Future<void> _eliminarTicket(String id) async {
    await _ticketsController.eliminarTicket(id);
    setState(() {
      _ticketsFuture = _ticketsController.leerTickets(); // Recargar los tickets después de eliminar
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tickets'),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ticketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay tickets disponibles'));
          } else {
            final tickets = snapshot.data!;
            return ListView.builder(
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text('Total: \$${ticket['total'] ?? '0.00'}'),
                    subtitle: Text('Atendido por: ${ticket['atendio'] ?? 'No especificado'}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _eliminarTicket(ticket['id']),
                    ),
                    onTap: () => _mostrarDetalles(context, ticket),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
