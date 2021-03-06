import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:simple_splashscreen/simple_splashscreen.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);
  await FlutterDownloader.initialize(debug: true);
  runApp(MyAppStart());
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false;
}

class MyAppStart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      builder: EasyLoading.init(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String pathPDF = "";
  String pathPDFTurk = "";

  // fetch PDF files
  void fetchFiles() async {
    var file1 = await fromAsset('assets/pdfFiles/evrad_AR.pdf', 'evrad_AR.pdf');
    var file2 = await fromAsset('assets/pdfFiles/evrad_TR.pdf', 'evrad_TR.pdf');

    if (this.mounted) {
      setState(() {
        // Your state change code goes here
        pathPDF = file1.path;
        pathPDFTurk = file2.path;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchFiles();
  }

  Future<File> fromAsset(String asset, String filename) async {
    // To open from assets, you can copy them to the app storage folder, and the access them "locally"
    Completer<File> completer = Completer();

    try {
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$filename");
      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Simple_splashscreen(
      context: context,
      gotoWidget: PDFScreen(
        path: pathPDF,
        pathTurk: pathPDFTurk,
      ),
      splashscreenWidget: MyApp(),
      timerInSeconds: 5,
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/splash.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: <Widget>[
          Image.asset('assets/images/evrad.png', fit: BoxFit.fill)
        ],
      ),
    );
  }
}

MaterialColor themeColor = const MaterialColor(0xFF2D45CB, const {
  50: const Color(0xFF2D45CB),
  100: const Color(0xFF2D45CB),
  200: const Color(0xFF2D45CB),
  300: const Color(0xFF2D45CB),
  400: const Color(0xFF2D45CB),
  500: const Color(0xFF2D45CB),
  600: const Color(0xFF2D45CB),
  700: const Color(0xFF2D45CB),
  800: const Color(0xFF2D45CB),
  900: const Color(0xFF2D45CB)
});

class PDFScreen extends StatefulWidget {
  final String path;
  final String pathTurk;

  PDFScreen({Key key, this.path, this.pathTurk}) : super(key: key);

  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  PDFViewController _Pdfcontroller;
  final _key = GlobalKey<ScaffoldState>();
  int pages = 0;
  int currentPage = 248;
  var currentPageName = new Text("Evrad-?? ??erife",
      style: TextStyle(fontSize: 16, color: Colors.white));
  var currentPageNumber =
      new Text("1.Sayfa", style: TextStyle(fontSize: 11, color: Colors.white));
  bool isReady = false;
  String errorMessage = '';
  double readSpeed = 1.0;
  bool _isVisible = true;
  IconData icon = Icons.play_arrow;
  Color mealColor = Colors.white;
  final AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer();
  var selectedDuration;
  UniqueKey pdfViewerKey;
  bool isplayingControl = false;
  bool pageplaying = false;
  bool iscreatedView = false;
  bool _switchLangToTurk = false;
  int totalPages;

  var pageSoundDurations = [
    {
      "startMinute": 0,
      "startSecond": 0,
      "startMilliSecond": 1,
      "endMinute": 0,
      "endSecond": 0,
      "endMilliSecond": 1
    },
    {
      "startMinute": 0,
      "startSecond": 0,
      "startMilliSecond": 1,
      "endMinute": 0,
      "endSecond": 1,
      "endMilliSecond": 1
    },
    {
      "startMinute": 0,
      "startSecond": 1,
      "startMilliSecond": 1,
      "endMinute": 0,
      "endSecond": 2,
      "endMilliSecond": 1
    },
    {
      "startMinute": 0,
      "startSecond": 2,
      "startMilliSecond": 1,
      "endMinute": 0,
      "endSecond": 55,
      "endMilliSecond": 800
    },
    {
      "startMinute": 0,
      "startSecond": 56,
      "startMilliSecond": 1,
      "endMinute": 2,
      "endSecond": 5,
      "endMilliSecond": 800
    },
    {
      "startMinute": 2,
      "startSecond": 6,
      "startMilliSecond": 1,
      "endMinute": 3,
      "endSecond": 6,
      "endMilliSecond": 30
    },
    {
      "startMinute": 3,
      "startSecond": 6,
      "startMilliSecond": 230,
      "endMinute": 4,
      "endSecond": 36,
      "endMilliSecond": 200
    },
    {
      "startMinute": 4,
      "startSecond": 36,
      "startMilliSecond": 400,
      "endMinute": 5,
      "endSecond": 57,
      "endMilliSecond": 800
    },
    {
      "startMinute": 5,
      "startSecond": 58,
      "startMilliSecond": 1,
      "endMinute": 7,
      "endSecond": 22,
      "endMilliSecond": 800
    },
    {
      "startMinute": 7,
      "startSecond": 22,
      "startMilliSecond": 850,
      "endMinute": 8,
      "endSecond": 43,
      "endMilliSecond": 800
    },
    {
      "startMinute": 8,
      "startSecond": 44,
      "startMilliSecond": 1,
      "endMinute": 10,
      "endSecond": 5,
      "endMilliSecond": 800
    },
    {
      "startMinute": 10,
      "startSecond": 06,
      "startMilliSecond": 1,
      "endMinute": 11,
      "endSecond": 8,
      "endMilliSecond": 800
    },
    {
      "startMinute": 11,
      "startSecond": 09,
      "startMilliSecond": 1,
      "endMinute": 12,
      "endSecond": 18,
      "endMilliSecond": 800
    },
    {
      "startMinute": 12,
      "startSecond": 19,
      "startMilliSecond": 1,
      "endMinute": 13,
      "endSecond": 27,
      "endMilliSecond": 800
    },
    {
      "startMinute": 13,
      "startSecond": 28,
      "startMilliSecond": 1,
      "endMinute": 14,
      "endSecond": 36,
      "endMilliSecond": 800
    },
    {
      "startMinute": 14,
      "startSecond": 37,
      "startMilliSecond": 50,
      "endMinute": 15,
      "endSecond": 53,
      "endMilliSecond": 800
    },
    {
      "startMinute": 15,
      "startSecond": 54,
      "startMilliSecond": 1,
      "endMinute": 16,
      "endSecond": 42,
      "endMilliSecond": 400
    },
    {
      "startMinute": 16,
      "startSecond": 42,
      "startMilliSecond": 600,
      "endMinute": 17,
      "endSecond": 38,
      "endMilliSecond": 800
    },
    {
      "startMinute": 17,
      "startSecond": 39,
      "startMilliSecond": 1,
      "endMinute": 18,
      "endSecond": 45,
      "endMilliSecond": 800
    },
    {
      "startMinute": 18,
      "startSecond": 46,
      "startMilliSecond": 1,
      "endMinute": 18,
      "endSecond": 48,
      "endMilliSecond": 800
    },
    {
      "startMinute": 18,
      "startSecond": 49,
      "startMilliSecond": 1,
      "endMinute": 20,
      "endSecond": 10,
      "endMilliSecond": 800
    },
    {
      "startMinute": 20,
      "startSecond": 11,
      "startMilliSecond": 999,
      "endMinute": 21,
      "endSecond": 9,
      "endMilliSecond": 800
    },
    {
      "startMinute": 21,
      "startSecond": 10,
      "startMilliSecond": 900,
      "endMinute": 22,
      "endSecond": 25,
      "endMilliSecond": 800
    },
    {
      "startMinute": 22,
      "startSecond": 26,
      "startMilliSecond": 850,
      "endMinute": 23,
      "endSecond": 38,
      "endMilliSecond": 800
    },
    {
      "startMinute": 23,
      "startSecond": 39,
      "startMilliSecond": 999,
      "endMinute": 24,
      "endSecond": 48,
      "endMilliSecond": 800
    },
    {
      "startMinute": 24,
      "startSecond": 49,
      "startMilliSecond": 1,
      "endMinute": 26,
      "endSecond": 13,
      "endMilliSecond": 800
    },
    {
      "startMinute": 26,
      "startSecond": 14,
      "startMilliSecond": 100,
      "endMinute": 27,
      "endSecond": 29,
      "endMilliSecond": 800
    },
    {
      "startMinute": 27,
      "startSecond": 30,
      "startMilliSecond": 999,
      "endMinute": 28,
      "endSecond": 10,
      "endMilliSecond": 950
    },
    {
      "startMinute": 28,
      "startSecond": 11,
      "startMilliSecond": 150,
      "endMinute": 28,
      "endSecond": 58,
      "endMilliSecond": 300
    },
    {
      "startMinute": 28,
      "startSecond": 58,
      "startMilliSecond": 500,
      "endMinute": 29,
      "endSecond": 40,
      "endMilliSecond": 650
    },
    {
      "startMinute": 29,
      "startSecond": 40,
      "startMilliSecond": 850,
      "endMinute": 30,
      "endSecond": 24,
      "endMilliSecond": 400
    },
    {
      "startMinute": 30,
      "startSecond": 24,
      "startMilliSecond": 500,
      "endMinute": 31,
      "endSecond": 32,
      "endMilliSecond": 800
    },
    {
      "startMinute": 31,
      "startSecond": 33,
      "startMilliSecond": 1,
      "endMinute": 32,
      "endSecond": 40,
      "endMilliSecond": 100
    },
    {
      "startMinute": 32,
      "startSecond": 40,
      "startMilliSecond": 300,
      "endMinute": 33,
      "endSecond": 40,
      "endMilliSecond": 850
    },
    {
      "startMinute": 33,
      "startSecond": 41,
      "startMilliSecond": 50,
      "endMinute": 34,
      "endSecond": 38,
      "endMilliSecond": 950
    },
    {
      "startMinute": 34,
      "startSecond": 39,
      "startMilliSecond": 150,
      "endMinute": 35,
      "endSecond": 36,
      "endMilliSecond": 900
    },
    {
      "startMinute": 35,
      "startSecond": 37,
      "startMilliSecond": 100,
      "endMinute": 36,
      "endSecond": 26,
      "endMilliSecond": 50
    },
    {
      "startMinute": 36,
      "startSecond": 26,
      "startMilliSecond": 250,
      "endMinute": 37,
      "endSecond": 14,
      "endMilliSecond": 300
    },
    {
      "startMinute": 37,
      "startSecond": 14,
      "startMilliSecond": 500,
      "endMinute": 38,
      "endSecond": 23,
      "endMilliSecond": 800
    },
    {
      "startMinute": 38,
      "startSecond": 24,
      "startMilliSecond": 1,
      "endMinute": 40,
      "endSecond": 11,
      "endMilliSecond": 600
    },
    {
      "startMinute": 40,
      "startSecond": 11,
      "startMilliSecond": 800,
      "endMinute": 41,
      "endSecond": 54,
      "endMilliSecond": 450
    },
    {
      "startMinute": 41,
      "startSecond": 54,
      "startMilliSecond": 650,
      "endMinute": 43,
      "endSecond": 0,
      "endMilliSecond": 300
    },
    {
      "startMinute": 43,
      "startSecond": 0,
      "startMilliSecond": 500,
      "endMinute": 43,
      "endSecond": 58,
      "endMilliSecond": 500
    },
    {
      "startMinute": 43,
      "startSecond": 58,
      "startMilliSecond": 700,
      "endMinute": 45,
      "endSecond": 9,
      "endMilliSecond": 800
    },
    {
      "startMinute": 45,
      "startSecond": 10,
      "startMilliSecond": 1,
      "endMinute": 46,
      "endSecond": 48,
      "endMilliSecond": 800
    },
    {
      "startMinute": 46,
      "startSecond": 49,
      "startMilliSecond": 1,
      "endMinute": 47,
      "endSecond": 51,
      "endMilliSecond": 800
    },
    {
      "startMinute": 47,
      "startSecond": 52,
      "startMilliSecond": 1,
      "endMinute": 48,
      "endSecond": 24,
      "endMilliSecond": 050
    },
    {
      "startMinute": 48,
      "startSecond": 24,
      "startMilliSecond": 250,
      "endMinute": 48,
      "endSecond": 27,
      "endMilliSecond": 800
    },
    {
      "startMinute": 48,
      "startSecond": 28,
      "startMilliSecond": 1,
      "endMinute": 49,
      "endSecond": 42,
      "endMilliSecond": 500
    },
    {
      "startMinute": 49,
      "startSecond": 42,
      "startMilliSecond": 700,
      "endMinute": 51,
      "endSecond": 5,
      "endMilliSecond": 800
    },
    {
      "startMinute": 51,
      "startSecond": 6,
      "startMilliSecond": 1,
      "endMinute": 52,
      "endSecond": 30,
      "endMilliSecond": 800
    },
    {
      "startMinute": 52,
      "startSecond": 31,
      "startMilliSecond": 1,
      "endMinute": 53,
      "endSecond": 57,
      "endMilliSecond": 800
    },
    {
      "startMinute": 53,
      "startSecond": 58,
      "startMilliSecond": 1,
      "endMinute": 55,
      "endSecond": 42,
      "endMilliSecond": 800
    },
    {
      "startMinute": 55,
      "startSecond": 42,
      "startMilliSecond": 1,
      "endMinute": 57,
      "endSecond": 27,
      "endMilliSecond": 450
    },
    {
      "startMinute": 57,
      "startSecond": 27,
      "startMilliSecond": 650,
      "endMinute": 59,
      "endSecond": 13,
      "endMilliSecond": 050
    },
    {
      "startMinute": 59,
      "startSecond": 13,
      "startMilliSecond": 250,
      "endMinute": 60,
      "endSecond": 12,
      "endMilliSecond": 800
    },
    {
      "startMinute": 60,
      "startSecond": 13,
      "startMilliSecond": 1,
      "endMinute": 61,
      "endSecond": 6,
      "endMilliSecond": 800
    },
    {
      "startMinute": 61,
      "startSecond": 7,
      "startMilliSecond": 1,
      "endMinute": 61,
      "endSecond": 50,
      "endMilliSecond": 800
    },
    {
      "startMinute": 61,
      "startSecond": 51,
      "startMilliSecond": 1,
      "endMinute": 62,
      "endSecond": 46,
      "endMilliSecond": 800
    },
    {
      "startMinute": 62,
      "startSecond": 47,
      "startMilliSecond": 1,
      "endMinute": 63,
      "endSecond": 30,
      "endMilliSecond": 150
    },
    {
      "startMinute": 63,
      "startSecond": 30,
      "startMilliSecond": 350,
      "endMinute": 64,
      "endSecond": 21,
      "endMilliSecond": 800
    },
    {
      "startMinute": 64,
      "startSecond": 22,
      "startMilliSecond": 1,
      "endMinute": 65,
      "endSecond": 19,
      "endMilliSecond": 800
    },
    {
      "startMinute": 65,
      "startSecond": 20,
      "startMilliSecond": 1,
      "endMinute": 66,
      "endSecond": 12,
      "endMilliSecond": 800
    },
    {
      "startMinute": 66,
      "startSecond": 13,
      "startMilliSecond": 1,
      "endMinute": 67,
      "endSecond": 15,
      "endMilliSecond": 800
    },
    {
      "startMinute": 67,
      "startSecond": 16,
      "startMilliSecond": 1,
      "endMinute": 68,
      "endSecond": 8,
      "endMilliSecond": 800
    },
    {
      "startMinute": 68,
      "startSecond": 9,
      "startMilliSecond": 1,
      "endMinute": 69,
      "endSecond": 18,
      "endMilliSecond": 450
    },
    {
      "startMinute": 69,
      "startSecond": 18,
      "startMilliSecond": 650,
      "endMinute": 71,
      "endSecond": 0,
      "endMilliSecond": 150
    },
    {
      "startMinute": 71,
      "startSecond": 0,
      "startMilliSecond": 350,
      "endMinute": 72,
      "endSecond": 4,
      "endMilliSecond": 800
    },
    {
      "startMinute": 72,
      "startSecond": 5,
      "startMilliSecond": 1,
      "endMinute": 72,
      "endSecond": 7,
      "endMilliSecond": 300
    },
    {
      "startMinute": 72,
      "startSecond": 7,
      "startMilliSecond": 500,
      "endMinute": 73,
      "endSecond": 21,
      "endMilliSecond": 900
    },
    {
      "startMinute": 73,
      "startSecond": 22,
      "startMilliSecond": 100,
      "endMinute": 75,
      "endSecond": 8,
      "endMilliSecond": 500
    },
    {
      "startMinute": 75,
      "startSecond": 8,
      "startMilliSecond": 700,
      "endMinute": 76,
      "endSecond": 33,
      "endMilliSecond": 950
    },
    {
      "startMinute": 76,
      "startSecond": 34,
      "startMilliSecond": 150,
      "endMinute": 77,
      "endSecond": 54,
      "endMilliSecond": 800
    },
    {
      "startMinute": 77,
      "startSecond": 55,
      "startMilliSecond": 1,
      "endMinute": 79,
      "endSecond": 5,
      "endMilliSecond": 350
    },
    {
      "startMinute": 79,
      "startSecond": 5,
      "startMilliSecond": 750,
      "endMinute": 80,
      "endSecond": 44,
      "endMilliSecond": 800
    },
    {
      "startMinute": 80,
      "startSecond": 45,
      "startMilliSecond": 1,
      "endMinute": 81,
      "endSecond": 55,
      "endMilliSecond": 200
    },
    {
      "startMinute": 81,
      "startSecond": 55,
      "startMilliSecond": 400,
      "endMinute": 83,
      "endSecond": 11,
      "endMilliSecond": 350
    },
    {
      "startMinute": 83,
      "startSecond": 11,
      "startMilliSecond": 550,
      "endMinute": 84,
      "endSecond": 20,
      "endMilliSecond": 300
    },
    {
      "startMinute": 84,
      "startSecond": 20,
      "startMilliSecond": 500,
      "endMinute": 85,
      "endSecond": 42,
      "endMilliSecond": 175
    },
    {
      "startMinute": 85,
      "startSecond": 42,
      "startMilliSecond": 375,
      "endMinute": 86,
      "endSecond": 46,
      "endMilliSecond": 50
    },
    {
      "startMinute": 86,
      "startSecond": 46,
      "startMilliSecond": 250,
      "endMinute": 87,
      "endSecond": 19,
      "endMilliSecond": 300
    },
    {
      "startMinute": 87,
      "startSecond": 19,
      "startMilliSecond": 500,
      "endMinute": 87,
      "endSecond": 52,
      "endMilliSecond": 700
    },
    {
      "startMinute": 87,
      "startSecond": 52,
      "startMilliSecond": 900,
      "endMinute": 88,
      "endSecond": 33,
      "endMilliSecond": 300
    },
    {
      "startMinute": 88,
      "startSecond": 33,
      "startMilliSecond": 500,
      "endMinute": 89,
      "endSecond": 26,
      "endMilliSecond": 680
    },
    {
      "startMinute": 89,
      "startSecond": 26,
      "startMilliSecond": 880,
      "endMinute": 90,
      "endSecond": 11,
      "endMilliSecond": 400
    },
    {
      "startMinute": 90,
      "startSecond": 11,
      "startMilliSecond": 600,
      "endMinute": 91,
      "endSecond": 14,
      "endMilliSecond": 800
    },
    {
      "startMinute": 91,
      "startSecond": 15,
      "startMilliSecond": 1,
      "endMinute": 92,
      "endSecond": 28,
      "endMilliSecond": 800
    },
    {
      "startMinute": 92,
      "startSecond": 29,
      "startMilliSecond": 1,
      "endMinute": 93,
      "endSecond": 10,
      "endMilliSecond": 800
    },
    {
      "startMinute": 93,
      "startSecond": 21,
      "startMilliSecond": 175,
      "endMinute": 94,
      "endSecond": 12,
      "endMilliSecond": 975
    },
    {
      "startMinute": 94,
      "startSecond": 13,
      "startMilliSecond": 175,
      "endMinute": 94,
      "endSecond": 41,
      "endMilliSecond": 975
    },
    {
      "startMinute": 94,
      "startSecond": 41,
      "startMilliSecond": 850,
      "endMinute": 95,
      "endSecond": 14,
      "endMilliSecond": 650
    },
    {
      "startMinute": 95,
      "startSecond": 15,
      "startMilliSecond": 1,
      "endMinute": 95,
      "endSecond": 47,
      "endMilliSecond": 800
    },
    {
      "startMinute": 95,
      "startSecond": 48,
      "startMilliSecond": 1,
      "endMinute": 96,
      "endSecond": 20,
      "endMilliSecond": 800
    },
    {
      "startMinute": 96,
      "startSecond": 20,
      "startMilliSecond": 500,
      "endMinute": 97,
      "endSecond": 5,
      "endMilliSecond": 300
    },
    {
      "startMinute": 97,
      "startSecond": 6,
      "startMilliSecond": 1,
      "endMinute": 97,
      "endSecond": 57,
      "endMilliSecond": 850
    },
    {
      "startMinute": 97,
      "startSecond": 58,
      "startMilliSecond": 150,
      "endMinute": 99,
      "endSecond": 38,
      "endMilliSecond": 600
    },
    {
      "startMinute": 99,
      "startSecond": 38,
      "startMilliSecond": 800,
      "endMinute": 100,
      "endSecond": 20,
      "endMilliSecond": 950
    },
    {
      "startMinute": 100,
      "startSecond": 21,
      "startMilliSecond": 150,
      "endMinute": 100,
      "endSecond": 49,
      "endMilliSecond": 800
    },
    {
      "startMinute": 100,
      "startSecond": 50,
      "startMilliSecond": 1,
      "endMinute": 100,
      "endSecond": 57,
      "endMilliSecond": 800
    },
    {
      "startMinute": 100,
      "startSecond": 58,
      "startMilliSecond": 1,
      "endMinute": 102,
      "endSecond": 31,
      "endMilliSecond": 800
    },
    {
      "startMinute": 102,
      "startSecond": 32,
      "startMilliSecond": 1,
      "endMinute": 104,
      "endSecond": 2,
      "endMilliSecond": 50
    },
    {
      "startMinute": 104,
      "startSecond": 2,
      "startMilliSecond": 250,
      "endMinute": 105,
      "endSecond": 50,
      "endMilliSecond": 50
    },
    {
      "startMinute": 105,
      "startSecond": 50,
      "startMilliSecond": 250,
      "endMinute": 107,
      "endSecond": 34,
      "endMilliSecond": 450
    },
    {
      "startMinute": 107,
      "startSecond": 34,
      "startMilliSecond": 650,
      "endMinute": 108,
      "endSecond": 53,
      "endMilliSecond": 50
    },
    {
      "startMinute": 108,
      "startSecond": 53,
      "startMilliSecond": 250,
      "endMinute": 110,
      "endSecond": 50,
      "endMilliSecond": 300
    },
    {
      "startMinute": 110,
      "startSecond": 50,
      "startMilliSecond": 500,
      "endMinute": 112,
      "endSecond": 8,
      "endMilliSecond": 50
    },
    {
      "startMinute": 112,
      "startSecond": 8,
      "startMilliSecond": 250,
      "endMinute": 113,
      "endSecond": 15,
      "endMilliSecond": 1
    },
    {
      "startMinute": 113,
      "startSecond": 15,
      "startMilliSecond": 200,
      "endMinute": 114,
      "endSecond": 8,
      "endMilliSecond": 185
    },
    {
      "startMinute": 114,
      "startSecond": 8,
      "startMilliSecond": 385,
      "endMinute": 115,
      "endSecond": 10,
      "endMilliSecond": 300
    },
    {
      "startMinute": 115,
      "startSecond": 10,
      "startMilliSecond": 500,
      "endMinute": 116,
      "endSecond": 17,
      "endMilliSecond": 840
    },
    {
      "startMinute": 116,
      "startSecond": 18,
      "startMilliSecond": 40,
      "endMinute": 117,
      "endSecond": 27,
      "endMilliSecond": 300
    },
    {
      "startMinute": 117,
      "startSecond": 27,
      "startMilliSecond": 500,
      "endMinute": 118,
      "endSecond": 20,
      "endMilliSecond": 200
    },
    {
      "startMinute": 118,
      "startSecond": 20,
      "startMilliSecond": 400,
      "endMinute": 118,
      "endSecond": 56,
      "endMilliSecond": 800
    },
    {
      "startMinute": 118,
      "startSecond": 57,
      "startMilliSecond": 1,
      "endMinute": 119,
      "endSecond": 39,
      "endMilliSecond": 800
    },
    {
      "startMinute": 119,
      "startSecond": 40,
      "startMilliSecond": 1,
      "endMinute": 121,
      "endSecond": 5,
      "endMilliSecond": 300
    },
    {
      "startMinute": 121,
      "startSecond": 5,
      "startMilliSecond": 500,
      "endMinute": 122,
      "endSecond": 15,
      "endMilliSecond": 850
    },
    {
      "startMinute": 122,
      "startSecond": 16,
      "startMilliSecond": 50,
      "endMinute": 123,
      "endSecond": 18,
      "endMilliSecond": 900
    },
    {
      "startMinute": 123,
      "startSecond": 19,
      "startMilliSecond": 100,
      "endMinute": 125,
      "endSecond": 7,
      "endMilliSecond": 50
    },
    {
      "startMinute": 125,
      "startSecond": 7,
      "startMilliSecond": 250,
      "endMinute": 126,
      "endSecond": 26,
      "endMilliSecond": 800
    },
    {
      "startMinute": 126,
      "startSecond": 27,
      "startMilliSecond": 1,
      "endMinute": 126,
      "endSecond": 28,
      "endMilliSecond": 800
    },
    {
      "startMinute": 126,
      "startSecond": 29,
      "startMilliSecond": 1,
      "endMinute": 127,
      "endSecond": 57,
      "endMilliSecond": 500
    },
    {
      "startMinute": 127,
      "startSecond": 57,
      "startMilliSecond": 700,
      "endMinute": 129,
      "endSecond": 27,
      "endMilliSecond": 300
    },
    {
      "startMinute": 129,
      "startSecond": 27,
      "startMilliSecond": 500,
      "endMinute": 130,
      "endSecond": 54,
      "endMilliSecond": 500
    },
    {
      "startMinute": 130,
      "startSecond": 54,
      "startMilliSecond": 700,
      "endMinute": 132,
      "endSecond": 4,
      "endMilliSecond": 700
    },
    {
      "startMinute": 132,
      "startSecond": 4,
      "startMilliSecond": 900,
      "endMinute": 133,
      "endSecond": 38,
      "endMilliSecond": 600
    },
    {
      "startMinute": 133,
      "startSecond": 38,
      "startMilliSecond": 800,
      "endMinute": 134,
      "endSecond": 59,
      "endMilliSecond": 650
    },
    {
      "startMinute": 134,
      "startSecond": 59,
      "startMilliSecond": 850,
      "endMinute": 135,
      "endSecond": 44,
      "endMilliSecond": 500
    },
    {
      "startMinute": 135,
      "startSecond": 44,
      "startMilliSecond": 700,
      "endMinute": 136,
      "endSecond": 47,
      "endMilliSecond": 300
    },
    {
      "startMinute": 136,
      "startSecond": 47,
      "startMilliSecond": 500,
      "endMinute": 137,
      "endSecond": 39,
      "endMilliSecond": 1
    },
    {
      "startMinute": 137,
      "startSecond": 39,
      "startMilliSecond": 200,
      "endMinute": 138,
      "endSecond": 19,
      "endMilliSecond": 1
    },
    {
      "startMinute": 138,
      "startSecond": 19,
      "startMilliSecond": 200,
      "endMinute": 139,
      "endSecond": 15,
      "endMilliSecond": 500
    },
    {
      "startMinute": 139,
      "startSecond": 15,
      "startMilliSecond": 700,
      "endMinute": 140,
      "endSecond": 9,
      "endMilliSecond": 950
    },
    {
      "startMinute": 140,
      "startSecond": 10,
      "startMilliSecond": 150,
      "endMinute": 141,
      "endSecond": 08,
      "endMilliSecond": 100
    },
    {
      "startMinute": 141,
      "startSecond": 08,
      "startMilliSecond": 300,
      "endMinute": 142,
      "endSecond": 45,
      "endMilliSecond": 50
    },
    {
      "startMinute": 142,
      "startSecond": 45,
      "startMilliSecond": 250,
      "endMinute": 143,
      "endSecond": 54,
      "endMilliSecond": 800
    },
    {
      "startMinute": 143,
      "startSecond": 55,
      "startMilliSecond": 1,
      "endMinute": 145,
      "endSecond": 12,
      "endMilliSecond": 600
    },
    {
      "startMinute": 145,
      "startSecond": 12,
      "startMilliSecond": 800,
      "endMinute": 146,
      "endSecond": 17,
      "endMilliSecond": 800
    },
    {
      "startMinute": 146,
      "startSecond": 18,
      "startMilliSecond": 1,
      "endMinute": 147,
      "endSecond": 23,
      "endMilliSecond": 300
    },
    {
      "startMinute": 147,
      "startSecond": 23,
      "startMilliSecond": 500,
      "endMinute": 148,
      "endSecond": 40,
      "endMilliSecond": 300
    },
    {
      "startMinute": 148,
      "startSecond": 40,
      "startMilliSecond": 500,
      "endMinute": 149,
      "endSecond": 44,
      "endMilliSecond": 150
    },
    {
      "startMinute": 149,
      "startSecond": 44,
      "startMilliSecond": 350,
      "endMinute": 151,
      "endSecond": 21,
      "endMilliSecond": 50
    },
    {
      "startMinute": 151,
      "startSecond": 21,
      "startMilliSecond": 250,
      "endMinute": 152,
      "endSecond": 30,
      "endMilliSecond": 200
    },
    {
      "startMinute": 152,
      "startSecond": 30,
      "startMilliSecond": 400,
      "endMinute": 152,
      "endSecond": 34,
      "endMilliSecond": 300
    },
    {
      "startMinute": 152,
      "startSecond": 34,
      "startMilliSecond": 500,
      "endMinute": 154,
      "endSecond": 01,
      "endMilliSecond": 800
    },
    {
      "startMinute": 154,
      "startSecond": 02,
      "startMilliSecond": 1,
      "endMinute": 155,
      "endSecond": 39,
      "endMilliSecond": 600
    },
    {
      "startMinute": 155,
      "startSecond": 39,
      "startMilliSecond": 800,
      "endMinute": 157,
      "endSecond": 12,
      "endMilliSecond": 800
    },
    {
      "startMinute": 157,
      "startSecond": 13,
      "startMilliSecond": 10,
      "endMinute": 158,
      "endSecond": 38,
      "endMilliSecond": 500
    },
    {
      "startMinute": 158,
      "startSecond": 38,
      "startMilliSecond": 700,
      "endMinute": 160,
      "endSecond": 06,
      "endMilliSecond": 150
    },
    {
      "startMinute": 160,
      "startSecond": 06,
      "startMilliSecond": 350,
      "endMinute": 161,
      "endSecond": 33,
      "endMilliSecond": 550
    },
    {
      "startMinute": 161,
      "startSecond": 33,
      "startMilliSecond": 750,
      "endMinute": 162,
      "endSecond": 54,
      "endMilliSecond": 800
    },
    {
      "startMinute": 162,
      "startSecond": 55,
      "startMilliSecond": 1,
      "endMinute": 164,
      "endSecond": 4,
      "endMilliSecond": 900
    },
    {
      "startMinute": 164,
      "startSecond": 5,
      "startMilliSecond": 100,
      "endMinute": 165,
      "endSecond": 16,
      "endMilliSecond": 800
    },
    {
      "startMinute": 165,
      "startSecond": 17,
      "startMilliSecond": 1,
      "endMinute": 166,
      "endSecond": 14,
      "endMilliSecond": 600
    },
    {
      "startMinute": 166,
      "startSecond": 14,
      "startMilliSecond": 800,
      "endMinute": 167,
      "endSecond": 15,
      "endMilliSecond": 500
    },
    {
      "startMinute": 167,
      "startSecond": 15,
      "startMilliSecond": 700,
      "endMinute": 168,
      "endSecond": 37,
      "endMilliSecond": 300
    },
    {
      "startMinute": 168,
      "startSecond": 37,
      "startMilliSecond": 500,
      "endMinute": 169,
      "endSecond": 44,
      "endMilliSecond": 400
    },
    {
      "startMinute": 169,
      "startSecond": 44,
      "startMilliSecond": 600,
      "endMinute": 170,
      "endSecond": 54,
      "endMilliSecond": 900
    },
    {
      "startMinute": 170,
      "startSecond": 55,
      "startMilliSecond": 100,
      "endMinute": 172,
      "endSecond": 4,
      "endMilliSecond": 500
    },
    {
      "startMinute": 172,
      "startSecond": 4,
      "startMilliSecond": 750,
      "endMinute": 173,
      "endSecond": 12,
      "endMilliSecond": 550
    },
    {
      "startMinute": 173,
      "startSecond": 12,
      "startMilliSecond": 750,
      "endMinute": 174,
      "endSecond": 25,
      "endMilliSecond": 800
    },
    {
      "startMinute": 174,
      "startSecond": 26,
      "startMilliSecond": 1,
      "endMinute": 175,
      "endSecond": 21,
      "endMilliSecond": 800
    },
    {
      "startMinute": 175,
      "startSecond": 22,
      "startMilliSecond": 1,
      "endMinute": 176,
      "endSecond": 16,
      "endMilliSecond": 800
    },
    {
      "startMinute": 176,
      "startSecond": 17,
      "startMilliSecond": 1,
      "endMinute": 177,
      "endSecond": 26,
      "endMilliSecond": 800
    },
    {
      "startMinute": 177,
      "startSecond": 27,
      "startMilliSecond": 1,
      "endMinute": 178,
      "endSecond": 51,
      "endMilliSecond": 800
    },
    {
      "startMinute": 178,
      "startSecond": 52,
      "startMilliSecond": 1,
      "endMinute": 180,
      "endSecond": 2,
      "endMilliSecond": 800
    },
    {
      "startMinute": 180,
      "startSecond": 3,
      "startMilliSecond": 1,
      "endMinute": 181,
      "endSecond": 31,
      "endMilliSecond": 800
    },
    {
      "startMinute": 181,
      "startSecond": 32,
      "startMilliSecond": 1,
      "endMinute": 182,
      "endSecond": 17,
      "endMilliSecond": 800
    },
    {
      "startMinute": 182,
      "startSecond": 18,
      "startMilliSecond": 1,
      "endMinute": 182,
      "endSecond": 20,
      "endMilliSecond": 800
    },
    {
      "startMinute": 182,
      "startSecond": 21,
      "startMilliSecond": 1,
      "endMinute": 183,
      "endSecond": 49,
      "endMilliSecond": 800
    },
    {
      "startMinute": 183,
      "startSecond": 50,
      "startMilliSecond": 300,
      "endMinute": 185,
      "endSecond": 35,
      "endMilliSecond": 400
    },
    {
      "startMinute": 185,
      "startSecond": 35,
      "startMilliSecond": 650,
      "endMinute": 187,
      "endSecond": 6,
      "endMilliSecond": 950
    },
    {
      "startMinute": 187,
      "startSecond": 7,
      "startMilliSecond": 150,
      "endMinute": 188,
      "endSecond": 44,
      "endMilliSecond": 850
    },
    {
      "startMinute": 188,
      "startSecond": 45,
      "startMilliSecond": 50,
      "endMinute": 190,
      "endSecond": 17,
      "endMilliSecond": 800
    },
    {
      "startMinute": 190,
      "startSecond": 18,
      "startMilliSecond": 1,
      "endMinute": 191,
      "endSecond": 48,
      "endMilliSecond": 200
    },
    {
      "startMinute": 191,
      "startSecond": 48,
      "startMilliSecond": 700,
      "endMinute": 193,
      "endSecond": 6,
      "endMilliSecond": 200
    },
    {
      "startMinute": 193,
      "startSecond": 6,
      "startMilliSecond": 400,
      "endMinute": 194,
      "endSecond": 49,
      "endMilliSecond": 200
    },
    {
      "startMinute": 194,
      "startSecond": 49,
      "startMilliSecond": 100,
      "endMinute": 196,
      "endSecond": 16,
      "endMilliSecond": 100
    },
    {
      "startMinute": 196,
      "startSecond": 16,
      "startMilliSecond": 350,
      "endMinute": 197,
      "endSecond": 12,
      "endMilliSecond": 300
    },
    {
      "startMinute": 197,
      "startSecond": 12,
      "startMilliSecond": 800,
      "endMinute": 198,
      "endSecond": 39,
      "endMilliSecond": 1
    },
    {
      "startMinute": 198,
      "startSecond": 39,
      "startMilliSecond": 400,
      "endMinute": 199,
      "endSecond": 41,
      "endMilliSecond": 100
    },
    {
      "startMinute": 199,
      "startSecond": 41,
      "startMilliSecond": 350,
      "endMinute": 201,
      "endSecond": 8,
      "endMilliSecond": 100
    },
    {
      "startMinute": 201,
      "startSecond": 8,
      "startMilliSecond": 300,
      "endMinute": 202,
      "endSecond": 43,
      "endMilliSecond": 300
    },
    {
      "startMinute": 202,
      "startSecond": 43,
      "startMilliSecond": 600,
      "endMinute": 203,
      "endSecond": 31,
      "endMilliSecond": 300
    },
    {
      "startMinute": 203,
      "startSecond": 31,
      "startMilliSecond": 600,
      "endMinute": 204,
      "endSecond": 15,
      "endMilliSecond": 1
    },
    {
      "startMinute": 204,
      "startSecond": 15,
      "startMilliSecond": 200,
      "endMinute": 205,
      "endSecond": 21,
      "endMilliSecond": 1
    },
    {
      "startMinute": 205,
      "startSecond": 21,
      "startMilliSecond": 200,
      "endMinute": 206,
      "endSecond": 21,
      "endMilliSecond": 900
    },
    {
      "startMinute": 206,
      "startSecond": 22,
      "startMilliSecond": 150,
      "endMinute": 207,
      "endSecond": 14,
      "endMilliSecond": 800
    },
    {
      "startMinute": 207,
      "startSecond": 21,
      "startMilliSecond": 1,
      "endMinute": 208,
      "endSecond": 14,
      "endMilliSecond": 800
    },
    {
      "startMinute": 208,
      "startSecond": 21,
      "startMilliSecond": 1,
      "endMinute": 208,
      "endSecond": 50,
      "endMilliSecond": 800
    },
    {
      "startMinute": 208,
      "startSecond": 53,
      "startMilliSecond": 600,
      "endMinute": 209,
      "endSecond": 44,
      "endMilliSecond": 800
    },
    {
      "startMinute": 209,
      "startSecond": 57,
      "startMilliSecond": 100,
      "endMinute": 211,
      "endSecond": 59,
      "endMilliSecond": 800
    },
    {
      "startMinute": 211,
      "startSecond": 2,
      "startMilliSecond": 1,
      "endMinute": 212,
      "endSecond": 51,
      "endMilliSecond": 800
    },
    {
      "startMinute": 212,
      "startSecond": 53,
      "startMilliSecond": 650,
      "endMinute": 213,
      "endSecond": 39,
      "endMilliSecond": 800
    },
    {
      "startMinute": 213,
      "startSecond": 33,
      "startMilliSecond": 1,
      "endMinute": 214,
      "endSecond": 44,
      "endMilliSecond": 1
    },
    {
      "startMinute": 214,
      "startSecond": 44,
      "startMilliSecond": 1,
      "endMinute": 214,
      "endSecond": 44,
      "endMilliSecond": 1
    },
    {
      "startMinute": 214,
      "startSecond": 44,
      "startMilliSecond": 1,
      "endMinute": 214,
      "endSecond": 44,
      "endMilliSecond": 1
    },
    {
      "startMinute": 214,
      "startSecond": 44,
      "startMilliSecond": 1,
      "endMinute": 214,
      "endSecond": 44,
      "endMilliSecond": 1
    },
    {
      "startMinute": 214,
      "startSecond": 44,
      "startMilliSecond": 1,
      "endMinute": 214,
      "endSecond": 44,
      "endMilliSecond": 1
    },
    {
      "startMinute": 214,
      "startSecond": 44,
      "startMilliSecond": 1,
      "endMinute": 214,
      "endSecond": 44,
      "endMilliSecond": 1
    },
    {
      "startMinute": 214,
      "startSecond": 44,
      "startMilliSecond": 1,
      "endMinute": 214,
      "endSecond": 44,
      "endMilliSecond": 1
    },
    {
      "startMinute": 214,
      "startSecond": 44,
      "startMilliSecond": 1,
      "endMinute": 214,
      "endSecond": 44,
      "endMilliSecond": 1
    },
    {
      "startMinute": 214,
      "startSecond": 44,
      "startMilliSecond": 1,
      "endMinute": 214,
      "endSecond": 44,
      "endMilliSecond": 1
    },
    {
      "startMinute": 214,
      "startSecond": 44,
      "startMilliSecond": 1,
      "endMinute": 214,
      "endSecond": 44,
      "endMilliSecond": 1
    },
    {
      "startMinute": 214,
      "startSecond": 44,
      "startMilliSecond": 1,
      "endMinute": 214,
      "endSecond": 44,
      "endMilliSecond": 1
    },
    {
      "startMinute": 214,
      "startSecond": 44,
      "startMilliSecond": 1,
      "endMinute": 214,
      "endSecond": 44,
      "endMilliSecond": 1
    },
    {
      "startMinute": 214,
      "startSecond": 44,
      "startMilliSecond": 1,
      "endMinute": 214,
      "endSecond": 44,
      "endMilliSecond": 1
    },
    {
      "startMinute": 214,
      "startSecond": 44,
      "startMilliSecond": 1,
      "endMinute": 214,
      "endSecond": 44,
      "endMilliSecond": 1
    },
    {
      "startMinute": 214,
      "startSecond": 33,
      "startMilliSecond": 1,
      "endMinute": 215,
      "endSecond": 29,
      "endMilliSecond": 550
    },
    {
      "startMinute": 215,
      "startSecond": 29,
      "startMilliSecond": 650,
      "endMinute": 216,
      "endSecond": 35,
      "endMilliSecond": 1
    },
    {
      "startMinute": 216,
      "startSecond": 35,
      "startMilliSecond": 1,
      "endMinute": 217,
      "endSecond": 34,
      "endMilliSecond": 1
    },
    {
      "startMinute": 217,
      "startSecond": 34,
      "startMilliSecond": 1,
      "endMinute": 218,
      "endSecond": 20,
      "endMilliSecond": 1
    },
    {
      "startMinute": 218,
      "startSecond": 20,
      "startMilliSecond": 1,
      "endMinute": 219,
      "endSecond": 18,
      "endMilliSecond": 1
    },
    {
      "startMinute": 219,
      "startSecond": 18,
      "startMilliSecond": 1,
      "endMinute": 220,
      "endSecond": 19,
      "endMilliSecond": 1
    },
    {
      "startMinute": 220,
      "startSecond": 19,
      "startMilliSecond": 1,
      "endMinute": 221,
      "endSecond": 7,
      "endMilliSecond": 1
    },
    {
      "startMinute": 221,
      "startSecond": 7,
      "startMilliSecond": 750,
      "endMinute": 225,
      "endSecond": 10,
      "endMilliSecond": 1
    },
    {
      "startMinute": 225,
      "startSecond": 10,
      "startMilliSecond": 1,
      "endMinute": 223,
      "endSecond": 10,
      "endMilliSecond": 250
    },
    {
      "startMinute": 223,
      "startSecond": 10,
      "startMilliSecond": 300,
      "endMinute": 224,
      "endSecond": 21,
      "endMilliSecond": 1
    },
    {
      "startMinute": 224,
      "startSecond": 21,
      "startMilliSecond": 58,
      "endMinute": 225,
      "endSecond": 31,
      "endMilliSecond": 1
    },
    {
      "startMinute": 225,
      "startSecond": 31,
      "startMilliSecond": 1,
      "endMinute": 226,
      "endSecond": 27,
      "endMilliSecond": 750
    },
    {
      "startMinute": 226,
      "startSecond": 27,
      "startMilliSecond": 750,
      "endMinute": 227,
      "endSecond": 23,
      "endMilliSecond": 1
    },
    {
      "startMinute": 227,
      "startSecond": 23,
      "startMilliSecond": 1,
      "endMinute": 228,
      "endSecond": 14,
      "endMilliSecond": 1
    },
    {
      "startMinute": 228,
      "startSecond": 14,
      "startMilliSecond": 1,
      "endMinute": 229,
      "endSecond": 13,
      "endMilliSecond": 1
    },
    {
      "startMinute": 229,
      "startSecond": 13,
      "startMilliSecond": 1,
      "endMinute": 230,
      "endSecond": 11,
      "endMilliSecond": 1
    },
    {
      "startMinute": 230,
      "startSecond": 11,
      "startMilliSecond": 1,
      "endMinute": 230,
      "endSecond": 54,
      "endMilliSecond": 1
    },
    {
      "startMinute": 230,
      "startSecond": 54,
      "startMilliSecond": 1,
      "endMinute": 231,
      "endSecond": 25,
      "endMilliSecond": 500
    },
    {
      "startMinute": 231,
      "startSecond": 25,
      "startMilliSecond": 500,
      "endMinute": 233,
      "endSecond": 4,
      "endMilliSecond": 1
    },
    {
      "startMinute": 233,
      "startSecond": 4,
      "startMilliSecond": 1,
      "endMinute": 234,
      "endSecond": 44,
      "endMilliSecond": 1
    },
    {
      "startMinute": 234,
      "startSecond": 44,
      "startMilliSecond": 1,
      "endMinute": 236,
      "endSecond": 33,
      "endMilliSecond": 1
    },
    {
      "startMinute": 236,
      "startSecond": 33,
      "startMilliSecond": 1,
      "endMinute": 238,
      "endSecond": 16,
      "endMilliSecond": 500
    },
    {
      "startMinute": 238,
      "startSecond": 16,
      "startMilliSecond": 500,
      "endMinute": 240,
      "endSecond": 14,
      "endMilliSecond": 1
    },
    {
      "startMinute": 240,
      "startSecond": 14,
      "startMilliSecond": 1,
      "endMinute": 242,
      "endSecond": 4,
      "endMilliSecond": 1
    },
    {
      "startMinute": 242,
      "startSecond": 4,
      "startMilliSecond": 1,
      "endMinute": 243,
      "endSecond": 46,
      "endMilliSecond": 1
    },
    {
      "startMinute": 243,
      "startSecond": 46,
      "startMilliSecond": 1,
      "endMinute": 245,
      "endSecond": 33,
      "endMilliSecond": 1
    },
    {
      "startMinute": 245,
      "startSecond": 33,
      "startMilliSecond": 1,
      "endMinute": 247,
      "endSecond": 15,
      "endMilliSecond": 1
    },
    {
      "startMinute": 247,
      "startSecond": 15,
      "startMilliSecond": 1,
      "endMinute": 249,
      "endSecond": 5,
      "endMilliSecond": 1
    },
    {
      "startMinute": 249,
      "startSecond": 5,
      "startMilliSecond": 1,
      "endMinute": 250,
      "endSecond": 58,
      "endMilliSecond": 1
    },
    {
      "startMinute": 250,
      "startSecond": 58,
      "startMilliSecond": 1,
      "endMinute": 252,
      "endSecond": 22,
      "endMilliSecond": 150
    },
    {
      "startMinute": 252,
      "startSecond": 22,
      "startMilliSecond": 150,
      "endMinute": 253,
      "endSecond": 51,
      "endMilliSecond": 1
    },
    {
      "startMinute": 253,
      "startSecond": 51,
      "startMilliSecond": 1,
      "endMinute": 255,
      "endSecond": 18,
      "endMilliSecond": 1
    },
    {
      "startMinute": 255,
      "startSecond": 18,
      "startMilliSecond": 1,
      "endMinute": 256,
      "endSecond": 43,
      "endMilliSecond": 1
    },
    {
      "startMinute": 256,
      "startSecond": 43,
      "startMilliSecond": 1,
      "endMinute": 258,
      "endSecond": 10,
      "endMilliSecond": 1
    },
    {
      "startMinute": 258,
      "startSecond": 10,
      "startMilliSecond": 1,
      "endMinute": 259,
      "endSecond": 36,
      "endMilliSecond": 1
    },
    {
      "startMinute": 259,
      "startSecond": 36,
      "startMilliSecond": 1,
      "endMinute": 261,
      "endSecond": 3,
      "endMilliSecond": 1
    },
    {
      "startMinute": 261,
      "startSecond": 3,
      "startMilliSecond": 1,
      "endMinute": 262,
      "endSecond": 7,
      "endMilliSecond": 1
    },
    {
      "startMinute": 262,
      "startSecond": 7,
      "startMilliSecond": 1,
      "endMinute": 263,
      "endSecond": 29,
      "endMilliSecond": 1
    },
    {
      "startMinute": 263,
      "startSecond": 29,
      "startMilliSecond": 1,
      "endMinute": 264,
      "endSecond": 55,
      "endMilliSecond": 1
    },
    {
      "startMinute": 264,
      "startSecond": 55,
      "startMilliSecond": 1,
      "endMinute": 265,
      "endSecond": 27,
      "endMilliSecond": 1
    },
    {
      "startMinute": 265,
      "startSecond": 27,
      "startMilliSecond": 1,
      "endMinute": 266,
      "endSecond": 49,
      "endMilliSecond": 1
    },
    {
      "startMinute": 266,
      "startSecond": 49,
      "startMilliSecond": 1,
      "endMinute": 268,
      "endSecond": 12,
      "endMilliSecond": 1
    }
  ];

  var pageNames = [
    "Evrad-?? ??erife",
    "G??nl??k Evr??d",
    "Had??si ??erifler",
    "Tilavet Duas??",
    "??yetler",
    "Y??sin-i ??erif",
    "Y??sin-i ??erif",
    "Y??sin-i ??erif",
    "Y??sin-i ??erif",
    "Y??sin-i ??erif",
    "Y??sin-i ??erif",
    "Salat-?? Tefriciye",
    "??sti??far",
    "??sti??far Dua Ve Tesbihler",
    "Esm????'l H??sn??",
    "Esm????'l H??sn??",
    "Esm????'l H??sn??",
    "Gece Ve Sabah Okunan Dua",
    "Gece Ve Sabah Okunan Dua",
    "Cuma Evr??d??", //19
    "Hamd ??yetleri",
    "Hamd ??yetleri",
    "Hamd ??yetleri",
    "Hamd ??yetleri",
    "Hamd ??yetleri",
    "Hamd ??yetleri",
    "Hamd ??yetleri",
    "????k??r Hizbi",
    "????k??r Hizbi",
    "????k??r Hizbi",
    "????k??r Hizbi",
    "????k??r Hizbi",
    "Hamd Hakk??nda Hadis-i ??erifler",
    "Hamd Hakk??nda Hadis-i ??erifler",
    "Hamd Hakk??nda Hadis-i ??erifler",
    "Abd??lkadir Geyl??n?? Hz. Evr??d??",
    "Abd??lkadir Geyl??n?? Hz. Evr??d??",
    "Abd??lkadir Geyl??n?? Hz. Evr??d??",
    "Abd??lkadir Geyl??n?? Hz. Evr??d??",
    "Hz.Muhammed (s.a.v)'in ??simleri",
    "Hz.Muhammed (s.a.v)'in ??simleri",
    "Ebubekir Es-S??dd??k(R.A.)'??n Kas??desi",
    "Ebubekir Es-S??dd??k(R.A.)'??n Kas??desi",
    "K??side-i B??rde",
    "K??side-i B??rde",
    "Cuma G??n?? Du??s??",
    "Cuma G??n?? Du??s??",
    "Cumartesi Evr??d??", //47
    "??sti??far ??yetleri",
    "??sti??far ??yetleri",
    "??sti??far ??yetleri",
    "??sti??far ??yetleri",
    "??sti??far ??yetleri",
    "??sti??far ??yetleri",
    "??sti??far ??yetleri",
    "Hz. Ukk????e(R.A)'??n Hizbi",
    "Hz. Ukk????e(R.A)'??n Hizbi",
    "Mevelan Sal??vat-?? ??erifeleri",
    "Mevelan Sal??vat-?? ??erifeleri",
    "Ey Allah Du??s??",
    "Ey Allah Du??s??",
    "Ey Allah Du??s??",
    "Ash??b-?? Kir??m'??n Du??s??",
    "Ash??b-?? Kir??m'??n Du??s??",
    "Ash??b-?? Kir??m'??n Du??s??",
    "K??side-i B??rde",
    "K??side-i B??rde",
    "Cumartesi G??n?? Du??s??",
    "Pazar Evr??d??", //68
    "Tesbih ??yetleri",
    "Tesbih ??yetleri",
    "Tesbih ??yetleri",
    "Tesbih ??yetleri",
    "Tesbih ??yetleri",
    "Tesbih ??yetleri",
    "Tesbih ??yetleri",
    "Tesbih ??yetleri",
    "Tesbih ??yetleri",
    "Tesbih ??yetleri",
    "Tesb??hatlar",
    "Tesb??hatlar",
    "Tesb??hatlar",
    "Tesb??hatlar",
    "Tesb??hatlar",
    "Tesb??hatlar",
    "Tesb??hatlar",
    "Tesb??hatlar",
    "Tesb??hatlar",
    "Tesb??hatlar",
    "??sm-i ??zam??'?? A????klayan Du??",
    "??sm-i ??zam??'?? A????klayan Du??",
    "??sm-i ??zam??'?? A????klayan Du??",
    "??sm-i ??zam??'?? A????klayan Du??",
    "??sm-i ??zam??'?? A????klayan Du??",
    "K??side-i B??rde",
    "K??side-i B??rde",
    "Pazar G??n?? Du??s??",
    "Pazar G??n?? Du??s??",
    "Pazartesi Evr??d??", //98
    "Tevekk??l ??yetleri",
    "Tevekk??l ??yetleri",
    "Tevekk??l ??yetleri",
    "Tevekk??l ??yetleri",
    "Tevekk??l ??yetleri",
    "Tevekk??l ??yetleri",
    "H??fz ??yetlerinin Hizbi",
    "H??fz ??yetlerinin Hizbi",
    "H??fz ??yetlerinin Hizbi",
    "H??fz ??yetlerinin Hizbi",
    "H??fz ??yetlerinin Hizbi",
    "H??fz ??yetlerinin Hizbi",
    "Hasbiyallah Du??lar??",
    "Hasbiyallah Du??lar??",
    "Korunma Du??lar??",
    "Korunma Du??lar??",
    "Korunma Du??lar??",
    "K??side-i B??rde",
    "K??side-i B??rde",
    "Pazartesi G??n?? Du??s??",
    "Sal?? Evr??d??", //119
    "Sel??m ??yetleri",
    "Sel??m ??yetleri",
    "Sel??m ??yetleri",
    "Sel??m ??yetleri",
    "Sel??m ??yetleri",
    "??ifa ??yetleri",
    "??sm-i ??'zam Du??s??",
    "??sm-i ??'zam Du??s??",
    "Besmele-i ??er??fe Du??s??",
    "Ey Allah'??m Du??s??",
    "Veys El-Kar??ni(K.S.)'n??n Du??s??'",
    "G??zel Son Ve ??m??n Du??s??",
    "H??sn-?? H??time Ve ??m??n Du??s?? ",
    "Abd??lk??dir Geyl??ni Hz.'nin Salav??t??",
    "Abd??lk??dir Geyl??ni Hz.'nin Salav??t??",
    "Abd??lk??dir Geyl??ni Hz.'nin Salav??t??",
    "Abd??lk??dir Geyl??ni Hz.'nin Salav??t??",
    "Abd??lk??dir Geyl??ni Hz.'nin Salav??t??",
    "N??r Du??s??",
    "K??side-i B??rde",
    "K??side-i B??rde",
    "Sal?? G??n?? Du??s??",
    "??ar??amba Evr??d??", //142
    "Tehlil ??yetleri",
    "Tehlil ??yetleri",
    "Tehlil ??yetleri",
    "Tehlil ??yetleri",
    "Tehlil ??yetleri",
    "Tehlil ??yetleri",
    "????hab??dd??n(K.SS)'??n Evr??d??",
    "????hab??dd??n(K.SS)'??n Evr??d??",
    "????hab??dd??n(K.SS)'??n Evr??d??",
    "????hab??dd??n(K.SS)'??n Evr??d??",
    "H??z??r Aleyhissel??m'??n Virdi",
    "H??z??r Aleyhissel??m'??n Virdi",
    "B??y??k Vird",
    "B??y??k Vird",
    "B??y??k Vird",
    "B??y??k Vird",
    "Esm??ullah Du??s?? Virdi",
    "Esm??ullah Du??s?? Virdi",
    "Esm??ullah Du??s?? Virdi",
    "Esm??ullah Du??s?? Virdi",
    "??sm-i Cel??l Du??s??",
    "K??side-i B??rde",
    "K??side-i B??rde",
    "??ar??amba G??n?? Du??s??",
    "Per??embe Evr??d??", //167
    "Du?? ??yetleri",
    "Du?? ??yetleri",
    "Du?? ??yetleri",
    "Du?? ??yetleri",
    "Du?? ??yetleri",
    "Du?? ??yetleri",
    "Du?? ??yetleri",
    "Du?? ??yetleri",
    "Du?? ??yetleri",
    "Du?? ??yetleri",
    "Du?? ??yetleri",
    "Du?? ??yetleri",
    "Du?? ??yetleri",
    "Du?? ??yetleri",
    "Du?? ??yetleri",
    "Peygamber(S.A.V.)'in Du??s??'",
    "??dem Aleyhissel??m'??n Du??s??",
    "??dem Aleyhissel??m'??n Du??s??",
    "Hz. Ebu Bekir S??dd??k(R.A.)'??n Du??s??'",
    "Hz. Ebu Bekir S??dd??k(R.A.)'??n Du??s??",
    "Sahabe-i G??zin'in Du??lar??",
    "Sahabe-i G??zin'in Du??lar??",
    "K??side-i B??rde",
    "K??side-i B??rde",
    "Per??embe G??n?? Du??s??",
    "Per??embe G??n?? Du??s??", //193
    "Her ??eyin ??ifas?? vard??r",
    "Her G??n??n Tesbihi",
    "Secde ??yetleri",
    "Secde ??yetleri",
    "Secde ??yetleri",
    "M??sl??man??n Bir G??n??",
    "M??sl??man??n Bir G??n??",
    "M??sl??man??n Bir G??n??",
    "M??sl??man??n Bir G??n??",
    "M??sl??man??n Bir G??n??",
    "M??sl??man??n Bir G??n??",
    "M??sl??man??n Bir G??n??",
    "M??sl??man??n Bir G??n??", //206
    "Tehlil Hatmi Du??s??",
    "Tehlil Hatmi Du??s??",
    "Tehlil Hatmi Du??s??",
    "Tehlil Hatmi Du??s??",
    "Hatm-i H??ceg??n Du??s??",
    "Hatm-i H??ceg??n Du??s??",
    "Hatm-i H??ceg??n Du??s??",
    "Hatm-i H??ceg??n Du??s??",
    "Hatm-i H??ceg??n Du??s??",
    "Hatm-i H??ceg??n Du??s??",
    "Hatm-i H??ceg??n Du??s??",
    "Hatm-i H??ceg??n Du??s??",
    "Hatm-i H??ceg??n Du??s??",
    "Hatm-i H??ceg??n Du??s??",
    "Hatm-i H??ceg??n Du??s??",
    "Hatm-i H??ceg??n Du??s??",
    "Hatm-i H??ceg??n Du??s??",
    "Kehf Suresi",
    "Kehf Suresi",
    "Kehf Suresi",
    "Kehf Suresi",
    "Kehf Suresi",
    "Kehf Suresi",
    "Kehf Suresi",
    "Kehf Suresi",
    "Kehf Suresi",
    "Kehf Suresi",
    "Kehf Suresi",
    "Kehf Suresi",
    "Fetih Suresi",
    "Fetih Suresi",
    "Fetih Suresi",
    "Fetih Suresi",
    "V??k??a Suresi",
    "V??k??a Suresi",
    "V??k??a Suresi",
    "V??k??a Suresi",
    "M??lk Suresi",
    "M??lk Suresi",
    "M??lk Suresi",
    "Nebe Suresi",
    "Nebe Suresi"
  ];

  void getFilePath() async {
    _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';
    soundfilePath = File(_localPath + '/evrad.mp3');
    hasSoundfilePath = await soundfilePath.exists();
    print('_localPath--------------------------------------------');
    print(_localPath);
  }

Future<Null> _prepare() async {
  _permissionReady = await _checkPermission();
}

  @override
  void initState() {
    getFilePath();
    super.initState();
    _prepare();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // didChangeMetrics rebuilds the PDF viewer when the device is rotated, by assigning it a new unique key
  @override
  void didChangeMetrics() {
    if (Platform.isAndroid) {
      Future.delayed(Duration(milliseconds: 100), () {
        setState(() => pdfViewerKey = UniqueKey());
      });
    }
  }

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences localStorage;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        setbookmarkNumber();
        break;
      case AppLifecycleState.resumed:
        print('resumed state');
        break;
      case AppLifecycleState.inactive:
        print('inactive state');
        break;
      case AppLifecycleState.detached:
        print('detached state');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    Orientation orien = MediaQuery.of(context).orientation;
    bool screen = orien == Orientation.portrait ? true : false;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _key,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: !_isVisible
            ? Stack(
                children: <Widget>[
                  PDFView(
                    key: pdfViewerKey,
                    filePath: _switchLangToTurk ? widget.pathTurk : widget.path,
                    enableSwipe: true,
                    swipeHorizontal: true,
                    autoSpacing: true,
                    pageFling: true,
                    defaultPage: currentPage,
                    fitPolicy: screen ? FitPolicy.BOTH : FitPolicy.WIDTH,
                    onRender: (_pages) {
                      setState(() {
                        pages = _pages;
                        isReady = true;
                        if (hasSoundfilePath) {
                          _assetsAudioPlayer.open(
                              Audio.file(_localPath + '/evrad.mp3'),
                              showNotification: true,
                              autoStart: false);
                          _assetsAudioPlayer.currentPosition.listen((data) {
                            print(selectedDuration['endMinute'].toString() +
                                ":" +
                                selectedDuration['endSecond'].toString() +
                                "---" +
                                data.inMinutes.toString() +
                                ":" +
                                (data.inSeconds >= 60
                                        ? data.inSeconds % 60
                                        : data.inSeconds)
                                    .toString());
                            if (data.inMinutes.toString() ==
                                    selectedDuration['endMinute'].toString() &&
                                (data.inSeconds >= 60
                                            ? data.inSeconds % 60
                                            : data.inSeconds)
                                        .toString() ==
                                    selectedDuration['endSecond'].toString()) {
                              print("sonraki sayfa");
                              isplayingControl = true;
                              _Pdfcontroller.setPage(currentPage - 1);
                              Future.delayed(
                                  Duration(milliseconds: 750), () {});
                            }
                          });
                        }
                      });
                    },
                    onError: (error) {
                      print("icon see error");
                      print(error.toString());
                      setState(() {
                        errorMessage = error.toString();
                      });
                      print(error.toString());
                    },
                    onPageError: (page, error) {
                      print("icon see error");
                      print(error.toString());
                      setState(() {
                        errorMessage = '$page: ${error.toString()}';
                      });
                      print('$page: ${error.toString()}');
                    },
                    onViewCreated: (_controller) {
                      _Pdfcontroller = _controller;
                      iscreatedView = true;
                      if (currentPage != null) _controller.setPage(currentPage);
                    },
                    onPageChanged: (int page, int total) {
                      print('page change: $page/$total');
                      setState(() {
                        pages = page;
                        isReady = true;
                        currentPageName = new Text(
                            pageNames.elementAt(248 - page),
                            style:
                                TextStyle(fontSize: 16, color: Colors.white));
                        int pageNumber = 248 - page;
                        currentPageNumber = new Text("$pageNumber. Sayfa",
                            style:
                                TextStyle(fontSize: 11, color: Colors.white));
                        currentPage = page;

                        if (iscreatedView == false) {
                          pageplaying = false;
                          if (isplayingControl == false) {
                            icon = Icons.play_arrow;
                            _assetsAudioPlayer.pause();
                          }
                          selectedDuration =
                              pageSoundDurations.elementAt(248 - currentPage);
                          isplayingControl = false;
                        }

                        totalPages = total;
                        iscreatedView = false;
                      });
                    },
                  ),
                  Positioned.fill(child: GestureDetector(
                    onDoubleTap: () {
                      setState(() {
                        _isVisible = !_isVisible;
                      });
                    },
                  ))
                ],
              )
            : Column(
                children: <Widget>[
                  _isVisible
                      ? Container(
                          color: themeColor,
                          width: MediaQuery.of(context).size.width,
                          height: 60,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 2,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.menu,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    _key.currentState.openDrawer();
                                  },
                                ),
                              ),
                              Expanded(
                                flex: 6,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Spacer(),
                                    currentPageName,
                                    currentPageNumber,
                                    Spacer(),
                                  ],
                                ),
                              ),
                              Expanded(
                                  flex: 2,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.details,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      _key.currentState.openEndDrawer();
                                    },
                                  )),
                            ],
                          ),
                        )
                      : Container(),
                  Expanded(
                    child: Stack(
                      children: <Widget>[
                        PDFView(
                          key: pdfViewerKey,
                          filePath:
                              _switchLangToTurk ? widget.pathTurk : widget.path,
                          enableSwipe: true,
                          swipeHorizontal: true,
                          autoSpacing: true,
                          pageFling: true,
                          defaultPage: currentPage,
                          fitPolicy: screen ? FitPolicy.BOTH : FitPolicy.WIDTH,
                          onRender: (_pages) {
                            setState(() {
                              pages = _pages;
                              isReady = true;
                              if (hasSoundfilePath) {
                                _assetsAudioPlayer.open(
                                    Audio.file(_localPath + '/evrad.mp3'),
                                    showNotification: true,
                                    autoStart: false);
                                _assetsAudioPlayer.currentPosition
                                    .listen((data) {
                                  print(selectedDuration['endMinute']
                                          .toString() +
                                      ":" +
                                      selectedDuration['endSecond'].toString() +
                                      "---" +
                                      data.inMinutes.toString() +
                                      ":" +
                                      (data.inSeconds >= 60
                                              ? data.inSeconds % 60
                                              : data.inSeconds)
                                          .toString());
                                  if (data.inMinutes.toString() ==
                                          selectedDuration['endMinute']
                                              .toString() &&
                                      (data.inSeconds >= 60
                                                  ? data.inSeconds % 60
                                                  : data.inSeconds)
                                              .toString() ==
                                          selectedDuration['endSecond']
                                              .toString()) {
                                    print("sonraki sayfa");
                                    isplayingControl = true;
                                    _Pdfcontroller.setPage(currentPage - 1);
                                    Future.delayed(
                                        Duration(milliseconds: 750), () {});
                                  }
                                });
                              }
                            });
                          },
                          onError: (error) {
                            print("icon see error");
                            print(error.toString());
                            setState(() {
                              errorMessage = error.toString();
                            });
                            print(error.toString());
                          },
                          onPageError: (page, error) {
                            print("icon see error");
                            print(error.toString());
                            setState(() {
                              errorMessage = '$page: ${error.toString()}';
                            });
                            print('$page: ${error.toString()}');
                          },
                          onViewCreated: (_controller) {
                            _Pdfcontroller = _controller;
                            iscreatedView = true;
                            if (currentPage != null)
                              _controller.setPage(currentPage);
                          },
                          onPageChanged: (int page, int total) {
                            print('page change: $page/$total');
                            setState(() {
                              pages = page;
                              isReady = true;
                              currentPageName = new Text(
                                  pageNames.elementAt(248 - page),
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white));
                              int pageNumber = 248 - page;
                              currentPageNumber = new Text("$pageNumber. Sayfa",
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.white));
                              currentPage = page;

                              if (iscreatedView == false) {
                                pageplaying = false;
                                if (isplayingControl == false) {
                                  icon = Icons.play_arrow;
                                  _assetsAudioPlayer.pause();
                                }
                                selectedDuration = pageSoundDurations
                                    .elementAt(248 - currentPage);
                                isplayingControl = false;
                              }

                              totalPages = total;
                              iscreatedView = false;
                            });
                          },
                        ),
                        errorMessage.isEmpty
                            ? !isReady
                                ? Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : Container()
                            : Center(
                                child: Text(
                                  errorMessage,
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                        Positioned(
                            right: 0,
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onDoubleTap: () {
                                setState(() {
                                  _isVisible = !_isVisible;
                                });
                              },
                            ))
                      ],
                    ),
                  ),
                ],
              ),
      ),
      drawer: Container(
        width: 225,
        child: Drawer(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/nav_background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                SizedBox(
                  height: 145,
                  child: DrawerHeader(
                    child: Container(),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/wallpaper.jpg"),
                          fit: BoxFit.cover),
                      color: Color(0xFF2D45CB),
                    ),
                  ),
                ),
                ListTile(
                  onTap: () {
                    getbookmarkNumber().then((value) {
                      _Pdfcontroller.setPage(value);
                      Navigator.of(context).pop();
                    });
                  },
                  leading: Icon(
                    Icons.bookmark_border,
                    color: Color(0xFF2E44CB),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0.0,
                    horizontal: 16.0,
                  ),
                  dense: true,
                  title: Text(
                    'Ayra??',
                    style: TextStyle(color: Color(0xFF223598)),
                  ),
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context).pop();
                    print("tapping");
                    showDialog(
                        context: context,
                        builder: (context) {
                          return DynamicDialog(_Pdfcontroller);
                        });
                  },
                  leading: Icon(
                    Icons.favorite_border,
                    color: Color(0xFF2E44CB),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0.0,
                    horizontal: 16.0,
                  ),
                  dense: true,
                  title: Text(
                    'Favoriler',
                    style: TextStyle(color: Color(0xFF223598)),
                  ),
                ),
                ListTile(
                  onTap: () {
                    currentPage = 247;
                    _Pdfcontroller.setPage(247);
                    Navigator.of(context).pop();
                  },
                  leading: Icon(
                    Icons.graphic_eq,
                    color: Color(0xFF2E44CB),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0.0,
                    horizontal: 16.0,
                  ),
                  dense: true,
                  title: Text(
                    'G??nl??k Evrad',
                    style: TextStyle(color: Color(0xFF223598)),
                  ),
                ),
                ListTile(
                  onTap: () {
                    currentPage = 229;
                    _Pdfcontroller.setPage(229);
                    Navigator.of(context).pop();
                  },
                  leading: Icon(
                    Icons.graphic_eq,
                    color: Color(0xFF2E44CB),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0.0,
                    horizontal: 16.0,
                  ),
                  dense: true,
                  title: Text(
                    'Cuma Evrad??',
                    style: TextStyle(color: Color(0xFF223598)),
                  ),
                ),
                ListTile(
                  onTap: () {
                    currentPage = 201;
                    _Pdfcontroller.setPage(201);
                    Navigator.of(context).pop();
                  },
                  leading: Icon(
                    Icons.graphic_eq,
                    color: Color(0xFF2E44CB),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0.0,
                    horizontal: 16.0,
                  ),
                  dense: true,
                  title: Text(
                    'Cumartesi Evrad??',
                    style: TextStyle(color: Color(0xFF223598)),
                  ),
                ),
                ListTile(
                  onTap: () {
                    currentPage = 180;
                    _Pdfcontroller.setPage(180);
                    Navigator.of(context).pop();
                  },
                  leading: Icon(
                    Icons.graphic_eq,
                    color: Color(0xFF2E44CB),
                  ),
                  title: Text(
                    'Pazar Evrad??',
                    style: TextStyle(color: Color(0xFF223598)),
                  ),
                ),
                ListTile(
                  onTap: () {
                    currentPage = 150;
                    _Pdfcontroller.setPage(150);
                    Navigator.of(context).pop();
                  },
                  leading: Icon(
                    Icons.graphic_eq,
                    color: Color(0xFF2E44CB),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0.0,
                    horizontal: 16.0,
                  ),
                  dense: true,
                  title: Text(
                    'Pazartesi Evrad??',
                    style: TextStyle(color: Color(0xFF223598)),
                  ),
                ),
                ListTile(
                  onTap: () {
                    currentPage = 129;
                    _Pdfcontroller.setPage(129);
                    Navigator.of(context).pop();
                  },
                  leading: Icon(
                    Icons.graphic_eq,
                    color: Color(0xFF2E44CB),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0.0,
                    horizontal: 16.0,
                  ),
                  dense: true,
                  title: Text(
                    'Sal?? Evrad??',
                    style: TextStyle(color: Color(0xFF223598)),
                  ),
                ),
                ListTile(
                  onTap: () {
                    currentPage = 106;
                    _Pdfcontroller.setPage(106);
                    Navigator.of(context).pop();
                  },
                  leading: Icon(
                    Icons.graphic_eq,
                    color: Color(0xFF2E44CB),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0.0,
                    horizontal: 16.0,
                  ),
                  dense: true,
                  title: Text(
                    '??ar??amba Evrad??',
                    style: TextStyle(color: Color(0xFF223598)),
                  ),
                ),
                ListTile(
                  onTap: () {
                    currentPage = 81;
                    _Pdfcontroller.setPage(81);
                    Navigator.of(context).pop();
                  },
                  leading: Icon(
                    Icons.graphic_eq,
                    color: Color(0xFF2E44CB),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0.0,
                    horizontal: 16.0,
                  ),
                  dense: true,
                  title: Text(
                    'Per??embe Evrad??',
                    style: TextStyle(color: Color(0xFF223598)),
                  ),
                ),
                Divider(
                  height: 20,
                  thickness: 0.6,
                  indent: 2,
                  color: Color(0xFF93A0F5),
                  endIndent: 2,
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context).pop();
                    showDialog(
                        context: context,
                        builder: (context) {
                          return MuellifDialog(_Pdfcontroller);
                        });
                  },
                  leading: Icon(
                    Icons.import_contacts,
                    color: Color(0xFF2E44CB),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0.0,
                    horizontal: 16.0,
                  ),
                  dense: true,
                  title: Text(
                    'M??ellif',
                    style: TextStyle(color: Color(0xFF223598)),
                  ),
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context).pop();
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AboutUsDialog(_Pdfcontroller);
                        });
                  },
                  leading: Icon(
                    Icons.info_outline,
                    color: Color(0xFF2E44CB),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0.0,
                    horizontal: 16.0,
                  ),
                  dense: true,
                  title: Text(
                    'Hakk??nda',
                    style: TextStyle(color: Color(0xFF223598)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      endDrawer: Container(
        width: 215,
        child: Drawer(
          child: Container(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                ListTile(
                  onTap: () {
                    currentPage = 243;
                    _Pdfcontroller.setPage(243);
                    Navigator.of(context).pop();
                  },
                  leading: Icon(
                    Icons.graphic_eq,
                    color: Color(0xFF2E44CB),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0.0,
                    horizontal: 16.0,
                  ),
                  dense: true,
                  title: Text(
                    'Yasin-i ??erife',
                    style: TextStyle(color: Color(0xFF223598)),
                  ),
                ),
                ListTile(
                  onTap: () {
                    currentPage = 234;
                    _Pdfcontroller.setPage(234);
                    Navigator.of(context).pop();
                  },
                  leading: Icon(
                    Icons.graphic_eq,
                    color: Color(0xFF2E44CB),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0.0,
                    horizontal: 16.0,
                  ),
                  dense: true,
                  title: Text(
                    "Esm????'l H??sn??",
                    style: TextStyle(color: Color(0xFF223598)),
                  ),
                ),
                ListTile(
                  onTap: () {
                    currentPage = 209;
                    _Pdfcontroller.setPage(209);
                    Navigator.of(context).pop();
                  },
                  leading: Icon(
                    Icons.graphic_eq,
                    color: Color(0xFF2E44CB),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0.0,
                    horizontal: 16.0,
                  ),
                  dense: true,
                  title: Text(
                    "Esma'??n Nebi",
                    style: TextStyle(color: Color(0xFF223598)),
                  ),
                ),
                ListTile(
                  onTap: () {
                    currentPage = 143;
                    _Pdfcontroller.setPage(143);
                    Navigator.of(context).pop();
                  },
                  leading: Icon(
                    Icons.graphic_eq,
                    color: Color(0xFF2E44CB),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0.0,
                    horizontal: 16.0,
                  ),
                  dense: true,
                  title: Text(
                    "H??fz ??yetleri",
                    style: TextStyle(color: Color(0xFF223598)),
                  ),
                ),
                ListTile(
                  onTap: () {
                    currentPage = 53;
                    _Pdfcontroller.setPage(53);
                    Navigator.of(context).pop();
                  },
                  leading: Icon(
                    Icons.graphic_eq,
                    color: Color(0xFF2E44CB),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0.0,
                    horizontal: 16.0,
                  ),
                  dense: true,
                  title: Text(
                    "G??nl??k Tesbihat",
                    style: TextStyle(color: Color(0xFF223598)),
                  ),
                ),
                ListTile(
                  onTap: () {
                    currentPage = 49;
                    _Pdfcontroller.setPage(49);
                    Navigator.of(context).pop();
                  },
                  leading: Icon(
                    Icons.graphic_eq,
                    color: Color(0xFF2E44CB),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0.0,
                    horizontal: 16.0,
                  ),
                  dense: true,
                  title: Text(
                    "Teberr??k Dersi",
                    style: TextStyle(color: Color(0xFF223598)),
                  ),
                ),
                ListTile(
                  onTap: () {
                    currentPage = 24;
                    _Pdfcontroller.setPage(24);
                    Navigator.of(context).pop();
                  },
                  leading: Icon(
                    Icons.graphic_eq,
                    color: Color(0xFF2E44CB),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0.0,
                    horizontal: 16.0,
                  ),
                  dense: true,
                  title: Text(
                    'Kehf Suresi',
                    style: TextStyle(color: Color(0xFF223598)),
                  ),
                ),
                ListTile(
                  onTap: () {
                    currentPage = 12;
                    _Pdfcontroller.setPage(12);
                    Navigator.of(context).pop();
                  },
                  leading: Icon(
                    Icons.graphic_eq,
                    color: Color(0xFF2E44CB),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0.0,
                    horizontal: 16.0,
                  ),
                  dense: true,
                  title: Text(
                    'Fetih Suresi',
                    style: TextStyle(color: Color(0xFF223598)),
                  ),
                ),
                ListTile(
                  onTap: () {
                    currentPage = 8;
                    _Pdfcontroller.setPage(8);
                    Navigator.of(context).pop();
                  },
                  leading: Icon(
                    Icons.graphic_eq,
                    color: Color(0xFF2E44CB),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0.0,
                    horizontal: 16.0,
                  ),
                  dense: true,
                  title: Text(
                    'V??k??a Suresi',
                    style: TextStyle(color: Color(0xFF223598)),
                  ),
                ),
                ListTile(
                  onTap: () {
                    currentPage = 4;
                    _Pdfcontroller.setPage(4);
                    Navigator.of(context).pop();
                  },
                  leading: Icon(
                    Icons.graphic_eq,
                    color: Color(0xFF2E44CB),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0.0,
                    horizontal: 16.0,
                  ),
                  dense: true,
                  title: Text(
                    'M??lk Suresi',
                    style: TextStyle(color: Color(0xFF223598)),
                  ),
                ),
                ListTile(
                  onTap: () {
                    currentPage = 1;
                    _Pdfcontroller.setPage(1);
                    Navigator.of(context).pop();
                  },
                  leading: Icon(
                    Icons.graphic_eq,
                    color: Color(0xFF2E44CB),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0.0,
                    horizontal: 16.0,
                  ),
                  dense: true,
                  title: Text(
                    'Nebe Suresi',
                    style: TextStyle(color: Color(0xFF223598)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: !_isVisible
          ? null
          : AnimatedContainer(
              duration: Duration(milliseconds: 500),
              height: 50,
              child: BottomAppBar(
                shape: CircularNotchedRectangle(),
                color: themeColor,
                elevation: 5,
                child: Container(
                  child: Center(
                    widthFactor: 1.1,
                    child: Row(
                      children: <Widget>[
                        Spacer(
                          flex: 2,
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _switchLangToTurk = !_switchLangToTurk;
                              pdfViewerKey = UniqueKey();
                              mealColor = mealColor == Colors.white
                                  ? Colors.orange
                                  : Colors.white;
                            });
                          },
                          color: themeColor,
                          icon: Icon(
                            Icons.import_contacts,
                            color: mealColor,
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          onPressed: showMenu,
                          color: themeColor,
                          icon: Icon(
                            Icons.av_timer,
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          color: themeColor,
                          icon: Icon(
                            Icons.playlist_add,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            final SharedPreferences prefs = await _prefs;
                            List<String> listNames =
                                await prefs.getStringList("favListNames") ??
                                    new List<String>();
                            listNames.add(currentPageName.data +
                                "\n" +
                                currentPageNumber.data);
                            prefs.setStringList("favListNames", listNames);

                            List<String> listPages =
                                await prefs.getStringList("favListPages") ??
                                    new List<String>();
                            listPages.add(currentPage.toString());
                            prefs.setStringList("favListPages", listPages);

                            showToast("Favorilere Eklendi");
                          },
                        ),
                        Spacer(
                          flex: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      floatingActionButtonLocation:
          !_isVisible ? null : FloatingActionButtonLocation.endDocked,
      floatingActionButton: !_isVisible
          ? null
          : FloatingActionButton(
              child: Icon(icon),
              backgroundColor: Colors.orange,
              onPressed: () {
                _requestDownload();
                if(hasSoundfilePath){
                  setState(() {
                  if (pageplaying == false) {
                    selectedDuration =
                        pageSoundDurations.elementAt(248 - currentPage);
                    _assetsAudioPlayer.seek(Duration(
                        minutes: selectedDuration['startMinute'],
                        seconds: selectedDuration['startSecond'],
                        milliseconds: selectedDuration['startMilliSecond']));
                    pageplaying = true;
                  }
                  icon =
                      icon == Icons.play_arrow ? Icons.pause : Icons.play_arrow;
                });
                _assetsAudioPlayer.playOrPause();
                }
              },
            ),
    );
  }

  static Future<int> getbookmarkNumber() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt("bookmark") ?? 248;
  }

  Future setbookmarkNumber() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("bookmark", currentPage);
  }

  void showToast(String msg, {int duration}) {
    Toast.show(msg, context, duration: duration, gravity: Toast.BOTTOM);
  }
bool _permissionReady = false;
Future<bool> _checkPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  String _localPath;
  Future<String> _findLocalPath() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }

  String downloadTask;
  File soundfilePath;
  bool hasSoundfilePath = false;
  void _requestDownload() async {
    if(_permissionReady == false){
      _permissionReady = await _checkPermission();
    }
    else{
    bool hasExisted;
    _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';
    final savedDir = Directory(_localPath);
    soundfilePath = File(_localPath + '/evrad.mp3');
    await soundfilePath.exists().then((bool value) async{
      hasSoundfilePath = value;
      await savedDir.exists().then((bool existedvalue) async{
        hasExisted = existedvalue;
        if (!hasExisted) {
          savedDir.create();
        }
        if (!hasSoundfilePath) {
        _assetsAudioPlayer.pause();
        await EasyLoading.show(
          status: 'Ses dosyas?? indiriliyor...',
          maskType: EasyLoadingMaskType.black,
        );
        downloadTask = await FlutterDownloader.enqueue(
            url: 'http://evradiserif.com/AppFiles/evrad.mp3',
            savedDir: _localPath,
            showNotification: true);
        print('----------------------------------------------------');
        Timer.periodic(Duration(seconds: 1), (timer) async {
          var tasks = await FlutterDownloader.loadTasks();
          var task = tasks.firstWhere((task) => task.taskId == downloadTask);

          setState(()   {
         if (task.progress == 100) {

              timer.cancel();
              EasyLoading.dismiss();
              hasSoundfilePath = true;
              currentPage = 248;
              _Pdfcontroller.setPage(248);
              _assetsAudioPlayer.open(Audio.file(_localPath + '/evrad.mp3'),
                  showNotification: true, autoStart: false);
              _assetsAudioPlayer.currentPosition.listen((data) {
                print(selectedDuration['endMinute'].toString() +
                    ":" +
                    selectedDuration['endSecond'].toString() +
                    "---" +
                    data.inMinutes.toString() +
                    ":" +
                    (data.inSeconds >= 60
                            ? data.inSeconds % 60
                            : data.inSeconds)
                        .toString());
                if (data.inMinutes.toString() ==
                        selectedDuration['endMinute'].toString() &&
                    (data.inSeconds >= 60
                                ? data.inSeconds % 60
                                : data.inSeconds)
                            .toString() ==
                        selectedDuration['endSecond'].toString()) {
                  print("sonraki sayfa");
                  isplayingControl = true;
                  _Pdfcontroller.setPage(currentPage - 1);
                  Future.delayed(Duration(milliseconds: 750), () {});
                }
              });
            }
          });
        });
      } else {}
      });
    });
    }
  }

  showAlertDialog(BuildContext context) async {
    List<Widget> favItems = new List<Widget>();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> listNames =
        prefs.getStringList("favListNames") ?? new List<String>();
    List<String> listPages =
        prefs.getStringList("favListPages") ?? new List<String>();
    for (int i = 0; i < listNames.length; i++) {
      String value = listNames.elementAt(i);
      favItems.add(ListTile(
          onTap: () {
            _Pdfcontroller.setPage(int.parse(listPages.elementAt(i)));
            Navigator.of(context).pop();
          },
          leading: Icon(Icons.favorite_border),
          dense: true,
          title: Align(
            child: Text('$value'),
            alignment: Alignment(-1.3, 0),
          ),
          trailing: new IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              listPages.removeAt(i);
              listNames.removeAt(i);
              prefs.setStringList("favListNames", listNames);
              prefs.setStringList("favListPages", listPages);
              setState(() {
                favItems.removeAt(i);
              });
            },
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20.0)));
    }

    SimpleDialog dialog = SimpleDialog(
      title: const Text('Favori Listesi',
          style: TextStyle(color: Color(0xFF223598))),
      children: favItems,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );
  }

  showMenu() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                color: Color(0xff223598),
                boxShadow: [
                  BoxShadow(color: Color(0xff223598), spreadRadius: 4),
                ],
              ),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      height: 36,
                    ),
                    SizedBox(
                      height: 120,
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16.0),
                              topRight: Radius.circular(16.0),
                            ),
                            color: Color(0xff2e44cb),
                          ),
                          child: Stack(
                            alignment: Alignment(0, 0),
                            overflow: Overflow.visible,
                            children: <Widget>[
                              Positioned(
                                top: -26,
                                child: Container(
                                  height: 60,
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.orange,
                                    child: Center(
                                        child: Text(
                                      readSpeed.toStringAsFixed(2),
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    )),
                                  ),
                                ),
                              ),
                              Positioned(
                                child: ListView(
                                  children: <Widget>[
                                    Padding(
                                        padding: const EdgeInsets.only(top: 45),
                                        child: Text(
                                          'OKUMA HIZI',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        )),
                                    Slider(
                                      value: readSpeed,
                                      activeColor: Colors.orange,
                                      inactiveColor: Colors.white,
                                      min: 0.75,
                                      max: 2.50,
                                      divisions: 7,
                                      label: '$readSpeed',
                                      onChanged: (value) {
                                        setState(() {
                                          _assetsAudioPlayer
                                              .setPlaySpeed(value);
                                          readSpeed = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    ),
                  ]),
            );
          });
        });
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/splash.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            Image.asset('assets/images/evrad.png', fit: BoxFit.fill)
          ],
        ),
      ),
    );
  }
}

class MuellifDialog extends StatefulWidget {
  final PDFViewController pdfcontroller;
  MuellifDialog(this.pdfcontroller);
  @override
  _MuellifDialogState createState() => _MuellifDialogState();
}

class _MuellifDialogState extends State<MuellifDialog> {
  List<Widget> bodyText = new List<Widget>();
  @override
  void initState() {
    super.initState();
    bodyText.add(Container(
        margin: const EdgeInsets.all(10.0),
        child: Text(
            "1950 sonras?? T??rkiye sosyal ve siyasi tarihinin en etkin ismi 1897 y??l??nda Bursa'da d??nyaya geldi. Tahsil hayat??, askerli??i, 1. D??nya sava????na i??tiraki, Bursa'daki imaml??k vazifesi sonras?? 1952 de ??stanbul'a kal??c?? olarak geldi ve tabiri caiz ise T??rkiye'nin evrilece??i yeni y??ne dair ??al????malar ba??lad??. \n\n 6 y??l boyunca Zeyrek ??mm?? G??ls??m camiinde imaml??k yapt?? ve ikindi sonras?? sohbetler verdi. Bu sohbetlerde 'M??sl??manl??????n sadece ibadet ve inan?? (akaid) sistemi de??il, t??m hayat?? de??i??tiren bir ya??am bi??imi oldu??u' nu i??ledi. Tek parti d??nemi sonras?? M??sl??manlar i??in ulvi bir hedef olan bu g??r????, bir g??ne?? gibi ufuktan parlad?? ve ??stanbul'un t??m ??niversitelerinden en se??kin ????renciler bu g??ne??e do??ru ak??n ak??n geldi. ??T??, Bo??azi??i, Y??ld??z ve di??er ??niversite ????rencileri gerek Zeyrek Camii'ne, gerek (1958 sonras??) ??skenderPa??a Camii'ne bu ismi dinlemeye geliyor, yap??lan Ramuz el-Ehadis derslerini dinliyor, m??sl??man karde??li??inin lezzetini tad??yor ve m??sl??man bir nizama g??re hayatlar??n?? yeniden yap??land??r??yordu. \n\n Uzun zaman ge??meden bu bak???? a????s?? t??m T??rkiye'de yank?? buldu. Yabanc??lar??n ??retti??i ila??lar??n kullan??lmamas??,  yabanc?? arabalara binilmemesi ??????tleniyor. ilac??m??z??, arabam??z??, silah??m??z?? k??saca her t??rl?? imkan ve teknolojiyi ithal etmek yerine bunlar??n ??lkemiz insanlari taraf??ndan ??retilmesi sohbetlerde i??leniyordu. En farkl?? ve vizyoner bu anlay???? tarz?? yurdun d??rt bir taraf??ndan m??sl??manlar??n kendini buldu??u adeta bir 'Marka' oldu. Pazar sohbetleri sebebiyle cumartesi ak??amdan ??ehir d??????ndan binilen otob??sler pazar sabah Topkap?? otogar??nda oluyor, inen insanlar ??skenderpa??a Camiine ak??n ak??n geliyor. Sohbet ????k??????nd ise Fatih'in ana ve yan caddeleri mecburen trafi??e kapan??yordu. \n\n Bu vizyon ile yo??rulan ????rencileri T??rkiye'de bu de??i??imi yapmak, m??sl??manl?????? bir ya??am tarz?? haline getirmek i??in y??netime talip oldu ve aralar??ndan 4 Ba??bakan, 3 Cumhurba??kan??, say??s??z bakanlar, millet vekilleri, belediye ba??kanlar??, b??rokratlar, teknokratlar ????kt??. \n\n Halen b??rakt?????? kitaplar, sohbet kay??tlar?? ve ??rnek uygulamalar?? ile bizlere m??sl??manl??????n en basit i??ten en komplekse her yerde, evde, i??te, seyahatte, ikili ve aile ili??kilerinde ve hayat??n t??m alan??nda bir ya??am bi??imi oldu??unu anlatan bu marka Mehmed Zahid Kotku Rahmetullahi Aleyhtir. \n\n Verdi??i e??siz vizyon ile m??sl??manlara y??kledi??i bu ulvi misyon, halen tam ula????lamam???? bir hedef olarak biz m??sl??manlar??n ufkunda durmaktad??r. \n\n Hayatta iken Hak yoldaki gayretleri ve bu yola feda etti??i t??m hayat??, ??ehadetimize gerek kalmaks??z??n milyonlar taraf??ndan g??r??lmekte idi. Allah Z.C.'in, Mehmed Zahid Kotku Hazretleri'nin derecesini ??li, makam??n?? uly?? eylemesi ve bizleri ??efaatine mazhar eylemesi i??ten duam??zd??r. Kendisini, hayat??n??, gayretini ve biz m??sl??manlara bi??ti??i gayeyi tam olarak anlamam??z duas?? ile.",
            textAlign: TextAlign.justify,
            style: TextStyle(color: Color(0xFF223598), fontSize: 11))));
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Mehmed Zahid Kotku R.A.',
          style: TextStyle(color: Color(0xFF223598), fontSize: 18)),
      children: bodyText,
    );
  }
}

class AboutUsDialog extends StatefulWidget {
  final PDFViewController pdfcontroller;
  AboutUsDialog(this.pdfcontroller);
  @override
  _AboutUsDialogState createState() => _AboutUsDialogState();
}

class _AboutUsDialogState extends State<AboutUsDialog> {
  List<Widget> bodyText = new List<Widget>();
  @override
  void initState() {
    super.initState();
    bodyText.add(Container(
        margin: const EdgeInsets.all(10.0),
        child: Text(
            "Hibb?? Resulullah (Res??lullah?????n sevdi??i ki??i) lakab??yla ????hret kazanan Hz. ??same R.A'a, oradan da Hz. Peygamber (sav) Efendimize dayanan bu Evrad-?? ??erifin olu??turulmas??ndaki temel ????yledir: \n\n Hz. ??same (ra) bir g??n Acemistan'??n (bug??nk?? ??ran) ??sfahan ??ehrine gittiklerinde sap??k bir kavim taraf??ndan al??konulur ve kendisine ??iddetli i??kenceler yap??l??r. Bu al??konulma ve i??kence esnas??nda Peygamberimiz (sav) Hz. ??same'nin r??yas??na te??fir buyurur ve ??same kalk ve Kuran'?? Kerimi eline al. Ondan haftan??n her g??n?? i??in bir evrad tertip et ve o evrada devam et. Muhakkak bu okuyacaklar??n ile hapisten ????kar ve daha iyi bir hale eri??irsin buyururlar. \n\n Hz. ??same Efendimize (ra) Cuma g??n?? i??in hamd ayetlerini, Cumartesi i??in isti??far ayetlerini, Pazar i??in tesbih ayetlerini, Pazartesi i??in tevekk??l ayetlerini, Sal?? i??in selamet ayetlerini, ??ar??amba i??in tehlil ayetlerini ve Per??embe i??in Cuma ayetlerini toplamas?? tavsiye edilmi??. ??same Efendimiz de ayetleri toplay??p evrad haline getirmi?? ve okumaya ba??lam????. Allah ZC'in izni ile k??sa s??rede hapisten kurtulmu?? ve daha iyi bir hale ula??m????lar. \n\n Mehmed Zahid Kotku Hazretleri taraf??ndan Peygamberimiz (sav) Hazretlerinin att?????? bu temel evrad ??zerine bina edilen Evrad-?? ??erif bir??ok ??nemli evrad ve dualar?? i??ermektedir. Hz. Ali (ra) efendimizin evrad??, ahmed ziyauddin hazretlerinin muhtesem eseri Mecmuat??l ahzab, K??t??b-i Sitte ve Ramuz-el Ehadis'ten al??nan dualar, yine Kuran-?? Kerim'de Allah ZC Hazretleri'nin bizlere ????retti??i dualar ve bir??ok ayeti kerime ve nice b??y??klerin tecr??be edilmi?? dualar?? elinizdeki evrad??n muhtevas??d??r. Bu e??siz muhtevan??n herbirinin kayna????nda belirtilen okunmas?? sonras??  elde edilecek m??jdeleri pek geni??tir, hem d??nyaya hem de ahirete y??nelik ve ??a????rt??c?? derecede engindir. Bu m??jdeler ancak ayr?? ve hacimli bir eser ile anlat??labilir. G??n??nde okunan Ayet-i kerime'ler, dualar ve belli say??daki zikirlerin Hav??si zenginli??i ve etkisi ise ancak erbab??nca malumdur. \n\n Evrad-?? ??erif Mehmed Zahid Kotku Hazretleri taraf??ndan son ??ekli verildi??i halde, ??zerinde hi??bir de??i??iklik yap??lmadan sizlerin istifadesine sunulmu??tur. \n\n Bize bu de??erli Evrad?? ??erifi hediyesi sebebiyle Mehmet Zahid Kotku Hazretlerine lay??k??yla te??ekk??rden aciziz. T??m varl?????? ile ??mr?? boyunca insanl??k i??in ??al????an, hem maddi hem manevi olarak T??rkiye'de b??y??k m??sbet de??i??imleri yapan/ba??latan Mehmed Zahid kotku Hazretleri'nin Hak kat??ndaki derecesinin ??li, makam??n??n uly?? olmas??, ahirette de ??efaat??imiz olmas?? nacizane istek ve duam??zd??r. S??zlerimizi yine Mehmed Zahid Kotku Hazretlerinin kendi dilinden Evrad?? ??erife ile ilgili yazd?????? ??u s??zler ile sonland??r??r??z. \n\n Abdest alarak tam bir ihlas ile okuyaca????n??z dualar??n??z?? Cenab-?? Hak kabul buyursun. Peygamberimiz(sav) ??efaat??imiz olsun. \n\n Dualar??n??zla bizim de Hak'k??n r??zas??na nail olmam??za sebep olursunuz.",
            textAlign: TextAlign.justify,
            style: TextStyle(color: Color(0xFF223598), fontSize: 11))));
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Evrad-?? ??erif ve ??nemi',
          style: TextStyle(color: Color(0xFF223598), fontSize: 18)),
      children: bodyText,
    );
  }
}

class DynamicDialog extends StatefulWidget {
  final PDFViewController pdfcontroller;
  DynamicDialog(this.pdfcontroller);
  @override
  _DynamicDialogState createState() => _DynamicDialogState();
}

class _DynamicDialogState extends State<DynamicDialog> {
  List<Widget> favItems = new List<Widget>();
  @override
  void initState() {
    super.initState();
    getItem();
  }

  getItem() async {
    List<Widget> _favItems = new List<Widget>();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> listNames =
        prefs.getStringList("favListNames") ?? new List<String>();
    List<String> listPages =
        prefs.getStringList("favListPages") ?? new List<String>();
    for (int i = 0; i < listNames.length; i++) {
      String value = listNames.elementAt(i);
      _favItems.add(ListTile(
          onTap: () {
            widget.pdfcontroller.setPage(int.parse(listPages.elementAt(i)));
            Navigator.of(context).pop();
          },
          leading: Icon(Icons.favorite_border),
          dense: true,
          title: Align(
            child: Text('$value'),
            alignment: Alignment(-1.3, 0),
          ),
          trailing: new IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              listPages.removeAt(i);
              listNames.removeAt(i);
              prefs.setStringList("favListNames", listNames);
              prefs.setStringList("favListPages", listPages);
              setState(() {
                _favItems.removeAt(i);
              });
              getItem();
            },
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20.0)));

      setState(() {
        favItems = _favItems;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Favori Listesi',
          style: TextStyle(color: Color(0xFF223598))),
      children: favItems,
    );
  }
}
