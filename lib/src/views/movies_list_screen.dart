import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moviedb/src/core/constants/api_constants.dart';
import 'package:moviedb/src/core/utils/response_model.dart';
import 'package:moviedb/src/models/movie_list_response.dart';
import 'package:moviedb/src/viewmodels/movie_list_view_model.dart';

import 'package:moviedb/src/viewmodels/view_model_provider.dart';
import 'package:moviedb/src/views/favorites_list_screen.dart';
import 'package:moviedb/src/views/movie_details_screen.dart';

class MovieListScreen extends StatelessWidget {
  static const routeName = '/movies-list';
  MovieListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movies'),
        actions: [TextButton(onPressed: (){
          Navigator.pushNamed(context, FavoritesListScreen.routeName);
        }, child: Text('Favorites'))],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final movieListResponse = ref.watch(movieListViewModel);

          if (movieListResponse.status == Status.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (movieListResponse.status == Status.error ||
              movieListResponse.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${movieListResponse.message}'),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(movieListViewModel.notifier).getMoviesList(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            final movieListData = movieListResponse.data!;
            final movies = movieListData.movies;
            return NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                getMoreItems(scrollInfo, ref.read(movieListViewModel.notifier));
                return true;
              },
              child: ListView.builder(
                itemCount: movies.length + 1,
                itemBuilder: (context, index) {
                  if (index < movies.length) {
                    final movie = movies[index];
                    return ListTile(
                      onTap: () {
                        Navigator.pushNamed(
                            context, MovieDetailsScreen.routeName,
                            arguments: movie);
                      },
                      title: Text(movie.title),
                      subtitle: Text(movie.releaseDate ?? ''),
                      leading: SizedBox(
                        width: 50,
                        child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl:
                                '${ApiConstants.moviePosterURL}/${movie.posterPath}'),
                      ),
                    );
                  } else {
                    return movieListData.page < movieListData.totalPages
                        ? const Center(child: CircularProgressIndicator())
                        : const SizedBox();
                  }
                },
              ),
            );
          }
        },
      ),
    );
  }

  bool isLoadingMoreItems = false;

  void getMoreItems(
      ScrollNotification scrollInfo, MovieListViewModel viewModel) async {
    if (!isLoadingMoreItems &&
        scrollInfo.metrics.pixels >=
            (scrollInfo.metrics.maxScrollExtent - 56)) {
      isLoadingMoreItems = true;
      await viewModel.getMoviesList(nextPage: true);
      isLoadingMoreItems = false;
    }
  }
}
