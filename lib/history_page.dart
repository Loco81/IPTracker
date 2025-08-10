import 'package:flutter/services.dart';
import 'language.dart';
import 'classes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';




List<Widget> togglePageList = [
  PublicIpHistory(),
  WifiIpHistory(),
];
int pagelistToggleValue = 0;



class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        body: Column(
          children: [
            CustomAnimatedToggle(
              values: [PUBLIC_IP, LOCAL_WIFI],
              onToggleCallback: (value) {
                setState(() {
                  pagelistToggleValue = value;
                });
              },
              buttonColor: Color.fromARGB(115, theme[1], theme[2], theme[3]),
              backgroundColor: Color.fromARGB(38, theme[1], theme[2], theme[3]),
              textColor: Colors.white,
            ),
            Expanded(
              child: GestureDetector(
                onHorizontalDragEnd: (info) {
                  if(info.primaryVelocity! > 0) {
                      pagelistToggleValue = 0;
                  }
                  else if(info.primaryVelocity! < 0) {
                      pagelistToggleValue = 1;              
                  }
                  setState(() {});
                },
                child: togglePageList.elementAt(pagelistToggleValue),
              ),
            ),
          ],
        ),
        appBar: AppBar(
          title: Center(child: SizedBox(width: 750.w, child: Text(CHANGE_HISTORY, style: TextStyle(fontFamily: FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, fontSize: 60.sp),),)),
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
            child: Icon(Icons.close_rounded, size: 100.r,),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            GestureDetector(
              child: Icon(Icons.cleaning_services_rounded, size: 85.r,),
              onTap: () async {
                HapticFeedback.mediumImpact();
                if(pagelistToggleValue==0) {
                  publicIpHistory.clear();
                  DateTime now = DateTime.now();
                  if(currentPublicIp.value!='') publicIpHistory.add([currentPublicIp.value.toString(), locationInfo.value['country'], '${now.year}/${now.month}/${now.day}  ${now.hour}:${now.minute}:${now.second}']);
                  dynamic li = locationInfo.value;
                  locationInfo.value = {};
                  locationInfo.value = li;
                  await storage.setItem('publicIpHistory', publicIpHistory);
                }
                else {
                  wifiIpHistory.clear();
                  DateTime now = DateTime.now();
                  if(currentWifiIp.value!='') wifiIpHistory.add([currentWifiIp.value.toString(), '${now.year}/${now.month}/${now.day}  ${now.hour}:${now.minute}:${now.second}']);
                  dynamic wi = currentWifiIp.value;
                  currentWifiIp.value = '';
                  currentWifiIp.value = wi;
                  await storage.setItem('wifiIpHistory', wifiIpHistory);
                }
              },
            ),
            SizedBox(width: 40.r,)
          ],
        ),
      )
    );
  }
}



class WifiIpHistory extends StatefulWidget {
  const WifiIpHistory({super.key});

  @override
  State<WifiIpHistory> createState() => _WifiIpHistoryState();
}

class _WifiIpHistoryState extends State<WifiIpHistory> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentWifiIp,
      builder: (context, value, child) { 
        return SingleChildScrollView(
          child: Column(
            spacing: 12.r,
            children: List.generate(wifiIpHistory.length, (index) {
              List<dynamic> rowItems = wifiIpHistory[index];

              return Row(
                children: [
                  SizedBox(width: 35.w,),
                  SizedBox(
                    width: 85.r,
                    child: Center(child: Text((index+1).toString(), style: TextStyle(fontFamily: 'Audiowide', fontWeight: FontWeight.bold, fontSize: 48.sp))),
                  ),
                  SizedBox(width: 60.w,),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 400.w,
                          height: 70.w,
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
                            child: Text(rowItems[0], style: TextStyle(fontFamily: 'AveriaLibre', fontWeight: FontWeight.bold, color: Theme.of(context).cardColor, fontSize: 40.sp),),
                          ),
                        ),
                        Text(rowItems[1], style: TextStyle(fontFamily: 'AveriaLibre', fontSize: 44.sp),),
                      ]
                    ),
                  ),
                  SizedBox(width: 50.w,),
                ]
              );
            }),
          ),
        );
      }
    );
  }
}


class PublicIpHistory extends StatefulWidget {
  const PublicIpHistory({super.key});

  @override
  State<PublicIpHistory> createState() => _PublicIpHistoryState();
}

class _PublicIpHistoryState extends State<PublicIpHistory> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: locationInfo,
      builder: (context, value, child) { 
        return SingleChildScrollView(
          child: Column(
            spacing: 12.r,
            children: List.generate(publicIpHistory.length, (index) {
              List<dynamic> rowItems = publicIpHistory[index];

              return Row(
                children: [
                  SizedBox(width: 35.w,),
                  SizedBox(
                    width: 85.r,
                    child: Center(child: Text((index+1).toString(), style: TextStyle(fontFamily: 'Audiowide', fontWeight: FontWeight.bold, fontSize: 48.sp))),
                  ),
                  SizedBox(width: 60.w,),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 400.w,
                          height: 70.w,
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
                            child: Text(rowItems[0], style: TextStyle(fontFamily: 'AveriaLibre', fontWeight: FontWeight.bold, color: Theme.of(context).cardColor, fontSize: 40.sp),),
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(rowItems[1], style: TextStyle(fontFamily: 'AveriaLibre', color: Colors.green[700], fontSize: 44.sp),),
                        ),
                        Text(rowItems[2], style: TextStyle(fontFamily: 'AveriaLibre', fontSize: 44.sp),),
                      ]
                    ),
                  ),
                  SizedBox(width: 50.w,),
                ]
              );
            }),
          ),
        );
      }
    );
  }
}