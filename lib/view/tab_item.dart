import 'package:flutter/material.dart';
//アイコンを付け足したかったらこのファイルを変える！

//表示したいタブを定義する
enum TabItem {
  scanning,
  broadcasting,
}

//Map形式で先ほど定義したenumをキーとして、titleとiconの情報を持ったTabItemDataを定義する
//タブに表示する名称やアイコンを変更したい場合は、ここのクラスを変更
class TabItemData {
  const TabItemData({required this.title, required this.icon});

  final String title;
  final IconData icon;

  static const Map<TabItem, TabItemData> allTabs = {
    TabItem.scanning: TabItemData(title: 'Scan', icon: Icons.list),
    TabItem.broadcasting: TabItemData(title: 'Broadcast', icon: Icons.send),
  };
}
