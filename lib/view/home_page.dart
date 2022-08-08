import 'package:flutter/material.dart';
import 'package:sumple_beacon/view/pages/beacon_broadcasting_page.dart';
import 'cupertino_home_scaffold.dart';
import 'pages/beacon_scanning_page.dart';
import 'tab_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //現在表示中のタブを管理
  TabItem _currentTab = TabItem.scanning;

  final Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.scanning: GlobalKey<NavigatorState>(),
    TabItem.broadcasting: GlobalKey<NavigatorState>(),
  };

  //enumで定義したTabItemに応じたページを実装する
  Map<TabItem, WidgetBuilder> get widgetBuilders {
    return {
      TabItem.scanning: (_) => const BeaconScanningPage(),
      TabItem.broadcasting: (_) => const BeaconBroadcastingPage(),
    };
  }

  void _select(TabItem tabItem) {
    if (tabItem == _currentTab) {
      // pop to first route 現在いるタブをタップしたら、pushしていたものを解除する.
      navigatorKeys[tabItem]!.currentState!.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentTab = tabItem;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async =>
            !await navigatorKeys[_currentTab]!.currentState!.maybePop(),
        child: CupertinoHomeScaffold(
          currentTab: _currentTab,
          widgetBuilders: widgetBuilders,
          onSelectTab: (tabItem) => _select(tabItem),
          navigatorKeys: navigatorKeys,
        ),
      ),
    );
  }
}
