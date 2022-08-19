import 'package:flutter/material.dart';

import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:sumple_beacon/util/constants.dart';

int isSelectedItem = 0;

class FightPage extends StatefulWidget {
  const FightPage({Key? key}) : super(key: key);
  @override
  _FightPageState createState() => _FightPageState();
}

class _FightPageState extends State<FightPage> with WidgetsBindingObserver {
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      majorField,
                      const SizedBox(height: 40),
                      /*SizedBox(
                        height: 200,
                      ),*/
                      //buttonBroadcast,
                      const SizedBox(height: 30),
                      buttonFight,
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  //UUIDのTextFormField
  Widget get uuidField {
    return TextFormField(
      readOnly: broadcasting,
      controller: uuidController,
      decoration: const InputDecoration(
        labelText: 'Proximity UUID',
      ),
      validator: (val) {
        //入力欄が空でないか
        if (val == null || val.isEmpty) {
          return 'Proximity UUID required';
        }
        //UUIDフォーマットに沿った入力値となっているか
        if (!regexUUID.hasMatch(val)) {
          return 'Invalid Proxmity UUID format';
        }

        return null;
      },
    );
  }

  //Major番号のTextFormField
  Widget get majorField {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 60),
        Text(
          'Help内容',
          style: TextStyle(fontSize: 25),
        ),
        SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(3.0, 3.0),
                blurRadius: 0.8,
                spreadRadius: 0.8,
              ),
            ],
          ),
          height: 100,
          child: SizedBox(
            height: 50,
            child: DropdownButton(
              //4
              items: const [
                //5
                DropdownMenuItem(
                  child: Text(
                    "食器の擦れあう音",
                    style: TextStyle(fontSize: 20),
                  ),
                  value: 0,
                ),
                DropdownMenuItem(
                  child: Text("囁き声", style: TextStyle(fontSize: 20)),
                  value: 1,
                ),
                DropdownMenuItem(
                  child: Text("大きな声", style: TextStyle(fontSize: 20)),
                  value: 2,
                ),
              ],
              //6
              onChanged: (int? value) {
                setState(() {
                  isSelectedItem = value!;
                });
              },
              value: isSelectedItem,
            ),
          ),
        ),
      ],
      //7
    );
  }

  //Minor番号のTextFormField
  Widget get minorField {
    return TextFormField(
      readOnly: broadcasting,
      controller: minorController,
      decoration: const InputDecoration(
        labelText: 'Minor',
      ),
      keyboardType: TextInputType.number,
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Minor required';
        }

        try {
          int minor = int.parse(val);

          if (minor < 0 || minor > 65535) {
            return 'Minor must be number between 0 and 65535';
          }
        } on FormatException {
          return 'Minor must be number';
        }

        return null;
      },
    );
  }

  Widget get buttonFight {
    final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
      onPrimary: Colors.brown[900],
      //ここで送信中の色を変えられる。
      primary: broadcasting ? Colors.lightBlue[200] : Colors.orange[400],
      minimumSize: const Size(88, 36),
      padding: const EdgeInsets.symmetric(vertical: 30),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    );
    return ElevatedButton(
      style: raisedButtonStyle,
      onPressed: () async {
        /*if (broadcasting) {
          //発信停止
          await flutterBeacon.stopBroadcast();
        } else {*/
        //発信開始
        await flutterBeacon.startBroadcast(BeaconBroadcast(
          proximityUUID: uuidController.text,
          major: 0,
          minor: 0,
        ));
        //}

        Navigator.pop(context);
        final isBroadcasting = await flutterBeacon.isBroadcasting();

        if (mounted) {
          setState(() {
            broadcasting = isBroadcasting;
          });
        }
      },
      child: Text(
        '協力と理解を示す',
        style: TextStyle(fontSize: 35),
      ),
    );
  }
}
