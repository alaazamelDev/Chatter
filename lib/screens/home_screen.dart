import 'package:chatter/configs/helpers.dart';
import 'package:chatter/configs/theme.dart';
import 'package:chatter/pages/calls_page.dart';
import 'package:chatter/pages/contacts_page.dart';
import 'package:chatter/pages/messages_page.dart';
import 'package:chatter/pages/notifications_page.dart';
import 'package:chatter/screens/select_user_screen.dart';
import 'package:chatter/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final ValueNotifier<int> pageIndex = ValueNotifier(0);
  final ValueNotifier<String> title = ValueNotifier('Messages');

  final pages = const [
    MessagesPage(),
    NotificationsPage(),
    CallsPage(),
    ContactsPage(),
  ];

  final pageTitles = const [
    'Messages',
    'Notifications',
    'Calls',
    'Contacts',
  ];

  void _onNavigationItemSelected(int index) {
    pageIndex.value = index;
    title.value = pageTitles[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: Theme.of(context).iconTheme,
        titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle,
        centerTitle: true,
        elevation: 0,
        title: ValueListenableBuilder(
          valueListenable: title,
          builder: (BuildContext context, String value, Widget? _) {
            return Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            );
          },
        ),
        leadingWidth: 54,
        leading: Align(
          alignment: Alignment.centerRight,
          child: IconBackground(
            icon: CupertinoIcons.search,
            onTap: () {
              // Implement search functionality
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Avatar.small(url: Helpers.randomPictureUrl()),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNavigationBar(
        onItemPressed: _onNavigationItemSelected,
      ),
      body: ValueListenableBuilder(
        valueListenable: pageIndex,
        builder: (BuildContext context, value, Widget? _) {
          return pages[pageIndex.value];
        },
      ),
    );
  }
}

class _BottomNavigationBar extends StatefulWidget {
  const _BottomNavigationBar({Key? key, required this.onItemPressed})
      : super(key: key);

  final ValueChanged<int> onItemPressed;

  @override
  State<_BottomNavigationBar> createState() => _BottomNavigationBarState();
}

class _BottomNavigationBarState extends State<_BottomNavigationBar> {
  late int selecetdIndex = 0; // for updating selected item
  void _handleItemSelected(int index) {
    setState(() {
      selecetdIndex = index;
    });
    widget.onItemPressed(index);
  }

  void _selectUserPressed() {
    // Go to select a new user to chat with
    Navigator.push(context, SelectUserScreen.route());
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Card(
      color: (brightness == Brightness.light) ? Colors.transparent : null,
      elevation: 0,
      margin: const EdgeInsets.all(0),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavigationBarItem(
                icon: CupertinoIcons.bubble_left_bubble_right_fill,
                lable: 'Messages',
                index: 0,
                onTap: _handleItemSelected,
                isSelected: (selecetdIndex == 0),
              ),
              _NavigationBarItem(
                icon: CupertinoIcons.bell_fill,
                lable: 'Notifications',
                index: 1,
                onTap: _handleItemSelected,
                isSelected: (selecetdIndex == 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: GlowingActionButton(
                  icon: CupertinoIcons.add,
                  color: AppColors.secondary,
                  onPressed: _selectUserPressed,
                ),
              ),
              _NavigationBarItem(
                icon: CupertinoIcons.phone_solid,
                lable: 'Calls',
                index: 2,
                onTap: _handleItemSelected,
                isSelected: (selecetdIndex == 2),
              ),
              _NavigationBarItem(
                icon: CupertinoIcons.person_2_fill,
                lable: 'Contacts',
                index: 3,
                onTap: _handleItemSelected,
                isSelected: (selecetdIndex == 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationBarItem extends StatelessWidget {
  const _NavigationBarItem({
    Key? key,
    required this.index,
    required this.lable,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
  }) : super(key: key);
  final IconData icon;
  final String lable;
  final int index;
  final ValueChanged<int> onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onTap(index);
      },
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.secondary : null,
            ),
            const SizedBox(height: 8),
            Text(
              lable,
              style: isSelected
                  ? const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    )
                  : const TextStyle(fontSize: 11),
            )
          ],
        ),
      ),
    );
  }
}
