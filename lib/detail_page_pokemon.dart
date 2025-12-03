import 'dart:io';
import 'package:flutter/material.dart';
import 'package:halobidan/models/pokemon_model.dart';

class DetailPage extends StatefulWidget {
  final PokemonModel item;

  const DetailPage({super.key, required this.item});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: File(widget.item.imagePath).existsSync()
                  ? Image.file(
                File(widget.item.imagePath),
                height: 200,
                fit: BoxFit.cover,
              )
                  : Image.asset(
                widget.item.imagePath,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              widget.item.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              widget.item.description,
              textAlign: TextAlign.justify,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
