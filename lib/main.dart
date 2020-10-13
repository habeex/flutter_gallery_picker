import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:postagraph_gallery/media_option.dart';

void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media Picker Example',
      theme: ThemeData(
        // This is the theme of your application.
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Media Picker Example App'),
    );
  }
}
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: MediaGrid(),
    );
  }
}
class MediaGrid extends StatefulWidget {
  @override
  _MediaGridState createState() => _MediaGridState();
}
class _MediaGridState extends State<MediaGrid> {
  List<MediaOption> medias = [];
  int currentPage = 0;
  int selectedItems = 0;
  int lastPage;
  @override
  void initState() {
    super.initState();
    _fetchNewMedia();
  }

  _handleScrollEvent(ScrollNotification scroll) {
    print("_handleScrollEvent $currentPage $lastPage");
    if (scroll.metrics.pixels / scroll.metrics.maxScrollExtent > 0.33) {
      if (currentPage != lastPage) {
        _fetchNewMedia();
      }
    }
  }

  _fetchNewMedia() async {
    print("_fetchNewMedia $currentPage $lastPage");

    lastPage = currentPage;
    var result = await PhotoManager.requestPermission();
    if (result) {
      // success
//load the album list
      List<AssetPathEntity> albums =
      await PhotoManager.getAssetPathList(onlyAll: true);
      print(albums.length);
      List<AssetEntity> media =
      await albums[0].getAssetListPaged(currentPage, 60);
      print(media.length);

      for (var asset in media) {
        medias.add(MediaOption(asset: asset));
      }
      setState(() {
        currentPage++;
      });
    } else {
      // fail
      /// if result is fail, you can call `PhotoManager.openSetting();`  to open android/ios applicaton's setting to get permission
    }
  }

  String showDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return twoDigits(duration.inHours) != '00' ? "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds" :
    twoDigitMinutes != '00' ? "$twoDigitMinutes:$twoDigitSeconds" :
    "0:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    print("BuildContext $currentPage $lastPage");

//    return Scaffold(
//      body: CustomScrollView(
//        key: PageStorageKey("media"),
//        physics: AlwaysScrollableScrollPhysics(),
//        slivers: <Widget>[
//          SliverGrid(
//            delegate: SliverChildBuilderDelegate(
//                  (context, index) {
//                return item(medias[index]);
//              },
//              childCount: medias.length,
//            ),
//          )
//        ],
//      ),
//    );
//
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scroll) {
        _handleScrollEvent(scroll);
        return;
      },
      child: GridView.builder(
          itemCount: medias.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          itemBuilder: (BuildContext context, int index) {
            return item(medias[index]);
          }),
    );
  }

  Widget item(MediaOption media){
    return FutureBuilder(
      future: media.asset.thumbDataWithSize(200, 200),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done)
          return InkWell(
            onTap: (){
              setState(() {
                media.selected = !media.selected;
                if(media.selected){
                  selectedItems ++;
                }else{
                  selectedItems --;
                }
              });
            },
            child: Stack(
              children: <Widget>[
                Stack(
                  key: ValueKey(media.asset.id),
                  children: <Widget>[
                    Positioned.fill(
                      child: Image.memory(
                        snapshot.data,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (media.asset.type == AssetType.video)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: 5, bottom: 5),
                          child: Text("${showDuration(media.asset.videoDuration)}", style: TextStyle(color: Colors.white),),
                        ),
                      ),
                  ],
                ),
                if(media.selected)
                  Stack(
                    children: <Widget>[
                      Positioned.fill(
                          child: Container(
                            color: Colors.white54,
                          )
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(20 / 2),
                              child: Container(
                                color: Colors.red,
                                  child: Text("${selectedItems}", style: TextStyle(color: Colors.white),)
                              )
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        return Container();
      },
    );
  }
}