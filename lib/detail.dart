import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:model/ResponseMovieDetail.dart';
import 'package:model/apiHandler.dart';
import 'package:url_launcher/url_launcher.dart';

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
        title: const Text("映画詳細"),
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
              Padding(
                padding: const EdgeInsets.all(20),
                child: isImageMode
                    ? const Spacer()
                    : detailItem(title, _movieDetail),
              )
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

  Widget detailItem(String title, ResponseMovieDetail? detail) {
    final backdropPath = detail?.backdropPath;
    return Column(
      children: [
        Card(
          child: ListTile(
            title: Text(title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
          ),
        ),
        Flexible(
            child: Card(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
              const Padding(padding: EdgeInsets.only(left: 8, top: 8), child: Text(
                    "評価",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                  )) ,
              popular(detail?.voteAverage)
            ]))),
        Expanded(child: Image.network(backdropPath != null ? imagePath + backdropPath : "",
            errorBuilder: (context, error, stackTrace) {
              return const Text("画像\nなし");
            })),
        MaterialButton(
            color: Theme.of(context).primaryColor,
            minWidth: double.infinity,
            child: button("データベース"),
            onPressed: () async {
              final id = detail?.id;
              final url = "https://www.themoviedb.org/movie/" + id.toString();
              if (id != null && await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url));
              }
            }),
        MaterialButton(
            color: Theme.of(context).primaryColor,
            minWidth: double.infinity,
            child: button("公式サイト"),
            onPressed: () async {
              final url = detail?.homepage;
              if (url != null && await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url));
              }
            })
      ],
    );
  }

  Widget popular(double? voteAverage) {
    if (voteAverage == null) {
      return const Spacer();
    }
    return Container(
      width: 200,
      height: 200,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black,
      ),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          CustomPaint(painter: PopularityPainter(0xff413D17, math.pi * 2)),
          CustomPaint(
              painter: PopularityPainter(
                  0xffD3D453, math.pi * 2 * voteAverage * 0.1)),
          Row(
            verticalDirection: VerticalDirection.up,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                (voteAverage * 10).toInt().toString(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.w700),
              ),
              const Text(
                "%",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

const imagePath = "https://image.tmdb.org/t/p/w1280";

Widget button(String text) {
  return Text(
    text,
    style: const TextStyle(color: Colors.white),
  );
}

class PopularityPainter extends CustomPainter {
  final int colorCode;
  final double sweepAngle;

  PopularityPainter(this.colorCode, this.sweepAngle);

  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = Color(colorCode)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    //draw arc
    canvas.drawArc(const Offset(-90, -90) & const Size(180, 180), -math.pi / 2,
        sweepAngle, false, paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
