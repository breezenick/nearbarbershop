import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../models/barbershop.dart';

class PhotoTab extends StatefulWidget {
 // final String instagramUrl = 'https://www.instagram.com/jason_barber_shop_/';
  //late final String barbershopId;
  final String homePage;

  PhotoTab({ required this.homePage}); // Allow for null homePage



  @override
  _PhotoTabState createState() => _PhotoTabState();
}

class _PhotoTabState extends State<PhotoTab> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.homePage));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Instagram Profile'),
      ),
      body: SingleChildScrollView( // Optional, but usually not needed
        child: SizedBox(
          height: MediaQuery.of(context).size.height, // Set the height to fit the screen
          child: WebViewWidget(controller: _controller),
        ),
      ),
    );
  }
}
