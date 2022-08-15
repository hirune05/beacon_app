import 'package:flutter/material.dart';
import 'package:sumple_beacon/view/pages/beacon_scanning_page.dart';

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
    );
  }
}
