import 'package:flutter/material.dart';
import 'package:grocery_app/models/grocery_item.dart';

class GroceryCard extends StatelessWidget {
  const GroceryCard(
      {super.key, required this.grocery, required this.onDismissing});

  final GroceryItemModel grocery;
  final void Function(GroceryItemModel item) onDismissing;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(grocery.id),
      onDismissed: (direction) {
        onDismissing(grocery);
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            children: [
              ColoredBox(
                color: grocery.category.color,
                child: const SizedBox(
                  width: 25,
                  height: 25,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Text(grocery.name),
              const Spacer(),
              Text('${grocery.quantity}'),
            ],
          ),
        ),
      ),
    );
  }
}
