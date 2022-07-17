// package we need for json encode/decode
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
// freezed package for generation of boilperplate code
import 'package:freezed_annotation/freezed_annotation.dart';
// service helper for loading json file
import 'package:flutter/services.dart' as rootBundle;
import 'package:riverpod_movie_example/models/movie.dart';
import 'package:riverpod_movie_example/services/movie_service.dart';

// Import freezed file (maybe not yet generated)
part 'movie_provider.freezed.dart';

// Creating state where the freezed annotation will suggest that boilerplate code needs to be generated
@freezed
abstract class MovieState with _$MovieState {
  const factory MovieState({
    @Default([]) List<Movie> movies,
    @Default(true) bool isLoading,
  }) = _MovieState;

  const MovieState._();
}

// Creating state notifier provider
final moviesProvider = StateNotifierProvider<MovieNotifier, MovieState>((ref) => MovieNotifier());

// Creating Notifier
class MovieNotifier extends StateNotifier<MovieState> {
  // Notifier constructor - call functions on provider initialization
  MovieNotifier() : super(MovieState()) {
    loadMovies();
  }

  // Simple loadMovies functions that will load json file from data folder
  loadMovies() async {
    state = state.copyWith(isLoading: true);
    final moviesList = await MovieService().fetchMovies();
    // Convert list to list of movies using the movie class constructor
    final movies = moviesList.map((e) => Movie.fromJson(e)).toList();
    // Update state in provider
    state = state.copyWith(movies: movies, isLoading: false);
  }

  filterMovies(filter) async {
    state = state.copyWith(isLoading: true);
    final moviesList = await MovieService().fetchMovies(filter);
    // Convert list to list of movies using the movie class constructor with simple filter title function inside
    final movies = moviesList.map((e) => Movie.fromJson(e)).toList();

    state = state.copyWith(movies: movies, isLoading: false);
  }

  updateMovie(id, movieData) async {
    //state = state.copyWith(isLoading: true);
    final movieJson = await MovieService().updateMovie(id, movieData);
    // Convert list to list of movies using the movie class constructor
    final movie =  Movie.fromJson(movieJson);

    final index = state.movies.indexWhere((element) => element.id == movie.id);
    final movies = List<Movie>.from(state.movies);
    movies[index] = movie;
    // Update state in provider
    state = state.copyWith(movies: movies, isLoading: false);
  }

  deleteMovie(id) async {
    //state = state.copyWith(isLoading: true);
    final movieJson = await MovieService().deleteMovie(id);
    // Convert list to list of movies using the movie class constructor

    final index = state.movies.indexWhere((element) => element.id == id);
    final movies = List<Movie>.from(state.movies);
    movies.removeAt(index);
    // Update state in provider
    state = state.copyWith(movies: movies, isLoading: false);
  }
}