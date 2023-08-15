import 'package:find_a_bro/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // var theme = Theme.of(context);
    var state = context.watch<TabManagementState>();
    int tabIndex = state.index;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: tabIndex,
      showUnselectedLabels: false,
      showSelectedLabels: false,
      iconSize: 30,
      onTap: state.switchToTab,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.handshake),
          label: 'Find People',
          // backgroundColor: theme.colorScheme.background,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_alt),
          label: 'Connections',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
