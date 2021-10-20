import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/globals.dart';
import 'package:frontend/i18n.dart';
import 'package:frontend/main.dart';

Future<void> main() async {
  testWidgets('Basic app opening tests', (WidgetTester tester) async {
    // Initialize configuration
    SharedPreferences.setMockInitialValues({"hostname": "", "token": ""});
    await App().init();
    // Build our app and trigger a frame
    await tester.pumpWidget(
      const MaterialApp(
        home: MyHomePage(title: 'Beer with me!'),
        localizationsDelegates: [
          MyLocalizationsDelegate(),
        ],
      ),
    );

    // Check that the app title is displayed
    expect(find.text('Beer with me!'), findsOneWidget);
    await tester.pump();
    // Check that we do not display the ticket list on startup if a user token is not set
    expect(find.text("01_name"), findsNothing);
    // Enter a user token
    await tester.enterText(find.byKey(const Key("tokenField")), 'a_token');
    await tester.tap(find.text("OK"));
    await tester.pumpAndSettle();
    // Check that we display the ticket list if a user token is set
    expect(find.text("01_name"), findsOneWidget);

    // To print the widget tree :
    //debugDumpApp();
  });
}
