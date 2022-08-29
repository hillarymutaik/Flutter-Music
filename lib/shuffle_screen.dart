import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:soundwave/item_builder.dart';
import 'package:soundwave/network.dart';
import 'package:soundwave/widgets/menu_button.dart';
import 'package:soundwave/music/song.dart';

class ShuffleScreen extends StatefulWidget {
  ShuffleScreen(this.data, {Key key, this.title}) : super(key: key);
  final String title;
  final dynamic data;

  @override
  _ShuffleScreenState createState() => new _ShuffleScreenState();
}

class _ShuffleScreenState extends State<ShuffleScreen>
    with TickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;

  String title;
  ItemBuilder _itemBuilder;
  Future<dynamic> future;
  ScrollController scrollController;
  bool visible = false;
  @override
  void initState() {
    super.initState();
    title = "Home";
    _itemBuilder = ItemBuilder(context);
    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    animation = Tween(begin: 0.0, end: 1.0).animate(controller);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.brown,
    ));
    print("3");
    scrollController = ScrollController();
    future = Network.getDetails(widget.data.url);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        navigationBar: createAppbar(),
        child: dynamicBody());
  }

  CupertinoNavigationBar createAppbar() {
    return CupertinoNavigationBar(
        leading: CupertinoButton(
          child: Icon(
            CupertinoIcons.left_chevron,
            color: Theme.of(context).iconTheme.color,
            size: 28.0,
          ),
          minSize: 0.0,
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
        middle: Text(
          widget.data.type[0].toUpperCase() + widget.data.type.substring(1),
          style: Theme.of(context).textTheme.headline1,
          textAlign: TextAlign.center,
        ),
        heroTag: DateTime.now().toString(),
        transitionBetweenRoutes: false,
        backgroundColor: Colors.transparent,
        trailing: MenuButton(widget.data));
  }

  Widget dynamicBody() {
    print("1");
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text("Sorry something wrong happened"));
        }
        var map = snapshot.data;
        List<Widget> widgets = [];
        Details details;
        if (map["details"] != null) {
          details = map["details"];
        } else {
          try {
            details = widget.data;
          } catch (exception) {
            print(exception);
          }
        }
        if (map["songs"] != null) {
          Map<String, dynamic> temp = details.toMap();
          temp["songs"] = map["songs"];
          Album album = Album.fromMap(temp);
          widgets.add(album.buildCoverWidget(context));
          widgets
              .add(_itemBuilder.buildSongsList(map["songs"], map["details"]));
        }
        if (map["artists"] != null && map["artists"].length != 0) {
          widgets.add(_itemBuilder.buildArtistList(map["artists"],
              axis: Axis.vertical));
        }
        if (map["albums"] != null && map["albums"].length != 0) {
          widgets.add(_itemBuilder.buildRelated(map["albums"]));
        }
        if (details != null) widgets.add(_itemBuilder.buildDetails(details));

        return ListView.builder(
          itemBuilder: (context, index) {
            return widgets[index];
          },
          controller: scrollController,
          itemCount: widgets.length,
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
        );
      },
    );
  }

  Widget buildCoverWidget(
    Details details,
  ) {
    double size = 150.0;
    return Container(
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ClipRRect(
            borderRadius: details.type == "artist"
                ? BorderRadius.circular(50.0)
                : BorderRadius.circular(4.0),
            child: Image(
              image: NetworkImage(details.thumbnail),
              width: size + 10.0,
              height: size,
              fit: BoxFit.fill,
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 3 / 4,
            padding: EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
            child: Text(title,
                style:
                    Theme.of(context).textTheme.titleMedium.copyWith(fontSize: 20.0),
                textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget createMenuButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: MenuButton(
        widget.data,
      ),
    );
  }
}
