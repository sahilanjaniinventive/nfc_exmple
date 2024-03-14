import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ndef/ndef.dart' as ndef;

void main() {
  runApp(MaterialApp(theme: ThemeData(useMaterial3: true), home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  final String _platformVersion = '';
  final NFCAvailability _availability = NFCAvailability.not_supported;
  NFCTag? _tag;
  String? _result;
  ndef.NDEFRecord _records = ndef.NDEFRecord();

  TextEditingController writeTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('NFC Example App'),
        ),
        body: Scrollbar(
            child: SingleChildScrollView(
                child: Center(
                    child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            TextFormField(
              controller: writeTextController,
              decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                  hintText: "write here"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  _records = ndef.TextRecord(text: writeTextController.text, encoding: ndef.TextEncoding.values[0], language: "en");
                  NFCTag tag = await FlutterNfcKit.poll();
                  setState(() {
                    _tag = tag;
                  });
                  await FlutterNfcKit.writeNDEFRecords([_records]);
                  Fluttertoast.showToast(msg: "Write Data Successfully");
                } catch (e) {
                  setState(() {});
                }
                await FlutterNfcKit.finish(iosAlertMessage: "Finished!");
              },
              child: const Text('write data'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  NFCTag tag = await FlutterNfcKit.poll();
                  setState(() {
                    _tag = tag;
                  });
                  await FlutterNfcKit.setIosAlertMessage("Working on it...");
                  if (tag.ndefAvailable ?? false) {
                    var ndefRecords = await FlutterNfcKit.readNDEFRecords();
                    var ndefString = '';
                    for (int i = 0; i < ndefRecords.length; i++) {
                      if (ndefRecords[i].toString().contains("text=")) {
                        ndefString = ndefRecords[i].toString().split("text=")[1];
                      }
                    }
                    // String data = ndefRecords
                    setState(() {
                      _result = ndefString;
                      print("------3--${ndefString}");
                    });
                  }
                } catch (e) {
                  setState(() {
                    // _result = 'error: $e';
                  });
                }
                await FlutterNfcKit.finish(iosAlertMessage: "Finished!");
              },
              child: const Text('Start polling'),
            ),
            const SizedBox(height: 10),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _result != null
                    ? Text(
                        'Result:$_result',
                        style: const TextStyle(fontSize: 18),
                      )
                    : const Text('')),
          ]),
        )))),
      ),
    );
  }
}
