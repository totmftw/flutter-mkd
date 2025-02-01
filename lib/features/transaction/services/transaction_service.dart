import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:csv/csv.dart' as csv_converter;

class TransactionService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> addInvoice() async {
    try {
      // Placeholder for invoice addition logic
      // In a real implementation, you'd collect invoice details from a form
      final newInvoice = {
        'customer_id': null, // Replace with actual customer ID
        'invoice_number': 'INV-${DateTime.now().millisecondsSinceEpoch}',
        'total_amount': 0.0, // Replace with actual amount
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      };

      await _client.from('invoices').insert(newInvoice);
      debugPrint('Invoice added successfully');
    } catch (e) {
      debugPrint('Error adding invoice: $e');
      rethrow;
    }
  }

  Future<void> downloadInvoiceTemplate() async {
    try {
      // Create a sample CSV template
      List<List<dynamic>> template = [
        ['Customer Name', 'Invoice Number', 'Total Amount', 'Due Date'],
        ['Example Customer', 'INV-001', '10000', '2024-02-15'],
      ];

      String csvContent = const csv_converter.ListToCsvConverter().convert(template);
      
      // Get temporary directory for saving
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/invoice_template.csv');
      
      await file.writeAsString(csvContent);
      debugPrint('Invoice template downloaded to ${file.path}');
    } catch (e) {
      debugPrint('Error downloading invoice template: $e');
      rethrow;
    }
  }

  Future<void> uploadInvoices() async {
    try {
      // Placeholder for invoice upload logic
      // In a real implementation, you'd parse the uploaded CSV file
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/uploaded_invoices.csv');
      
      if (!await file.exists()) {
        throw Exception('No invoice file selected');
      }

      // Read and parse CSV
      String csvString = await file.readAsString();
      List<List<dynamic>> csvTable = const csv_converter.CsvToListConverter().convert(csvString);

      // Skip header row and process invoices
      for (var i = 1; i < csvTable.length; i++) {
        final invoice = {
          'customer_name': csvTable[i][0],
          'invoice_number': csvTable[i][1],
          'total_amount': csvTable[i][2],
          'due_date': csvTable[i][3],
        };

        await _client.from('invoices').insert(invoice);
      }

      debugPrint('Invoices uploaded successfully');
    } catch (e) {
      debugPrint('Error uploading invoices: $e');
      rethrow;
    }
  }

  Future<void> addPayment() async {
    try {
      // Placeholder for payment addition logic
      final newPayment = {
        'invoice_id': null, // Replace with actual invoice ID
        'payment_number': 'PAY-${DateTime.now().millisecondsSinceEpoch}',
        'amount': 0.0, // Replace with actual amount
        'payment_date': DateTime.now().toIso8601String(),
        'status': 'pending',
      };

      await _client.from('payments').insert(newPayment);
      debugPrint('Payment added successfully');
    } catch (e) {
      debugPrint('Error adding payment: $e');
      rethrow;
    }
  }

  Future<void> downloadPaymentTemplate() async {
    try {
      // Create a sample CSV template
      List<List<dynamic>> template = [
        ['Invoice Number', 'Payment Amount', 'Payment Date'],
        ['INV-001', '10000', '2024-02-15'],
      ];

      String csvContent = const csv_converter.ListToCsvConverter().convert(template);
      
      // Get temporary directory for saving
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/payment_template.csv');
      
      await file.writeAsString(csvContent);
      debugPrint('Payment template downloaded to ${file.path}');
    } catch (e) {
      debugPrint('Error downloading payment template: $e');
      rethrow;
    }
  }

  Future<void> uploadPayments() async {
    try {
      // Placeholder for payment upload logic
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/uploaded_payments.csv');
      
      if (!await file.exists()) {
        throw Exception('No payment file selected');
      }

      // Read and parse CSV
      String csvString = await file.readAsString();
      List<List<dynamic>> csvTable = const csv_converter.CsvToListConverter().convert(csvString);

      // Skip header row and process payments
      for (var i = 1; i < csvTable.length; i++) {
        final payment = {
          'invoice_number': csvTable[i][0],
          'amount': csvTable[i][1],
          'payment_date': csvTable[i][2],
        };

        await _client.from('payments').insert(payment);
      }

      debugPrint('Payments uploaded successfully');
    } catch (e) {
      debugPrint('Error uploading payments: $e');
      rethrow;
    }
  }
}
