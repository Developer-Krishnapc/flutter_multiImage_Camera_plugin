import 'dart:io';

import 'package:camera/camera.dart';
import 'package:custom_camera_plugin/preview_page.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription>? cameras;
  const CameraPage({super.key, required this.cameras});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  List<String> selectedImagePathList = [];

  Future initCamera(CameraDescription cameraDescription) async {
// create a CameraController
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.ultraHigh);

// Next, initialize the controller. This returns a Future.
    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  @override
  void initState() {
    super.initState();

    initCamera(widget.cameras![0]);
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _cameraController.dispose();
    super.dispose();
  }

  Future takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      await _cameraController.setFlashMode(FlashMode.off);
      XFile picture = await _cameraController.takePicture();

      // ignore: use_build_context_synchronously
      List<dynamic>? data = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PreviewPage(
                    filePath: picture.path,
                  )));

      if (data != null && data.isNotEmpty) {
        setState(() {
          selectedImagePathList.add(picture.path);
        });
      }
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: _cameraController.value.isInitialized
                ? Stack(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: CameraPreview(_cameraController)),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          height: 70,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.black,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () async {
                                  await takePicture();
                                },
                                child: const Icon(
                                  Icons.circle,
                                  size: 65,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                          bottom: 5,
                          left: 10,
                          child: (selectedImagePathList.isNotEmpty)
                              ? Stack(
                                  children: [
                                    const SizedBox(
                                      width: 40,
                                      height: 40,
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: CircleAvatar(
                                          radius: 27,
                                          child: Image.file(
                                            File(selectedImagePathList.last),
                                            fit: BoxFit.fitWidth,
                                          )),
                                    ),
                                    Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.red,
                                          radius: 10,
                                          child: Text(
                                            selectedImagePathList.length
                                                .toString(),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10),
                                          ),
                                        ))
                                  ],
                                )
                              : const SizedBox()),
                      Positioned(
                          bottom: 0,
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 30),
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(
                                    context, [...selectedImagePathList]);
                              },
                              child: const SizedBox(
                                height: 70,
                                width: 60,
                                child: Center(
                                  child: Text(
                                    'Done',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ))
                    ],
                  )
                : const Center(child: CircularProgressIndicator())));
  }
}
