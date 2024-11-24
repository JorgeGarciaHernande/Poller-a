class TicketManager {
  final String cashier;
  final List<Map<String, dynamic>> products;
  final double total;
  final double cashReceived;
  final double change;
  final String establishmentName;
  final String phone;

  TicketManager({
    required this.cashier,
    required this.products,
    required this.total,
    required this.cashReceived,
    required this.change,
    required this.establishmentName,
    required this.phone,
  });

  String generateTicket() {
    String ticket = '';
    ticket += _printHeader();
    ticket += _printClientDetails();
    ticket += _printProducts();
    ticket += _printTotal();
    ticket += _printFooter();
    return ticket;
  }

  String _printHeader() {
    return '''$establishmentName
TEL: $phone
--------------------------------
''';
  }

  String _printClientDetails() {
    return '''FECHA: ${DateTime.now().toString().split(' ')[0]} ${DateTime.now().toString().split(' ')[1]}
CAJERO: $cashier
--------------------------------
''';
  }

  String _printProducts() {
    String productsDetails = 'PRODUCTOS COBRADOS:\n';
    for (var product in products) {
      productsDetails += '${product['cantidad']}  ${product['nombreProducto']}  ${product['precioProducto']}\n';
    }
    productsDetails += '--------------------------------\n';
    return productsDetails;
  }

  String _printTotal() {
    return '''TOTAL: \$${total.toStringAsFixed(2)}
EFECTIVO: \$${cashReceived.toStringAsFixed(2)}
CAMBIO: \$${change.toStringAsFixed(2)}
--------------------------------
''';
  }

  String _printFooter() {
    return '''VUELVA PRONTO, GRACIAS POR SU PREFERENCIA.
''';
  }
}
