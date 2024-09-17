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


// Method to capture an image using the camera and upload it
  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path); // Convert path to a File object

      setState(() {
        _image = imageFile;
      });

      // After capturing the image, upload it via the API
      await addPhoto(widget.barbershopId, imageFile, "Description for the photo");
      fetchPhotos();  // Fetch the latest photos to update the UI
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

    // Check if the file exists before attempting to upload
    if (!imageFile.existsSync()) {
      print("File does not exist: ${imageFile.path}");
      return;  // Stop the execution if the file does not exist
    }

    final uri = Uri.parse('https://nearbarbershop-fd0337b6be1a.herokuapp.com/barbershops/${widget.barbershopId}/add-photo');
    var request = http.MultipartRequest('POST', uri)
      ..fields['description'] = description
      ..files.add(await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: MediaType('image', 'jpeg') // Ensure the media type matches your file type
      ));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        print("Upload successful");
        // Listen to the response body if needed
        response.stream.transform(utf8.decoder).listen((value) {
          print(value);
        });
      } else {
        print("Upload failed with status: ${response.statusCode}");
        // Optionally listen to the response body to get more information
        response.stream.transform(utf8.decoder).listen((value) {
          print(value);
        });
      }
    } catch (e) {
      print("Upload failed with error: $e");
    }
  }



/*

  Future<void> addPhoto9999(int? barbershopId, File imageFile, String description) async {
    if (barbershopId == null) {
      print('Invalid barbershop ID');
      return;
    }

    final url = Uri.parse('https://nearbarbershop-fd0337b6be1a.herokuapp.com/barbershops/${widget.barbershopId}/add-photo');
    var request = http.MultipartRequest('POST', url)
      ..fields['description'] = description
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'), // Adjust depending on your image type
      ));

    var response = await request.send();

    if (response.statusCode == 201) {
      print('Photo added successfully.');
      response.stream.transform(utf8.decoder).listen((value) {
        print(value);
      });
    } else {
      print('Failed to add photo');
    }
  }
*/


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


