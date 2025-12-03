import 'dart:io';
import 'package:flutter/material.dart';
import 'package:halobidan/models/pokemon_model.dart';
import 'detail_page_pokemon.dart';

class ItemSearchDelegate extends SearchDelegate {
  final List<PokemonModel> data;
  ItemSearchDelegate(this.data);

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(
      onPressed: () => query = "",
      icon: const Icon(Icons.clear),
    ),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    onPressed: () => close(context, null),
    icon: const Icon(Icons.arrow_back),
  );

  @override
  Widget buildResults(BuildContext context) {
    final results = data
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return _buildList(results, context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = data
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return _buildList(results, context);
  }


  Widget _buildList(List<PokemonModel> results, BuildContext context) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: File(item.imagePath).existsSync()
                ? FileImage(File(item.imagePath))
                : AssetImage(item.imagePath) as ImageProvider,
          ),
          title: Text(item.name),
          subtitle: Text(
            item.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailPage(item: item),
              ),
            );
          },
        );
      },
    );
  }
}
