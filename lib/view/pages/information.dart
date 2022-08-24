import 'package:flutter/material.dart';
import 'package:sumple_beacon/view/pages/beacon_scanning_page.dart';
import 'package:sumple_beacon/view/pages/webpage.dart';
import 'package:url_launcher/link.dart';

class InformationPage extends StatefulWidget {
  const InformationPage({Key? key}) : super(key: key);
  @override
  _InformationPageState createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage>
    with WidgetsBindingObserver {
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
          '情報',
          style: TextStyle(color: Color.fromARGB(255, 21, 9, 4)),
        ),
        shape:
            Border(bottom: BorderSide(color: Colors.pink.shade100, width: 6)),
      ),
      body: Center(
          child: ElevatedButton(
              style: raisedButtonStyle,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WebPage()),
                );
              },
              child: Text('聴覚過敏について知る'))),
    );
  }
}
