import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'global.dart' as global;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'database_helper.dart';
import 'package:mailer/mailer.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sqflite_common_porter/sqflite_porter.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  final accentColor = Colors.pink;
  static const String _title = 'Putting App';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: _title,
        scaffoldMessengerKey: global.snackbarKey,
        home: const MainAppWidget(),
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: accentColor,
        ));
  }
}

class MainAppWidget extends StatelessWidget {
  const MainAppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: global.startTab,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: const TabBar(
            indicatorColor: Colors.pink,
            tabs: <Widget>[
              Tab(
                icon: Text('Setup'),
              ),
              Tab(
                icon: Text('Putt'),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            Center(
              child: PuttingSetup(),
            ),
            Center(
              child: PuttingCounter(),
            ),
          ],
        ),
      ),
    );
  }
}

class PuttingSetup extends StatelessWidget {
  const PuttingSetup({Key? key}) : super(key: key);

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
      GoogleAuthApi.signOut();

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
                  _StanceSelectorChip()
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
                  "Shot Type",
                  textScaleFactor: 1.25,
                )),
                _ShotTypeSelectorChip(),
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
          Column(
            children: const [
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: NotesField(),
              ),
            ],
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
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

//
// This is where the code for the Choice Chips goes
//

class _ShotTypeSelectorChip extends StatefulWidget {
  @override
  _ShotTypeSelectorChipState createState() => _ShotTypeSelectorChipState();
}

class _ShotTypeSelectorChipState extends State<_ShotTypeSelectorChip>
    with RestorationMixin {
  final RestorableInt _indexSelected = RestorableInt(global.shotType);

  @override
  String get restorationId => 'choice_chip_demo';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_indexSelected, 'choice_chip');
  }

  @override
  void dispose() {
    _indexSelected.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        children: [
          ChoiceChip(
            label: const Text("Hyzer"),
            selected: _indexSelected.value == 0,
            onSelected: (value) {
              setState(() {
                _indexSelected.value = value ? 0 : -1;
                global.shotType = 0;
              });
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text("Flat"),
            selected: _indexSelected.value == 1,
            onSelected: (value) {
              setState(() {
                _indexSelected.value = value ? 1 : -1;
                global.shotType = 1;
              });
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text("Anhyzer"),
            selected: _indexSelected.value == 2,
            onSelected: (value) {
              setState(() {
                _indexSelected.value = value ? 2 : -1;
                global.shotType = 2;
              });
            },
          ),
        ],
      ),
    );
  }
}

// Stance Selector

class _StanceSelectorChip extends StatefulWidget {
  @override
  _StanceSelectorChipState createState() => _StanceSelectorChipState();
}

class _StanceSelectorChipState extends State<_StanceSelectorChip>
    with RestorationMixin {
  final RestorableInt _indexSelected = RestorableInt(global.stance == "Normal"
      ? 0
      : (global.stance == "Straddle"
          ? 1
          : (global.stance == "Kneeling"
              ? 2
              : (global.stance == "Reaching Right" ? 3 : 4))));

  @override
  String get restorationId => 'choice_chip_demo';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_indexSelected, 'choice_chip');
  }

  @override
  void dispose() {
    _indexSelected.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        children: [
          ChoiceChip(
            label: const Text("Normal"),
            selected: _indexSelected.value == 0,
            onSelected: (value) {
              setState(() {
                _indexSelected.value = value ? 0 : -1;
                global.stance = "Normal";
              });
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text("Straddle"),
            selected: _indexSelected.value == 1,
            onSelected: (value) {
              setState(() {
                _indexSelected.value = value ? 1 : -1;
                global.stance = "Straddle";
              });
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text("Kneeling"),
            selected: _indexSelected.value == 2,
            onSelected: (value) {
              setState(() {
                _indexSelected.value = value ? 2 : -1;
                global.stance = "Kneeling";
              });
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text("Reaching Right"),
            selected: _indexSelected.value == 3,
            onSelected: (value) {
              setState(() {
                _indexSelected.value = value ? 3 : -1;
                global.stance = "Reaching Right";
              });
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text("Reaching Left"),
            selected: _indexSelected.value == 4,
            onSelected: (value) {
              setState(() {
                _indexSelected.value = value ? 4 : -1;
                global.stance = "Reaching Left";
              });
            },
          ),
        ],
      ),
    );
  }
}

//
// This is where the stackSize Slider Code goes
//

class StackSizeSliders extends StatefulWidget {
  const StackSizeSliders({Key? key}) : super(key: key);

  @override
  StackSizeSlidersState createState() => StackSizeSlidersState();
}

class StackSizeSlidersState extends State<StackSizeSliders>
    with RestorationMixin {
  final RestorableInt _continuousValue = RestorableInt(global.stackSize);

  @override
  String get restorationId => 'stackSize_slider';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_continuousValue, 'continuous_value');
  }

  @override
  void dispose() {
    _continuousValue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                child: SizedBox(
                  width: 64,
                  height: 48,
                  child: TextField(
                    textAlign: TextAlign.center,
                    onSubmitted: (value) {
                      final newValue = int.tryParse(value);
                      if (newValue != null &&
                          newValue != _continuousValue.value) {
                        setState(() {
                          _continuousValue.value =
                              newValue.clamp(0, 20).truncate();
                          global.stackSize = newValue.clamp(0, 20).toInt();
                        });
                      }
                    },
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(
                      text: _continuousValue.value.toStringAsFixed(0),
                    ),
                  ),
                ),
              ),
              Slider(
                value: _continuousValue.value.toDouble(),
                min: 0,
                max: 20,
                onChanged: (value) {
                  setState(() {
                    _continuousValue.value = value.toInt();
                    global.stackSize = value.toInt();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//
// This is where the distance slider code goes

class DistanceSliders extends StatefulWidget {
  const DistanceSliders({Key? key}) : super(key: key);

  @override
  DistanceSlidersState createState() => DistanceSlidersState();
}

class DistanceSlidersState extends State<DistanceSliders>
    with RestorationMixin {
  final RestorableInt _continuousValue = RestorableInt(global.distance);

  @override
  String get restorationId => 'distance_slider';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_continuousValue, 'continuous_value');
  }

  @override
  void dispose() {
    _continuousValue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                child: SizedBox(
                  width: 64,
                  height: 48,
                  child: TextField(
                    textAlign: TextAlign.center,
                    onSubmitted: (value) {
                      final newValue = double.tryParse(value);
                      if (newValue != null &&
                          newValue != _continuousValue.value) {
                        setState(() {
                          _continuousValue.value =
                              newValue.clamp(0, 100).truncate();
                          global.distance = newValue.clamp(0, 100).toInt();
                        });
                      }
                    },
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(
                      text: _continuousValue.value.toStringAsFixed(0),
                    ),
                  ),
                ),
              ),
              Slider(
                value: _continuousValue.value.toDouble(),
                min: 0,
                max: 100,
                onChanged: (value) {
                  setState(() {
                    _continuousValue.value = value.toInt();
                    global.distance = value.toInt();
                  });
                },
              ),
            ],
          ),
        ],
      ),
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

class CustomPageRoute extends MaterialPageRoute {
  CustomPageRoute({builder}) : super(builder: builder);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);
}

class Counter extends StatefulWidget {
  const Counter({Key? key}) : super(key: key);
  @override
  _CounterState createState() => _CounterState();
}

// add a cache feature for the makes so that when I press the back button, the previously
// selected makes is subtracted from the makes count.

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
                      DataBaseHelper.columnShotType: global.shotType,
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
                            "Logged session $i to database:\n\nYou made $currentMakes of $currentCount ${global.shotType == 0 ? "hyzer" : (global.shotType == 1 ? "flat" : "anhyzer")} throws from ${global.distance} feet."),

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
