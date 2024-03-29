import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:fitnessapp/main.dart';
import 'package:fitnessapp/screens/HomeScreen.dart';
import 'package:fitnessapp/utils/AppWidgets.dart';
import 'package:fitnessapp/utils/Constants.dart';
import 'package:fitnessapp/utils/resources/Colors.dart';
import 'package:fitnessapp/utils/resources/Images.dart';
import 'package:fitnessapp/utils/resources/Size.dart';

class OnBoardingScreen extends StatefulWidget {
  static String tag = '/OnBoardingScreen';

  @override
  OnBoardingScreenState createState() => OnBoardingScreenState();
}

class OnBoardingScreenState extends State<OnBoardingScreen> {
  int currentIndexPage = 0;
  PageController controller = PageController();
  List<Widget> listItem = [];

  @override
  void initState() {
    listItem.addAll([
      WalkThrough(title: walk_titles[0], subtitle: walk_sub_titles[0]),
      WalkThrough(title: walk_titles[1], subtitle: walk_sub_titles[1]),
      WalkThrough(title: walk_titles[2], subtitle: walk_sub_titles[2]),
    ]);
    super.initState();
    setStatusBarColor(Colors.transparent);
  }

  @override
  void dispose() {
    setStatusBarColor(appBackground);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          commonCacheImageWidget(ic_walk_background, width: double.infinity, height: double.infinity, fit: BoxFit.cover),
          Container(
            height: double.infinity,
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
          ),
          Align(alignment: Alignment.topLeft, child: commonCacheImageWidget(ic_logo, height: 32)).paddingAll(spacing_standard_new),
          Container(
            height: context.height(),
            child: PageView(
              controller: controller,
              children: listItem,
              onPageChanged: (value) {
                setState(() => currentIndexPage = value);
              },
            ).paddingTop(spacing_standard),
          ),
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: listItem.map((e) {
                int index = listItem.indexOf(e);
                return AnimatedContainer(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  duration: const Duration(milliseconds: 150),
                  height: 10,
                  width: index == currentIndexPage ? 24 : 10,
                  decoration: BoxDecoration(
                    color: index == currentIndexPage ? colorPrimary : colorPrimary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(index == currentIndexPage ? 8 : 100),
                  ),
                );
              }).toList(),
            ).paddingAll(spacing_standard_new),
          ),
          AppButton(
            width: context.width(),
            textColor: colorPrimary,
            color: colorPrimary,
            padding: EdgeInsets.only(top: 12, bottom: 12),
            child: Text(
              language!.getStarted,
              style: primaryTextStyle(size: ts_normal.toInt(), color: context.textTheme.labelLarge!.color),
            ),
            shapeBorder: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(spacing_control),
              side: BorderSide(color: colorPrimary),
            ),
            onTap: () {
              HomeScreen().launch(context, isNewTask: true);
            },
          ).paddingAll(spacing_standard_new),
        ],
      ).paddingTop(context.statusBarHeight),
    );
  }
}

class WalkThrough extends StatelessWidget {
  final String? title;
  final String? subtitle;

  WalkThrough({Key? key, this.title, this.subtitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title!, style: boldTextStyle(size: 22, color: Colors.white)),
          16.height,
          Text(subtitle!, style: secondaryTextStyle(size: 16, color: Colors.white), maxLines: 2),
        ],
      ),
    );
  }
}
