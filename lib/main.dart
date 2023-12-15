import 'package:camera/camera.dart';
import 'package:custom_camera_plugin/camera_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  List<String> imagePathList = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              child: const Text('Show Camera'),
              onPressed: () async {
                final data = await availableCameras();
                if (data.isNotEmpty) {
                  List<String>? response = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => CameraPage(cameras: data)));

                  if (response != null &&
                      response.runtimeType == List<String>) {
                    if (response.isNotEmpty) {
                      setState(() {
                        imagePathList = response;
                      });
                    }
                  }
                }
              },
            ),
            ...List.generate(
                imagePathList.length, (index) => Text(imagePathList[index]))
          ],
        ),
      ),
    );
  }
}
