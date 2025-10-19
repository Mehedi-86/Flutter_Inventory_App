import 'package:flutter/material.dart';

// --- AZROF-NOTE: This is a temporary data model for UI development. ---
//
// MUBIN-TODO: Your service layer will use this dummy model to provide data
// to the UI before the database is connected.
//
// MEHEDI-TODO: Your task will be to eventually replace every usage of this
// `DummyCategory` class with your real, permanent `Category` model that will
// live in `lib/data/models/category_model.dart` and will include methods for
// converting data to and from Firestore.
class DummyCategory {
  final String id;
  final String name;
  final Color color;

  const DummyCategory({
    required this.id,
    required this.name,
    required this.color,
  });
}

