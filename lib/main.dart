import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'classes.dart';
import 'language.dart';
import 'main_page.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await databaseReady();
  await getTheme();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;
        
        lightColorScheme = ColorScheme.fromSeed(
          seedColor: Color.fromARGB(
              gettedTheme[0], gettedTheme[1], gettedTheme[2], gettedTheme[3]),
          brightness: Brightness.light,
        );
        darkColorScheme = ColorScheme.fromSeed(
          seedColor: Color.fromARGB(
              gettedTheme[0], gettedTheme[1], gettedTheme[2], gettedTheme[3]),
          brightness: Brightness.dark,
        );
        theme = [
          75,
          (lightColorScheme.primary.r*255).toInt(),
          (lightColorScheme.primary.g*255).toInt(),
          (lightColorScheme.primary.b*255).toInt()
        ];
        

        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeMode,
          
          builder: (context, ThemeMode currentMode, _) {
            return ScreenUtilInit(
              designSize: Size(1440, 3088),
              builder: (_, child) => MaterialApp(
                home: const HomePage(),
                debugShowCheckedModeBanner: false,
                
                title: 'IP Tracker',
                theme: ThemeData(
                  colorScheme: lightColorScheme,
                  useMaterial3: true,
                ),
                darkTheme: ThemeData(
                  colorScheme: darkColorScheme,
                  useMaterial3: true,
                ),
                themeMode: currentMode,
              )
            );
          },
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    APPNAME.addListener(() {if(mounted) setState(() {});});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        body: MainPage(),
        appBar: AppBar(
          title: Center(child: SizedBox(width: 750.w, child: TextField(
            controller: APPNAME,
            decoration: const InputDecoration(
              border: OutlineInputBorder(borderSide: BorderSide.none),
            ),
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, fontSize: 78.sp),
            readOnly: true,
          ),)),
          centerTitle: true,
          backgroundColor: Color.fromARGB(15, theme[1], theme[2], theme[3]),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(80.r)),
          ),
          shadowColor: Color.fromARGB(80, theme[1], theme[2], theme[3]),
          elevation: 36.r,
          toolbarHeight: 200.h,
          leading: MaterialButton(
            hoverColor: const Color.fromARGB(0, 0, 0, 0),
            highlightColor: const Color.fromARGB(0, 0, 0, 0),
            splashColor: const Color.fromARGB(0, 0, 0, 0),
            child: Icon(Icons.info_outline, size: 100.r,),
            onPressed: () => showAbout(context),
          ),
          actions: [
            Visibility(visible: false, maintainSize: true, maintainAnimation: true, maintainState: true, child: Icon(Icons.info_outline, size: 130.r,),)
          ],
        ),
      )
    );
  }
}