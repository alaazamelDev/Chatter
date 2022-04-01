import 'package:flutter/material.dart';

class DisplayErrorMessage extends StatelessWidget {
  const DisplayErrorMessage({
    Key? key,
    this.error,
  }) : super(key: key);

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Oh no! Something went wrong. '
        'Please Check your Configs $error',
        textAlign: TextAlign.center,
      ),
    );
  }
}
