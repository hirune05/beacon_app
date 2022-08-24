import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:sumple_beacon/view/notification.dart';
import 'package:sumple_beacon/view/pages/fight.dart';
import 'package:sumple_beacon/view/pages/thanks.dart';

import '../../util/constants.dart';

List<String> helps = [
  "協力するよ！頑張って!!",
  "問題が解決しました。ありがとう！",
  "食事中の食器の擦れあう音が苦手です。",
  "ささやき声が苦手です。",
  "大きな声が苦手です。"
];

Color? scanningColor = Colors.indigo[100];
int notificationCount = 0;
int helpCountBase = 0;
int helpCountSecond = 0;
bool favo = false;

class BeaconScanningPage extends StatefulWidget {
  const BeaconScanningPage({Key? key}) : super(key: key);

  @override
  _BeaconScanningPageState createState() => _BeaconScanningPageState();
}

//ビーコンを検出する
class _BeaconScanningPageState extends State<BeaconScanningPage>
    with WidgetsBindingObserver {
  final StreamController<BluetoothState> streamController = StreamController();
  StreamSubscription<BluetoothState>? _streamBluetooth;
  StreamSubscription<RangingResult>? _streamRanging;
  StreamSubscription<MonitoringResult>? _streamMonitoring;
  final _beacons = <Beacon>[];
  bool _authorizationStatusOk = false; //アプリの位置情報の使用権限許可
  bool _locationServiceEnabled = false; //端末の位置情報 ON
  bool _bluetoothEnabled = false; //端末のBluetooth ON

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this); //ライフサイクル変化を検知するオブザーバーを登録する

    super.initState();
    listeningState();
  }

  ///
  /// Bluetooth ON/OFF初期化
  ///
  listeningState() async {
    print('Listening to bluetooth state');
    _streamBluetooth = flutterBeacon
        .bluetoothStateChanged()
        .listen((BluetoothState state) async {
      print('BluetoothState = $state');
      streamController.add(state);
      //↑ここに値が入ると、Streambuilderのbuilder以下の滅ソッドが実行され、再描画される

      if (state == BluetoothState.stateOn) {
        initScanBeacon();
      } else if (state == BluetoothState.stateOff) {
        await pauseScanBeacon();
        await checkAllRequirements();
      }
    });
  }

  ///
  /// 権限チェック
  ///
  checkAllRequirements() async {
    final bluetoothState =
        await flutterBeacon.bluetoothState; //Bluetoothの状態を取得する
    final bluetoothEnabled = bluetoothState == BluetoothState.stateOn;
    final authorizationStatus =
        await flutterBeacon.authorizationStatus; //位置情報認証状態を取得する
    /*【iOS】アプリ初回起動時、「このAPPの使用中にみ許可」に設定すると、alwaysとなり、位置情報認証OKとなるが、
    そのあと設定画面から「このAPPの使用中にみ許可」に設定すると、whenInUseとなるため注意.
    （サンプルコードには、whenInUseの条件は入っていなかった）らしい*/
    final authorizationStatusOk =
        authorizationStatus == AuthorizationStatus.allowed ||
            authorizationStatus == AuthorizationStatus.whenInUse ||
            authorizationStatus == AuthorizationStatus.always;
    final locationServiceEnabled =
        await flutterBeacon.checkLocationServicesIfEnabled; // 端末の位置情報の利用可否を取得する

    print('authorizationStatusOk=$authorizationStatusOk, '
        'locationServiceEnabled=$locationServiceEnabled, '
        'bluetoothEnabled=$bluetoothEnabled');

    setState(() {
      _authorizationStatusOk = authorizationStatusOk;
      _locationServiceEnabled = locationServiceEnabled;
      _bluetoothEnabled = bluetoothEnabled;
    });
  }

  ///
  /// ビーコンScan初期化
  ///
  Future<void> initScanBeacon() async {
    // 公式のライブラリで用意されたビーコンスキャン初期化プロパティ
    await flutterBeacon.initializeScanning;
    // 権限チェック
    await checkAllRequirements();
    if (_bluetoothEnabled &&
        _authorizationStatusOk &&
        _locationServiceEnabled) {
      listeningRanging();
      listeningMonitoring();
    }
  }

  ///
  /// レンジングによる監視
  ///
  void listeningRanging() {
    final regions = <Region>[
      Region(
        identifier: 'Cubeacon',
        proximityUUID: kProximityUUID,
      ),
    ];

    //flutterBeacon.ranging(regions)をlistenすることで、
    //1秒おきにlisten以下のコールバック関数にてアドバタイズ信号の検出結果(RangingResult result)
    //を持った解析処理が実行できるようになる。
    _streamRanging = flutterBeacon.ranging(regions).listen(
      (RangingResult result) {
        print(result);
        if (mounted) {
          setState(() {
            _beacons.clear();
            _beacons.addAll(result.beacons);
            _beacons.sort(_compareParameters);
          });
        }
      },
    );
  }

  void listeningMonitoring() {
    final regions = <Region>[
      Region(
        identifier: 'Cubeacon',
        proximityUUID: kProximityUUID,
      ),
    ];
    _streamMonitoring = flutterBeacon.monitoring(regions).listen(
      (MonitoringResult result) {
        print(result);
        if (mounted) {
          print('beacon圏内に入ったよ');
          if (notificationCount != 1) {
            if (Platform.isAndroid) {
              //notifyAndroid();
            }
            if (Platform.isIOS) {
              notifyIOS();
            }
          } else {
            notificationCount++;
          }
        }
      },
    );
  }
  /*
  Beacons.monitoring(
  region: new BeaconRegionIBeacon(
    identifier: 'test',
    proximityUUID: '7da11b71-6f6a-4b6d-81c0-8abd031e6113',
  ),
  inBackground: false, // continue the monitoring operation in background or not, see below
).listen((result) {
  // result contains the new monitoring state:
  // - enter
  // - exit
}
  */

  ///
  /// 並べ替え
  ///
  int _compareParameters(Beacon a, Beacon b) {
    int compare = a.proximityUUID.compareTo(b.proximityUUID);

    if (compare == 0) {
      compare = a.major.compareTo(b.major);
    }

    if (compare == 0) {
      compare = a.minor.compareTo(b.minor);
    }

    return compare;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print('AppLifecycleState = $state');
    //権限更新およびBluetoothがONなら、initScanBeacon()を実行する
    if (state == AppLifecycleState.resumed) {
      if (_streamBluetooth != null) {
        if (_streamBluetooth!.isPaused) {
          _streamBluetooth?.resume();
        }
      }

      await checkAllRequirements();

      if (_bluetoothEnabled) {
        await initScanBeacon();
      }
    } else if (state == AppLifecycleState.paused) {
      _streamBluetooth?.pause();
    }
  }

  pauseScanBeacon() async {
    _streamRanging?.pause();
    if (_beacons.isNotEmpty) {
      setState(() {
        _beacons.clear();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); //オブザーバーを破棄します。
    streamController.close();
    _streamRanging?.cancel();
    _streamMonitoring?.cancel();
    _streamBluetooth?.cancel();
    flutterBeacon.close;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '受信',
          style: TextStyle(color: Colors.black),
        ),
        leading: Image.asset('images/icon.png'),
        backgroundColor: scanningColor,
        shape:
            Border(bottom: BorderSide(color: Colors.pink.shade100, width: 6)),
        actions: [
          //アプリの位置情報の使用権限許可off&&端末の位置情報 ON
          if (!_authorizationStatusOk && _locationServiceEnabled)
            IconButton(
              icon: const Icon(Icons.portable_wifi_off),
              color: Colors.red,
              onPressed: () async {
                //位置情報の使用権限許可リクエストができる
                await flutterBeacon.requestAuthorization;
              },
            ),
          //端末の位置情報 OFF
          if (!_locationServiceEnabled)
            IconButton(
              icon: const Icon(Icons.location_off),
              color: Colors.red,
              onPressed: () async {
                //androidの場合
                if (Platform.isAndroid) {
                  await flutterBeacon.openLocationSettings;
                }
                //iOSの場合
                else if (Platform.isIOS) {
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Location Services Off'),
                        content: const Text(
                            'Please enable Location Services on Settings > Privacy > Location Services.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          //streamControllerが変化すると再描画される
          //今回は、BluetoothStateの型を持ったStreamController<BluetoothState>を使って、Bluetooth ON/OFF状態が変化したときに再描画されるようになっています。
          StreamBuilder<BluetoothState>(
            stream: streamController.stream,
            initialData: BluetoothState.stateUnknown,
            builder: (context, snapshot) {
              //bluetoothがONかOFFか
              if (snapshot.hasData) {
                final state = snapshot.data;
                //ONだった場合
                if (state == BluetoothState.stateOn) {
                  return IconButton(
                    icon: const Icon(Icons.bluetooth_connected),
                    onPressed: () {},
                    color: Colors.lightBlueAccent,
                  );
                }
                //OFFだった場合
                if (state == BluetoothState.stateOff) {
                  return IconButton(
                    icon: const Icon(Icons.bluetooth),
                    onPressed: () async {
                      if (Platform.isAndroid) {
                        try {
                          await flutterBeacon.openBluetoothSettings;
                        } on PlatformException catch (e) {
                          print(e);
                        }
                      } else if (Platform.isIOS) {
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Bluetooth is Off'),
                              content: const Text(
                                  'Please enable Bluetooth on Settings > Bluetooth.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    color: Colors.red,
                  );
                }
                //bluetoothが使えない場合
                return IconButton(
                  icon: const Icon(Icons.bluetooth_disabled),
                  onPressed: () {},
                  color: Colors.grey,
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Container(
        color: scanningColor,
        child: _beacons.isEmpty
            //何も来てない時
            ? Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(30),
                    //padding: EdgeInsets.all(50),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('メッセージを受信したら\nここに表示されます。'),
                      ],
                    ),
                  ),
                ],
              )
            //何か来た時
            : ListView(
                children: ListTile.divideTiles(
                  context: context,
                  //検出した全ビーコン情報に対して、ひとつずつListTileウィジェットを使ってリストを構築していく。
                  tiles: _beacons.map(
                    (beacon) {
                      return ListTile(
                        title: Flexible(
                          child: Text(
                            beacon.major == 0
                                ? '協力するよ！頑張って!!'
                                : beacon.major == 1
                                    ? helps[1]
                                    : '${helps[beacon.major]}',
                            style: const TextStyle(fontSize: 13.0),
                          ),
                          flex: 2,
                          fit: FlexFit.tight,
                        ),
                        subtitle: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Flexible(
                              child: Text(
                                beacon.major == 1
                                    ? ''
                                    : beacon.major == 0
                                        ? '半径${beacon.accuracy}m以内にあなたを理解してくれている人がいます。'
                                        : '半径${beacon.accuracy}m以内に聴覚過敏で苦しんでいる人がいます',
                                style: const TextStyle(fontSize: 13.0),
                              ),
                              flex: 1,
                              fit: FlexFit.tight,
                            ),
                          ],
                        ),
                        trailing: beacon.major == 1
                            ? Text(
                                '🎉',
                                style: TextStyle(fontSize: 20),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey, //色
                                      spreadRadius: 5,
                                      blurRadius: 5,
                                      offset: Offset(1, 1),
                                    ),
                                  ],
                                  color: Colors.white,
                                ),
                                child: beacon.major == 0
                                    ? Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          IconButton(
                                            icon: const Icon(Icons.favorite,
                                                color: Colors.pink),
                                            onPressed: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ThanksPage()),
                                              );
                                              initScanBeacon();
                                            },
                                          ),
                                          /*Text(
                                'ファイト！',
                                style:
                                    TextStyle(fontSize: 4, color: Colors.red),
                              ),*/
                                        ],
                                      )
                                    : Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          IconButton(
                                            icon: const Icon(
                                                Icons.local_fire_department,
                                                color: Colors.orange),
                                            onPressed: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        FightPage()),
                                              );
                                              initScanBeacon();
                                            },
                                          ),
                                          /*Text(
                                'ファイト！',
                                style:
                                    TextStyle(fontSize: 4, color: Colors.red),
                              ),*/
                                        ],
                                      ),
                              ),
                      );
                    },
                  ),
                ).toList(),
              ),
      ),
    );
  }
}
