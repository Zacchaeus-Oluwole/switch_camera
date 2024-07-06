import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:switch_camera/switch_camera.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Switch Camera Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Switch Camera Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Stream<Uint8List> cam;
  final camera = Camera();

  @override
  void initState() {
    super.initState();
    camera.open(0);
    cam = camera.streamFrames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Computer Vision"),
            StreamBuilder<Uint8List>(
              stream: cam,
              builder: (context, snap) {
                final data = snap.data;
                if (data != null)
                  return Image.memory(
                    data,
                    gaplessPlayback: true,
                  );
                return const CircularProgressIndicator();
              },
            )
          ],
        ),
      ),
    );
  }
}
