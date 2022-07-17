import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_movie_example/models/movie.dart';
import 'package:riverpod_movie_example/providers/movie_provider.dart';

class MovieCard extends ConsumerWidget {
  const MovieCard({Key? key, required this.movie}) : super(key: key);

  final Movie movie;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
        padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
        child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
                padding: const EdgeInsets.all(10),
                height: 200,
                color: const Color(0xfff7f7f7),
                child: Row(children: <Widget>[
                  Container(
                    width: 80,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.network(movie.poster.toString()),
                  ),
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(children: <Widget>[
                            Text("${movie.title} (${movie.year})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(height: 10),
                            Text(movie.plot.toString(), overflow: TextOverflow.ellipsis, softWrap: false, maxLines: 3),
                            Spacer(),
                            Row(
                              children: [
                                ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                                    ),
                                    onPressed: () => {
                                          showModalBottomSheet(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return StatefulBottomSheet(
                                                  movie: movie,
                                                );
                                              })
                                        },
                                    child: Text("Edit")),
                                Padding(padding: EdgeInsets.all(15)),
                                ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                    ),
                                    onPressed: () => showDialog<String>(
                                          context: context,
                                          builder: (BuildContext context) => AlertDialog(
                                            title: Text('Delete ${movie.title.toString()}'),
                                            content: const Text('Are you sure you want to delete this movie?'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, 'Cancel'),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => deleteMovie(movie.id, ref, context),
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                        ),
                                    child: Text("Delete"))
                              ],
                            )
                          ])))
                ]))));
  }
}

deleteMovie(movieId, WidgetRef ref, BuildContext context) {
  ref.read(moviesProvider.notifier).deleteMovie(movieId);
  Navigator.pop(context);
}

class StatefulBottomSheet extends ConsumerStatefulWidget {
  final Movie movie;
  StatefulBottomSheet({Key? key, required this.movie});

  @override
  _StatefulBottomSheetState createState() => _StatefulBottomSheetState();
}

class _StatefulBottomSheetState extends ConsumerState<StatefulBottomSheet> {
  late Movie movie;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    movie = widget.movie;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.only(top: 30, left: 30, right: 30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a title',
                ),
                initialValue: movie.title,
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                onChanged: (value) {
                  movie.title = value;
                }
              ),
              Padding(padding: EdgeInsets.only(bottom: 20)),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a year',
                ),
                initialValue: movie.year,
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                onChanged: (value) {
                  movie.year = value;
                }
              ),
              Padding(padding: EdgeInsets.only(bottom: 20)),
              TextFormField(
                maxLines: 4,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a description',
                ),
                initialValue: movie.plot,
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                onChanged: (value) {
                  movie.plot = value;
                }
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                  ),
                  onPressed: () {
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.
                      Navigator.pop(context);
                      /* ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Processing Data')),
                      ); */

                      ref.read(moviesProvider.notifier).updateMovie(movie.id, movie.toJson());
                    }
                  },
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
