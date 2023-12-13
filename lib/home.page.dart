import 'package:flutter/material.dart';

import 'api/pdf.api.dart';
import 'api/pdf_invoice.api.dart';
import 'model/customer.model.dart';
import 'model/invoice.model.dart';
import 'model/invoice_info.model.dart';
import 'model/invoice_item.model.dart';
import 'model/supplier.model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice PDF Generator'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: double.infinity,
          width: double.infinity,
          alignment: Alignment.center,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    'Generate Invoice',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    final date = DateTime.now();
                    final dueDate = date.add(const Duration(days: 7));

                    final invoice = InvoiceModel(
                      supplier: SupplierModel(
                        name: 'John Doe',
                        address: 'John Doe Street, 1',
                        paymentInfo: 'https://john-doe-payment-info.com',
                      ),
                      customer: CustomerModel(
                        name: 'Google Inc',
                        address: 'Google Street, 2',
                      ),
                      info: InvoiceInfoModel(
                        date: date,
                        dueDate: dueDate,
                        description: 'This is an example invoice.',
                        number: '${DateTime.now().year}-9999',
                      ),
                      items: [
                        InvoiceItemModel(
                          description: 'Tea',
                          date: DateTime.now(),
                          quantity: 1,
                          vat: 0.19,
                          unitPrice: 10.99,
                        ),
                        InvoiceItemModel(
                          description: 'Coffee',
                          date: DateTime.now(),
                          quantity: 3,
                          vat: 0.19,
                          unitPrice: 5.99,
                        ),
                        InvoiceItemModel(
                          description: 'Water',
                          date: DateTime.now(),
                          quantity: 2,
                          vat: 0.19,
                          unitPrice: 1.99,
                        ),
                        InvoiceItemModel(
                          description: 'Coca Cola',
                          date: DateTime.now(),
                          quantity: 1,
                          vat: 0.19,
                          unitPrice: 3.99,
                        ),
                        InvoiceItemModel(
                          description: 'Fanta',
                          date: DateTime.now(),
                          quantity: 1,
                          vat: 0.19,
                          unitPrice: 3.99,
                        ),
                      ],
                    );

                    final pdfFile = await PdfInvoiceApi.generate(invoice);

                    PdfApi.openFile(pdfFile);
                  },
                  child: const Text('Invoice PDF'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
