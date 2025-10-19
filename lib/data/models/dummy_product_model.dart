// --- AZROF-NOTE: This is a temporary data model for UI development. ---
//
// MUBIN-TODO: Your service layer (e.g., ProductService) will use this dummy
// model to provide product data to the UI before the database is connected.
// This acts as the "contract" for how product data should be shaped.
//
// MEHEDI-TODO: Your task will be to eventually replace every usage of this
// `DummyProduct` class with your real, permanent `Product` model that will
// live in `lib/data/models/product_model.dart`. The real model will include
// methods for converting data to and from Firestore.
class DummyProduct {
  final String name;
  final String sku;
  final int quantity;
  final String categoryId;

  DummyProduct({
    required this.name,
    required this.sku,
    required this.quantity,
    required this.categoryId,
  });
}

