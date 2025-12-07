import 'package:flutter/material.dart';
import 'package:e_cycle/constants/colors.dart';
import 'package:e_cycle/constants/app_styles.dart';
import 'package:e_cycle/screens/widgets/new_header.dart';

class Kebijakan_Screen extends StatelessWidget {
  const Kebijakan_Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: NewHeader(title: "Kebijakan Privasi"),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.privacy_tip_rounded,
                                    color: primaryColor,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Kebijakan Privasi',
                                  style: AppStyles.titleStyle.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Terakhir diperbarui: 1 Januari 2024',
                                  style: AppStyles.descriptionStyle.copyWith(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Content Sections
                          _buildSection(
                            title: '1. Pengumpulan Data',
                            content:
                                'E-Cycle mengumpulkan informasi pribadi yang Anda berikan secara sukarela melalui aplikasi, termasuk nama, email, nomor telepon, alamat, dan informasi rekening bank. Kami juga mengumpulkan data penggunaan aplikasi seperti aktivitas, lokasi, dan preferensi untuk meningkatkan layanan kami.',
                          ),
                          const SizedBox(height: 20),
                          _buildSection(
                            title: '2. Penggunaan Data',
                            content:
                                'Data yang kami kumpulkan digunakan untuk:\n• Menyediakan dan meningkatkan layanan E-Cycle\n• Memproses transaksi penarikan poin\n• Berkomunikasi dengan Anda tentang akun dan layanan\n• Menganalisis penggunaan aplikasi\n• Mencegah fraud dan melindungi keamanan\n• Mematuhi kewajiban hukum',
                          ),
                          const SizedBox(height: 20),
                          _buildSection(
                            title: '3. Keamanan Data',
                            content:
                                'Kami menggunakan enkripsi SSL/TLS untuk melindungi data pribadi Anda dalam transit. Semua informasi sensitif disimpan di server aman dengan akses terbatas. Namun, tidak ada metode transmisi internet yang 100% aman. Kami tidak dapat menjamin keamanan absolut dari akses tidak sah.',
                          ),
                          const SizedBox(height: 20),
                          _buildSection(
                            title: '4. Pembagian Data Kepada Pihak Ketiga',
                            content:
                                'Kami tidak akan menjual, menyewakan, atau membagikan informasi pribadi Anda kepada pihak ketiga tanpa persetujuan Anda, kecuali:\n• Untuk mitra layanan pembayaran (bank, e-wallet)\n• Ketika diperlukan oleh hukum atau otoritas pemerintah\n• Untuk melindungi hak dan keselamatan kami',
                          ),
                          const SizedBox(height: 20),
                          _buildSection(
                            title: '5. Hak Pengguna',
                            content:
                                'Anda memiliki hak untuk:\n• Mengakses data pribadi Anda\n• Meminta koreksi data yang tidak akurat\n• Menghapus akun dan data pribadi Anda\n• Menolak penggunaan data untuk tujuan marketing\n• Mencabut persetujuan kapan saja',
                          ),
                          const SizedBox(height: 20),
                          _buildSection(
                            title: '6. Cookies dan Teknologi Pelacakan',
                            content:
                                'E-Cycle menggunakan cookies dan teknologi pelacakan serupa untuk meningkatkan pengalaman pengguna. Anda dapat menonaktifkan cookies melalui pengaturan perangkat, tetapi ini mungkin mempengaruhi fungsionalitas aplikasi.',
                          ),
                          const SizedBox(height: 20),
                          _buildSection(
                            title: '7. Retensi Data',
                            content:
                                'Kami menyimpan data pribadi Anda selama akun aktif dan untuk periode yang diperlukan oleh hukum. Setelah penghapusan akun, data akan dihapus dalam jangka waktu 30 hari, kecuali ada kewajiban hukum untuk mempertahankannya.',
                          ),
                          const SizedBox(height: 20),
                          _buildSection(
                            title: '8. Perubahan Kebijakan',
                            content:
                                'E-Cycle dapat mengubah kebijakan privasi ini kapan saja. Kami akan memberitahu Anda tentang perubahan signifikan melalui notifikasi dalam aplikasi. Penggunaan berkelanjutan atas aplikasi setelah perubahan berarti Anda menerima kebijakan yang diperbarui.',
                          ),
                          const SizedBox(height: 20),
                          _buildSection(
                            title: '9. Hubungi Kami',
                            content:
                                'Jika Anda memiliki pertanyaan tentang kebijakan privasi ini, silakan hubungi kami di:\n• Email: privacy@ecycle.com\n• Alamat: Jl. Sustainability No. 123, Jakarta',
                          ),
                          const SizedBox(height: 32),

                          // Agreement Box
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: accentColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.verified_rounded,
                                      color: accentColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Komitmen Kami',
                                      style: AppStyles.titleStyle.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'E-Cycle berkomitmen untuk melindungi privasi Anda dan mematuhi semua peraturan perlindungan data yang berlaku. Kami percaya transparansi adalah kunci hubungan yang baik dengan pengguna kami.',
                                  style: AppStyles.descriptionStyle.copyWith(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppStyles.titleStyle.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: AppStyles.descriptionStyle.copyWith(
            fontSize: 13,
            color: Colors.grey.shade700,
            height: 1.6,
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }
}
