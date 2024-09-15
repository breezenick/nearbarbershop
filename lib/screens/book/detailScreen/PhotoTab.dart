import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'PhotoViewGalleryScreen.dart';

class PhotoTab extends StatefulWidget {
  final String shopName;  // The shop name (or shop ID) passed from BarbershopDetailScreen

  PhotoTab({required this.shopName});

  @override
  _PhotoTabState createState() => _PhotoTabState();
}

class _PhotoTabState extends State<PhotoTab> {
  final picker = ImagePicker();
  List<Map<String, String>> _images = []; // List of image paths with shop names

  @override
  void initState() {
    super.initState();
    _loadImagePaths();  // Load saved images with shop names
  }

  // Pick an image and associate it with the current shop name
  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _images.add({
          'path': pickedFile.path,
          'shop': widget.shopName,  // Save the shop name with the image
        });
      });
      _saveImagePaths();  // Save the image paths to SharedPreferences
    } else {
      print('No image selected.');
    }
  }

  // Save the list of image paths and shop names in SharedPreferences
  Future<void> _saveImagePaths() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get existing images from SharedPreferences and merge
    String? savedImagePathsJson = prefs.getString('imagePaths');
    List<Map<String, String>> existingData = [];
    if (savedImagePathsJson != null) {
      existingData = List<Map<String, String>>.from(
          jsonDecode(savedImagePathsJson).map((item) => Map<String, String>.from(item))
      );
    }

    // Merge new images with the existing data
    existingData.addAll(_images);
    await prefs.setString('imagePaths', jsonEncode(existingData));
  }

  // Load the list of image paths and shop names from SharedPreferences
  Future<void> _loadImagePaths() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePathsJson = prefs.getString('imagePaths');
    if (imagePathsJson != null) {
      setState(() {
        _images = List<Map<String, String>>.from(
            jsonDecode(imagePathsJson).map((item) => Map<String, String>.from(item))
        );
      });
    }
  }

  // Filter images based on the current shop name
  List<File> _getImagesForCurrentShop() {
    return _images
        .where((image) => image['shop'] == widget.shopName)  // Filter by shop name
        .map((image) => File(image['path']!))  // Convert path from Map to File
        .toList();
  }

  // Open zoomable gallery when an image is tapped
  void _openImageGallery(int initialIndex, List<File> images) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewGalleryScreen(
          images: images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<File> shopImages = _getImagesForCurrentShop();  // Get images for the current shop

    return Scaffold(
      appBar: AppBar(
        title: Text('Photos for ${widget.shopName}'),
      ),
      body: shopImages.isEmpty
          ? Center(child: Text('No images for ${widget.shopName}.'))
          : GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,  // Adjust to show 2 images per row
        ),
        itemCount: shopImages.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _openImageGallery(index, shopImages);  // Open zoomable gallery
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(shopImages[index]),  // Display each image
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Take Picture',
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}
