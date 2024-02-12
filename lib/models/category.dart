import 'package:flutter/material.dart';

enum Categories {
  vegetable,
  fruit,
  meat,
  dairy,
  carbs,
  sweets,
  spices,
  convenience,
  hygiene,
  other
}

class CategoryModel {
  const CategoryModel(this.title, this.color);

  final String title;
  final Color color;
}
