import 'package:flutter/material.dart';
import 'package:sumple_beacon/main.dart';
import 'package:sumple_beacon/view/pages/beacon_scanning_page.dart';
import 'package:sumple_beacon/view/pages/webpage.dart';

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
      onPrimary: subcolor,
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
            SizedBox(height: 50),
            //アプリの使い方ウェブページへ飛ぶ
            SizedBox(
              width: double.infinity,
              height: 80,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.white, //ボタンの背景色
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ManualPage()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.help_outline, color: subcolor, size: 45),
                    Text(
                      '使い方',
                      style: TextStyle(fontSize: 25, color: subcolor),
                    ),
                    Icon(Icons.navigate_next, color: subcolor, size: 45),
                  ],
                ),
              ),
            ),
            SizedBox(height: 50),
            //情報ページの表示
            SizedBox(
              width: double.infinity,
              height: 80,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.white, //ボタンの背景色
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WebPage()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.headphones,
                      color: subcolor,
                      size: 40,
                    ),
                    Text(
                      '聴覚過敏について知る',
                      style: TextStyle(fontSize: 20, color: subcolor),
                    ),
                    Icon(
                      Icons.navigate_next,
                      color: subcolor,
                      size: 45,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
