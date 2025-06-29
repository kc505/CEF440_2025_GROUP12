import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/lecturer.dart';

class LecturerProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Lecturer?> getLecturer(String userId) async {
    if (userId.isEmpty) return null;

    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return Lecturer.fromFirestore(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching lecturer: $e');
      return null;
    }
  }
}