import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:tawqalnajah/Core/Widgets/AppBar.dart';
import 'package:tawqalnajah/Core/utiles/Colors.dart';

import '../../../../../../generated/l10n.dart';
import '../OrderReport.dart';

class ProfitDetailsPage extends StatelessWidget {
  final List<OrderReport> orders;
  const ProfitDetailsPage({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(title: S.of(context).profitDetails),
      body: orders.isEmpty
          ? Center(child: Text(S.of(context).noData))
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(screenWidth * 0.04),
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(screenWidth * 0.03)
                  ),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: const {
                    0: IntrinsicColumnWidth(),
                    1: IntrinsicColumnWidth(),
                    2: IntrinsicColumnWidth(),
                    3: IntrinsicColumnWidth(),
                    4: IntrinsicColumnWidth(),
                    5: IntrinsicColumnWidth()
                  },
                  children: [
                    TableRow(
                        decoration: BoxDecoration(color: KprimaryColor.withOpacity(0.1)),
                        children: [
                          S.of(context).orderId,
                          S.of(context).amount,
                          S.of(context).code,
                          S.of(context).quantity,
                          S.of(context).status,
                          S.of(context).date
                        ].map((h) =>
                            Padding(
                              padding: EdgeInsets.all(screenWidth * 0.03),
                              child: Text(h,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.035),
                              ),
                            )
                        ).toList()
                    ),
                    ...orders.map((order) => TableRow(children: [
                      _dataCell(context, order.orderId),
                      _dataCell(context, order.amount.toStringAsFixed(2), color: KprimaryColor),
                      _dataCell(context, order.code),
                      _dataCell(context, order.quantity.toString(), color: KprimaryColor),
                      _dataCell(context, order.status),
                      _dataCell(context, order.date),
                    ])),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: SizedBox(
              height: screenWidth * 0.12,
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: KprimaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.02))
                ),
                onPressed: () async => await _generatePDF(context, orders),
                label: Text(S.of(context).profitReport,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: screenWidth * 0.03, fontWeight: FontWeight.bold, color: SecoundColor)
                ),
              ),
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
        ],
      ),
    );
  }

  Widget _dataCell(BuildContext context, String text, {Color? color}) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.03),
      child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: screenWidth * 0.03, color: color ?? Colors.black87)),
    );
  }

  Future<void> _generatePDF(BuildContext flutterContext, List<OrderReport> orders) async {
    final pdf = pw.Document();

    // احفظ النصوص في متغيرات
    final profitReportText = S.of(flutterContext).profitReport;
    final orderIdText = S.of(flutterContext).orderId;
    final amountText = S.of(flutterContext).amount;
    final codeText = S.of(flutterContext).code;
    final quantityText = S.of(flutterContext).quantity;
    final statusText = S.of(flutterContext).status;
    final dateText = S.of(flutterContext).date;

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [ // هنا context هو pdf.Context
        pw.Center(
          child: pw.Text(
            profitReportText,
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Table.fromTextArray(
          headers: [orderIdText, amountText, codeText, quantityText, statusText, dateText],
          data: orders.map((e) => [
            e.orderId,
            e.amount.toStringAsFixed(2),
            e.code,
            e.quantity.toString(),
            e.status,
            e.date
          ]).toList(),
          headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          border: pw.TableBorder.all(color: PdfColors.grey600),
          cellAlignment: pw.Alignment.center,
        ),
      ],
    ));

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/profit_report.pdf");
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }
}
