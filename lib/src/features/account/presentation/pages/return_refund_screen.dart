import 'package:flutter/material.dart';

class ReturnRefundScreen extends StatelessWidget {
  const ReturnRefundScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Return & Refund Policy'),
        backgroundColor: Colors.transparent,
        foregroundColor: cs.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF1E40AF), const Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.currency_rupee_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Return & Refund Policy',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last updated: 23 July 2026',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Overview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2563EB).withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF1E40AF),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'At View Institute, we strive to provide the best learning experience. '
                      'This policy outlines the terms for refunds and cancellations for course purchases.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 1: Course Purchase Failure Refund
            _buildHighlightSection(
              icon: Icons.error_outline_rounded,
              iconColor: const Color(0xFFDC2626),
              bgColor: const Color(0xFFFEF2F2),
              title: 'Payment Failure — 7-Day Refund Policy',
              content:
                  'If a course purchase fails due to a technical error but the amount has been deducted from your account, '
                  'we will process a full refund within 7 working days.\n\n'
                  'This refund will be processed manually by our support team. '
                  'Please contact us with the following details:\n\n'
                  '• Transaction ID / Reference Number\n'
                  '• Course Name\n'
                  '• Registered Email / Phone Number\n'
                  '• Screenshot of the deduction (if available)',
            ),
            const SizedBox(height: 20),

            // Section 2: General Refund Policy
            _buildSection(
              icon: Icons.refresh_rounded,
              title: 'General Refund Policy',
              content:
                  '• All course purchases are non-refundable once the course content has been accessed or downloaded.\n\n'
                  '• If you have not accessed any course material within 7 days of purchase, you may request a full refund.\n\n'
                  '• Refunds will be processed within 7-10 business days after approval.\n\n'
                  '• The refund will be credited to the original payment method used during purchase.',
            ),
            const SizedBox(height: 20),

            // Section 3: How to Request a Refund
            _buildSection(
              icon: Icons.assignment_rounded,
              title: 'How to Request a Refund',
              content:
                  'To request a refund, please follow these steps:\n\n'
                  '1. Send an email to support@viewinstitute.com with the subject "Refund Request".\n\n'
                  '2. Include your registered name, email, phone number, and transaction ID.\n\n'
                  '3. Explain the reason for your refund request.\n\n'
                  '4. Our support team will review your request and respond within 2-3 business days.\n\n'
                  '5. If approved, the refund will be processed manually within 7 working days.',
            ),
            const SizedBox(height: 20),

            // Section 4: Contact for Refund Issues
            _buildSection(
              icon: Icons.headset_mic_rounded,
              title: 'Need Help? Contact Us',
              content:
                  'If you have any questions or concerns regarding refunds, please reach out to us:\n\n'
                  '• Email: support@viewinstitute.com\n'
                  '• Website: https://viewinstitutes.com\n'
                  '• Response Time: Within 24-48 hours',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E40AF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: const Color(0xFF1E40AF)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightSection({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: iconColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}