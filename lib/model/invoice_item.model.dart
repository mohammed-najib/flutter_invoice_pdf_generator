class InvoiceItemModel {
  final String description;
  final DateTime date;
  final int quantity;
  final double vat;
  final double unitPrice;

  InvoiceItemModel({
    required this.description,
    required this.date,
    required this.quantity,
    required this.vat,
    required this.unitPrice,
  });
}
