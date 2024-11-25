import 'package:flutter/material.dart';
import '/Controladores/Dispositivos.dart';
import '/Vistas/qrcodepage.dart'; // Update the path to match your project structure.

class DispositivosPage extends StatefulWidget {
  const DispositivosPage({super.key});

  @override
  _DispositivosPageState createState() => _DispositivosPageState();
}

class _DispositivosPageState extends State<DispositivosPage> {
  final DispositivosService _dispositivosService = DispositivosService();
  List<Map<String, dynamic>> _dispositivos = [];

  @override
  void initState() {
    super.initState();
    _cargarDispositivos();
  }

  Future<void> _cargarDispositivos() async {
    List<Map<String, dynamic>> dispositivos = await _dispositivosService.obtenerDispositivos();
    setState(() {
      _dispositivos = dispositivos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispositivos Autorizados'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: _dispositivos.isNotEmpty
                  ? ListView.builder(
                      itemCount: _dispositivos.length,
                      itemBuilder: (context, index) {
                        final dispositivo = _dispositivos[index];
                        return Card(
                          color: Colors.yellow.shade200,
                          child: ListTile(
                            title: Text(dispositivo['nombre'] ?? 'Sin nombre'),
                            subtitle: Text('ID: ${dispositivo['id'] ?? 'Sin ID'}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.qr_code),
                                  onPressed: () {
                                    // Navigate to the QR Code page
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => QrCodePage(
                                          deviceId: dispositivo['id'] ?? 'Unknown ID',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _dispositivosService.eliminarDispositivo(dispositivo['id']);
                                    _cargarDispositivos();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(child: Text("No hay dispositivos autorizados")),
            ),
          ],
        ),
      ),
    );
  }
}
