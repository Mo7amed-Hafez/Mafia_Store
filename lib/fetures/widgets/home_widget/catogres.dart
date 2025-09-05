import 'package:flutter/material.dart';
import 'package:mafia_store/core/app_colore.dart';

Widget buildCategory(String title, IconData icon) {
  return Container(
    width: 100,
    height: 60,
    margin: const EdgeInsets.symmetric(horizontal: 15),
    decoration: BoxDecoration(
      color: AppColore.lightColor,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: AppColore.primaryColor),
        const SizedBox(height: 1),
        Text(title,
            style: TextStyle(color: AppColore.oliveGreen, fontSize: 10)),
      ],
    ),
  );
}