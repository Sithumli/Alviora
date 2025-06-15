import 'package:flutter/material.dart';

class MoodGallery extends StatelessWidget {
  const MoodGallery({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Go Back Button
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF4A90E2),
                          width: 2,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back,
                            color: Color(0xFF4A90E2),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Go Back',
                            style: TextStyle(
                              color: Color(0xFF4A90E2),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Joy Gallery Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF7BA7F7),
                      Color(0xFFA78BFA),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Stars decoration
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStar(12),
                        _buildStar(8),
                        _buildStar(10),
                        _buildStar(6),
                        _buildStar(14),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Joy Gallery',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add Him/Her collection of happy moments',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Photo Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return _buildPhotoCard(index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStar(double size) {
    return Icon(
      Icons.star,
      color: Colors.white.withOpacity(0.8),
      size: size,
    );
  }

  Widget _buildPhotoCard(int index) {
    // Replace these with your actual image paths
    final List<String> imageUrls = [
      'assets/images/friends_field.png',
      'assets/images/celebration.png',
      'assets/images/family_sunset.png',
      'assets/images/team_work.png',
      'assets/images/birthday_party.png',
      'assets/images/group_walk.png',
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Actual image display
            Image.asset(
              imageUrls[index % imageUrls.length],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback if image doesn't load
                return Container(
                  color: _getPlaceholderColor(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Image not found',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Overlay for better visual effect
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPlaceholderColor(int index) {
    final colors = [
      const Color(0xFFFFB74D), // Orange
      const Color(0xFFFFD54F), // Yellow
      const Color(0xFFFF8A65), // Deep Orange
      const Color(0xFF81C784), // Green
      const Color(0xFF64B5F6), // Blue
      const Color(0xFFBA68C8), // Purple
    ];
    return colors[index % colors.length];
  }

  Widget _getPlaceholderContent(int index) {
    final icons = [
      Icons.people,
      Icons.celebration,
      Icons.family_restroom,
      Icons.work,
      Icons.cake,
      Icons.directions_walk,
    ];

    return Center(
      child: Icon(
        icons[index % icons.length],
        size: 40,
        color: Colors.white.withOpacity(0.8),
      ),
    );
  }
}