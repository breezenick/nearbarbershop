import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReviewTab extends StatefulWidget {
  final int? barbershopId;

  ReviewTab({required this.barbershopId});

  @override
  _ReviewTabState createState() => _ReviewTabState();
}

class _ReviewTabState extends State<ReviewTab> {
  final _reviewController = TextEditingController();
  final _ratingController = TextEditingController();

  // Function to submit a review to the backend (POST request)
  Future<void> submitReview() async {
    if(widget.barbershopId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Barbershop ID is not provided")),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('https://nearbarbershop-fd0337b6be1a.herokuapp.com/barbershops/${widget.barbershopId}/add-review'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "rating": int.parse(_ratingController.text),
        "comment": _reviewController.text,
        "user": "User123",  // Adjust this to the actual user ID as necessary
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Review submitted successfully')),
      );
      _reviewController.clear();
      _ratingController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit review: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Review'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _ratingController,
              decoration: InputDecoration(labelText: 'Rating (1-5)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(labelText: 'Enter your review here'),
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitReview,
              child: Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}
