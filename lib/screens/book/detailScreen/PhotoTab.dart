import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // For encoding JSON
import 'dart:io'; // For File
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

class _PhotoTabState extends State<PhotoTab>
    with AutomaticKeepAliveClientMixin {
  List<dynamic> photos = []; // To store fetched photos from the server
  final picker = ImagePicker();
  bool get wantKeepAlive => true; // This ensures the state is preserved

  @override
  void initState() {
    super.initState();
    fetchPhotos(); // Call your method to fetch images from the server
  }

  Future<void> fetchPhotos() async {
    if (widget.barbershopId == null) {
      print('Invalid barbershop ID');
      return;
    }
    final url =
        'https://nearbarbershop-fd0337b6be1a.herokuapp.com/barbershops/${widget.barbershopId}/photos';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          photos = json.decode(response.body); // Update the list of photos
        });
      } else {
        print('Failed to fetch photos: ${response.body}');
      }
    } catch (e) {
      print('Error fetching photos: $e');
    }
  }

  // Function to select an image from the camera and upload it immediately
  Future<void> _takeAndUploadPhoto() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Immediately upload the photo after taking it
      await uploadPhoto(widget.barbershopId, imageFile, 'A new photo');
    } else {
      print('No image selected.');
    }
  }

  // Method to upload a photo to the server
  Future<void> uploadPhoto(
      int? barbershopId, File imageFile, String description) async {
    if (barbershopId == null) {
      print('Invalid barbershop ID');
      return;
    }

    var uri = Uri.parse(
        'https://nearbarbershop-fd0337b6be1a.herokuapp.com/barbershops/$barbershopId/add-photo');
    print('Uploading photo to: $uri');

    var request = http.MultipartRequest('POST', uri)
      ..fields['description'] = description
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path,
          contentType: MediaType('image', 'jpg')));

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      if (response.statusCode == 201) {
        print('Photo uploaded successfully');

        // Parse the response to get the image URL if the server returns it
        final responseData = jsonDecode(responseBody);
        final newPhotoUrl = responseData['imageUrl'];

        // Add the newly uploaded photo to the top of the list
        _addPhotoToTop(newPhotoUrl, description);

        fetchPhotos(); // Optionally refetch the full list of photos after upload
      } else {
        print(
            'Failed to upload photo: ${response.statusCode}, Body: $responseBody');
      }
    } catch (e) {
      print('Error uploading photo: $e');
    }
  }

  // Add the new photo to the top of the list
  void _addPhotoToTop(String newPhotoUrl, String description) {
    setState(() {
      photos.insert(0, {
        'url': newPhotoUrl,
        'description': description,
        'date': DateTime.now().toIso8601String(),
      });
    });
  }

  // Delete a photo from the server
  Future<void> deletePhoto(String photoUrl) async {
    final url =
        'https://nearbarbershop-fd0337b6be1a.herokuapp.com/barbershops/${widget.barbershopId}/photos';
    final response = await http.delete(
      Uri.parse(url),
      body: json.encode({'url': photoUrl}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      setState(() {
        photos.removeWhere((photo) => photo['url'] == photoUrl);
      });
      print('Photo deleted successfully');
    } else {
      print('Failed to delete photo');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Tab'),
      ),
      body: Column(
        children: [
          Expanded(
            child: photos.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('No photos available from the server.'),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemCount: photos.length,
                    itemBuilder: (context, index) {
                      final photo = photos[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CachedNetworkImage(
                            imageUrl: photo['url'],
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Description: ${photo['description'] ?? 'No Description'}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Date: ${photo['date'] != null ? formatDate(photo['date']) : 'No Date'}',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _confirmDelete(context, photo['url']);
                                },
                              ),
                            ],
                          ),
                          Divider(),
                        ],
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _takeAndUploadPhoto,
              child: Text('Take and Upload Photo'),
            ),
          ),
        ],
      ),
    );
  }

  // Confirmation dialog before deleting the photo
  void _confirmDelete(BuildContext context, String photoUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Photo'),
          content: Text('Are you sure you want to delete this photo?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                deletePhoto(photoUrl); // Call the deletePhoto function
              },
            ),
          ],
        );
      },
    );
  }

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
