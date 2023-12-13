class InvoiceInfoModel {
  final DateTime date;
  final DateTime dueDate;
  final String description;
  final String number;

  InvoiceInfoModel({
    required this.date,
    required this.dueDate,
    required this.description,
    required this.number,
  });
}
