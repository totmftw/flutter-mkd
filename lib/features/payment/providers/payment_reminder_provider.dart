import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart' show AsyncValue;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/payment_reminder_service.dart';

final paymentReminderServiceProvider = Provider<PaymentReminderService>((ref) {
  return PaymentReminderService(client: Supabase.instance.client);
});

final paymentReminderControllerProvider = StateNotifierProvider<PaymentReminderController, AsyncValue<void>>((ref) {
  final service = ref.watch(paymentReminderServiceProvider);
  return PaymentReminderController(service);
});

class PaymentReminderController extends StateNotifier<AsyncValue<void>> {
  final PaymentReminderService _service;

  PaymentReminderController(this._service) : super(AsyncValue.data(null));

  Future<void> checkAndSendReminders() async {
    state = AsyncValue.loading();
    try {
      // Fetch pending invoices
      final pendingInvoices = await _fetchPendingInvoices();
      
      // Send reminders for each pending invoice
      for (var invoice in pendingInvoices) {
        await _service.sendWhatsappReminder(
          customerPhone: invoice['customer_phone'],
          invoiceNumber: invoice['invoice_number'],
          invoiceDate: DateTime.parse(invoice['invoice_date']),
          creditPeriodEnd: DateTime.parse(invoice['credit_period_end']),
        );
      }
      
      state = AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchPendingInvoices() async {
    // Placeholder implementation
    // In a real app, this would query the database for unpaid invoices
    return [
      {
        'customer_phone': '+919876543210',
        'invoice_number': 'INV-001',
        'invoice_date': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        'credit_period_end': DateTime.now().add(const Duration(days: 20)).toIso8601String(),
      }
    ];
  }
}
