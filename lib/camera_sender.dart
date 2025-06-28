import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

class CameraSenderPage extends StatefulWidget {
  const CameraSenderPage({Key? key}) : super(key: key);

  @override
  State<CameraSenderPage> createState() => _CameraSenderPageState();
}

class _CameraSenderPageState extends State<CameraSenderPage> {
  CameraController? _controller;
  Timer? _timer;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;
    _controller = CameraController(camera, ResolutionPreset.medium);
    await _controller!.initialize();
    setState(() {});
    _startPeriodicCapture();
  }

  void _startPeriodicCapture() {
    _timer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _captureAndSend(),
    );
  }

  Future<void> _captureAndSend() async {
    if (_isSending || _controller == null || !_controller!.value.isInitialized)
      return;
    _isSending = true;
    try {
      final XFile file = await _controller!.takePicture();
      final bytes = await file.readAsBytes();
      await _sendFrame(bytes);
    } catch (e) {
      // Optionally handle error
    }
    _isSending = false;
  }

  Future<void> _sendFrame(Uint8List bytes) async {
    final uri = Uri.parse('https://your-backend-url/upload');
    await http.post(
      uri,
      body: bytes,
      headers: {HttpHeaders.contentTypeHeader: 'application/octet-stream'},
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Sender')),
      body: _controller == null || !_controller!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : CameraPreview(_controller!),
    );
  }
}