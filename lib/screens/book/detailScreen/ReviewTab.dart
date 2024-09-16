import 'package:firebase_auth/firebase_auth.dart';
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
    String userId;
    try {
      userId = await getCurrentUserId(); // Get the current user's ID
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('https://nearbarbershop-fd0337b6be1a.herokuapp.com/barbershops/${widget.barbershopId}/add-review'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "rating": int.parse(_ratingController.text),
        "comment": _reviewController.text,
        "user": userId,
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


Future<String> getCurrentUserId() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    return user.uid; // Firebase User ID
  } else {
    throw Exception('No user logged in');
  }
}