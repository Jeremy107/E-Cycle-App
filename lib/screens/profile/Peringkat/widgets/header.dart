import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              // Go Back
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),
          Text(
            "E-Leaderboard",
            style: const TextStyle(fontSize: 24, color: Colors.white),
          ),
          const SizedBox(
            width: 25,
          ),
        ],
      ),
    );
  }
}
