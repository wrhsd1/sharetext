import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

void main() {
  // 确保Flutter绑定已初始化
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '文本分享收集器',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: '文本分享收集器'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  late StreamSubscription _intentDataStreamSubscription;
  List<String> savedTexts = [];
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // 加载保存的文本列表
    _loadSavedTexts();
    
    // 监听分享意图
    _intentDataStreamSubscription = ReceiveSharingIntent.getTextStream().listen((String value) {
      setState(() {
        _textController.text = value;
      });
    }, onError: (err) {
      debugPrint("错误: $err");
    });

    // 检查是否有初始传来的数据
    ReceiveSharingIntent.getInitialText().then((String? value) {
      if (value != null && value.isNotEmpty) {
        setState(() {
          _textController.text = value;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    _textController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  // 加载保存的文本列表
  Future<void> _loadSavedTexts() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedTexts = prefs.getStringList('savedTexts') ?? [];
    });
  }
  
  // 保存文本
  Future<void> _saveText() async {
    String text = _textController.text.trim();
    if (text.isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      if (!savedTexts.contains(text)) {
        savedTexts.insert(0, text); // 将新文本添加到列表开头
        prefs.setStringList('savedTexts', savedTexts);
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已保存文本'))
    );
  }
  
  // 删除保存的文本
  Future<void> _deleteText(int index) async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      savedTexts.removeAt(index);
      prefs.setStringList('savedTexts', savedTexts);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已删除文本'))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: '输入要保存的文本或从其他应用分享文本至此',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveText,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('保存文本'),
            ),
            const SizedBox(height: 24),
            const Text(
              '已保存的文本',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: savedTexts.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(
                        savedTexts[index],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        _textController.text = savedTexts[index];
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteText(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
