import 'package:flutter/material.dart';
import 'package:fplayer_example/recent_list.dart';

import 'app_bar.dart';

String globalInputValue = "rtsp://192.168.11.123/1/h264major";

class HomeItem extends StatelessWidget {
  const HomeItem({
    super.key,
    required this.onPressed,
    required this.text,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      height: 45,
      child: Container(
        padding: const EdgeInsets.all(0),
        child: TextButton(
          key: ValueKey(text),
          onPressed: onPressed,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Text(text),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final RecentMediaList list = RecentMediaList();

  final TextEditingController _controller = TextEditingController();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FAppBar.defaultSetting(
        title: "FPlayer",
      ),
      body: Builder(
        builder: (ctx) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            HomeItem(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SamplesScreen(),
                  ),
                );
              },
              text: "Online Samples",
            ),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "请输入地址",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                globalInputValue = _controller.text; // 把输入框的值保存
              },
              child: const Text("提交"),
            ),
            const SizedBox(height: 20),
            /*
            Container(
              color: Theme.of(context).primaryColorLight,
              padding: EdgeInsets.only(left: 15, top: 3, bottom: 3, right: 15),
              child: Text(
                "Recent",
                style: TextStyle(fontSize: 15),
              ),
            ),
            Expanded(
              child: list,
            ),
             */
          ],
        ),
      ),
    );
  }
}

void displaySnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    duration: Duration(seconds: 1),
    content: Text('Not implemented, pull request is welcome 👏👏🍺🍺'),
  ));
}
