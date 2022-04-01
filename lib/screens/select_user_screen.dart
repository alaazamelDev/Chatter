import 'package:chatter/configs/app.dart';
import 'package:chatter/models/demo_users.dart';
import 'package:chatter/screens/home_screen.dart';
import 'package:chatter/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class SelectUserScreen extends StatelessWidget {
  SelectUserScreen({Key? key}) : super(key: key);

  static Route route() => MaterialPageRoute(
        builder: (context) => SelectUserScreen(),
      );

  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final List<String> dropDownMenuItemsTitle = const [
    'Invite a firend',
    'Refresh',
    'Help',
  ];

  Future<void> _onUserSelected(BuildContext context, DemoUser user) async {
    // flip the state
    _isLoading.value = true;

    try {
      // move on to create a new chat
      final client = StreamChatCore.of(context).client;
      client.connectUser(
        User(
          id: user.id,
          extraData: {
            'name': user.name,
            'image': user.image,
          },
        ),
        client.devToken(user.id).rawValue,
      );

      // sign in as user selected
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ));
    } on Exception catch (e, st) {
      _isLoading.value = false;
      logger.e('Could not connect a user', e, st);
    }
  }

  void _handleMenuClick(String? selectedItem) {
    switch (selectedItem) {
      case 'Invite a firend':
        // Handle Invite a friend case
        break;
      case 'Refresh':
        // Handle Refresh case
        break;
      case 'Help':
        // Handle Help case
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: Theme.of(context).iconTheme,
        titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle,
        elevation: 0,
        title: const Text(
          'Select a Contact',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        leadingWidth: 54,
        leading: const SizedBox(),
        // Align(
        //   alignment: Alignment.centerRight,
        //   child: IconBackground(
        //     icon: CupertinoIcons.back,
        //     onTap: () {
        //       // Implement search functionality
        //       Navigator.pop(context);
        //     },
        //   ),
        // ),
        actions: [
          Theme(
            data: Theme.of(context).copyWith(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
            ),
            child: PopupMenuButton<String>(
              onSelected: _handleMenuClick,
              tooltip: '',
              itemBuilder: (BuildContext context) {
                return dropDownMenuItemsTitle.map((String option) {
                  return PopupMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList();
              },
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _isLoading,
        builder: (BuildContext context, bool isLoading, Widget? _) {
          if (isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return _ContactsListView(
            users: users, // change it when needed
            onUserSelected: (DemoUser user) {
              _onUserSelected(context, user);
            },
          );
        },
      ),
    );
  }
}

class _ContactsListView extends StatelessWidget {
  const _ContactsListView({
    Key? key,
    required this.onUserSelected,
    required this.users,
  }) : super(key: key);
  final Function(DemoUser) onUserSelected;
  final List<DemoUser> users;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _SearchContactView(),
        Expanded(
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: ((context, index) {
              return _ContactListTile(
                user: users[index],
                onTap: onUserSelected,
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _SearchContactView extends StatelessWidget {
  const _SearchContactView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(45),
          color: Theme.of(context).cardColor,
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 24,
            right: 16,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 100),
            child: const TextField(
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: TextStyle(fontSize: 14, height: 1.5),
              decoration: InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactListTile extends StatelessWidget {
  const _ContactListTile({
    Key? key,
    required this.user,
    required this.onTap,
  }) : super(key: key);
  final DemoUser user;
  final Function(DemoUser) onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap(user); // return an instance of selected user
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Avatar.small(url: user.image),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                user.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                  wordSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
