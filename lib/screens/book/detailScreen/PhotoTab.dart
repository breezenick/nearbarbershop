import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // For encoding JSON
import 'dart:io'; // For File
import 'package:image_picker/image_picker.dart'; // For taking photos
import 'package:http/http.dart' as http; // For making HTTP requests
import 'package:http_parser/http_parser.dart'; // For specifying media type
import 'package:intl/intl.dart';

import 'FullScreenImage.dart';

class PhotoTab extends StatefulWidget {
  final int? barbershopId;

  PhotoTab({Key? key, required this.barbershopId}) : super(key: key);

  @override
  _PhotoTabState createState() => _PhotoTabState();
}

class _PhotoTabState extends State<PhotoTab> with AutomaticKeepAliveClientMixin {
  List<dynamic> photos = [];
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchPhotos(); // Fetch images from server
  }

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
          photos = json.decode(response.body);
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
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final photo = photos[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Open the full-screen zoomable image on tap
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenImage(
                                imageUrl: photo['url'],
                              ),
                            ),
                          );
                        },
                        child: CachedNetworkImage(
                          imageUrl: photo['url'],
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                          height: 300,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Description: ${photo['description'] ?? 'No Description'}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Date: ${photo['date'] != null ? formatDate(photo['date']) : 'No Date'}',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

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
                deletePhoto(photoUrl); // Call deletePhoto function
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deletePhoto(String photoUrl) async {
    final url = 'https://nearbarbershop-fd0337b6be1a.herokuapp.com/barbershops/${widget.barbershopId}/photos';
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

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  bool get wantKeepAlive => true;
}
