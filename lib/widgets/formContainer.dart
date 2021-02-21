import 'package:flutter/cupertino.dart';

class FormContainer extends StatelessWidget {
  final Key formkey;
  final List<Widget> children;

  const FormContainer({Key key, this.formkey, this.children}) : super(key: key);
  
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
    child: Form(
      key: this.formkey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: this.children,
      )
    )
  );
}