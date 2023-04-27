import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moviedb/src/core/constants/api_constants.dart';
import 'package:moviedb/src/viewmodels/view_model_provider.dart';
import 'package:moviedb/src/views/movie_details_screen.dart';

class FavoritesListScreen extends ConsumerWidget {
  static const routeName = '/favorites';
  const FavoritesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(favoritesListViewModel.notifier).getFavorites();
    return Scaffold(
        appBar: AppBar(
          title: const Text('Favorites'),
        ),
        body: Consumer(builder: (context, ref, child) {
          final favorites = ref.watch(favoritesListViewModel);
          log('favorites: ${favorites.length}');
          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final movie = favorites[index];
              return Dismissible(
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  padding: const EdgeInsets.all(8),
                  child: const Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                ),
                key: ValueKey(movie.id),
                onDismissed: (direction) {
                  if (direction == DismissDirection.endToStart) {
                    ref
                        .read(favoritesListViewModel.notifier)
                        .removeFavorite(movie);
                  } else {}
                },
                child: ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, MovieDetailsScreen.routeName,
                        arguments: movie);
                  },
                  leading: SizedBox(
                    width: 50,
                    child: Image.network(
                      '${ApiConstants.moviePosterURL}/${movie.posterPath}',
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(movie.title),
                  subtitle: Text(movie.releaseDate ?? ''),
                ),
              );
            },
          );
        }));
  }
}
