import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:perna/helpers/app_localizations.dart';
import 'package:perna/main.dart';
import 'package:perna/models/user.dart';
import 'package:perna/pages/employee_page.dart';

enum UserFetchFrom { userEmails, askedPointIds }

class UserListPage extends StatefulWidget {
  UserListPage(
      {this.userFetchFrom = UserFetchFrom.userEmails,
      this.readOnly = false,
      this.keys,
      this.email,
      this.companyId,
      this.onSubmmitChanges,
      @required this.title}) {
        if (!readOnly) {
          assert(companyId != null);
        }
        assert(userFetchFrom == UserFetchFrom.userEmails);
      }

  final UserFetchFrom userFetchFrom;
  final Future<void> Function(List<User>) onSubmmitChanges;
  final bool readOnly;
  final String title;
  final String email;
  final String companyId;
  final List<String> keys;

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  bool isLoading = false;
  List<User> users;
  StreamSubscription<QuerySnapshot> usersListener;

  @override
  void dispose() {
    super.dispose();
    usersListener?.cancel();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    if (widget.userFetchFrom == UserFetchFrom.userEmails) {
      usersListener = getIt<FirebaseFirestore>()
          .collection('user')
          .where('email', whereIn: widget.keys)
          .snapshots()
          .listen((QuerySnapshot usersSnapshot) {
        setState(() {
          users = usersSnapshot.docs.map<User>((QueryDocumentSnapshot user) {
            return User.fromJson(user.data());
          }).toList();
          isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Theme.of(context).brightness,
          centerTitle: true,
          title: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Text(widget.title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 30.0)),
            const SizedBox(width: 5),
            const Icon(Icons.business, size: 30),
          ]),
          backgroundColor: Theme.of(context).backgroundColor,
          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
          actions: <Widget>[
            if (!widget.readOnly)
              IconButton(
                  icon: const Icon(Icons.person_add_outlined),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute<AddEmployeePage>(
                            builder: (BuildContext context) => AddEmployeePage(
                                companyId: widget.companyId,
                                )));
                  })
          ],
          textTheme: TextTheme(
              headline6: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 20,
                  fontFamily:
                      Theme.of(context).textTheme.headline6.fontFamily)),
        ),
        body: isLoading
            ? Center(
                child: SpinKitDoubleBounce(
                    size: 100.0, color: Theme.of(context).primaryColor))
            : (users.isEmpty
                ? Center(
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Image.asset('assets/no_user.png', scale: 2),
                      Text(AppLocalizations.of(context).translate('no_user'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 20)),
                      Text(
                        AppLocalizations.of(context)
                            .translate('no_user_description'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 17),
                      )
                    ],
                  ))
                : Builder(builder: (BuildContext context) {
                    return ListView.separated(
                        itemCount: users.length,
                        separatorBuilder: (BuildContext context, int index) {
                          return const Divider();
                        },
                        itemBuilder: (BuildContext context, int index) {
                          final User user = users[index];
                          return IgnorePointer(
                              ignoring:
                                  widget.readOnly || widget.email == user.email,
                              child: Dismissible(
                                  background: Container(
                                    decoration: const BoxDecoration(
                                        color: Colors.redAccent),
                                    child: const Icon(Icons.person_remove),
                                  ),
                                  onDismissed: (DismissDirection direction) {
                                    setState(() {
                                      users.removeAt(index);
                                    });
                                  },
                                  key: UniqueKey(),
                                  child: ListTile(
                                    enabled: widget.readOnly ||
                                        widget.email != user.email,
                                    leading: CircleAvatar(
                                      radius: 50,
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      backgroundImage:
                                          NetworkImage(user.photoUrl),
                                      child: user.photoUrl == null ||
                                              user.photoUrl == ''
                                          ? const Icon(Icons.person, size: 90)
                                          : null,
                                    ),
                                    title: Text(user.name),
                                    subtitle: Text(user.email),
                                  )));
                        });
                  })),
        floatingActionButton: Builder(
            builder: (BuildContext context) => isLoading || widget.readOnly
                ? const SizedBox()
                : FloatingActionButton(
                    heroTag: '3',
                    backgroundColor: Theme.of(context).primaryColor,
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      await widget.onSubmmitChanges(users);
                      Navigator.of(context).pop();
                      setState(() {
                        isLoading = false;
                      });
                    },
                    tooltip: AppLocalizations.of(context).translate('save'),
                    child: Icon(Icons.save_outlined,
                        color: Theme.of(context).backgroundColor))));
  }
}
