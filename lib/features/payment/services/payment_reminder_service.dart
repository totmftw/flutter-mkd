import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentReminderService {
  final SupabaseClient _client;

  PaymentReminderService({required SupabaseClient client}) : _client = client;

  Future<void> sendWhatsappReminder({
    required String customerPhone,
    required String invoiceNumber,
    required DateTime invoiceDate,
    required DateTime creditPeriodEnd,
  }) async {
    // TODO: Implement WhatsApp API Integration
    // Detailed steps:
    // 1. Validate WhatsApp API credentials
    // 2. Construct message template
    // 3. Send API request to WhatsApp provider
    // 4. Log reminder sending status
    try {
      debugPrint('Sending WhatsApp reminder for invoice $invoiceNumber');
      debugPrint('Customer Phone: $customerPhone');
      debugPrint('Invoice Date: $invoiceDate');
      debugPrint('Credit Period End: $creditPeriodEnd');

      final reminderTypes = _determineReminderTypes(invoiceDate, creditPeriodEnd);
      
      for (var reminderType in reminderTypes) {
        debugPrint('Sending $reminderType WhatsApp reminder');
        // Actual WhatsApp API call would go here
      }

      // Log the reminder attempt
      await _client.from('payment_reminders').insert({
        'customer_phone': customerPhone,
        'invoice_number': invoiceNumber,
        'invoice_date': invoiceDate.toIso8601String(),
        'credit_period_end': creditPeriodEnd.toIso8601String(),
        'reminder_sent_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error sending WhatsApp reminder: $e');
      rethrow;
    }
  }

  List<String> _determineReminderTypes(DateTime invoiceDate, DateTime creditPeriodEnd) {
    final List<String> reminders = [];
    final now = DateTime.now();
    final daysSinceInvoice = now.difference(invoiceDate).inDays;
    final daysUntilCreditEnd = creditPeriodEnd.difference(now).inDays;

    // Standard reminder logic based on credit period
    if (daysSinceInvoice >= 7) {
      reminders.add('7-day reminder');
    }

    if (daysSinceInvoice >= 15) {
      reminders.add('15-day reminder');
    }

    if (daysUntilCreditEnd <= 1) {
      reminders.add('credit period ending');
    }

    return reminders;
  }

  Future<List<Map<String, dynamic>>> getPendingInvoices() async {
    try {
      final response = await _client
          .from('invoices')
          .select('*')
          .eq('status', 'unpaid')
          .execute();
      
      return response.data ?? [];
    } catch (e) {
      debugPrint('Error fetching pending invoices: $e');
      return [];
    }
  }

  Future<void> checkAndSendReminders() async {
    final pendingInvoices = await getPendingInvoices();
    
    for (var invoice in pendingInvoices) {
      final invoiceDate = DateTime.parse(invoice['invoice_date']);
      final creditPeriodEnd = DateTime.parse(invoice['credit_period_end']);

      // Reminder logic based on credit period
      final reminderTypes = _determineReminderTypes(invoiceDate, creditPeriodEnd);
      if (reminderTypes.isNotEmpty) {
        await sendWhatsappReminder(
          customerPhone: invoice['customer_phone'],
          invoiceNumber: invoice['invoice_number'],
          invoiceDate: invoiceDate,
          creditPeriodEnd: creditPeriodEnd,
        );
      }
    }
  }
}
