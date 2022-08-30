import 'package:flutter/material.dart';
//アイコンを付け足したかったらこのファイルを変える！

//表示したいタブを定義する
enum TabItem {
  scanning,
  broadcasting,
  information,
  settings,
}

//Map形式で先ほど定義したenumをキーとして、titleとiconの情報を持ったTabItemDataを定義する
//タブに表示する名称やアイコンを変更したい場合は、ここのクラスを変更
class TabItemData {
  const TabItemData({required this.title, required this.icon});

  final String title;
  final IconData icon;

  static const Map<TabItem, TabItemData> allTabs = {
    TabItem.scanning: TabItemData(title: '受信', icon: Icons.wifi),
    TabItem.broadcasting: TabItemData(title: '送信', icon: Icons.send),
    TabItem.information:
        TabItemData(title: 'マーク', icon: Icons.perm_device_information),
    TabItem.settings: TabItemData(title: '地図', icon: Icons.map_outlined),
  };
}
