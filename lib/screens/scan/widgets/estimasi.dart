import 'package:e_cycle/constants/colors.dart';
import 'package:e_cycle/screens/scan/scan.dart';
import 'package:flutter/material.dart';

class Estimasi extends StatelessWidget {
  final String result;
  final int points;

  const Estimasi({super.key, required this.result, required this.points});

  @override
  Widget build(BuildContext context) {
    final pointText = points.toString();
    final pointToPrice = (points * 100).toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Scan()),
                      );
                    },
                    icon: const Icon(Icons.arrow_back_ios_new),
                    color: Colors.white,
                  ),
                  const Expanded(
                    child: Text(
                      "Tips Pengolahan",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 48)
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Estimasi Harga",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        result,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/coin.png",
                            width: 110,
                          ),
                          const SizedBox(width: 15),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                pointText,
                                style: const TextStyle(
                                    fontSize: 40, color: primaryColor),
                              ),
                              const Text(
                                "GreenPoints",
                                style: TextStyle(fontSize: 12),
                              )
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Icon(
                        Icons.keyboard_double_arrow_down_rounded,
                        size: 32,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Rp$pointToPrice",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Divider(
                        color: Colors.grey[300],
                        thickness: 1,
                      ),
                      const SizedBox(height: 10),
                      _buildTipStep(
                          "01",
                          "Sortir dan periksa perangkat elektronik",
                          "Sortir dan periksa perangkat elektronik Anda dari kondisi fisik dan fungsionalitasnya. Perangkat Anda bisa diremanufaktur!"),
                      _buildTipStep("02", "Bongkar dan Bersihkan",
                          "Coba bongkar perangkat elektronik Anda berdasarkan komponennya. Apabila tidak bisa, tim E-Cycle akan membantu!"),
                      _buildTipStep("03", "Antar / Pick-up E-Waste kamu!",
                          "Antar atau pesan pick-up untuk sampah elektronikmu, dan dapatkan E-Point sebagai reward!"),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildTipStep(String step, String title, String description) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.yellow[700],
          child: Text(
            step,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
