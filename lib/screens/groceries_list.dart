import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grocery_app/data/groceries_data.dart';
import 'package:grocery_app/models/grocery_item.dart';
import 'package:grocery_app/screens/add_new_grocery.dart';
import 'package:grocery_app/widgets/grocery_card.dart';
import 'package:http/http.dart' as http;

class GroceriesList extends StatefulWidget {
  const GroceriesList({super.key});

  @override
  State<GroceriesList> createState() => _GroceriesListState();
}

class _GroceriesListState extends State<GroceriesList> {
  List<GroceryItemModel> _groceriesList = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchGroceryItems();
  }

  void _fetchGroceryItems() async {
    final url = Uri.https(
        'flutter-demo-d9288-default-rtdb.firebaseio.com', 'grocery-app.json');

    try {
      final resp = await http.get(url);
      if (resp.statusCode >= 400) {
        setState(() {
          _error = "Failed to fetch data. Try after some time.";
        });
      }

      if (resp.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> allData = json.decode(resp.body);
      print(allData);
      final List<GroceryItemModel> tempGroceryItems = [];
      for (final item in allData.entries) {
        final category = categories.entries
            .firstWhere(
                (element) => element.value.title == item.value["category"])
            .value;
        tempGroceryItems.add(
          GroceryItemModel(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }
      setState(() {
        _groceriesList = tempGroceryItems;
        _isLoading = false;
      });
    } catch (err) {
      setState(() {
        _error = 'Oops! Something went wrong.';
      });
    }
  }

  void _onAddNewGroceryItem() async {
    final newItem = await Navigator.of(context).push<GroceryItemModel>(
      MaterialPageRoute(
        builder: (ctx) => const AddNewGroceryScreen(),
      ),
    );

    if (newItem == null) return;

    setState(() {
      _groceriesList.add(newItem);
    });
  }

  void _onDismissing(GroceryItemModel item) async {
    final itemIndex = _groceriesList.indexOf(item);

    setState(() {
      _groceriesList.remove(item);
    });

    final url = Uri.https('flutter-demo-d9288-default-rtdb.firebaseio.com',
        'grocery-app/${item.id}.json');

    final dltResp = await http.delete(url);

    if (dltResp.statusCode >= 400) {
      setState(() {
        _groceriesList.insert(itemIndex, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "No Grocery Items Found!",
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 10),
          Text("Try to add new item"),
        ],
      ),
    );

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

    if (_groceriesList.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceriesList.length,
        itemBuilder: (context, i) => GroceryCard(
          grocery: _groceriesList[i],
          onDismissing: _onDismissing,
        ),
      );
    }

    if (_error != null) {
      content = Center(child: Text(_error!));
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Your Groceries"),
          actions: [
            IconButton(
              onPressed: _onAddNewGroceryItem,
              icon: const Icon(Icons.add),
              tooltip: "Add",
            ),
          ],
        ),
        body: content);
  }
}
