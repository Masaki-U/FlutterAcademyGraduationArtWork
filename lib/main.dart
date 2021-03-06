import 'package:flutter/material.dart';
import 'package:model/ResponseMovieCategory.dart';
import 'package:model/ResponseMovieSearch.dart';
import 'package:model/apiHandler.dart';

import 'detail.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Academy Graduation!'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Set<Results> _movieList = {};
  List<Genres> _movieCategoryList = [];

  void fetchListData() {
    isFetching = true;
    fetchMovieList(currentPage, (res) {
      final result = res.results;
      if (result != null) {
        var list = _movieList;
        setState(() {
          _movieList.addAll(result);
        });
      }
      isFetching = false;
    });
  }

  void fetchCategoryData() {
    fetchMovieCategoryList((res) {
      final result = res.genres;
      if (result != null) {
        setState(() {
          _movieCategoryList = result;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchListData();
    fetchCategoryData();
    infiniteScroll();
  }

  final _controller = ScrollController();
  var isFetching = false;
  var currentPage = 1;

  void infiniteScroll() {
    _controller.addListener(() {
      if (_isNeedFetch()) {
        currentPage++;
        fetchListData();
      }
    });
  }

  bool _isNeedFetch() {
    final maxScrollExtent = _controller.position.maxScrollExtent;
    final currentPosition = _controller.position.pixels;
    final screenHeight = MediaQuery.of(context).size.height;
    return !isFetching &&
        maxScrollExtent > 0 &&
        (maxScrollExtent - screenHeight * 2) <= currentPosition;
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
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Container(
            height: double.infinity,
            width: double.infinity,
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
            child: ListView.builder(
              itemCount: _movieList.length,
              itemBuilder: (listContext, idx) {
                return listItem(context, _movieList.elementAt(idx));
              },
              controller: _controller,
            )),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget listItem(BuildContext context, Results result) {
    final posterPath = result.posterPath;
    return Card(
      child: ListTile(
        title: Text(result.title ?? ""),
        leading: thumbnail(context, posterPath),
        onTap: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (builder) => IntrinsicWidth(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                      child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(color: Colors.transparent),
                  )),
                  GestureDetector(
                      child: bottomSheet(context, result),
                      onTap: () {
                        navigate(result);
                      })
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget bottomSheet(BuildContext context, Results result) {
    return Card(
      color: Colors.white,
      elevation: 0.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: thumbnail(context, result.posterPath),
              ),
              Flexible(
                  flex: 3,
                  child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: Text(result.title ?? "",
                                      style: const TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w300))),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                          Text("??????: " +
                              (result.voteCount?.toString() ?? "-") +
                              "???" +
                              "??????" +
                              (result.voteAverage?.toString() ?? "0.0")),
                          Text("?????????: " +
                              (result.releaseDate?.toString() ?? "0000-00-00")),
                          Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: MaterialButton(
                                color: Theme.of(context).primaryColor,
                                child: button("???????????????"),
                                onPressed: () {
                                  navigate(result);
                                },
                              )),
                        ],
                      )))
            ],
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Wrap(
                  spacing: 2.0,
                  children: categoryChip(context, result, _movieCategoryList)))
        ],
      ),
    );
  }

  List<Widget> categoryChip(
      BuildContext context, Results result, List<Genres> genres) {
    final genreIds = result.genreIds ?? [];
    return genres
        .map((e) {
          String result;
          if (genreIds.contains(e.id)) {
            result = e.name ?? "";
          } else {
            result = "";
          }
          return result;
        })
        .where((element) => element.isNotEmpty)
        .map((e) => Chip(label: Text(e)))
        .toList();
  }

  Widget thumbnail(BuildContext context, String? posterPath) {
    return Image.network(posterPath != null ? imagePath + posterPath : "",
        errorBuilder: (context, error, stackTrace) {
      return const Text("??????\n??????");
    });
  }

  navigate(Results result) {
    Navigator.pop(context);
    final id = result.id;
    final title = result.title;
    if (id != null && title != null) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => MovieDetail(id, title)));
    }
  }
}

const imagePath = "https://image.tmdb.org/t/p/w1280";
