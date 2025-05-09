import 'dart:async';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Share Text App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textController = TextEditingController();
  StreamSubscription? _intentDataStreamSubscription;
  String _sharedText = "";
  final String _savedTextKey = 'saved_text';

  @override
  void initState() {
    super.initState();
    _loadSavedText();

    // For sharing or sending text.
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      setState(() {
        _sharedText = value;
        _textController.text = _sharedText;
      });
    }, onError: (err) {
      // print("getLinkStream error: $err");
    });

    // For sharing or sending text when the app is closed.
    ReceiveSharingIntent.getInitialText().then((String? value) {
      setState(() {
        if (value != null) {
          _sharedText = value;
          _textController.text = _sharedText;
        }
      });
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription?.cancel();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedText() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _textController.text = prefs.getString(_savedTextKey) ?? _sharedText;
    });
  }

  Future<void> _saveText() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_savedTextKey, _textController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Text saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Text App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter or paste text here',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveText,
              child: const Text('Save Text'),
            ),
          ],
        ),
      ),
    );
  }
}
