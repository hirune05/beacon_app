import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';

import '../../util/constants.dart';

List<String> helps = [
  "次降ります支えて下さい",
  "せきを譲っていただきたいです",
  "痴漢です！助けて下さい",
  "階段を登りたいです。支えて下さい"
];

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
    _streamBluetooth?.cancel();
    flutterBeacon.close;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan'),
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
      body: _beacons.isEmpty
          //ビーコンが未検出時は、ぐるぐる表示
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: ListTile.divideTiles(
                context: context,
                //検出した全ビーコン情報に対して、ひとつずつListTileウィジェットを使ってリストを構築していく。
                tiles: _beacons.map(
                  (beacon) {
                    return ListTile(
                      title: Text(
                        beacon.proximityUUID,
                        style: const TextStyle(fontSize: 15.0),
                      ),
                      subtitle: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                            child: Text(
                              'Major: ${helps[beacon.major]}\nMinor: ${beacon.minor}',
                              style: const TextStyle(fontSize: 13.0),
                            ),
                            flex: 1,
                            fit: FlexFit.tight,
                          ),
                          Flexible(
                            child: Text(
                              'Accuracy: ${beacon.accuracy}m\nRSSI: ${beacon.rssi}',
                              style: const TextStyle(fontSize: 13.0),
                            ),
                            flex: 2,
                            fit: FlexFit.tight,
                          )
                        ],
                      ),
                    );
                  },
                ),
              ).toList(),
            ),
    );
  }
}
