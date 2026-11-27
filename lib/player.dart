import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class InternalPlayer extends StatefulWidget {
  final String title;
  final String url;
  const InternalPlayer({super.key, required this.title, required this.url});
  @override
  State<InternalPlayer> createState() => _InternalPlayerState();
}

class _InternalPlayerState extends State<InternalPlayer> {
  late VideoPlayerController _v;
  ChewieController? _c;
  bool err = false;

  @override
  void initState() {
    super.initState();
    _v = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) setState(() => _c = ChewieController(videoPlayerController: _v, autoPlay: true));
      }).catchError((_) {
        if (mounted) setState(() => err = true);
      });
  }

  @override
  void dispose() {
    _v.dispose();
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(widget.title), backgroundColor: Colors.black),
      body: Center(
        child: err
            ? const Text('\u0627\u0644\u0633\u064a\u0631\u0641\u0631 \u0645\u0634\u063a\u0648\u0644 \u062d\u0627\u0644\u064a\u0627\u064b\u060c \u062c\u0631\u0628 \u0642\u0646\u0627\u0629 \u0623\u062e\u0631\u0649', style: TextStyle(color: Colors.red))
            : (_c != null ? Chewie(controller: _c!) : const CircularProgressIndicator(color: Colors.red)),
      ),
    );
  }
}
