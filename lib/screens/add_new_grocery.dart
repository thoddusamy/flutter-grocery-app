import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:grocery_app/data/groceries_data.dart';
import 'package:grocery_app/models/category.dart';
import 'package:grocery_app/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class AddNewGroceryScreen extends StatefulWidget {
  const AddNewGroceryScreen({super.key});

  @override
  State<AddNewGroceryScreen> createState() => _AddNewGroceryScreenState();
}

class _AddNewGroceryScreenState extends State<AddNewGroceryScreen> {
  final _formKey = GlobalKey<FormState>();
  var _enteredTitle;
  var _enteredQuantity = 1;
  var _selectCategory = categories[Categories.vegetable];
  var _isSending = false;

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });
      // calling api
      final url = Uri.https(
          'flutter-demo-d9288-default-rtdb.firebaseio.com', 'grocery-app.json');
      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
          {
            "name": _enteredTitle,
            "quantity": _enteredQuantity,
            "category": _selectCategory!.title,
          },
        ),
      );

      final Map<String, dynamic> respData = json.decode(resp.body);

      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pop(
        GroceryItemModel(
          id: respData['name'],
          name: _enteredTitle,
          quantity: _enteredQuantity,
          category: _selectCategory!,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Grocery"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 20,
                  decoration: const InputDecoration(label: Text("Title")),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 4) {
                      return "Name must be between 1 to 20 characters.";
                    }
                    return null;
                  },
                  onSaved: (newValue) => _enteredTitle = newValue,
                ),
                TextFormField(
                  initialValue: _enteredQuantity.toString(),
                  decoration: const InputDecoration(label: Text("Quantity")),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        int.tryParse(value) == null ||
                        int.tryParse(value)! <= 0) {
                      return "Quantity must be valid, positive number.";
                    }
                    return null;
                  },
                  onSaved: (newValue) =>
                      _enteredQuantity = int.parse(newValue!),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField(
                  value: _selectCategory,
                  items: [
                    for (final category in categories.entries)
                      DropdownMenuItem(
                        value: category.value,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              color: category.value.color,
                            ),
                            const SizedBox(width: 10),
                            Text(category.value.title)
                          ],
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectCategory = value;
                    });
                  },
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: _isSending
                          ? null
                          : () {
                              _formKey.currentState!.reset();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[400],
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text("Reset"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _isSending ? null : _saveItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[400],
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _isSending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(),
                            )
                          : const Text("Add Item"),
                    ),
                  ],
                )
              ],
            )),
      ),
    );
  }
}
