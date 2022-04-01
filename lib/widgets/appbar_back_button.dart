import 'package:chatter/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';

class AppBarBackButton extends StatelessWidget {
  const AppBarBackButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: IconBackground(
        icon: CupertinoIcons.back,
        onTap: onTap,
      ),
    );
  }
}
