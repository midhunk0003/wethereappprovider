import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:wetherappapiprovider/data/image_path.dart';
import 'package:wetherappapiprovider/secretes/wether_service_provider.dart';
import 'package:wetherappapiprovider/services/location_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);

    locationProvider.determinPosition().then((_) {
      if (locationProvider.currentLocationName != null) {
        var city = locationProvider.currentLocationName!.locality;
        if (city != null) {
          Provider.of<WetherServiceProvider>(context, listen: false)
              .fetchWetherData(city.toString(), context);
        }
      } else {
        print("please enable location");
      }
    });
    super.initState();
  }

  TextEditingController citynameController = TextEditingController();

  @override
  void dispose() {
    citynameController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() async {
    // Fetch weather data
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    if (locationProvider.currentLocationName != null) {
      var city = locationProvider.currentLocationName!.locality;
      if (city != null) {
        await Provider.of<WetherServiceProvider>(context, listen: false)
            .fetchWetherData(city.toString(), context);
      }
    }

    // if failed, use refreshFailed()
    _refreshController.refreshCompleted();
  }

  bool isclickesearch = false;

  @override
  Widget build(BuildContext context) {
    final wetherProvider = Provider.of<WetherServiceProvider>(context);
    Size size = MediaQuery.of(context).size;
    final locationProvider = Provider.of<LocationProvider>(context);
    //sunrise and sunset

    int sunriseTimeStamp = wetherProvider.wether?.sys?.sunrise ?? 0;
    int sunsetTimeStamp = wetherProvider.wether?.sys?.sunset ?? 0;

    // convert the time stamp to date time format

    DateTime sunriseDateTime =
        DateTime.fromMillisecondsSinceEpoch(sunriseTimeStamp);
    DateTime sunsetDateTime =
        DateTime.fromMillisecondsSinceEpoch(sunsetTimeStamp);

    //format the sunrise time as a String

    String formattedSunrise = DateFormat.Hm().format(sunriseDateTime);
    String formattedSunSet = DateFormat.Hm().format(sunsetDateTime);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(),
      body: Consumer<WetherServiceProvider>(
        builder: (BuildContext context,
            WetherServiceProvider wetherServiceProvider, Widget) {
          return SmartRefresher(
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: Container(
              padding: EdgeInsets.only(top: 65, left: 40, right: 40),
              height: size.height,
              width: size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(
                    background[
                            wetherProvider.wether?.weather![0].main ?? "N/A"] ??
                        "assets/images/default.png",
                  ),
                ),
              ),
              child: Stack(
                children: [
                  // /search bar
                  isclickesearch == true
                      ? Positioned(
                          top: 60,
                          left: 20,
                          right: 20,
                          child: Container(
                            height: 45,
                            // color: Colors.red,
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: citynameController,
                                    decoration: InputDecoration(
                                        hintText: 'Search Location',
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.green))),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    print(citynameController.text);
                                    Provider.of<WetherServiceProvider>(context,
                                            listen: false)
                                        .fetchWetherData(
                                            citynameController.text.toString(),
                                            context);
                                  },
                                  icon: Icon(Icons.search),
                                )
                              ],
                            ),
                          ),
                        )
                      : SizedBox(),

                  ///search bar end
                  Container(
                    height: 50,
                    child: Consumer<LocationProvider>(builder:
                        (BuildContext context,
                            LocationProvider locationProvider, child) {
                      var locationCity;
                      if (locationProvider.currentLocationName != null) {
                        locationCity =
                            locationProvider.currentLocationName!.locality;
                      } else {
                        locationCity = "Unknown Location";
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            // color: Colors.green,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_pin,
                                  // color: Colors.red,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${locationCity}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18,
                                          color: Colors.white),
                                    ),
                                    Text(
                                      'Good Morning',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          color: Colors.white),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                isclickesearch = !isclickesearch;
                              });
                            },
                            icon: Icon(
                              Icons.search,
                              size: 32,
                            ),
                          )
                        ],
                      );
                    }),
                  ),

                  /// image
                  Consumer<WetherServiceProvider>(
                    builder: (BuildContext context,
                        WetherServiceProvider wetherServiceProvider, child) {
                      if (wetherServiceProvider.isloading) {
                        return Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            child: Lottie.asset(
                              'assets/json/Animation - 1719578745161.json',
                            ),
                          ),
                        );
                      } else if (wetherServiceProvider.wether != null) {
                        return Stack(
                          children: [
                            Align(
                              alignment: Alignment(0, -0.5),
                              child: Image.asset(
                                imagepathsmall[wetherProvider
                                            .wether?.weather![0].main ??
                                        "N/A"] ??
                                    "assets/images/default.png",
                                width: 170,
                              ),
                            ),

                            //second part
                            //value of temp

                            Align(
                              alignment: Alignment(0, 0),
                              child: Container(
                                // color: Colors.amber,
                                height: 150,
                                width: 130,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${wetherProvider.wether?.main!.temp?.toStringAsFixed(0) ?? "N/A"}\u00B0C',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${wetherProvider.wether?.name ?? "N/A"}',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${wetherProvider.wether?.weather?[0].main ?? "N/A"}',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 26),
                                    ),
                                    Text(
                                      '${DateFormat("hh:mm a").format(DateTime.now())}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            //second part end

                            Align(
                              alignment: Alignment(0, 0.75),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(20)),
                                height: 180,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                              'assets/images/temperature-high.png',
                                              height: 55,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Temp Max',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14),
                                                ),
                                                Text(
                                                  '${wetherProvider.wether?.main!.tempMax!.toStringAsFixed(0) ?? "N/A"}\u00B0C',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Row(
                                          children: [
                                            Image.asset(
                                              'assets/images/temperature-low.png',
                                              height: 55,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Temp Min',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14),
                                                ),
                                                Text(
                                                  "${wetherProvider.wether?.main!.tempMin!.toStringAsFixed(0) ?? "N/A"}\u00B0C",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      color: Colors.white,
                                      thickness: 2,
                                      indent: 20,
                                      endIndent: 20,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                              'assets/images/sun.png',
                                              height: 55,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'SunRise',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14),
                                                ),
                                                Text(
                                                  '${formattedSunrise} AM',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Row(
                                          children: [
                                            Image.asset(
                                              'assets/images/moon.png',
                                              height: 55,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Sun set',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14),
                                                ),
                                                Text(
                                                  '${formattedSunSet} PM',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      } else if (wetherServiceProvider.errors!.isNotEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                child: Lottie.asset(
                                  'assets/json/Animation - 1719578745161.json',
                                ),
                              ),
                              Center(
                                child: Text(
                                  wetherServiceProvider.errors!,
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 219, 67, 59),
                                      fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),

                  //third part
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
