import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moviedb/src/core/constants/api_constants.dart';
import 'package:moviedb/src/models/movie_list_response.dart';
import 'package:moviedb/src/services/service_provider.dart';

class MovieDetailsScreen extends ConsumerStatefulWidget {
  static const routeName = '/movie_details';
  const MovieDetailsScreen({super.key, required this.movie});
  final Movies movie;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends ConsumerState<MovieDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title),
        actions: [
          FutureBuilder(
              future: ref.read(localDBService).isFavorite(widget.movie.id),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final isFavorite = snapshot.data as bool;
                  return IconButton(
                      onPressed: () async {
                        if (isFavorite) {
                          await ref
                              .read(localDBService)
                              .deleteFavorite(widget.movie.id);
                        } else {
                          await ref
                              .read(localDBService)
                              .insertFavorite(widget.movie);
                        }
                        setState(() {});
                      },
                      icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border));
                } else {
                  return const SizedBox();
                }
              })
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 200,
              child: CachedNetworkImage(
                imageUrl:
                    '${ApiConstants.moviePosterURL}/${widget.movie.posterPath}',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.movie.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(widget.movie.overview),
            const SizedBox(height: 8),
            widget.movie.releaseDate == null
                ? const SizedBox()
                : Text('Release Date: ${widget.movie.releaseDate}'),
          ],
        ),
      ),
    );
  }
}
