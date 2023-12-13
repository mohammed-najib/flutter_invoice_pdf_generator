import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../model/customer.model.dart';
import '../model/invoice.model.dart';
import '../model/invoice_info.model.dart';
import '../model/supplier.model.dart';
import '../utils.dart';
import 'pdf.api.dart';

class PdfInvoiceApi {
  static Future<File> generate(InvoiceModel invoice) async {
    final pdf = Document();

    pdf.addPage(MultiPage(
      build: (context) => [
        _buildHeader(invoice),
        SizedBox(height: 3 * PdfPageFormat.cm),
        _buildTitle(invoice),
        _buildInvoice(invoice),
        Divider(),
        _buildTotal(invoice),
      ],
      footer: (context) => _buildFooter(invoice),
    ));

    return PdfApi.saveDocument(name: 'my_invoice.pdf', pdf: pdf);
  }

  static Widget _buildTitle(InvoiceModel invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INVOICE',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 0.8 * PdfPageFormat.cm),
          Text(invoice.info.description),
          SizedBox(height: 0.5 * PdfPageFormat.cm),
        ],
      );

  static Widget _buildInvoice(InvoiceModel invoice) {
    final headers = [
      'Description',
      'Date',
      'Quantity',
      'Unit Price',
      'VAT',
      'Total'
    ];

    final data = invoice.items.map((item) {
      final total = item.unitPrice * item.quantity + (1 + item.vat);

      return [
        item.description,
        Utils.formatDate(item.date),
        '${item.quantity}',
        '\$ ${item.unitPrice}',
        '${item.vat} %',
        '\$ ${total.toStringAsFixed(2)}',
      ];
    }).toList();

    return TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: TextStyle(fontWeight: FontWeight.bold),
      headerDecoration: const BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.centerRight,
        2: Alignment.centerRight,
        3: Alignment.centerRight,
        4: Alignment.centerRight,
        5: Alignment.centerRight,
      },
    );
  }

  static Widget _buildTotal(InvoiceModel invoice) {
    final netTotal = invoice.items
        .map((item) => item.unitPrice * item.quantity)
        .reduce((item1, item2) => item1 + item2);

    final vatPercent = invoice.items.first.vat;
    final vatTotal = netTotal * vatPercent;
    final total = netTotal + vatTotal;

    return Container(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Spacer(flex: 6),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildText(
                  title: 'Net total',
                  value: Utils.formatPrice(netTotal),
                  unite: true,
                ),
                _buildText(
                  title: 'Vat (${vatPercent * 100} %)',
                  value: Utils.formatPrice(vatTotal),
                  unite: true,
                ),
                Divider(),
                _buildText(
                  title: 'Total amount due',
                  value: Utils.formatPrice(total),
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  unite: true,
                ),
                SizedBox(height: 2 * PdfPageFormat.mm),
                Container(
                  height: 1,
                  color: PdfColors.grey400,
                ),
                SizedBox(height: 0.5 * PdfPageFormat.mm),
                Container(
                  height: 1,
                  color: PdfColors.grey400,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildText({
    required String title,
    required String value,
    double width = double.infinity,
    TextStyle? titleStyle,
    bool unite = false,
  }) {
    final style = titleStyle ?? TextStyle(fontWeight: FontWeight.bold);

    return Container(
      width: width,
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: style),
          ),
          Text(value, style: unite ? style : null),
        ],
      ),
    );
  }

  static Widget _buildFooter(InvoiceModel invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Divider(),
          SizedBox(height: 2 * PdfPageFormat.mm),
          _buildSimpleText(title: 'Address', value: invoice.supplier.address),
          SizedBox(height: 1 * PdfPageFormat.mm),
          _buildSimpleText(
              title: 'Paypal', value: invoice.supplier.paymentInfo),
        ],
      );

  static Widget _buildSimpleText({
    required String title,
    required String value,
  }) {
    final style = TextStyle(fontWeight: FontWeight.bold);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(title, style: style),
        SizedBox(width: 2 * PdfPageFormat.mm),
        Text(value),
      ],
    );
  }

  static Widget _buildHeader(InvoiceModel invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 1 * PdfPageFormat.cm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSupplierAddress(invoice.supplier),
              Container(
                width: 50,
                height: 50,
                child: BarcodeWidget(
                  barcode: Barcode.qrCode(),
                  data: invoice.info.number,
                ),
              ),
            ],
          ),
          SizedBox(height: 1 * PdfPageFormat.cm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildCustomerAddress(invoice.customer),
              _buildInvoiceInfo(invoice.info),
            ],
          ),
          SizedBox(height: 1 * PdfPageFormat.cm),
        ],
      );

  static Widget _buildSupplierAddress(SupplierModel supplier) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            supplier.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 1 * PdfPageFormat.mm),
          Text(supplier.address),
        ],
      );

  static Widget _buildCustomerAddress(CustomerModel customer) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            customer.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 1 * PdfPageFormat.mm),
          Text(customer.address),
        ],
      );

  static Widget _buildInvoiceInfo(InvoiceInfoModel info) {
    final paymentTerms = '${info.dueDate.difference(info.date).inDays} days';
    final titles = [
      'Invoice Number:',
      'Invoice Date:',
      'Payment Terms:',
      'Due Date:',
    ];
    final data = [
      info.number,
      Utils.formatDate(info.date),
      paymentTerms,
      Utils.formatDate(info.dueDate),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(titles.length, (index) {
        final title = titles[index];
        final value = data[index];

        return _buildText(
          title: title,
          value: value,
          width: 200,
        );
      }),
    );
  }
}
