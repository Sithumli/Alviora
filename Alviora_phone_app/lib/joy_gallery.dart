import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'home_screen.dart';

class JoyGalleryPage extends StatefulWidget {
  const JoyGalleryPage({super.key});

  @override
  State<JoyGalleryPage> createState() => _JoyGalleryPageState();
}

class _JoyGalleryPageState extends State<JoyGalleryPage> {
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  Future<void> fetchImages() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('joy_gallery').get();
    setState(() {
      imageUrls = snapshot.docs.map((doc) => doc['url'] as String).toList();
    });
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      UploadTask uploadTask = FirebaseStorage.instance
          .ref('joy_gallery/$fileName.jpg')
          .putFile(imageFile);

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('joy_gallery').add({
        'url': downloadUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      fetchImages(); // Refresh the gallery
    } catch (e) {
      print('Error uploading: $e');
    }
  }

  void showUploadDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Upload Image"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_upload, size: 60, color: Colors.blue),
            const SizedBox(height: 10),
            const Text("Drag & Drop or Browse from your device"),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                pickAndUploadImage();
              },
              icon: const Icon(Icons.upload),
              label: const Text("Upload from device"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()),
                      );
                    },
                    child: const Icon(Icons.home_rounded),
                  ),
                  const Icon(Icons.menu),
                ],
              ),
            ),

            // Header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF85A6FF), Color(0xFFA0BDFD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Joy Gallery',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Add Him/Her collection of happy moments',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Gallery Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  itemCount: imageUrls.length + 1,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (context, index) {
                    if (index < imageUrls.length) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrls[index],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                        ),
                      );
                    } else {
                      // Add Button
                      return GestureDetector(
                        onTap: showUploadDialog,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueAccent),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: const Center(
                            child: Icon(Icons.add, size: 40, color: Colors.blue),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
