import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'dart:io';


class PhotoTab extends StatefulWidget {
  final int? barbershopId;  // Barbershop ID passed from BarbershopDetailScreen

  PhotoTab({required this.barbershopId});  // Constructor that accepts the barbershop ID

  @override
  _PhotoTabState createState() => _PhotoTabState();
}

class _PhotoTabState extends State<PhotoTab> {
  File? _image;  // To store the captured image
  final picker = ImagePicker();
  List<dynamic> photos = [];  // To store the fetched photos

  @override
  void initState() {
    super.initState();
    fetchPhotos();  // Fetch photos when the widget is initialized
  }



  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);  // Convert path to a File object

      setState(() {
        _image = imageFile;
      });

      // Use the reliableUpload function to handle the upload process with retries
      if (widget.barbershopId != null) {
        await reliableUpload(imageFile, "Description for the photo", widget.barbershopId!);
        fetchPhotos();  // Fetch the latest photos to update the UI after upload
      } else {
        print("Barbershop ID is null");
      }
    }
  }

  // The reliableUpload method goes here
  Future<void> reliableUpload(File imageFile, String description, int barbershopId) async {
    int maxTries = 3;
    int attempts = 0;
    while (attempts < maxTries) {
      try {
        await addPhoto(barbershopId, imageFile, description);
        break; // If successful, exit loop
      } catch (e) {
        attempts++;
        print("Upload attempt $attempts failed: $e");
        if (attempts == maxTries) {
          print("All upload attempts failed.");
          // Optionally, notify the user or take additional recovery actions
        }
      }
    }
  }




  // Method to fetch photos from the backend
  Future<void> fetchPhotos() async {
    if (widget.barbershopId == null) {
      print('Invalid barbershop ID');
      return;
    }

    final url = 'https://nearbarbershop-fd0337b6be1a.herokuapp.com/barbershops/${widget.barbershopId}/photos';

    try {
      final response = await http.get(Uri.parse(url));
      print('Status Code:=======================>>> ${response.statusCode}');  // Print the status code of the response
      print('Response Body:===================>>> ${response.body}');      // Print the body of the response

      if (response.statusCode == 200) {
        final List<dynamic> fetchedPhotos = json.decode(response.body);
        setState(() {
          photos = fetchedPhotos;  // Update the photos state with the fetched data
        });
      } else {
        print('Failed to fetch photos: ${response.body}');
      }
    } catch (e) {
      print('Error fetching photos: $e');
    }
  }


  Future<void> addPhoto(int? barbershopId, File imageFile, String description) async {
    if (barbershopId == null) {
      print('Invalid barbershop ID');
      return;
    }

    var uri = Uri.parse('https://nearbarbershop-fd0337b6be1a.herokuapp.com/barbershops/${widget.barbershopId}/add-photo');
    var client = http.Client();
    int retries = 3;  // Number of retries

    while (retries > 0) {
      try {
        var request = http.MultipartRequest('POST', uri)
          ..fields['description'] = description
          ..files.add(await http.MultipartFile.fromPath(
              'file',
              imageFile.path,
              contentType: MediaType('image', 'jpeg')
          ));

        var streamedResponse = await client.send(request).timeout(Duration(minutes: 2));

        if (streamedResponse.statusCode == 200) {
          print("Upload successful");
          await streamedResponse.stream.bytesToString().then((responseBody) {
            print(responseBody);
          });
          break;  // Exit loop on success
        } else {
          print("Upload failed with status: ${streamedResponse.statusCode}");
          await streamedResponse.stream.bytesToString().then((responseBody) {
            print(responseBody);
          });
          retries--;
          if (retries == 0) throw Exception("Failed after retries");
        }
      } catch (e) {
        print("Attempt failed with error: $e");
        retries--;
        if (retries == 0) throw Exception("Failed after retries");
      }
    }
    client.close();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Tab'),
      ),
      body: ListView.builder(
        itemCount: photos.length,
        itemBuilder: (context, index) {
          final photo = photos[index];
          return ListTile(
            leading: Container(
              width: 100,
              height: 100,
              child: Image.network(
                photo['url'],
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                  return Icon(Icons.error, color: Colors.red);
                },
              ),
            )
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImage,  // Capture image on button press
        tooltip: 'Pick Image',
        child: Icon(Icons.camera),
      ),
    );
  }
}


