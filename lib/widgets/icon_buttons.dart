import 'package:chatter/configs/theme.dart';
import 'package:flutter/material.dart';

class IconBackground extends StatelessWidget {
  const IconBackground({
    Key? key,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.secondary,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(
            icon,
            size: 18,
          ),
        ),
      ),
    );
  }
}
