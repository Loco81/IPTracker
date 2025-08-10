import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animations/animations.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'history_page.dart';
import 'classes.dart';
import 'language.dart';



class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Map<dynamic, dynamic> ipInfo = {};
  Timer? _timer;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    Future<void> publicIpChanged(ip) async {
      isLoading = false;
      if(ip!='') {
        locationInfo.value = await getLocationFromIP(ip);
        if(publicIpHistory.isNotEmpty) {
          if(ip.toString() != (publicIpHistory.last[0])) {
            DateTime now = DateTime.now();
            publicIpHistory.add([ip.toString(), locationInfo.value['country'], '${now.year}/${now.month}/${now.day}  ${now.hour}:${now.minute}:${now.second}']);
            if(publicIpHistory.length>99) publicIpHistory.removeAt(0);
            await storage.setItem('publicIpHistory', publicIpHistory);
          }
        }
        else {
          DateTime now = DateTime.now();
          publicIpHistory.add([ip.toString(), locationInfo.value['country'], '${now.year}/${now.month}/${now.day}  ${now.hour}:${now.minute}:${now.second}']);
          await storage.setItem('publicIpHistory', publicIpHistory);
        }
      }
      else {
        locationInfo.value = <String, dynamic>{};
      }
    }
    Future<void> wifiIpChanged(ip) async {
      if(ip!='') {
        if(wifiIpHistory.isNotEmpty) {
          if(ip.toString() != (wifiIpHistory.last[0])) {
            DateTime now = DateTime.now();
            wifiIpHistory.add([ip.toString(), '${now.year}/${now.month}/${now.day}  ${now.hour}:${now.minute}:${now.second}']);
            if(wifiIpHistory.length>99) wifiIpHistory.removeAt(0);
            await storage.setItem('wifiIpHistory', wifiIpHistory);
          }
        }
        else {
          DateTime now = DateTime.now();
          wifiIpHistory.add([ip.toString(), '${now.year}/${now.month}/${now.day}  ${now.hour}:${now.minute}:${now.second}']);
          await storage.setItem('wifiIpHistory', wifiIpHistory);
        }
      }
    }
    currentPublicIp.removeListener(() async => await publicIpChanged(currentPublicIp.value));
    currentPublicIp.addListener(() async => await publicIpChanged(currentPublicIp.value));
    currentWifiIp.removeListener(() async => await wifiIpChanged(currentWifiIp.value));
    currentWifiIp.addListener(() async => await wifiIpChanged(currentWifiIp.value));

    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      ipInfo = await getIp();
      isLoading = false;
      currentPublicIp.value = ipInfo['Internet'] ?? '';
      currentWifiIp.value = ipInfo['WiFi'] ?? '';
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 50.w,),
                Transform.scale(
                  scale: 4.5.r,
                  child: GestureDetector(
                    child: Image.asset('assets/$languageValue.png', scale: 3),
                    onTap: () => setState(() {changeLanguage();})
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(scale: 3.6.r, child: ThemeModer()),
                SizedBox(width: 25.w,),
              ],
            ),
          ],
        ),
        Stack(
          children: [
            Container(
              width: 0.67.sw,
              height: 1000.r,
              decoration: ShapeDecoration(
                color: Theme.of(context).cardColor,
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(340.r),
                ),
                shadows: [
                  BoxShadow(
                    color: Color.fromARGB(80, theme[1], theme[2], theme[3]),
                    blurRadius: 62.r
                  )
                ]
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(height: 50.r,),
                  Text(PUBLIC_IP_INFO, style: TextStyle(fontFamily: FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, fontSize: 64.sp),),
                  SizedBox(height: 50.r,),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    textDirection: languageValue=='English' ? TextDirection.ltr : TextDirection.rtl,
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: isVpnActivated ? Colors.orange : Colors.lightBlueAccent,
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: [BoxShadow(
                            color: isVpnActivated ? Colors.orange : Colors.lightBlueAccent,
                            blurRadius: 20.r,
                            offset: Offset.zero
                          )]
                        ),
                      ),
                      SizedBox(width: 15.w,),
                      Text(isVpnActivated ? VPN_IS_ACTIVE : VPN_IS_NOT_ACTIVE, style: TextStyle(fontFamily: FONTFAMILY_DESCRIPTION, fontSize: 50.sp),),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    textDirection: languageValue=='English' ? TextDirection.ltr : TextDirection.rtl,
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: ipInfo.containsKey('Internet') ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: [BoxShadow(
                            color: ipInfo.containsKey('Internet') ? Colors.green : Colors.red,
                            blurRadius: 20.r,
                            offset: Offset.zero
                          )]
                        ),
                      ),
                      SizedBox(width: 15.w,),
                      Text(ipInfo.containsKey('Internet') ? INTERNET_ACCESS : NO_INTERNET_ACCESS, style: TextStyle(fontFamily: FONTFAMILY_DESCRIPTION, fontSize: 50.sp),),
                    ],
                  ),
                  Visibility(
                    visible: ipInfo.containsKey('Internet') ? true : false,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      textDirection: languageValue=='English' ? TextDirection.ltr : TextDirection.rtl,
                      children: [
                        Container(
                          width: 190.w,
                          height: 50.w,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: [BoxShadow(
                              color: Colors.green,
                              blurRadius: 20.r,
                              offset: Offset.zero
                            )]
                          ),
                          child: Center(
                            child: Text(PUBLIC_IP, style: TextStyle(fontFamily: FONTFAMILY_DESCRIPTION, fontWeight: FontWeight.bold, color: Theme.of(context).cardColor, fontSize: 36.sp),),
                          ),
                        ),
                        SizedBox(width: 18.w,),
                        Text(ipInfo['Internet']??'', style: TextStyle(fontFamily: 'AveriaLibre', fontSize: 50.sp),),
                        SizedBox(width: 18.w,),
                        GestureDetector(
                          child: Icon(Icons.info_outline_rounded, size: 60.r, color: Color.fromARGB(220, theme[1], theme[2], theme[3]),),
                          onTap: () => showIpInfo(context),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 50.r,),
                  Text(LOCAL_IP_INFO, style: TextStyle(fontFamily: FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, fontSize: 64.sp),),
                  SizedBox(height: 50.r,),
                  isVpnActivated ?
                    Text(TURN_OFF_VPN, style: TextStyle(fontFamily: FONTFAMILY_DESCRIPTION, fontSize: 46.sp),) :
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          textDirection: languageValue=='English' ? TextDirection.ltr : TextDirection.rtl,
                          children: [
                            Container(
                              width: 125.w,
                              height: 50.w,
                              decoration: BoxDecoration(
                                color: ipInfo.containsKey('WiFi') ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(8.r),
                                boxShadow: [BoxShadow(
                                  color: ipInfo.containsKey('WiFi') ? Colors.green : Colors.red,
                                  blurRadius: 20.r,
                                  offset: Offset.zero
                                )]
                              ),
                              child: Center(
                                child: Text(WIFI, style: TextStyle(fontFamily: FONTFAMILY_DESCRIPTION, fontWeight: FontWeight.bold, color: Theme.of(context).cardColor, fontSize: 36.sp),),
                              ),
                            ),
                            SizedBox(width: 15.w,),
                            Text(ipInfo.containsKey('WiFi') ? ipInfo['WiFi'] : '', style: TextStyle(fontFamily: 'AveriaLibre', fontSize: 50.sp),),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          textDirection: languageValue=='English' ? TextDirection.ltr : TextDirection.rtl,
                          children: [
                            Container(
                              width: 200.w,
                              height: 50.w,
                              decoration: BoxDecoration(
                                color: ipInfo.containsKey('Hotspot') ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(8.r),
                                boxShadow: [BoxShadow(
                                  color: ipInfo.containsKey('Hotspot') ? Colors.green : Colors.red,
                                  blurRadius: 20.r,
                                  offset: Offset.zero
                                )]
                              ),
                              child: Center(
                                child: Text(HOTSPOT, style: TextStyle(fontFamily: FONTFAMILY_DESCRIPTION, fontWeight: FontWeight.bold, color: Theme.of(context).cardColor, fontSize: 36.sp),),
                              ),
                            ),
                            SizedBox(width: 15.w,),
                            Text(ipInfo.containsKey('Hotspot') ? ipInfo['Hotspot'] : '', style: TextStyle(fontFamily: 'AveriaLibre', fontSize: 50.sp),),
                          ],
                        ),
                      ]
                    ),
                  SizedBox(height: 50.r,),
                  OpenContainer(
                    transitionType: ContainerTransitionType.fade,
                    transitionDuration: Duration(milliseconds: 600),
                    closedElevation: 0,
                    closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    closedColor: Colors.transparent,
                    openColor: Colors.transparent,
                    closedBuilder: (context, openContainer) {
                      return GestureDetector(
                        onTap: openContainer,
                        child: Container(
                          height: 95.h,
                          width: 0.6.sw,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            border: Border(
                              top: BorderSide(color: Color.fromARGB(255, theme[1], theme[2], theme[3]), width: 0.7),
                              bottom: BorderSide(color: Color.fromARGB(255, theme[1], theme[2], theme[3]), width: 0.7),
                            ),
                            borderRadius: BorderRadius.circular(45.r),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(80, theme[1], theme[2], theme[3]),
                                blurRadius: 30.r
                              )
                            ]
                          ),
                          child: Center(child: Text(CHANGE_HISTORY, style: TextStyle(fontFamily: FONTFAMILY_SUBJECT, fontSize: 48.r, color: Color.fromARGB(255, theme[1], theme[2], theme[3])),),),
                        )
                      );
                    },
                    openBuilder: (context, _) {
                      return HistoryPage(); 
                    },
                  ),
                  SizedBox(height: 50.r,),
                ]
              )
            ),
            Visibility(
              visible: isLoading,
              child: Container(
                width: 0.67.sw,
                height: 1000.r,
                decoration: ShapeDecoration(
                  color: Theme.of(context).cardColor,
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(340.r),
                  ),
                ),
                child: LoadingAnimationWidget.inkDrop(color: Color.fromARGB(220, theme[1], theme[2], theme[3]), size: 160.r),
              )
            ),
          ]
        ),
        SizedBox(
          height: 100.r,
          child: Center(
            child: Text('${deviceInfo[0].toUpperCase()} ${deviceInfo[1].toUpperCase()} ANDROID ${deviceInfo[2]}', style: TextStyle(color: Color.fromARGB(255, theme[1], theme[2], theme[3]), fontFamily: 'Harmattan', fontSize: 44.sp),),
          ),
        )
      ],
    );
  }
}