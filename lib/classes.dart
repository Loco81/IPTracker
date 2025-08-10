import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_ip_address/get_ip_address.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'language.dart';
import 'history_page.dart';




final LocalStorage storage = LocalStorage('IPTracker');
final networkInfo = NetworkInfo();
List<String> deviceInfo = [];
List<int> theme = [];

List gettedTheme = [];
ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);
Icon themeModeIcon = const Icon(Icons.brightness_4, size: 28);
String languageValue = 'English';

bool isVpnActivated = false;
ValueNotifier<String> currentPublicIp = ValueNotifier('');
ValueNotifier<String> currentWifiIp = ValueNotifier('');
ValueNotifier<Map<String, dynamic>> locationInfo = ValueNotifier(<String, dynamic>{});
List<dynamic> wifiIpHistory = [];
List<dynamic> publicIpHistory = [];




Future<void> databaseReady() async {
  await storage.ready;
  final androidInfo = await DeviceInfoPlugin().androidInfo;
  deviceInfo = [androidInfo.brand, androidInfo.model, androidInfo.version.release];
}

Future<void> getTheme() async {
  gettedTheme = [
    storage.getItem('a') ?? 255,
    storage.getItem('r') ?? 0,
    storage.getItem('g') ?? 200,
    storage.getItem('b') ?? 0,
    storage.getItem('brightness') ?? 'system',
    storage.getItem('language') ?? 'english',
  ];

  if (gettedTheme[4] == 'light') {
    themeMode.value = ThemeMode.light;
    themeModeIcon = const Icon(Icons.brightness_5, size: 28);
  } else if (gettedTheme[4] == 'dark') {
    themeMode.value = ThemeMode.dark;
    themeModeIcon = const Icon(Icons.brightness_2_rounded, size: 28);
  } else if (gettedTheme[4] == 'system') {
    themeMode.value = ThemeMode.system;
    themeModeIcon = const Icon(Icons.brightness_4, size: 28);
  }

  if (gettedTheme[5] == 'english') {
    languageValue='English';
    setLanguage(languageValue);
  } else {
    languageValue='Persian';
    setLanguage(languageValue);
  }

  wifiIpHistory = await storage.getItem('wifiIpHistory') ?? [];
  publicIpHistory = await storage.getItem('publicIpHistory') ?? [];
}

void setThemeMode(currentmode) async {
  HapticFeedback.mediumImpact();
  if (currentmode == ThemeMode.system) {
    themeMode.value = ThemeMode.light;
    themeModeIcon = const Icon(Icons.brightness_5, size: 28);
    await storage.setItem('brightness', 'light');
  } else if (currentmode == ThemeMode.light) {
    themeMode.value = ThemeMode.dark;
    themeModeIcon = const Icon(Icons.brightness_2_rounded, size: 28);
    await storage.setItem('brightness', 'dark');
  } else if (currentmode == ThemeMode.dark) {
    themeMode.value = ThemeMode.system;
    themeModeIcon = const Icon(Icons.brightness_4, size: 28);
    await storage.setItem('brightness', 'system');
  }
}

void changeLanguage() async {
  HapticFeedback.mediumImpact();
  if (languageValue=='English'){
    languageValue='Persian';
    setLanguage(languageValue);
    await storage.setItem('language', 'persian');
  }
  else{
    languageValue='English';
    setLanguage(languageValue);
    await storage.setItem('language', 'english');
  }
}

void showAbout(BuildContext context) {
  showGeneralDialog(
    barrierColor:Color.fromARGB(90, theme[1], theme[2], theme[3]),
    transitionBuilder: (context, a1, a2, widget) {
      return Transform.scale(
        scale: a1.value,
        child: Opacity(
          opacity: a1.value,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              elevation: 22.r,
              shadowColor: Colors.black,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(400.r),
                side: BorderSide.none,
              ),
              title: Text(ABOUT, textAlign: TextAlign.center, style: TextStyle(fontFamily: FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, fontSize: 86.sp),),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60.r,
                        height: 60.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(200, theme[1], theme[2], theme[3]),
                          boxShadow: [BoxShadow(
                            color: Color.fromARGB(140, theme[1], theme[2], theme[3]),
                            blurRadius: 5,
                            offset: Offset.zero
                          )]
                        ),
                      ),
                      SizedBox(width: 4,),
                      Text(ABOUT_SUBJECT, textAlign: TextAlign.center, style: TextStyle(fontFamily: FONTFAMILY_DESCRIPTION, fontSize: 56.sp),),
                      SizedBox(width: 4,),
                      Container(
                        width: 60.r,
                        height: 60.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(200, theme[1], theme[2], theme[3]),
                          boxShadow: [BoxShadow(
                            color: Color.fromARGB(140, theme[1], theme[2], theme[3]),
                            blurRadius: 5,
                            offset: Offset.zero
                          )]
                        ),
                      ),
                    ],
                  ),
                  Text(ABOUT_DESCRIPTION, textAlign: TextAlign.center, style: TextStyle(fontFamily: FONTFAMILY_DESCRIPTION, fontSize: 50.sp), textDirection: languageValue=='English' ? TextDirection.ltr : TextDirection.rtl,),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child: Image.asset('assets/Gmail.png', width: 170.r),
                      onTap: () => urlLauncher(
                          'mailto:hosseinbahiraei81@gmail.com?subject=$MAIL_SUB&body=$MAIL_BOD'),
                    ),
                    SizedBox(width: 24.w),
                    GestureDetector(
                      child: Image.asset('assets/LocoSite.png', width: 170.r,),
                      onTap: () => urlLauncher('https://Loco81.ir'),
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                Center(child: Text(VERSION, style: TextStyle(fontFamily: 'AveriaLibre', fontSize: 45.sp),))
              ],
            ),
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
    barrierDismissible: true,
    barrierLabel: '',
    context: context,
    pageBuilder: (context, animation1, animation2) {
      return const Text('');
    }
  );
}

void showIpInfo(BuildContext context) {
  showGeneralDialog(
    barrierColor:Color.fromARGB(90, theme[1], theme[2], theme[3]),
    transitionBuilder: (context, a1, a2, widget) {
      return Transform.scale(
        scale: a1.value,
        child: Opacity(
          opacity: a1.value,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              elevation: 22.r,
              shadowColor: Colors.black,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(400.r),
                side: BorderSide.none,
              ),
              title: ValueListenableBuilder(
                valueListenable: currentPublicIp, 
                builder: (context, value, child) {
                  return Text(currentPublicIp.value!='' ? currentPublicIp.value : NO_INTERNET_ACCESS, textAlign: TextAlign.center, style: TextStyle(fontFamily: FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, fontSize: 80.sp),);
                }
              ),
              content: ValueListenableBuilder(
                valueListenable: locationInfo,
                builder: (context, value, child) { 
                  return Visibility(
                    visible: currentPublicIp.value!='' ? true : false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 18.w,),
                              Container(
                                width: 190.w,
                                height: 60.w,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).hintColor.withAlpha(120),
                                  borderRadius: BorderRadius.circular(10.r),
                                  boxShadow: [BoxShadow(
                                    color: Theme.of(context).hintColor.withAlpha(120),
                                    blurRadius: 20.r,
                                    offset: Offset.zero
                                  )]
                                ),
                                child: Center(
                                  child: Text('Location', style: TextStyle(fontFamily: FONTFAMILY_DESCRIPTION, fontWeight: FontWeight.bold, color: Theme.of(context).cardColor, fontSize: 36.sp),),
                                )
                              ),
                              SizedBox(width: 18.w,),
                              Text('${locationInfo.value['country']??''}, ${locationInfo.value['regionName']??''}, ${locationInfo.value['city']??''}', style: TextStyle(fontFamily: 'AveriaLibre', fontSize: 50.sp),),
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 18.w,),
                              Container(
                                width: 210.w,
                                height: 60.w,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).hintColor.withAlpha(120),
                                  borderRadius: BorderRadius.circular(10.r),
                                  boxShadow: [BoxShadow(
                                    color: Theme.of(context).hintColor.withAlpha(120),
                                    blurRadius: 20.r,
                                    offset: Offset.zero
                                  )]
                                ),
                                child: Center(
                                  child: Text('Time Zone', style: TextStyle(fontFamily: FONTFAMILY_DESCRIPTION, fontWeight: FontWeight.bold, color: Theme.of(context).cardColor, fontSize: 36.sp),),
                                )
                              ),
                              SizedBox(width: 18.w,),
                              Text('${locationInfo.value['timezone']??''}', style: TextStyle(fontFamily: 'AveriaLibre', fontSize: 50.sp),),
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 18.w,),
                              Container(
                                width: 95.w,
                                height: 60.w,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).hintColor.withAlpha(120),
                                  borderRadius: BorderRadius.circular(10.r),
                                  boxShadow: [BoxShadow(
                                    color: Theme.of(context).hintColor.withAlpha(120),
                                    blurRadius: 20.r,
                                    offset: Offset.zero
                                  )]
                                ),
                                child: Center(
                                  child: Text('ISP', style: TextStyle(fontFamily: FONTFAMILY_DESCRIPTION, fontWeight: FontWeight.bold, color: Theme.of(context).cardColor, fontSize: 36.sp),),
                                )
                              ),
                              SizedBox(width: 18.w,),
                              Text('${locationInfo.value['isp']??''}', style: TextStyle(fontFamily: 'AveriaLibre', fontSize: 50.sp),),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              ),
            ),
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
    barrierDismissible: true,
    barrierLabel: '',
    context: context,
    pageBuilder: (context, animation1, animation2) {
      return const Text('');
    }
  );
}

void customDialog(BuildContext context, subject, str, List<Widget> actions) {
  showGeneralDialog(
    barrierColor: Color.fromARGB(90, theme[1], theme[2], theme[3]),
    transitionBuilder: (context, a1, a2, widget) {
      return Transform.scale(
        scale: a1.value,
        child: Opacity(
          opacity: a1.value,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              elevation: 22.r,
              contentPadding: EdgeInsets.all(100.r),
              titlePadding: EdgeInsets.fromLTRB(160.r, 80.r, 160.r, 0),
              shadowColor: Color.fromARGB(255, theme[1], theme[2], theme[3]),
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(380.r),
                side: BorderSide.none,
              ),
              title: subject=='' ? null : Text(subject, textAlign: TextAlign.center, style: TextStyle(fontFamily: FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, fontSize: 58.sp),),
              content: Text(str, style: TextStyle(fontFamily: FONTFAMILY_DESCRIPTION, fontSize: 48.sp), textDirection: languageValue=='English' ? TextDirection.ltr : TextDirection.rtl,),
              actions: actions.isEmpty ? null : actions,
            ),
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
    barrierDismissible: true,
    barrierLabel: '',
    context: context,
    pageBuilder: (context, animation1, animation2) {
      return const Text('');
    }
  );
}

class ThemeModer extends StatelessWidget {
  const ThemeModer({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (context, ThemeMode currentMode, _) {
        return IconButton(
          icon: themeModeIcon,
          color: Color.fromARGB(160, theme[1], theme[2], theme[3]),
          onPressed: () {
            setThemeMode(themeMode.value);
          },
        );
      },
    );
  }
}

Future<void> urlLauncher(url) async {
  url = Uri.parse(url);
  try {
    await launchUrl(url);
  }
  // ignore: empty_catches
  catch (e) {}
}

void rebuildAllChildren(BuildContext context) {
  void rebuild(Element el) {
    try {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }
    catch (e) {}
  }

  (context as Element).visitChildren(rebuild);
}

class CustomAnimatedToggle extends StatefulWidget {
  final List<String> values;
  final ValueChanged onToggleCallback;
  final Color backgroundColor;
  final Color buttonColor;
  final Color textColor;

  const CustomAnimatedToggle({super.key, 
    required this.values,
    required this.onToggleCallback,
    this.backgroundColor = const Color(0xFFe7e7e8),
    this.buttonColor = const Color(0xFFFFFFFF),
    this.textColor = const Color(0xFF000000),
  });
  @override
  _CustomAnimatedToggleState createState() => _CustomAnimatedToggleState();
}

class _CustomAnimatedToggleState extends State<CustomAnimatedToggle> {
  bool initialPosition = true;
  @override
  Widget build(BuildContext context) {
    if (pagelistToggleValue==1) {initialPosition=false;}
    else {initialPosition=true;}
    return Container(
      height: 140.h,
      margin: const EdgeInsets.all(10),
      child: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              initialPosition = !initialPosition;
              var index = 0;
              if (!initialPosition) {
                index = 1;
              }
              widget.onToggleCallback(index);
              setState(() {});
            },
            child: Container(
              height: 105.h,
              decoration: ShapeDecoration(
                color: widget.backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  widget.values.length,
                  (index) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 100.w),
                    child: Text(
                      widget.values[index],
                      style: TextStyle(
                        fontFamily: FONTFAMILY_SUBJECT, 
                        fontWeight: FontWeight.bold, 
                        fontSize: 46.r,
                        color: Color.fromARGB(150, 95, 95, 95),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.decelerate,
            alignment:
                initialPosition ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              decoration: ShapeDecoration(
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(34.r),
                ),
              ),
              child: 
                Container(
                  width: 680.w,
                  height: 110.h,
                  decoration: ShapeDecoration(
                    color: widget.buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(34.r),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initialPosition ? widget.values[0] : widget.values[1],
                    style: TextStyle(
                      fontFamily: FONTFAMILY_SUBJECT, 
                      fontWeight: FontWeight.bold, 
                      fontSize: 50.r,
                      color: widget.textColor,
                    ),
                  ),
                ),
            ),
          ),
        ],
      ),
    );
  }
}

bool isPrivateIp(String ip) {
  return ip.startsWith('192.168.') ||
         ip.startsWith('10.') ||
         ip.startsWith('172.16.') || ip.startsWith('172.17.') ||
         ip.startsWith('172.18.') || ip.startsWith('172.19.') ||
         ip.startsWith('172.20.') || ip.startsWith('172.21.') ||
         ip.startsWith('172.22.') || ip.startsWith('172.23.') ||
         ip.startsWith('172.24.') || ip.startsWith('172.25.') ||
         ip.startsWith('172.26.') || ip.startsWith('172.27.') ||
         ip.startsWith('172.28.') || ip.startsWith('172.29.') ||
         ip.startsWith('172.30.') || ip.startsWith('172.31.');
}

Future<bool> isVpnActive() async {
  final interfaces = await NetworkInterface.list();
  for (var interface in interfaces) {
    final name = interface.name.toLowerCase();
    if (name.contains('tun') || name.contains('ppp') || name.contains('vpn') || name.contains('wg')) {
      return true;
    }
  }
  return false;
}

Future<Map> getIp() async {
  isVpnActivated = await isVpnActive();
  Map<String, String> ipInfo = {};

  // Local WiFi
  List<ConnectivityResult> result = await Connectivity().checkConnectivity();
  if (result[0] == ConnectivityResult.wifi || result[0] == ConnectivityResult.ethernet) {
    try {
      ipInfo['WiFi'] = (await NetworkInfo().getWifiIP().timeout(Duration(seconds: 1), onTimeout: () => ''))!;
    } catch (e) {/**/}
  }

  // Local Hotspot
  for (var interface in await NetworkInterface.list()) {
    for (var addr in interface.addresses) {
      if (isPrivateIp(addr.address) && addr.type == InternetAddressType.IPv4) {
        if((ipInfo['WiFi']??'')!=addr.address && !isVpnActivated) {
          ipInfo['Hotspot'] = addr.address;
        }
      }
    }
  }

  // Public
  try {
    var ipAddress = IpAddress(type: RequestType.json);

    dynamic data = await ipAddress.getIpAddress().timeout(Duration(seconds: 6), onTimeout: () => '');
    ipInfo['Internet'] = data['ip'].toString();
  } catch (exception) {/**/}

  return ipInfo;
}

Future<Map<String, dynamic>> getLocationFromIP(String ip) async {
  final url = Uri.parse('http://ip-api.com/json/$ip?fields=status,country,regionName,city,timezone,isp');

  try {
    final response = await http
        .get(url)
        .timeout(const Duration(seconds: 3));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["status"] == "success") {
        return data;
      } else {
        return <String, dynamic>{};
      }
    } else {
      return <String, dynamic>{};
    }
  } on TimeoutException catch (_) {
    return <String, dynamic>{};
  } catch (e) {
    return <String, dynamic>{};
  }
}