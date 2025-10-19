import 'package:flutter/material.dart';
import 'dummy_category_model.dart';
import 'dummy_product_model.dart';

// --- A SINGLE SOURCE OF TRUTH FOR ALL DUMMY DATA ---
// AZROF-NOTE: This file is the central repository for all our temporary data.
// By having one source, we prevent bugs caused by different parts of the app
// having inconsistent or different object instances in memory.

// MUBIN-TODO: Your service layer (e.g., ProductService, CategoryService) will be
// responsible for providing this data to the UI. Your dummy methods will read
// directly from the static lists in this file. This acts as a simulation of your
// future database connection.

// MEHEDI-TODO: Your main task will be to make the service layer real. You will
// replace all references to this `DummyData` class with live calls and streams
// to your Firestore collections. Once all features are connected to Firebase,
// this entire file can be deleted.

class DummyData {
  // This is the authoritative list of all categories.
  // Every part of the app will use this exact list.
  static const List<DummyCategory> categories = [
    DummyCategory(id: 'cat1', name: 'Electronics', color: Colors.blue),
    DummyCategory(id: 'cat2', name: 'Office Supplies', color: Color(0xFFFBC02D)),
    DummyCategory(id: 'cat3', name: 'Furniture', color: Colors.pink),
    DummyCategory(id: 'cat4', name: 'Accessories', color: Colors.green),
  ];

  // This is the authoritative list of all products.
  static final List<DummyProduct> products = [
    DummyProduct(name: 'Laptop Pro X1', sku: 'LP-12345', quantity: 15, categoryId: 'cat1'),
    DummyProduct(name: 'Wireless Mouse', sku: 'WM-67890', quantity: 7, categoryId: 'cat1'),
    DummyProduct(name: '4K Monitor', sku: 'MON-4K-001', quantity: 2, categoryId: 'cat1'),
    DummyProduct(name: 'USB-C Hub', sku: 'USB-HUB-01', quantity: 35, categoryId: 'cat1'),

    DummyProduct(name: 'A4 Printer Paper (500 Sheets)', sku: 'PAP-A4-500', quantity: 50, categoryId: 'cat2'),
    DummyProduct(name: 'Black Ballpoint Pens (Box of 12)', sku: 'PEN-BLK-12', quantity: 110, categoryId: 'cat2'),
    DummyProduct(name: 'Stapler', sku: 'STP-001', quantity: 25, categoryId: 'cat2'),

    DummyProduct(name: 'Ergonomic Office Chair', sku: 'CHR-ERG-01', quantity: 12, categoryId: 'cat3'),
    DummyProduct(name: 'Standing Desk', sku: 'DSK-STND-01', quantity: 5, categoryId: 'cat3'),

    DummyProduct(name: 'Laptop Bag', sku: 'BAG-LAP-01', quantity: 20, categoryId: 'cat4'),
  ];
}

