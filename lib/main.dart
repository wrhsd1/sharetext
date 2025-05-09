import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Text Saver',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Simple Text Saver'),
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
  final TextEditingController _textController = TextEditingController();
  String _savedText = "";
  StreamSubscription? _intentDataStreamSubscription;
  String? _sharedText;

  @override
  void initState() {
    super.initState();
    _loadSavedText();

    // 监听应用程序在内存中时的外部分享
    _intentDataStreamSubscription = ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> value) {
      setState(() {
        if (value.isNotEmpty && value[0].type == SharedMediaType.text) {
          _sharedText = value[0].path;
        _textController.text = _sharedText ?? _textController.text;
        }
      });
    }, onError: (err) {
      print("getMediaStream error: $err");
    });

    // 处理应用程序关闭状态下的外部分享
    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
      setState(() {
        if (value.isNotEmpty && value[0].type == SharedMediaType.text) {
          _sharedText = value[0].path;
        if (_sharedText != null) {
          _textController.text = _sharedText!;
          }
        }
      });
      
      // 告诉库我们已完成处理意图
      ReceiveSharingIntent.instance.reset();
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadSavedText() async {
    final prefs = await SharedPreferences.getInstance();
    // 只有在没有共享文本覆盖的情况下才加载保存的文本
    if (_sharedText == null) {
       setState(() {
        _textController.text = prefs.getString('saved_text') ?? '';
        _savedText = _textController.text;
      });
    }
  }

  Future<void> _saveText() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_text', _textController.text);
    setState(() {
      _savedText = _textController.text;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Text saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter text to save or share here',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveText,
              child: const Text('Save Text'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Previously saved text (if any):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_savedText.isEmpty ? "No text saved yet." : _savedText),
          ],
        ),
      ),
    );
  }
}

