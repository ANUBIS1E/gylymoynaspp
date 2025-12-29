import 'package:flutter/material.dart';

class RuleExampleContainer extends StatelessWidget {
  final String title;
  final Widget example; // Виджет с примером (доска)
  final String? description; // Опциональное описание под примером

  const RuleExampleContainer({
    Key? key,
    required this.title,
    required this.example,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: RepaintBoundary(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: example,
              ),
            ),
          ), // Центрируем сам пример
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(
              description!,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ],
        ],
      ),
    );
  }
}
