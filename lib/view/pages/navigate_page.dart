/*import 'package:flutter/material.dart';

import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:sumple_beacon/util/constants.dart';
import 'package:sumple_beacon/view/pages/beacon_scanning_page.dart';
import 'package:sumple_beacon/view/pages/scan2.dart';

int isSelectedItem = 0;

class NavigatePage extends StatefulWidget {
  const NavigatePage({Key? key}) : super(key: key);
  @override
  _NavigatePageState createState() => _NavigatePageState();
}

class _NavigatePageState extends State<NavigatePage>
    with WidgetsBindingObserver {
  final clearFocus = FocusNode();
  bool broadcasting = false;
  bool authorizationStatusOk = false;
  bool locationServiceEnabled = false;
  bool bluetoothEnabled = false;

  final regexUUID = RegExp(
      r'[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}');
  final uuidController = TextEditingController(text: kProximityUUID);
  final majorController = TextEditingController(text: '0'); //2バイト
  final minorController = TextEditingController(text: '0'); //2バイト

  bool get broadcastReady =>
      authorizationStatusOk == true &&
      locationServiceEnabled == true &&
      bluetoothEnabled == true;

  //アプリ起動時は、検出用のページが開かれるので、
  //発信用のページではシンプルに、権限チェックのみ実施
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();

    checkAllRequirements();
  }

  ///
  /// 権限チェック
  ///
  checkAllRequirements() async {
    final bluetoothState = await flutterBeacon.bluetoothState;
    final bluetoothEnabled = bluetoothState == BluetoothState.stateOn;
    final authorizationStatus = await flutterBeacon.authorizationStatus;
    final authorizationStatusOk =
        authorizationStatus == AuthorizationStatus.allowed ||
            authorizationStatus == AuthorizationStatus.whenInUse ||
            authorizationStatus == AuthorizationStatus.always;
    final locationServiceEnabled =
        await flutterBeacon.checkLocationServicesIfEnabled;

    print('broadcast: authorizationStatusOk=$authorizationStatusOk, '
        'locationServiceEnabled=$locationServiceEnabled, '
        'bluetoothEnabled=$bluetoothEnabled');

    setState(() {
      this.authorizationStatusOk = authorizationStatusOk;
      this.locationServiceEnabled = locationServiceEnabled;
      this.bluetoothEnabled = bluetoothEnabled;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print('AppLifecycleState = $state');
    if (state == AppLifecycleState.resumed) {
      await checkAllRequirements();
    } else if (state == AppLifecycleState.paused) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    flutterBeacon.close;

    clearFocus.dispose();

    super.dispose();
  }

//ここが実際の描画画面
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // (1) テキスト入力が表示された際に、Widgetがはみ出してエラー表示されるのを回避
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[400],
      appBar: AppBar(
        leading: Image.asset('images/icon.png'),
        backgroundColor: Colors.white,
        title: const Text(
          '送信',
          style: TextStyle(color: Color.fromARGB(255, 21, 9, 4)),
        ),
        shape:
            Border(bottom: BorderSide(color: Colors.pink.shade100, width: 6)),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(clearFocus),
        child: broadcastReady != true
            ? const Center(child: Text('Please wait...'))
            : Form(
                // (2)ユーザーが入力した時にバリデーションチェックを行う
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Kind),
              ),
      ),
    );
  }

  Widget get Kind {
    return Center(
      child: Container(
        height: 200,
        width: 300,
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(
                  width: 15,
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Icon(Icons.wifi, size: 50),
                    Text('受信'),
                  ],
                ),
                Text(
                  '  をタップ！',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              '助けや応援を待ちましょう☺️',
              style: TextStyle(fontSize: 17),
            ),
          ],
        ),
      ),
    );
  }
}*/
