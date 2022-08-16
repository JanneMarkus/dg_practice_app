import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'global.dart' as global;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'database_helper.dart';
import 'package:mailer/mailer.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'nav_drawer_widgets.dart';
import 'selectors.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  final accentColor = Colors.pink;
  static const String _title = 'DG Practice App';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: _title,
        scaffoldMessengerKey: global.snackbarKey,
        home: const PuttingWidget(),
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: accentColor,
        ));
  }
}

class ApplicationSetup extends StatelessWidget {
  const ApplicationSetup({Key? key}) : super(key: key);

  // Setup Functions for sending database via email
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/databaseExport.csv');
  }

  Future<File> writeExport(List<String> databaseInfo) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(databaseInfo.toString());
  }

  Future sendEmail() async {
    try {
      GoogleAuthApi.signOut();
      //Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      //Get dbFile from path and dbName
      final dbFile = '${directory.path}/' + DataBaseHelper.dbName;
      //Have user sign in to google account
      final user = await GoogleAuthApi.signIn();
      //Check if login was successful
      if (user == null) return;

      final email = user.email;
      final auth = await user.authentication;
      final token = auth.accessToken;
      final smtpServer = gmailSaslXoauth2(email, token!);

      // This will sign the user out every time the button is pressed. Remove this line for release.
      //GoogleAuthApi.signOut();

      // Create the email that will be sent

      final message = Message()
        ..from = Address(email)
        ..recipients = [email]
        ..subject = 'Database Export - ${DateTime.now()}'
        ..text = 'Your database is attached.'
        ..attachments = [
          FileAttachment(File(dbFile))..location = Location.attachment
        ];

      await send(message, smtpServer);
      final emailSentSnackBar =
          SnackBar(content: Text("Database sent to $email."));
      global.snackbarKey.currentState?.showSnackBar(emailSentSnackBar);
    } on MailerException catch (e) {
      const emailFailedSnackBar = SnackBar(
        content: Text(
            "There was a problem sending the email. Please reload the app and try again."),
      );
      global.snackbarKey.currentState?.showSnackBar(emailFailedSnackBar);
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        TextEditingController().clear();
      },
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 20, 50, 0),
            child: ElevatedButton(
              onPressed: () {
                try {
                  sendEmail();
                } on Exception catch (e) {
                  print(e);
                }
              },
              onLongPress: () {
                const Tooltip(message: 'Send Database.db as an email');
              },
              child: const Text("Export Database"),
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                  child: Opacity(
                opacity: 0.5,
                child:
                    Text("Disc Golf Practice App Version: ${global.version}"),
              ))),
        ],
      ),
    );
  }
}

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Drawer(
          child: SingleChildScrollView(
              child: Container(
        padding: const EdgeInsets.fromLTRB(0, 75, 0, 0),
        child: Wrap(
          runSpacing: 16,
          children: [
            ListTile(
              title: const Text("Putting"),
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const PuttingWidget()));
              },
            ),
            ListTile(
                title: const Text("Approach"),
                onTap: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const ApproachWidget()));
                }),
            ListTile(
                title: const Text("Settings"),
                onTap: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const SettingsWidget()));
                }),
            // ListTile(
            //   title: const Text("Long Throws"),
            //   onTap: () {},
            // ),
            // ListTile(
            //   title: const Text("Utility Shots"),
            //   onTap: () {},
            // )
          ],
        ),
      )));
}

class PuttingSetup extends StatelessWidget {
  const PuttingSetup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        TextEditingController().clear();
      },
      child: ListView(
        children: [
          SizedBox(
            height: 250,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Center(
                      child: Text(
                    "Stance",
                    textScaleFactor: 1.25,
                  )),
                  StanceSelectorChip()
                ]),
          ),
          const Divider(),
          SizedBox(
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Center(
                    child: Text(
                  "Shot Angle",
                  textScaleFactor: 1.25,
                )),
                ShotAngleSelectorChip(),
              ],
            ),
          ),
          const Divider(),
          SizedBox(
            height: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Center(
                    child: Text(
                  "# of Putters",
                  textScaleFactor: 1.25,
                )),
                StackSizeSliders(),
              ],
            ),
          ),
          const Divider(),
          SizedBox(
            height: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Center(
                    child: Text(
                  "Distance To Basket (ft)",
                  textScaleFactor: 1.25,
                )),
                DistanceSliders(),
              ],
            ),
          ),
          const Divider(),
          SizedBox(
            height: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Center(
                    child: Text(
                  "Session Putt Goal",
                  textScaleFactor: 1.25,
                )),
                GoalSliders(),
              ],
            ),
          ),
          const Divider(),
          Column(
            children: const [
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: NotesField(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ApproachSetup extends StatelessWidget {
  const ApproachSetup({Key? key}) : super(key: key);

  // Build approach setup page

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        TextEditingController().clear();
      },
      child: ListView(
        children: [
          SizedBox(
            height: 250,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Center(
                      child: Text(
                    "Stance",
                    textScaleFactor: 1.25,
                  )),
                  StanceSelectorChip()
                ]),
          ),
          const Divider(),
          SizedBox(
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Center(
                    child: Text(
                  "Shot Angle",
                  textScaleFactor: 1.25,
                )),
                ShotAngleSelectorChip(),
              ],
            ),
          ),
          const Divider(),
          SizedBox(
            height: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Center(
                    child: Text(
                  "# of Discs",
                  textScaleFactor: 1.25,
                )),
                AppStackSizeSliders(),
              ],
            ),
          ),
          const Divider(),
          SizedBox(
            height: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Center(
                    child: Text(
                  "Distance To Basket (ft)",
                  textScaleFactor: 1.25,
                )),
                AppDistanceSliders(),
              ],
            ),
          ),
          const Divider(),
          SizedBox(
            height: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Center(
                    child: Text(
                  "Radius Of Target (ft)",
                  textScaleFactor: 1.25,
                )),
                TargetSizeSliders(),
              ],
            ),
          ),
          const Divider(),
          SizedBox(
            height: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Center(
                    child: Text(
                  "Session Throw Goal",
                  textScaleFactor: 1.25,
                )),
                AppGoalSliders(),
              ],
            ),
          ),
          const Divider(),
          Column(
            children: const [
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: NotesField(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GoogleAuthApi {
  static final _googleSignIn =
      GoogleSignIn(scopes: ['https://mail.google.com/']);

  static Future<GoogleSignInAccount?> signIn() async {
    if (await _googleSignIn.isSignedIn()) {
      return _googleSignIn.currentUser;
    } else {
      return await _googleSignIn.signIn();
    }
  }

  static Future signOut() => _googleSignIn.signOut();
}

class NotesField extends StatefulWidget {
  const NotesField({Key? key}) : super(key: key);

  @override
  State<NotesField> createState() => _NotesFieldState();
}

class _NotesFieldState extends State<NotesField> {
  TextEditingController notesController = TextEditingController();

  @override
  // ignore: must_call_super
  void initState() {
    if (global.notes != "") {
      notesController = TextEditingController(text: global.notes);
    }
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: notesController,
      onChanged: (String value) {
        global.notes = value;
      },
      decoration: const InputDecoration(hintText: "Any notes?"),
      maxLines: null,
    );
  }
}

class ShotsMade extends StatefulWidget {
  const ShotsMade({Key? key}) : super(key: key);
  @override
  State<ShotsMade> createState() => _ShotsMadeState();
}

class _ShotsMadeState extends State<ShotsMade> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(title: const Text("Made putts")),
      body: SafeArea(
        top: false,
        child: ListView.builder(
            reverse: true,
            itemBuilder: (context, int index) => SizedBox(
                height: (height) / 7,
                child: GestureDetector(
                  onTap: () => {
                    global.makes += index,
                    global.previousMake = index,
                    print(global.makes),
                    Navigator.pop(context)
                  },
                  child: Container(
                    color: Color.fromARGB(
                        (255 / global.stackSize * index).ceil(), 200, 0, 0),
                    child: Center(
                        child: Text(
                      (index).toString(),
                      textScaleFactor: 5,
                    )),
                  ),
                )),
            itemCount: global.stackSize + 1),
      ),
    );
  }
}

class AppShotsMade extends StatefulWidget {
  const AppShotsMade({Key? key}) : super(key: key);
  @override
  State<AppShotsMade> createState() => _AppShotsMadeState();
}

class _AppShotsMadeState extends State<AppShotsMade> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(title: const Text("Made throws")),
      body: SafeArea(
        top: false,
        child: ListView.builder(
            reverse: true,
            itemBuilder: (context, int index) => SizedBox(
                height: (height) / 7,
                child: GestureDetector(
                  onTap: () => {
                    global.appMakes += index,
                    global.appPreviousMake = index,
                    print(global.appMakes),
                    Navigator.pop(context)
                  },
                  child: Container(
                    color: Color.fromARGB(
                        (255 / global.appStackSize * index).ceil(), 200, 0, 0),
                    child: Center(
                        child: Text(
                      (index).toString(),
                      textScaleFactor: 5,
                    )),
                  ),
                )),
            itemCount: global.appStackSize + 1),
      ),
    );
  }
}

class CustomPageRoute extends MaterialPageRoute {
  CustomPageRoute({builder}) : super(builder: builder);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);
}

//
// This is where the putting counter code goes
//
class PuttingCounter extends StatelessWidget {
  const PuttingCounter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Counter();
  }
}

class Counter extends StatefulWidget {
  const Counter({Key? key}) : super(key: key);
  @override
  _CounterState createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  var stackSize = global.stackSize;
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Row(children: [
          GestureDetector(
              onLongPress: () {
                final makesSnackBar = SnackBar(
                    content: Text(
                        "${global.makes}/${global.count} - Accuracy: ${((global.makes / global.count) * 100).truncate()}%"));
                global.snackbarKey.currentState?.showSnackBar(makesSnackBar);
              },
              onTap: () => setState(() {
                    if (global.count - stackSize <= 0) {
                      global.makes = 0;
                      global.count = 0;
                    } else {
                      global.count = global.count - stackSize;
                      global.makes -= global.previousMake;
                    }
                    if (global.count >= global.goal) {
                      global.backgroundColor = global.green;
                    } else {
                      global.backgroundColor = Colors.transparent;
                    }
                  }),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                      height: constraints.maxHeight,
                      width: (MediaQuery.of(context).size.width / 2),
                      color: global.backgroundColor))),
          GestureDetector(
              onLongPress: () {
                final makesSnackBar = SnackBar(
                    content: Text(
                        "${global.makes}/${global.count} - Accuracy: ${(global.makes / global.count) * 100.round()}%"));
                global.snackbarKey.currentState?.showSnackBar(makesSnackBar);
              },
              onTap: () => setState(() {
                    Navigator.push(
                        context,
                        CustomPageRoute(
                            builder: (context) => const ShotsMade()));
                    global.count = global.count + stackSize;
                    if (global.count >= global.goal) {
                      global.backgroundColor = global.green;
                    } else {
                      global.backgroundColor = Colors.transparent;
                    }
                  }),
              child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                      height: constraints.maxHeight,
                      width: (MediaQuery.of(context).size.width / 2),
                      color: global.backgroundColor))),
        ]);
      }),
      Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Center(
            child: IgnorePointer(
                child: Text(
          "${global.count}",
          textScaleFactor: 10,
        ))),
        ElevatedButton(
            child: const Text(
              "Log Session",
              textScaleFactor: 2,
            ),
            style: null,
            onPressed: global.count == 0
                ? null
                : () async {
                    final currentCount = global.count;
                    final currentMakes = global.makes;
                    final currentNotes = global.notes;
                    int? i = await DataBaseHelper.instance.insert({
                      DataBaseHelper.columnName: global.name,
                      DataBaseHelper.columnDate: DateTime.now().toString(),
                      DataBaseHelper.columnThrows: global.count,
                      DataBaseHelper.columnMakes: global.makes,
                      DataBaseHelper.columnShotAngle: global.shotAngle,
                      DataBaseHelper.columnDistance: global.distance,
                      DataBaseHelper.columnStackSize: global.stackSize,
                      DataBaseHelper.columnStance: global.stance,
                      DataBaseHelper.columnNotes: global.notes,
                    });

                    setState(() {
                      global.makes = 0;
                      global.count = 0;
                      global.notes = "";
                      global.backgroundColor = Colors.transparent;
                    });
                    final snackBar = SnackBar(
                        content: Text(
                            "Logged session $i to putting table:\n\nYou made $currentMakes of $currentCount ${global.shotAngle == 0 ? "hyzer" : (global.shotAngle == 1 ? "flat" : "anhyzer")} throws from ${global.distance} feet."),

                        // Undo Session Log
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () async {
                            await DataBaseHelper.instance.delete(i);
                            setState(() {
                              global.count = currentCount;
                              global.makes = currentMakes;
                              global.notes = currentNotes;
                              if (global.count >= global.goal) {
                                global.backgroundColor = global.green;
                              } else {
                                global.backgroundColor = Colors.transparent;
                              }
                            });
                            final deleteSnackBar = SnackBar(
                              content: Text("Deleted session $i"),
                            );
                            global.snackbarKey.currentState
                                ?.showSnackBar(deleteSnackBar);
                          },
                          //
                        ));
                    global.snackbarKey.currentState?.showSnackBar(snackBar);
                  }),
      ])
    ]);
  }
}

//
// This is where the approach counter code goes
//
class ApproachCounter extends StatelessWidget {
  const ApproachCounter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ApproachCounterState();
  }
}

class ApproachCounterState extends StatefulWidget {
  const ApproachCounterState({Key? key}) : super(key: key);
  @override
  _ApproachCounterState createState() => _ApproachCounterState();
}

class _ApproachCounterState extends State<ApproachCounterState> {
  var appStackSize = global.appStackSize;
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Row(children: [
          GestureDetector(
              onLongPress: () {
                final makesSnackBar = SnackBar(
                    content: Text(
                        "${global.appMakes}/${global.appCount} - Accuracy: ${((global.appMakes / global.appCount) * 100).truncate()}%"));
                global.snackbarKey.currentState?.showSnackBar(makesSnackBar);
              },
              onTap: () => setState(() {
                    if (global.appCount - appStackSize <= 0) {
                      global.appMakes = 0;
                      global.appCount = 0;
                    } else {
                      global.appCount = global.appCount - appStackSize;
                      global.appMakes -= global.appPreviousMake;
                    }
                    if (global.appCount >= global.appGoal) {
                      global.backgroundColor = global.green;
                    } else {
                      global.backgroundColor = Colors.transparent;
                    }
                  }),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                      height: constraints.maxHeight,
                      width: (MediaQuery.of(context).size.width / 2),
                      color: global.backgroundColor))),
          GestureDetector(
              onLongPress: () {
                final makesSnackBar = SnackBar(
                    content: Text(
                        "${global.appMakes}/${global.appCount} - Accuracy: ${(global.appMakes / global.appCount) * 100.round()}%"));
                global.snackbarKey.currentState?.showSnackBar(makesSnackBar);
              },
              onTap: () => setState(() {
                    Navigator.push(
                        context,
                        CustomPageRoute(
                            builder: (context) => const AppShotsMade()));
                    global.appCount = global.appCount + appStackSize;
                    if (global.appCount >= global.appGoal) {
                      global.backgroundColor = global.green;
                    } else {
                      global.backgroundColor = Colors.transparent;
                    }
                  }),
              child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                      height: constraints.maxHeight,
                      width: (MediaQuery.of(context).size.width / 2),
                      color: global.backgroundColor))),
        ]);
      }),
      Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Center(
            child: IgnorePointer(
                child: Text(
          "${global.appCount}",
          textScaleFactor: 10,
        ))),
        ElevatedButton(
            child: const Text(
              "Log Session",
              textScaleFactor: 2,
            ),
            style: null,
            onPressed: global.appCount == 0
                ? null
                : () async {
                    final currentCount = global.appCount;
                    final currentMakes = global.appMakes;
                    final currentNotes = global.appNotes;
                    int? i = await ApproachDataBaseHelper.instance.insert({
                      ApproachDataBaseHelper.columnName: global.appName,
                      ApproachDataBaseHelper.columnDate:
                          DateTime.now().toString(),
                      ApproachDataBaseHelper.columnThrows: global.appCount,
                      ApproachDataBaseHelper.columnMakes: global.appMakes,
                      ApproachDataBaseHelper.columnShotAngle:
                          global.appShotAngle,
                      ApproachDataBaseHelper.columnDistance: global.appDistance,
                      ApproachDataBaseHelper.columnTargetSize:
                          global.appTargetSize,
                      ApproachDataBaseHelper.columnStackSize:
                          global.appStackSize,
                      ApproachDataBaseHelper.columnStance: global.appStance,
                      ApproachDataBaseHelper.columnNotes: global.appNotes,
                    });

                    setState(() {
                      global.appMakes = 0;
                      global.appCount = 0;
                      global.appNotes = "";
                      global.backgroundColor = Colors.transparent;
                    });
                    final snackBar = SnackBar(
                        content: Text(
                            "Logged session $i to approach table:\n\nYou made $currentMakes of $currentCount ${global.appShotAngle == 0 ? "hyzer" : (global.appShotAngle == 1 ? "flat" : "anhyzer")} throws from ${global.appDistance} feet."),

                        // Undo Session Log
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () async {
                            await ApproachDataBaseHelper.instance.delete(i);
                            setState(() {
                              global.appCount = currentCount;
                              global.appMakes = currentMakes;
                              global.appNotes = currentNotes;
                              if (global.appCount >= global.appGoal) {
                                global.backgroundColor = global.green;
                              } else {
                                global.backgroundColor = Colors.transparent;
                              }
                            });
                            final deleteSnackBar = SnackBar(
                              content: Text("Deleted session $i"),
                            );
                            global.snackbarKey.currentState
                                ?.showSnackBar(deleteSnackBar);
                          },
                          //
                        ));
                    global.snackbarKey.currentState?.showSnackBar(snackBar);
                  }),
      ])
    ]);
  }
}
