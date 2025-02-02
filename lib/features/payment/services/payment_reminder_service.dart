import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentReminderService {
  final Logger _logger = Logger('PaymentReminderService');
  final SupabaseClient _client;

  const PaymentReminderService({required SupabaseClient client}) : _client = client;

  /// Send payment reminder via WhatsApp
  /// 
  /// [invoiceId] The unique identifier for the invoice
  /// [reminderType] Type of reminder (7 days, 15 days, pre-expiry)
  Future<bool> sendWhatsAppReminder({
    required String invoiceId, 
    required ReminderType reminderType,
  }) async {
    try {
      // TODO: Implement actual WhatsApp API Integration
      // Comprehensive steps:
      // 1. Validate invoice details from Supabase
      // 2. Fetch customer contact and communication preferences
      // 3. Compose personalized message based on reminder type
      // 4. Select appropriate WhatsApp API (Twilio, WhatsApp Business, etc.)
      // 5. Send message and log delivery status
      
      _logger.info('Preparing WhatsApp reminder for invoice $invoiceId');
      
      // Simulated API call with detailed logging
      await Future.delayed(const Duration(seconds: 2));
      
      _logger.info('WhatsApp reminder sent successfully for invoice $invoiceId');
      return true;
    } catch (e, stackTrace) {
      _logger.severe('Failed to send WhatsApp reminder', e, stackTrace);
      return false;
    }
  }

  /// Determine reminder schedule based on credit period
  /// 
  /// [creditPeriodDays] Total days in credit period
  List<ReminderSchedule> calculateReminderSchedule(int creditPeriodDays) {
    final List<ReminderSchedule> reminders = [];

    if (creditPeriodDays >= 15) {
      reminders.addAll([
        const ReminderSchedule(
          type: ReminderType.sevenDaysAfter, 
          daysFromInvoice: 7,
        ),
        const ReminderSchedule(
          type: ReminderType.fifteenDaysAfter, 
          daysFromInvoice: 15,
        ),
      ]);
    } else if (creditPeriodDays > 7) {
      // For shorter periods, consolidate reminders
      reminders.add(ReminderSchedule(
        type: ReminderType.preExpiry, 
        daysFromInvoice: creditPeriodDays - 1,
      ));
    } else {
      // Very short credit periods
      reminders.add(ReminderSchedule(
        type: ReminderType.preExpiry, 
        daysFromInvoice: creditPeriodDays - 1,
      ));
    }

    return reminders;
  }

  /// Send WhatsApp reminder to a specific customer
  /// 
  /// [customerPhone] Customer's phone number
  /// [invoiceNumber] Unique invoice identifier
  /// [reminderMessage] Customized reminder message
  Future<void> sendWhatsappReminder({
    required String customerPhone,
    required String invoiceNumber,
    required String reminderMessage,
  }) async {
    try {
      // TODO: Implement WhatsApp API Integration
      _logger.info('Sending WhatsApp reminder to $customerPhone for invoice $invoiceNumber');
      
      // Simulated async operation
      await Future.delayed(const Duration(seconds: 1));
      
      _logger.info('WhatsApp reminder sent successfully');
    } catch (e, stackTrace) {
      _logger.severe('Failed to send WhatsApp reminder', e, stackTrace);
    }
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
          reminderMessage: 'Reminder: Your invoice is due on $creditPeriodEnd',
        );
      }
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
}

/// Enum to categorize different reminder types
enum ReminderType {
  sevenDaysAfter,
  fifteenDaysAfter,
  preExpiry,
}

/// Represents a scheduled reminder
class ReminderSchedule {
  final ReminderType type;
  final int daysFromInvoice;

  const ReminderSchedule({
    required this.type, 
    required this.daysFromInvoice,
  });
}
