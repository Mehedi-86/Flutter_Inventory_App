import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';
import '../../data/services/product_service.dart';
import '../../widgets/update_stock_dialog.dart';
import 'add_edit_product_screen.dart';

class ProductListScreen extends StatefulWidget {
  final UserRole userRole;
  final Category? category;

  const ProductListScreen({
    super.key,
    required this.userRole,
    this.category,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Stream<List<Product>> _productsStream;

  @override
  void initState() {
    super.initState();
    _productsStream = widget.category == null
        ? ProductService.instance.getProductsStream()
        : ProductService.instance.getProductsByCategoryStream(widget.category!.id);
  }

  void _deleteProduct(BuildContext context, Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure?'),
        content: Text('Do you want to permanently delete "${product.name}"?'),
        actions: [
          TextButton(child: const Text('No'), onPressed: () => Navigator.of(ctx).pop(false)),
          TextButton(child: const Text('Yes'), onPressed: () => Navigator.of(ctx).pop(true)),
        ],
      ),
    );

    if (confirmed == true) {
      await ProductService.instance.deleteProduct(product.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'All Products' : 'Products in: ${widget.category!.name}'),
      ),
      body: StreamBuilder<List<Product>>(
        stream: _productsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found.'));
          }

          final productsToDisplay = snapshot.data!;
          return ListView.builder(
            itemCount: productsToDisplay.length,
            itemBuilder: (context, index) {
              final product = productsToDisplay[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('SKU: ${product.sku}'),
                  leading: Chip(
                    label: Text('Qty: ${product.quantity}'),
                    backgroundColor: product.quantity <= product.reorderLevel ? Colors.red.shade100 : Colors.green.shade100,
                    labelStyle: TextStyle(color: product.quantity <= product.reorderLevel ? Colors.red.shade900 : Colors.green.shade900),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'update_stock') {
                        // This is now uncommented and functional
                        showDialog(
                          context: context,
                          builder: (ctx) => UpdateStockDialog(product: product),
                        );
                      } else if (value == 'edit') {
                        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => AddEditProductScreen(product: product)));
                      } else if (value == 'delete') {
                        _deleteProduct(context, product);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem(value: 'update_stock', child: ListTile(leading: Icon(Icons.layers_outlined), title: Text('Update Stock'))),
                      const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Edit'))),
                      if (widget.userRole == UserRole.admin) const PopupMenuDivider(),
                      if (widget.userRole == UserRole.admin) const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text('Delete', style: TextStyle(color: Colors.red)))),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddEditProductScreen(category: widget.category)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

