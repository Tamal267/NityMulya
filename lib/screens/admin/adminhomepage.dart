import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final List<Map<String, dynamic>> products = [
    {"title": "চাল সরু (নাজির/মিনিকেট)", "price": "75-85", "category": "চাল"},
    {"title": "সয়াবিন তেল (পিউর)", "price": "160-175", "category": "তেল"},
  ];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  void addProduct() {
    if (titleController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        categoryController.text.isNotEmpty) {
      setState(() {
        products.add({
          "title": titleController.text,
          "price": priceController.text,
          "category": categoryController.text,
        });
      });
      Navigator.pop(context);
      clearFields();
    }
  }

  void editProduct(int index) {
    titleController.text = products[index]["title"];
    priceController.text = products[index]["price"];
    categoryController.text = products[index]["category"];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Edit Product", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextField(controller: titleController, decoration: InputDecoration(labelText: "Title")),
              TextField(controller: priceController, decoration: InputDecoration(labelText: "Price Range")),
              TextField(controller: categoryController, decoration: InputDecoration(labelText: "Category")),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    products[index] = {
                      "title": titleController.text,
                      "price": priceController.text,
                      "category": categoryController.text,
                    };
                  });
                  Navigator.pop(context);
                  clearFields();
                },
                child: Text("Update"),
              ),
            ],
          ),
        );
      },
    );
  }

  void deleteProduct(int index) {
    setState(() {
      products.removeAt(index);
    });
  }

  void showAddProductSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Add Product", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextField(controller: titleController, decoration: InputDecoration(labelText: "Title")),
              TextField(controller: priceController, decoration: InputDecoration(labelText: "Price Range")),
              TextField(controller: categoryController, decoration: InputDecoration(labelText: "Category")),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: addProduct,
                child: Text("Add"),
              ),
            ],
          ),
        );
      },
    );
  }

  void clearFields() {
    titleController.clear();
    priceController.clear();
    categoryController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Panel"),
        backgroundColor: const Color(0xFF079b11),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(product["title"]),
              subtitle: Text("${product["price"]} • ${product["category"]}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => editProduct(index),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteProduct(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF079b11),
        child: Icon(Icons.add),
        onPressed: showAddProductSheet,
      ),
    );
  }
}
