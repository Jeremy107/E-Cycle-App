import 'package:flutter/material.dart';
import 'package:e_cycle/constants/colors.dart';
import 'package:e_cycle/constants/app_styles.dart';
import 'package:e_cycle/screens/widgets/new_header.dart';

class Pusat_Bantuan_Screen extends StatefulWidget {
  const Pusat_Bantuan_Screen({super.key});

  @override
  State<Pusat_Bantuan_Screen> createState() => _Pusat_Bantuan_ScreenState();
}

class _Pusat_Bantuan_ScreenState extends State<Pusat_Bantuan_Screen> {
  final List<FAQItem> faqItems = [
    FAQItem(
      question: 'Bagaimana cara mendapatkan poin E-Point?',
      answer:
          'Anda dapat mendapatkan poin E-Point dengan mengumpulkan sampah daur ulang melalui aplikasi E-Cycle. Setiap pengumpulan sampah akan memberikan poin berdasarkan jenis dan jumlah sampah yang dikumpulkan.',
    ),
    FAQItem(
      question: 'Berapa nilai tukar poin ke rupiah?',
      answer:
          'Nilai tukar poin adalah 1 poin = Rp 100. Anda dapat menukarkan poin ke rekening bank atau e-wallet sesuai dengan pilihan yang tersedia di aplikasi.',
    ),
    FAQItem(
      question: 'Berapa lama proses penarikan poin?',
      answer:
          'Proses penarikan poin membutuhkan waktu 1x24 jam untuk diverifikasi oleh tim kami. Setelah diverifikasi, uang akan langsung ditransfer ke rekening bank atau e-wallet Anda.',
    ),
    FAQItem(
      question: 'Apakah ada biaya untuk penarikan poin?',
      answer:
          'Tidak ada biaya administratif untuk proses penarikan poin. Semua biaya transfer akan ditanggung oleh pihak E-Cycle.',
    ),
    FAQItem(
      question: 'Bagaimana jika akun saya lupa password?',
      answer:
          'Anda dapat menggunakan fitur "Lupa Password" di halaman login. Kami akan mengirimkan link reset password ke email terdaftar Anda. Ikuti instruksi di email untuk membuat password baru.',
    ),
    FAQItem(
      question: 'Bagaimana cara menghubungi customer support?',
      answer:
          'Anda dapat menghubungi tim support kami melalui email: support@ecycle.com atau melalui chat dalam aplikasi. Tim kami siap membantu Anda 24/7.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: NewHeader(title: "Pusat Bantuan"),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // Search Bar
                    // FAQ Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.help_outline_rounded,
                              color: primaryColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Pertanyaan Umum',
                            style: AppStyles.titleStyle.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // FAQ Items
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: faqItems.length,
                        itemBuilder: (context, index) {
                          return _buildFAQItem(faqItems[index], index);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Contact Section
                    _buildContactSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(FAQItem item, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        backgroundColor: Colors.grey.shade50,
        collapsedBackgroundColor: Colors.white,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${index + 1}',
            style: AppStyles.titleStyle.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
        ),
        title: Text(
          item.question,
          style: AppStyles.titleStyle.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              item.answer,
              style: AppStyles.descriptionStyle.copyWith(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryColor.withOpacity(0.05),
              primaryColor.withOpacity(0.02)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: primaryColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hubungi Tim Support',
              style: AppStyles.titleStyle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildContactItem(
              icon: Icons.email_rounded,
              title: 'Email',
              value: 'support@ecycle.com',
            ),
            const SizedBox(height: 12),
            _buildContactItem(
              icon: Icons.phone_rounded,
              title: 'Telepon',
              value: '+62 812 3456 7890',
            ),
            const SizedBox(height: 12),
            _buildContactItem(
              icon: Icons.location_on_rounded,
              title: 'Alamat',
              value: 'Jl. Universitas',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to chat or contact form
                },
                icon: Icon(Icons.chat_rounded),
                label: Text(
                  'Chat dengan Support',
                  style: AppStyles.titleStyle.copyWith(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppStyles.descriptionStyle.copyWith(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              value,
              style: AppStyles.titleStyle.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({
    required this.question,
    required this.answer,
  });
}
