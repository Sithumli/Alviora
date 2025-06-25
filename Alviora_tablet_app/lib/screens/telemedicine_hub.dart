import 'package:flutter/material.dart';
import 'telemedicine_videocall.dart';

class TelemedicineHub extends StatelessWidget {
  final List<Map<String, dynamic>> doctors = [
    {
      "name": "Dr. Isanka Gunawardhana",
      "specialization": "Brain Specialist",
      "experience": "6 yrs",
      "startsIn": "Starts in 30 min",
      "icon": Icons.psychology,
      //"image": "https://i.imgur.com/EzH78hr.png", // removed image
    },
    {
      "name": "Dr. Uthpala Jayawansha",
      "specialization": "Cardiologist",
      "experience": "10 yrs",
      "startsIn": "Starts in 5 hrs",
      "icon": Icons.favorite,
      //"image": "https://i.imgur.com/BpFboN2.png", // removed image
    },
    {
      "name": "Dr. Wasantha Jayawansha",
      "specialization": "Neurologist",
      "experience": "10 yrs",
      "startsIn": "Starts in 5 hrs",
      "icon": Icons.favorite,
      //"image": "https://i.imgur.com/BpFboN2.png", // removed image
    },
    {
      "name": "Dr. sithumli nanayakkara",
      "specialization": "Oncologist",
      "experience": "10 yrs",
      "startsIn": "Starts in 5 hrs",
      "icon": Icons.favorite,
      //"image": "https://i.imgur.com/BpFboN2.png", // removed image
    },
  ];

  final Color blueTheme = Color(0xFF368FF5); // Main blue
  final Color lightBlue = Color(0xFFE8F1FA); // Light background

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlue,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: blueTheme),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Connect with ',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Doctors',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: blueTheme),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: blueTheme,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Container(
                            margin: EdgeInsets.all(12),
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50), // circle
                              color: Colors.white24,
                            ),
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white70,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doctor["name"],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(doctor["icon"],
                                          color: Colors.white, size: 18),
                                      SizedBox(width: 6),
                                      Text(
                                        doctor["specialization"],
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      SizedBox(width: 12),
                                      Icon(Icons.medical_services,
                                          color: Colors.white, size: 18),
                                      SizedBox(width: 4),
                                      Text(
                                        doctor["experience"],
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius:
                                          BorderRadius.circular(16),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.schedule,
                                                color: Colors.white, size: 16),
                                            SizedBox(width: 4),
                                            Text(
                                              doctor["startsIn"],
                                              style:
                                              TextStyle(color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Spacer(),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => VideoCallPage(
                                                doctorName: doctor["name"],
                                                specialization:
                                                doctor["specialization"],
                                              ),
                                            ),
                                          );
                                        },
                                        icon: Icon(Icons.video_camera_front,
                                            size: 18),
                                        label: Text("Join Call"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: blueTheme,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(16),
                                          ),
                                          elevation: 2,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
