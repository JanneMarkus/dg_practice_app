import 'package:flutter/material.dart';
import 'global.dart' as global;
import 'main.dart';

// Putting Widget

class PuttingWidget extends StatelessWidget {
  const PuttingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: global.startTab,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Putting Practice"),
          toolbarHeight: 50,
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
        drawer: const NavigationDrawer(),
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

// Approach Widget

class ApproachWidget extends StatelessWidget {
  const ApproachWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: global.startTab,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Approach Practice"),
          toolbarHeight: 50,
          bottom: const TabBar(
            indicatorColor: Colors.pink,
            tabs: <Widget>[
              Tab(
                icon: Text('Setup'),
              ),
              Tab(
                icon: Text('Throw'),
              ),
            ],
          ),
        ),
        drawer: const NavigationDrawer(),
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            Center(
              child: ApproachSetup(),
            ),
            Center(
              child: ApproachCounter(),
            ),
          ],
        ),
      ),
    );
  }
}

// Settings widget

class SettingsWidget extends StatelessWidget {
  const SettingsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
          toolbarHeight: 50,
        ),
        drawer: const NavigationDrawer(),
        body: const ApplicationSetup());
  }
}
