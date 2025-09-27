import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- Added
import 'package:lottie/lottie.dart'; // Add this to your pubspec.yaml

void showWaterIntakeBottomSheet(BuildContext context, String userId) {
  double selectedCups = 0;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          top: 16,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Select water cups",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Lottie.asset(
                  'assets/water_glass.json', // Add a Lottie animation file
                  height: 120,
                  repeat: true,
                ),
                const SizedBox(height: 10),
                Slider(
                  min: 0,
                  max: 12,
                  divisions: 12,
                  label: '${selectedCups.toInt()} cups',
                  value: selectedCups,
                  onChanged: (value) {
                    setState(() {
                      selectedCups = value;
                    });
                  },
                  activeColor: const Color(0xFF6785F2),
                  inactiveColor: Colors.grey[300],
                ),
                const SizedBox(height: 10),
                Text(
                  "${selectedCups.toInt()} cups",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6785F2),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '"Keep sipping — your body will thank you!"',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6785F2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: () async {
                    final currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser != null) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser.uid)
                          .collection('water_intake_logs')
                          .add({
                        'cups': selectedCups.toInt(),
                        'timestamp': Timestamp.now(),
                      });
                    }
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.water_drop, color: Colors.white),
                  label: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
