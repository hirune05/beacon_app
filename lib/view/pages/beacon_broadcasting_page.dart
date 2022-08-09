import 'package:flutter/material.dart';

import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:sumple_beacon/util/constants.dart';

int isSelectedItem = 0;

class BeaconBroadcastingPage extends StatefulWidget {
  const BeaconBroadcastingPage({Key? key}) : super(key: key);

  @override
  _BeaconBroadcastingPageState createState() => _BeaconBroadcastingPageState();
}

class _BeaconBroadcastingPageState extends State<BeaconBroadcastingPage>
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // (1) テキスト入力が表示された際に、Widgetがはみ出してエラー表示されるのを回避
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Broadcast'),
        centerTitle: false,
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
                      uuidField,
                      majorField,
                      minorField,
                      const SizedBox(height: 16),
                      buttonBroadcast,
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
    /*return TextFormField(
      readOnly: broadcasting,
      controller: majorController,
      decoration: const InputDecoration(
        labelText: 'Major',
      ),
      keyboardType: TextInputType.number,
      validator: (val) {
        //入力欄が空でないか
        if (val == null || val.isEmpty) {
          return 'Major required';
        }

        try {
          int major = int.parse(val);
          //入力範囲0～65535
          if (major < 0 || major > 65535) {
            return 'Major must be number between 0 and 65535';
          }
        } on FormatException {
          return 'Major must be number';
        }

        return null;
      },
    );*/
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'Help内容',
          style: TextStyle(fontSize: 10),
        ),
        DropdownButton(
          //4
          items: const [
            //5
            DropdownMenuItem(
              child: Text("次降ります。支えて下さい"),
              value: 0,
            ),
            DropdownMenuItem(
              child: Text("せきを譲っていただきたいです"),
              value: 1,
            ),
            DropdownMenuItem(
              child: Text("痴漢です！助けて下さい"),
              value: 2,
            ),
            DropdownMenuItem(
              child: Text("階段を登りたいです。支えて下さい"),
              value: 3,
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

  Widget get buttonBroadcast {
    final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
      onPrimary: Colors.white,
      primary: broadcasting ? Colors.red : Theme.of(context).primaryColor,
      minimumSize: const Size(88, 36),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)),
      ),
    );
    return ElevatedButton(
      style: raisedButtonStyle,
      onPressed: () async {
        if (broadcasting) {
          //発信停止
          await flutterBeacon.stopBroadcast();
        } else {
          //発信開始
          await flutterBeacon.startBroadcast(BeaconBroadcast(
            proximityUUID: uuidController.text,
            major: isSelectedItem,
            minor: int.tryParse(minorController.text) ?? 0,
          ));
        }

        final isBroadcasting = await flutterBeacon.isBroadcasting();

        if (mounted) {
          setState(() {
            broadcasting = isBroadcasting;
          });
        }
      },
      child: Text('Broadcast${broadcasting ? 'ing' : ''}'),
    );
  }
}
