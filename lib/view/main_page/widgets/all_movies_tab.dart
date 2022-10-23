import 'package:flutter/material.dart';
import 'package:movie_recommender/models/movie.dart';
import 'package:movie_recommender/view/main_page/widgets/list_of_movies.dart';

// TODO: This is temporary list only
final List<Movie> temporaryMovies = [
  Movie(
    title: 'The Lord of the Rings: The Fellowship of the Ring',
    director: 'Peter Jackson',
    genre: 'Fantasy',
    year: 2001,
  ),
  Movie(
    title: 'The Lord of the Rings: The Two Towers',
    director: 'Peter Jackson',
    genre: 'Fantasy',
    year: 2002,
    url:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Image_created_with_a_mobile_phone.png/640px-Image_created_with_a_mobile_phone.png',
  ),
  Movie(
    title: 'The Lord of the Rings: The Return of the King',
    director: 'Peter Jackson',
    genre: 'Fantasy',
    year: 2003,
  ),
];

class AllMoviesTab extends StatelessWidget {
  const AllMoviesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListOfMovies(movies: temporaryMovies);
  }
}
