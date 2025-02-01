import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/transaction_service.dart';

class TransactionPage extends ConsumerStatefulWidget {
  const TransactionPage({Key? key}) : super(key: key);

  @override
  ConsumerState<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends ConsumerState<TransactionPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedYear = '2024-2025';
  final TransactionService _transactionService = TransactionService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _safeAction(Future<void> Function() action, String successMessage) async {
    try {
      await action();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Invoices'),
            Tab(text: 'Payments'),
            Tab(text: 'Ledger'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFinancialYearDropdown(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInvoicesTab(),
                _buildPaymentsTab(),
                _buildLedgerTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialYearDropdown() {
    return DropdownButton<String>(
      value: _selectedYear,
      items: const [
        DropdownMenuItem(value: '2024-2025', child: Text('2024-2025')),
        DropdownMenuItem(value: '2023-2024', child: Text('2023-2024')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedYear = value!;
        });
      },
    );
  }

  Widget _buildInvoicesTab() {
    return Column(
      children: [
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _safeAction(
            () => _transactionService.addInvoice(), 
            'Invoice added successfully',
          ),
          child: const Text('Add Invoice'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _safeAction(
            () => _transactionService.downloadInvoiceTemplate(), 
            'Invoice template downloaded',
          ),
          child: const Text('Download Template'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _safeAction(
            () => _transactionService.uploadInvoices(), 
            'Invoices uploaded successfully',
          ),
          child: const Text('Upload Invoices'),
        ),
      ],
    );
  }

  Widget _buildPaymentsTab() {
    return Column(
      children: [
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _safeAction(
            () => _transactionService.addPayment(), 
            'Payment added successfully',
          ),
          child: const Text('Add Payment'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _safeAction(
            () => _transactionService.downloadPaymentTemplate(), 
            'Payment template downloaded',
          ),
          child: const Text('Download Template'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _safeAction(
            () => _transactionService.uploadPayments(), 
            'Payments uploaded successfully',
          ),
          child: const Text('Upload Payments'),
        ),
      ],
    );
  }

  Widget _buildLedgerTab() {
    return const Center(
      child: Text('Customer Ledger'),
    );
  }
}
