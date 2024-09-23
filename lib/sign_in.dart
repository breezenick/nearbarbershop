import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

String name = "";
String email = "";
String imageUrl = "";

Future<String?> signInWithGoogle() async {

  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: 'AIzaSyAi-ThdsuY7f6FlD_05vdLISt71Xqm04Lc',
              appId: '1:127198410428:android:5faeb5e5e662e41a8a42b9',
              projectId: 'nearbarbershop2-6798e',
              messagingSenderId: '12345'
          ));
    } catch (e) {
      print('Error======================================: $e');
    }
  }


  // Attempt to sign in the user with Google
  final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
  if (googleSignInAccount == null) {
    // User canceled the sign in process
    print('Sign-in aborted by user');
    return null;
  }

  // Obtain the auth details from the request
  final GoogleSignInAuthentication googleSignInAuthentication =
  await googleSignInAccount.authentication;

  // Create a new credential using the tokens obtained from the Google sign-in API
  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  try {
    // Use the credentials to sign in with Firebase
    final UserCredential authResult =
    await _auth.signInWithCredential(credential);
    final User? user = authResult.user;

    if (user != null) {
      // Successfully signed in
      name = user.displayName ?? "";
      email = user.email ?? "";
      imageUrl = user.photoURL ?? "";

      // Optionally handle the name to get the first part only
      if (name.contains(" ")) {
        name = name.substring(0, name.indexOf(" "));
      }

      print('signInWithGoogle succeeded: $user');

      // Optionally return a more useful value or handle the signed in user
      return '$user'; // Consider returning something like user.uid or a custom user object
    }
  } catch (e) {
    // Handle any errors during sign in
    print('Failed to sign in with Google: $e');
    return null;
  }

  return null;
}

Future<void> signOutGoogle() async {
  // Sign out from Google
  await googleSignIn.signOut();
  print("User Signed Out");
}
