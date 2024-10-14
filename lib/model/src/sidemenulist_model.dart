// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

class SideMultiMenuList {
  final int index;
  final String title;
  final IconData icon;
  SideMultiMenuList({
    required this.index,
    required this.title,
    required this.icon,
  });

  SideMultiMenuList copyWith({
    int? index,
    String? title,
    IconData? icon,
  }) {
    return SideMultiMenuList(
      index: index ?? this.index,
      title: title ?? this.title,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'index': index,
      'title': title,
      'icon': icon.codePoint,
    };
  }

  factory SideMultiMenuList.fromMap(Map<String, dynamic> map) {
    return SideMultiMenuList(
      index: map['index'] as int,
      title: map['title'] as String,
      icon: IconData(map['icon'] as int, fontFamily: 'MaterialIcons'),
    );
  }

  String toJson() => json.encode(toMap());

  factory SideMultiMenuList.fromJson(String source) =>
      SideMultiMenuList.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'SideMultiMenuList(index: $index, title: $title, icon: $icon)';

  @override
  bool operator ==(covariant SideMultiMenuList other) {
    if (identical(this, other)) return true;

    return other.index == index && other.title == title && other.icon == icon;
  }

  @override
  int get hashCode => index.hashCode ^ title.hashCode ^ icon.hashCode;
}
