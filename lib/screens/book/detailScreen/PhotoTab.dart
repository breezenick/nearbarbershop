import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PhotoTab extends StatefulWidget {
  final int? barbershopId;

  PhotoTab({required this.barbershopId});  // Constructor that accepts the shop ID

  @override
  _PhotoTabState createState() => _PhotoTabState();
}

class _PhotoTabState extends State<PhotoTab> {
  File? _image; // To store the captured image
  final picker = ImagePicker();
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    loadSharedPreferences();
  }

  Future<void> loadSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  // Method to capture an image using the camera
  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      // Save the image path to SharedPreferences (if needed)
      if (prefs != null) {
        prefs!.setString('photoPath', pickedFile.path);
      }

      // After capturing the image, upload it via the API
      await addPhoto(widget.shopId, pickedFile.path, "Description for the photo"); // Using the passed shop ID
    }
  }

  // Method to add the photo to MongoDB via the API
  Future<void> addPhoto(String barbershopId, String photoUrl, String description) async {
    final url = 'https://nearbarbershop-fd0337b6be1a.herokuapp.com/barbershops/$barbershopId/add-photo';  // Update with your API endpoint

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'url': photoUrl,         // Path to the photo
        'description': description,
      }),
    );

    if (response.statusCode == 201) {
      print('Photo added successfully.');
    } else {
      print('Failed to add photo: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Tab'),
      ),
      body: Center(
        child: _image == null
            ? Text('No image selected.')
            : Image.file(_image!), // Display the captured image
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImage, // Capture image on button press
        tooltip: 'Pick Image',
        child: Icon(Icons.camera),
      ),
    );
  }
}
