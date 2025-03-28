import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
  CollectionReference<Map<String, dynamic>>, // Include generic type
  DocumentReference<Map<String, dynamic>>,   // Include generic type
  DocumentSnapshot<Map<String, dynamic>>,    // Include generic type
  UserCredential,
])

void main() {}
