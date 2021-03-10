import 'package:flutter/cupertino.dart';

class FormContainer extends StatelessWidget {
  const FormContainer({Key key, this.formkey, this.children}) : super(key: key);

  final Key formkey;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Form(
          key: formkey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          )));
}
