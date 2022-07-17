import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_movie_example/models/movie.dart';
import 'package:riverpod_movie_example/providers/movie_provider.dart';
import 'package:riverpod_movie_example/widgets/movie_card.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
    statusBarColor: Colors.transparent, // optional
  ));

  runApp(ProviderScope(
    child: MovieApp(),
  ));
}

class MovieApp extends ConsumerWidget {
  MovieApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = ThemeData();

    return MaterialApp.router(
      routeInformationProvider: _router.routeInformationProvider,
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
      theme: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: Colors.black,
          secondary: Colors.blue,
        ),
      ),
      title: 'Le Movie App',
    );
  }

  final GoRouter _router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => const MovieList(),
      ),
      GoRoute(
        path: '/:id',
        builder: (context, state) {
          // use state.params to get router parameter values
          //final family = Families.family(state.params['fid']!);
          final id = state.params['id'];

          return MovieDetails(id: id.toString());
        },
      ),
    ],
  );
}

class MovieDetails extends ConsumerWidget {
  const MovieDetails({Key? key, required String this.id}) : super(key: key);

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Future<Movie> movie = ref.read(moviesProvider.notifier).loadMovie(id);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Sample"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          child: FutureBuilder<Movie>(
            future: movie, // a previously-obtained Future<String> or null
            builder: (BuildContext context, AsyncSnapshot<Movie> snapshot) {
              List<Widget> children;
              if (snapshot.hasData) {
                final Movie mov = snapshot.data as Movie;

                children = <Widget>[
                  Image.network(mov.poster.toString()),
                  SizedBox(height: 20),
                  Text("${mov.title} (${mov.year})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  Padding(padding: EdgeInsets.all(30), child: Text(mov.plot.toString())),
                ];
              } else if (snapshot.hasError) {
                children = <Widget>[
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Error: ${snapshot.error}'),
                  )
                ];
              } else {
                children = const <Widget>[
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('Awaiting result...'),
                  )
                ];
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: children,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class MovieList extends ConsumerWidget {
  const MovieList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Movie> formattedMovies = ref.watch(moviesProvider).movies;
    bool isLoading = ref.watch(moviesProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 20),
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a search term',
                ),
                onChanged: (text) async {
                  // text here is the inputed text
                  await ref.read(moviesProvider.notifier).filterMovies(text);
                },
              ),
            ),
            isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: Container(
                        color: Colors.white,
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: formattedMovies.length,
                            itemBuilder: (BuildContext context, int index) {
                              Movie movie = formattedMovies[index];

                              return MovieCard(movie: movie);
                            })),
                  )
          ],
        ),
      ),
    );
  }
}
