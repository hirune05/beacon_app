import 'package:flutter/material.dart';
import 'package:sumple_beacon/view/pages/beacon_scanning_page.dart';

import 'manualpage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);
  @override
  _SettingsPage createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this); //ライフサイクル変化を検知するオブザーバーを登録する

    super.initState();
  }

  Widget build(BuildContext context) {
    final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
      onPrimary: Colors.brown[900],
      //ここで送信中の色を変えられる。
      primary: Colors.pink[100],
      minimumSize: const Size(88, 36),
      padding: const EdgeInsets.symmetric(vertical: 35),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(80)),
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: Image.asset('images/icon.png'),
        backgroundColor: Colors.white,
        title: const Text(
          'その他',
          style: TextStyle(color: Color.fromARGB(255, 21, 9, 4)),
        ),
        shape:
            Border(bottom: BorderSide(color: Colors.pink.shade100, width: 6)),
      ),
      body: Center(
        child: Column(
          children: [
            //アプリの使い方ウェブページへ飛ぶ
            ElevatedButton(
                style: raisedButtonStyle,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ManualPage()),
                  );
                },
                child: Text(
                  '使い方',
                  style: TextStyle(fontSize: 25),
                )),
            //聴覚過敏マークの表示
            ElevatedButton(
                style: raisedButtonStyle,
                onPressed: () {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("マーク"),
                        content: Image(
                            image: NetworkImage(
                          'http://www.ishiimark.com/Image/symbol/symbol-irr-21.jpg',
                        )),
                        actions: [
                          // ボタン領域
                          TextButton(
                            child: Text("×"),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text(
                  'マークを表示',
                  style: TextStyle(fontSize: 25),
                )),
          ],
        ),
      ),
    );
  }
}
