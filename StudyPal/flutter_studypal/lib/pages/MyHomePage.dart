import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_studypal/utils/theme_provider.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Provider.of<ThemeModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Theme Switcher Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Choose a primary color:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _colorButton(context, Color.fromARGB(255, 174, 196, 250), 'Custom1'),
                _colorButton(context, Color.fromARGB(255, 124, 129, 250), 'Custom2'),
                _colorButton(context, Color.fromARGB(255, 100, 100, 250), 'Blue'), // Default blue
              ],
            ),
            SizedBox(height: 20),
            Text('Toggle Dark Mode:'),
            Switch(
              value: theme.isDarkMode,
              onChanged: (value) {
                theme.toggleDarkMode(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorButton(BuildContext context, Color color, String colorName) {
    return ElevatedButton(
      onPressed: () {
        Provider.of<ThemeModel>(context, listen: false).updatePrimaryColor(color);
      },
      style: ElevatedButton.styleFrom(backgroundColor: color),
      child: Text(colorName),
    );
  }
}
