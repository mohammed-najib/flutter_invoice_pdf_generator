import 'customer.model.dart';
import 'invoice_info.model.dart';
import 'invoice_item.model.dart';
import 'supplier.model.dart';

class InvoiceModel {
  final SupplierModel supplier;
  final CustomerModel customer;
  final InvoiceInfoModel info;
  final List<InvoiceItemModel> items;

  InvoiceModel({
    required this.supplier,
    required this.customer,
    required this.info,
    required this.items,
  });
}
