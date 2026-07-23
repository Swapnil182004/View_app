import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
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
                      Icons.shield_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Privacy Policy',
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

            // Content
            _buildSection(
              icon: Icons.info_outline,
              title: 'Introduction',
              content:
                  'View Institute ("we", "our", "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and services.',
            ),
            const SizedBox(height: 20),

            _buildSection(
              icon: Icons.download_rounded,
              title: 'Information We Collect',
              content:
                  'We may collect the following types of information:\n\n'
                  '• Personal Information: Name, email address, phone number, and profile information when you register.\n\n'
                  '• Payment Information: When you purchase courses, payment details are processed securely through third-party payment gateways. We do not store your full payment credentials.\n\n'
                  '• Usage Data: Information about how you use our app, including courses viewed, progress tracking, and feature interactions.\n\n'
                  '• Device Information: Device type, operating system, and app version for optimization and troubleshooting.',
            ),
            const SizedBox(height: 20),

            _buildSection(
              icon: Icons.settings_rounded,
              title: 'How We Use Your Information',
              content:
                  'We use the collected information for the following purposes:\n\n'
                  '• To provide, maintain, and improve our educational services.\n\n'
                  '• To process transactions and send purchase confirmations.\n\n'
                  '• To send updates, promotional materials, and important notices related to your courses.\n\n'
                  '• To personalize your learning experience and recommend relevant content.\n\n'
                  '• To detect, prevent, and address technical issues and fraud.',
            ),
            const SizedBox(height: 20),

            _buildSection(
              icon: Icons.share_rounded,
              title: 'Data Sharing & Disclosure',
              content:
                  'We do not sell your personal information. We may share your data only in the following circumstances:\n\n'
                  '• With service providers who assist us in operating our platform (e.g., payment processors, cloud hosting).\n\n'
                  '• To comply with legal obligations or respond to lawful requests.\n\n'
                  '• To protect our rights, property, or safety, and that of our users.',
            ),
            const SizedBox(height: 20),

            _buildSection(
              icon: Icons.lock_rounded,
              title: 'Data Security',
              content:
                  'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the internet is 100% secure.',
            ),
            const SizedBox(height: 20),

            _buildSection(
              icon: Icons.remove_red_eye_rounded,
              title: 'Your Rights',
              content:
                  'You have the right to:\n\n'
                  '• Access, update, or delete your personal information.\n\n'
                  '• Object to or restrict processing of your data.\n\n'
                  '• Withdraw consent at any time where we rely on your consent.\n\n'
                  '• Request a copy of your data in a structured, machine-readable format.\n\n'
                  'To exercise these rights, please contact us at support@viewinstitute.com.',
            ),
            const SizedBox(height: 20),

            _buildSection(
              icon: Icons.update_rounded,
              title: 'Changes to This Policy',
              content:
                  'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new policy on this page and updating the "Last updated" date. You are advised to review this policy periodically.',
            ),
            const SizedBox(height: 20),

            _buildSection(
              icon: Icons.contact_mail_rounded,
              title: 'Contact Us',
              content:
                  'If you have any questions about this Privacy Policy, please contact us:\n\n'
                  '• Email: support@viewinstitute.com\n'
                  '• Website: https://viewinstitutes.com\n'
                  '• Address: View Institute, India',
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
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
}