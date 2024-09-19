import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:convert';  // For encoding JSON
import 'dart:io';       // For File
import 'package:image_picker/image_picker.dart'; // For taking photos
import 'package:http/http.dart' as http; // For making HTTP requests
import 'package:http_parser/http_parser.dart'; // For specifying media type
import 'package:intl/intl.dart';

class PhotoTab extends StatefulWidget {
  final int? barbershopId; // Barbershop ID to interact with the backend

  PhotoTab({Key? key, required this.barbershopId}) : super(key: key);

  @override
  _PhotoTabState createState() => _PhotoTabState();
}

class _PhotoTabState extends State<PhotoTab> with AutomaticKeepAliveClientMixin {
  File? _image; // To store the selected image
  List<dynamic> photos = [];  // To store fetched photos from the server
  final picker = ImagePicker();
  bool get wantKeepAlive => true; // This ensures the state is preserved


  @override
  void initState() {
    super.initState();
   // fetchPhotos(); // Call your method to fetch images from the server
  }

  // Function to select an image from the camera
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Method to upload a photo to the server
  Future<void> uploadPhoto(int? barbershopId, File imageFile, String description) async {
    if (barbershopId == null) {
      print('Invalid barbershop ID');
      return;
    }

    var uri = Uri.parse(
        'https://nearbarbershop-fd0337b6be1a.herokuapp.com/barbershops/$barbershopId/add-photo');
    print('Uploading photo to:============================= $uri');

    var request = http.MultipartRequest('POST', uri)
      ..fields['description'] = description
      ..files.add(await http.MultipartFile.fromPath(
          'file', imageFile.path,
          contentType: MediaType('image', 'jpg')));
    print('Uploading photo to request :============================= $request');

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString(); // Convert response to String
      if (response.statusCode == 201) {
        print('Photo uploaded successfully');
        fetchPhotos();  // Refresh the list of photos after a successful upload
      } else {
        print('Failed to upload photo: ${response
            .statusCode}, Body: $responseBody');
      }
    } catch (e) {
      print('Error uploading photo: $e');
    }
  }

    // Fetch photos from the server
  Future<void> fetchPhotos() async {
    if (widget.barbershopId == null) {
      print('Invalid barbershop ID');
      return;
    }

    final url = 'https://nearbarbershop-fd0337b6be1a.herokuapp.com/barbershops/${widget.barbershopId}/photos';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          photos = json.decode(response.body);  // Update the list of photos
        });
      } else {
        print('Failed to fetch photos: ${response.body}');
      }
    } catch (e) {
      print('Error fetching photos: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Tab'),
      ),
      body: Column(
        children: [
          // Expanded area for showing images and photos from the server
          Expanded(
            child: ListView(
              children: [
                // Display selected image or prompt to select one
                _image == null
                    ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('No image selected.'),
                )
                    : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(_image!),
                ),

                // Display list of fetched photos from the server
                photos.isEmpty
                    ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('No photos available from the server.'),
                )
                    : ListView.builder(
                  shrinkWrap: true, // This will prevent overflow in the ListView
                  physics: NeverScrollableScrollPhysics(), // Disable internal scrolling
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final photo = photos[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CachedNetworkImage(
                          imageUrl: photo['url'],
                          placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        ),
                        SizedBox(height: 8), // Adds space between the image and the text
                        Text(
                          'Description: ${photo['description'] ?? 'No Description'}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'URL: ${photo['url']}',
                          style: TextStyle(color: Colors.blue),
                        ),
                        Text(
                          'Date: ${photo['date'] != null ? formatDate(photo['date']) : 'No Date'}',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Divider(), // Divider to separate photos
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          // Buttons area at the bottom
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Button to take a new photo
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Take Photo'),
                ),

                // Button to upload the selected photo
                ElevatedButton(
                  onPressed: () {
                    if (_image != null) {
                      uploadPhoto(widget.barbershopId, _image!, 'A new photo');
                    } else {
                      print('No image selected to upload');
                    }
                  },
                  child: Text('Upload Photo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


  String formatDate(String dateString) {
  DateTime dateTime = DateTime.parse(dateString);
  return DateFormat.yMMMd().format(dateTime); // e.g., "Sep 19, 2024"
}