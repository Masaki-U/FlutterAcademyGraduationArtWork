import 'package:flutter/material.dart';
import 'package:model/ResponseMovieDetail.dart';
import 'package:model/apiHandler.dart';

class MovieDetail extends StatelessWidget {
  final int id;
  final String title;

  const MovieDetail(this.id, this.title, {Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MovieDetailPage(id, title);
  }
}

class MovieDetailPage extends StatefulWidget {
  const MovieDetailPage(this.id, this.title, {Key? key}) : super(key: key);

  final int id;
  final String title;

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState(id, title);
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  _MovieDetailPageState(this.id, this.title);

  ResponseMovieDetail? _movieDetail;

  final int id;
  final String title;

  var isImageMode = false;

  void fetchDetailData(int id) {
    fetchMovieDetail(id, (res) {
      setState(() {
        _movieDetail = res;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    fetchDetailData(id);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Stack(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            children: [
              backgroundImage(_movieDetail),
              isImageMode ? const Spacer() : detailItem(_movieDetail)
            ]),
      ), // This trai
      floatingActionButton: isImageMode
          ? const Spacer()
          : floatingButton(), // ling comma makes auto-formatting nicer for build methods.
    );
  }

  Widget floatingButton() {
    return FloatingActionButton(
      child: const Icon(Icons.image),
      onPressed: () {
        setState(() {
          isImageMode = true;
        });
      },
    );
  }

  Widget backgroundImage(ResponseMovieDetail? detail) {
    final posterPath = detail?.posterPath;
    return InkWell(
      onTap: () {
        setState(() {
          isImageMode = false;
        });
      },
      child: Opacity(
        opacity: isImageMode ? 1.0 : 0.5,
        child: Image.network(posterPath != null ? imagePath + posterPath : "",
            errorBuilder: (context, error, stackTrace) {
          return const Text("画像\nなし");
        }),
      ),
    );
  }

  Widget detailItem(ResponseMovieDetail? detail) {
    return Card(
      child: ListTile(
        title: Text(detail?.title ?? ""),
      ),
    );
  }
}

const imagePath = "https://image.tmdb.org/t/p/w1280";
