// emergency_screen.dart - Firebase Integrated
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/firebase_service.dart';
import '../models/emergency_contact_model.dart';
import '../widgets/emergency_buttons.dart';
import '../screens/emergency_contacts_screen.dart';
import '../screens/medical_info_screen.dart';
import 'package:just_audio/just_audio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';


class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  List<EmergencyContactModel> emergencyContacts = [];
  bool isLoading = true;
  Position? currentLocation;
  String? get userId => FirebaseService.currentUserId;

  late final AudioPlayer _alertPlayer;
  StreamSubscription<DatabaseEvent>? _alertSubscription;

  @override
  void initState() {
    super.initState();
    _alertPlayer = AudioPlayer();
    _loadEmergencyContacts();
    _getCurrentLocation();
    _listenForEmergencyAlerts();
  }

  void _listenForEmergencyAlerts() {
    final alertsRef = FirebaseDatabase.instance.ref('alerts');
    _alertSubscription = alertsRef.onChildAdded.listen((event) async {
      final alert = event.snapshot.value as Map<dynamic, dynamic>?;
      if (alert == null) return;
      // Only play sound if alert is for this user
      if (alert['userId'] == userId && alert['sound'] == 'alert_sound.mp3') {
        try {
          await _alertPlayer.setAsset('assets/sounds/notification.mp3');
          await _alertPlayer.play();
        } catch (e) {
          print('Error playing emergency alert sound: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    _alertSubscription?.cancel();
    _alertPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadEmergencyContacts() async {
    try {
      final contacts = await FirebaseService.getEmergencyContacts();
      setState(() {
        emergencyContacts = contacts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading contacts: $e')),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        currentLocation = position;
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _triggerEmergency(String type) async {
    try {
      // Show confirmation dialog
      final confirmed = await _showEmergencyConfirmation(type);
      if (!confirmed) return;

      // Get current location
      Map<String, dynamic> location = {};
      if (currentLocation != null) {
        location = {
          'latitude': currentLocation!.latitude,
          'longitude': currentLocation!.longitude,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
      }

      // Trigger emergency alert
      await FirebaseService.triggerEmergencyAlert(
        type: type,
        location: location,
        additionalInfo: 'Emergency triggered from Alviora app',
      );

      // Log activity
      await FirebaseService.logUserActivity('emergency_triggered', {
        'type': type,
        'hasLocation': currentLocation != null,
      });

      // Make actual call for critical emergencies
      if (type == 'medical' || type == 'fire' || type == 'police') {
        await _makeEmergencyCall(type);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Emergency alert sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<bool> _showEmergencyConfirmation(String type) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Confirm Emergency'),
        content: Text('Are you sure you want to trigger a $type emergency alert?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _makeEmergencyCall(String type) async {
    String phoneNumber = '';
    switch (type) {
      case 'medical':
      case 'fire':
      case 'police':
        phoneNumber = '911';
        break;
    }

    if (phoneNumber.isNotEmpty) {
      final uri = Uri.parse('tel:$phoneNumber');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  Future<void> _callFamilyMember() async {
    if (emergencyContacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No emergency contacts available')),
      );
      return;
    }

    // Show dialog to select family member
    final selectedContact = await showDialog<EmergencyContactModel>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Contact'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: emergencyContacts.length,
            itemBuilder: (context, index) {
              final contact = emergencyContacts[index];
              return ListTile(
                leading: Icon(Icons.person),
                title: Text(contact.name),
                subtitle: Text(contact.relationship),
                onTap: () => Navigator.of(context).pop(contact),
              );
            },
          ),
        ),
      ),
    );

    if (selectedContact != null) {
      final uri = Uri.parse('tel:${selectedContact.phoneNumber}');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);

        // Log the call
        await FirebaseService.logUserActivity('emergency_call', {
          'contactId': selectedContact.id,
          'contactName': selectedContact.name,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FF),
      appBar: AppBar(
        backgroundColor: const Color(0x5EA8FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Emergency',
          style: TextStyle(
            color: Colors.red,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Emergency header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.shade200, width: 2),
                ),
                child: Column(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red, size: 80),
                    const SizedBox(height: 15),
                    const Text(
                      'Emergency Assistance',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currentLocation != null
                          ? 'Location services enabled - Help will find you'
                          : 'Press any button below for immediate help',
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Emergency buttons
              Builder(
                builder: (context) {
                  final screenHeight = MediaQuery.of(context).size.height;
                  final buttonRowHeight = screenHeight * 0.38;
                  return SizedBox(
                    height: buttonRowHeight,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: EmergencyButton(
                              icon: Icons.local_hospital,
                              label: 'Call 911\nMedical Emergency',
                              color: Colors.red,
                              onTap: () => _triggerEmergency('medical'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: EmergencyButton(
                              icon: Icons.local_fire_department,
                              label: 'Fire Department',
                              color: Colors.orange,
                              onTap: () => _triggerEmergency('fire'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: EmergencyButton(
                              icon: Icons.local_police,
                              label: 'Police',
                              color: Colors.blue,
                              onTap: () => _triggerEmergency('police'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: EmergencyButton(
                              icon: Icons.home_filled,
                              label: 'Call Family\nMember',
                              color: const Color(0xFF5EA8FF),
                              onTap: _callFamilyMember,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.black12)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            QuickActionButton(
              icon: Icons.location_on,
              label: 'Share Location',
              onTap: () async {
                if (currentLocation != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Location shared with emergency contacts')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Location not available')),
                  );
                }
              },
            ),
            QuickActionButton(
              icon: Icons.medical_information,
              label: 'Medical Info',
              onTap: () {
                if (userId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MedicalInfoScreen(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User not authenticated')),
                  );
                }
              },
            ),
            QuickActionButton(
              icon: Icons.contact_emergency,
              label: 'Emergency Contacts',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EmergencyContactsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}