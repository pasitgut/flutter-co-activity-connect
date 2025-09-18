import 'package:flutter/material.dart';

class ActivityCard extends StatelessWidget {
  final String element;
  final void Function()? onTap;
  const ActivityCard({super.key, required this.element, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(element, style: TextStyle(fontSize: 18.0)),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(onPressed: () {}, child: Text("join")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
