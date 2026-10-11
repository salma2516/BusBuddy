
import 'package:flutter/material.dart';

class DigitalTicketScreen extends StatelessWidget {
  final String ticketId;
  final String fromStop;
  final String toStop;
  final int seats;
  final double amount;
  final String status;
  final String busName;

  const DigitalTicketScreen({
    super.key,
    required this.ticketId,
    required this.fromStop,
    required this.toStop,
    required this.seats,
    required this.amount,
    required this.status,
    required this.busName,
  });

  @override
  Widget build(BuildContext context) {
    final Color purple = Colors.deepPurple;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAFF),
      appBar: AppBar(
        title: const Text('Digital Ticket'),
        backgroundColor: purple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 7,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.directions_bus_rounded,
                      size: 76,
                      color: purple,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'BusBuddy Digital Ticket',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ticket issued successfully',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Divider(color: purple.withValues(alpha: 0.35)),
                    _ticketRow('Ticket ID', ticketId),
                    _ticketRow('Bus', busName),
                    _ticketRow('From', fromStop),
                    _ticketRow('To', toStop),
                    _ticketRow('Number of Seats', seats.toString()),
                    _ticketRow('Amount', '₹${amount.toStringAsFixed(2)}'),
                    _ticketRow('Status', status),
                    _ticketRow(
                      'Issued On',
                      _formatDate(DateTime.now()),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: purple.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: purple.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            size: 54,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Ticket Confirmed',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Keep this ticket available for verification.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back to Conductor Dashboard'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: purple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ticketRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
