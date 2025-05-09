import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShareText',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ShareTextScreen(),
    );
  }
}

class ShareTextScreen extends StatefulWidget {
  const ShareTextScreen({Key? key}) : super(key: key);

  @override
  _ShareTextScreenState createState() => _ShareTextScreenState();
}

class _ShareTextScreenState extends State<ShareTextScreen> {
  final TextEditingController _textController = TextEditingController();
  List<String> _savedTexts = [];
  late StreamSubscription _intentDataStreamSubscription;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSavedTexts();
    
    // 监听分享意图
    _intentDataStreamSubscription = ReceiveSharingIntent.getTextStream().listen((String text) {
      _handleSharedText(text);
    }, onError: (err) {
      debugPrint("Error receiving shared text: $err");
    });

    // 检查应用启动时是否有分享内容
    ReceiveSharingIntent.getInitialText().then((String? text) {
      if (text != null && text.isNotEmpty) {
        _handleSharedText(text);
      }
    });
  }

  void _handleSharedText(String text) {
    setState(() {
      _textController.text = text;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已接收分享的文本')),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  // 加载保存的文本
  Future<void> _loadSavedTexts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _savedTexts = prefs.getStringList('saved_texts') ?? [];
      });
    } catch (e) {
      debugPrint('加载保存的文本失败: $e');
    }
  }

  // 保存当前文本
  Future<void> _saveText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('文本不能为空')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // 获取当前时间作为文件名的一部分
      final now = DateTime.now();
      final formatter = DateFormat('yyyyMMdd_HHmmss');
      final timestamp = formatter.format(now);
      
      // 保存到文件
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/text_$timestamp.txt');
      await file.writeAsString(text);
      
      // 保存到列表中
      final prefs = await SharedPreferences.getInstance();
      final newSavedTexts = [
        '${now.toString()} - $text',
        ..._savedTexts,
      ].take(100).toList(); // 最多保存100条
      
      await prefs.setStringList('saved_texts', newSavedTexts);
      
      setState(() {
        _savedTexts = newSavedTexts;
        _textController.clear();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('文本已保存到: ${file.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShareText'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // 文本输入区域
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _textController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: '输入或从其他应用分享的文本',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          
          // 操作按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _textController.text.trim().isEmpty ? null : () {
                    _textController.clear();
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('清空'),
                ),
                ElevatedButton.icon(
                  onPressed: _isSaving || _textController.text.trim().isEmpty ? null : _saveText,
                  icon: _isSaving 
                      ? const SizedBox(
                          width: 16, 
                          height: 16, 
                          child: CircularProgressIndicator(strokeWidth: 2)
                        ) 
                      : const Icon(Icons.save),
                  label: const Text('保存'),
                ),
              ],
            ),
          ),
          
          const Divider(height: 32),
          
          // 历史记录
          Expanded(
            child: _savedTexts.isEmpty
                ? const Center(child: Text('暂无保存记录'))
                : ListView.builder(
                    itemCount: _savedTexts.length,
                    itemBuilder: (context, index) {
                      final text = _savedTexts[index];
                      final parts = text.split(' - ');
                      final dateTimeStr = parts.first;
                      final content = parts.length > 1 ? parts.sublist(1).join(' - ') : '';
                      
                      return ListTile(
                        title: Text(
                          content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(dateTimeStr),
                        onTap: () {
                          _textController.text = content;
                        },
                        leading: const Icon(Icons.history),
                        trailing: IconButton(
                          icon: const Icon(Icons.content_copy),
                          onPressed: () {
                            _textController.text = content;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('文本已复制到输入框')),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
} 