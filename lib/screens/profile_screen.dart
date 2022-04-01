import 'package:chatter/configs/app.dart';
import 'package:chatter/screens/screens.dart';
import 'package:chatter/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  static Route route() => MaterialPageRoute(
        builder: (BuildContext context) => const ProfileScreen(),
      );

  @override
  Widget build(BuildContext context) {
    // Get instance of current user
    final user = context.currentUser;
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 54,
        leading: AppBarBackButton(onTap: () {
          Navigator.pop(context);
        }),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Hero(
                tag: 'profile-picture-hero',
                child: Avatar.large(url: user?.image),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  user?.name ?? 'No Name',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Divider(thickness: 1),
              ),
              const Spacer(),
              const _SignOutButton(),
              const SizedBox(height: 30)
            ],
          ),
        ),
      ),
    );
  }
}

class _SignOutButton extends StatefulWidget {
  const _SignOutButton({
    Key? key,
  }) : super(key: key);

  @override
  State<_SignOutButton> createState() => _SignOutButtonState();
}

class _SignOutButtonState extends State<_SignOutButton> {
  late bool _isLoading = false;

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
    });

    // Sign out operation
    try {
      // Disconnect user
      await StreamChatCore.of(context).client.disconnectUser();

      // Go out of this page
      Navigator.pushReplacement(context, SelectUserScreen.route());
    } on Exception catch (e, st) {
      setState(() {
        _isLoading = false;
      });

      logger.e('Cannot disconnect user', e, st);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : TextButton(
            onPressed: _signOut,
            style: TextButton.styleFrom(
                backgroundColor: Colors.transparent, elevation: 0),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          );
  }
}
