import 'package:flutter/material.dart';

import '../models/navbar_model.dart';

class NavbarProvider with ChangeNotifier {
  int _currentIndex = 0;

  final List<NavItem> _navItems = [
    NavItem(icon: Icons.auto_awesome, label: "Generate", index: 0),
    NavItem(icon: Icons.public, label: "Community", index: 1),
    NavItem(icon: Icons.history, label: "History", index: 2),
    NavItem(icon: Icons.shopping_cart, label: "Store", index: 3),
    NavItem(icon: Icons.person, label: "Profile", index: 4),
  ];

  int get currentIndex => _currentIndex;
  List<NavItem> get navItems => _navItems;
  NavItem get currentNavItem => _navItems[_currentIndex];

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  bool isSelected(int index) {
    return _currentIndex == index;
  }

  int getNextIndex() {
    return (_currentIndex + 1) % _navItems.length;
  }

  int getPreviousIndex() {
    return (_currentIndex - 1) % _navItems.length;
  }
}