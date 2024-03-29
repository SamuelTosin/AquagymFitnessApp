import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:fitnessapp/components/DownloadButtonWidget.dart';
import 'package:fitnessapp/components/LoadingDotWidget.dart';
import 'package:fitnessapp/components/SourcesDataWidget.dart';
import 'package:fitnessapp/components/TrailerVideoWidget.dart';
import 'package:fitnessapp/components/UpcomingRelatedMovieListWidget.dart';
import 'package:fitnessapp/components/VideoContentWidget.dart';
import 'package:fitnessapp/main.dart';
import 'package:fitnessapp/models/MovieData.dart';
import 'package:fitnessapp/models/MovieDetailResponse.dart';
import 'package:fitnessapp/network/NetworkUtils.dart';
import 'package:fitnessapp/network/RestApis.dart';
import 'package:fitnessapp/screens/CastDetailScreen.dart';
import 'package:fitnessapp/screens/EditProfileScreen.dart';
import 'package:fitnessapp/screens/Signin.dart';
import 'package:fitnessapp/utils/AppWidgets.dart';
import 'package:fitnessapp/utils/Common.dart';
import 'package:fitnessapp/utils/Constants.dart';
import 'package:fitnessapp/utils/resources/Colors.dart';
import 'package:fitnessapp/utils/resources/Images.dart';
import 'package:fitnessapp/utils/resources/Size.dart';

import 'movieDetailComponents/MovieDetailLikeWatchListWidget.dart';
import 'movieDetailComponents/SeasonDataWidget.dart';

class MovieDetailScreen extends StatefulWidget {
  final String? title;
  final MovieData movieData;

  MovieDetailScreen({this.title = "", required this.movieData});

  @override
  MovieDetailScreenState createState() => MovieDetailScreenState();
}

class MovieDetailScreenState extends State<MovieDetailScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ScrollController scrollController = ScrollController();

  late MovieData movie;

  List<MovieData> mMovieList = [];
  List<MovieData> mMovieOriginalsList = [];

  bool isSubscribe = false;

  Future<MovieDetailResponse>? future;

  int page = 1;
  String genre = '';

  PostType? postType;

  @override
  void initState() {
    super.initState();
    movie = widget.movieData;
    postType = movie.postType!;

    if (postType == PostType.MOVIE) {
      future = movieDetail(movie.id.validate());
    } else if (postType == PostType.TV_SHOW) {
      future = tvShowDetail(movie.id.validate());
    } else if (postType == PostType.EPISODE) {
      future = episodeDetail(movie.id.validate());
    } else if (postType == PostType.VIDEO) {
      future = getVideosDetail(movie.id.validate());
    }
  }
  //fetch user plan data from shared pref

  Future<void> init() async {
    isSubscribe = await getUserPlanData(movie.restSubPlan.validate());
  }

  double roundDouble({required double value, int? places}) =>
      ((value * 10).round().toDouble() / 10);

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget subscriptionWidget() {
    return Observer(
      builder: (_) {
        if (!appStore.isTrailerVideoPlaying) {
          if (!movie.isPostRestricted.validate()) {
            return Stack(
              children: [
                VideoContentWidget(
                  choice: movie.choice,
                  image: movie.image,
                  embedContent: movie.embedContent,
                  urlLink: movie.urlLink,
                  fileLink: movie.file,
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, size: 24),
                    onPressed: () {
                      if (appStore.hasInFullScreen) {
                        appStore.setToFullScreen(false);
                        setOrientationPortrait();
                      } else {
                        finish(context);
                      }
                    },
                  ).visible(isAndroid),
                ),
              ],
            );
          } else {
            return Container(
              width: context.width(),
              height: appStore.hasInFullScreen
                  ? context.height() - 25
                  : context.height() * 0.3,
              child: Stack(
                children: [
                  commonCacheImageWidget(
                    movie.image.validate(),
                    width: context.width(),
                    fit: BoxFit.cover,
                  ),
                  Container(
                      color: Colors.black.withOpacity(0.7),
                      width: context.width()),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (movie.isPostRestricted.validate() && mIsLoggedIn)
                        if (movie.restrictionSetting!.restrictType ==
                                RestrictionTypeMessage ||
                            movie.restrictionSetting!.restrictType ==
                                RestrictionTypeTemplate ||
                            movie.restrictionSetting!.restrictType
                                .validate()
                                .isEmpty)
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  openInfoBottomSheet(
                                    context: context,
                                    restrictSubscriptionPlan: movie.restSubPlan,
                                    data: HtmlWidget(
                                      '<html>${movie.restrictionSetting!.restrictMessage.validate().replaceAll('&lt;', '<').replaceAll('&gt;', '>').replaceAll('&quot;', '"').replaceAll('[embed]', '<embed>').replaceAll('[/embed]', '</embed>').replaceAll('[caption]', '<caption>').replaceAll('[/caption]', '</caption>')}</html>',
                                    ),
                                    btnText: language!.subscribeNow,
                                    onTap: () async {
                                      finish(context);
                                      if (getStringAsync(ACCOUNT_PAGE)
                                          .isNotEmpty) {
                                        await launchURL(getStringAsync(
                                                REGISTRATION_PAGE))
                                            .then((value) async {
                                          await refreshToken();
                                          getUserProfileDetails().then((value) {
                                            setState(() {});
                                          });
                                        });
                                      } else {
                                        toast(redirectionUrlNotFound);
                                      }
                                    },
                                  );
                                },
                                child: Text(language!.viewInfo,
                                    style: boldTextStyle(color: Colors.white)),
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        colorPrimary)),
                              ),
                            ],
                          ),
                      if (movie.isPostRestricted.validate() && !mIsLoggedIn)
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                openInfoBottomSheet(
                                  context: context,
                                  restrictSubscriptionPlan: movie.restSubPlan,
                                  data: HtmlWidget(
                                    '<html>${movie.restrictionSetting!.restrictMessage.validate().replaceAll('&lt;', '<').replaceAll('&gt;', '>').replaceAll('&quot;', '"').replaceAll('[embed]', '<embed>').replaceAll('[/embed]', '</embed>').replaceAll('[caption]', '<caption>').replaceAll('[/caption]', '</caption>')}</html>',
                                  ),
                                  btnText: language!.loginNow,
                                  onTap: () {
                                    finish(context);
                                    SignInScreen().launch(context);
                                  },
                                );
                              },
                              child: Text(language!.viewInfo,
                                  style: boldTextStyle(color: Colors.white)),
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(colorPrimary)),
                            ),
                          ],
                        ),
                    ],
                  ).center(),
                ],
              ),
            );
          }
        } else {
          return TrailerVideoWidget(
            url: movie.trailerLink,
            image: movie.image.validate(),
            onTap: () async {
              youtubePlayerController!.pause();
              appStore.setTrailerVideoPlayer(false);
              setState(() {});
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (appStore.hasInFullScreen) {
          appStore.setToFullScreen(false);
          setOrientationPortrait();
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Theme.of(context).cardColor,
          centerTitle: false,
          title: commonCacheImageWidget(ic_logo, height: 32),
          leading: BackButton(
            color: Colors.white,
          ),
          automaticallyImplyLeading: false,
          actions: [
            appStore.isLogging
                ? Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(shape: BoxShape.circle),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: commonCacheImageWidget(
                appStore.userProfileImage.validate(),
                fit: appStore.userProfileImage.validate().contains("http")
                    ? BoxFit.cover
                    : BoxFit.cover,
              ).onTap(() {
                EditProfileScreen().launch(context);
              },
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent),
            )
                : commonCacheImageWidget(
              add_user,
              width: 20,
              fit: BoxFit.cover,
              height: 20,
              color: Colors.white,
            ).paddingAll(16).onTap(() {
              SignInScreen().launch(context);
            }, borderRadius: BorderRadius.circular(60)),
          ],
        ),
        /*appBar: AppBar(
          backgroundColor: Theme.of(context).cardColor,
          centerTitle: false,
          titleTextStyle: boldTextStyle(color: Colors.white, size: 22, ),
          title: const Text('Dashboard'),
          leading: BackButton(
            color: Colors.white,
          ),
        ),*/
        /*appBar: PreferredSize(
          preferredSize: movie.isPostRestricted.validate() ||
                  appStore.isTrailerVideoPlaying
              ? Size(context.width(), kToolbarHeight)
              : Size(0, 0),
          child: appBarWidget(
            parseHtmlString(movie.title.validate()),
            color: colorPrimaryDark,
            textColor: Colors.white,
            elevation: 0,
          ),
        ),*/

        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: FutureBuilder<MovieDetailResponse>(
            future: future!.then((value) => value),
            builder: (_, snap) {
              if (snap.hasData) {
                movie = snap.data!.data!;

                if (movie.postType == PostType.TV_SHOW) {
                  log(snap.data!.seasons.validate().length);
                }

                if (snap.data!.data!.genre != null) {
                  snap.data!.data!.genre!.forEach((element) {
                    genre = '';
                    if (genre.isNotEmpty) {
                      genre = '$genre • ${element.name.validate()}';
                    } else {
                      genre = element.name.validate();
                    }
                  });
                }

                if (snap.data!.data!.cat != null) {
                  snap.data!.data!.cat!.forEach((element) {
                    genre = '';
                    if (genre.isNotEmpty) {
                      genre = '$genre • ${element.name.validate()}';
                    } else {
                      genre = element.name.validate();
                    }
                  });
                }
              }
              return Observer(
                builder: (ctx) {
                  if (!appStore.hasInFullScreen) {
                    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                        overlays: SystemUiOverlay.values);
                    setOrientationPortrait();
                  } else {
                    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
                    setOrientationLandscape();
                  }
                  return SingleChildScrollView(
                    physics: appStore.hasInFullScreen
                        ? NeverScrollableScrollPhysics()
                        : ScrollPhysics(),
                    controller: scrollController,
                    padding: EdgeInsets.only(bottom: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        subscriptionWidget(),
                        8.height,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                headingText(
                                    parseHtmlString(movie.title.validate()),
                                    fontSize: 30,
                                    maxLines: 2),
                                8.height,
                                movie.imdbRating != null &&
                                        movie.imdbRating != 0.0
                                    ? Row(
                                        children: [
                                          RatingBarIndicator(
                                            rating: roundDouble(
                                                value: movie.imdbRating
                                                        .toDouble() ??
                                                    0,
                                                places: 1),
                                            itemBuilder: (context, index) =>
                                                Icon(Icons.star,
                                                    color: colorPrimary),
                                            itemCount: 5,
                                            itemSize: 14.0,
                                            unratedColor: Colors.white12,
                                          ),
                                          4.width,
                                          Text(
                                            '(${roundDouble(value: movie.imdbRating.toDouble() ?? 0, places: 1)})',
                                            style: primaryTextStyle(
                                                color: Colors.white, size: 12),
                                          ),
                                        ],
                                      ).visible(
                                        movie.postType == PostType.MOVIE)
                                    : SizedBox(),
                                4.height,
                                itemSubTitle(
                                  context,
                                  genre,
                                  fontSize: ts_small,
                                  textColor: Colors.grey.shade500,
                                ).visible(genre.trim().isNotEmpty),
                                4.height,
                                if (snap.hasData)
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Container(
                                            child: Text(
                                              snap.data!.data!.censorRating
                                                  .validate(),
                                              style: boldTextStyle(
                                                  color: Colors.black,
                                                  size: 12),
                                            ),
                                            padding: EdgeInsets.only(
                                                left: 4,
                                                right: 4,
                                                top: 2,
                                                bottom: 2),
                                            decoration: BoxDecoration(
                                                color: Colors.white),
                                          )
                                              .cornerRadiusWithClipRRect(4)
                                              .visible(snap
                                                  .data!.data!.censorRating
                                                  .validate()
                                                  .isNotEmpty),
                                          8.width.visible(
                                              snap.data!.data!.censorRating !=
                                                  null),
                                          Container(
                                            child: Row(
                                              children: [
                                                Icon(Icons.visibility_outlined,
                                                    color: Colors.black,
                                                    size: 12),
                                                4.width,
                                                Text(
                                                  '${snap.data!.data!.views.validate()}',
                                                  style: boldTextStyle(
                                                      size: 12,
                                                      color: Colors.black),
                                                ),
                                                4.width,
                                                Text(language!.views,
                                                    style: boldTextStyle(
                                                        size: 12,
                                                        color: Colors.black)),
                                              ],
                                            ),
                                            padding: EdgeInsets.only(
                                                left: 4,
                                                right: 4,
                                                top: 2,
                                                bottom: 2),
                                            decoration: BoxDecoration(
                                                color: Colors.white),
                                          )
                                              .cornerRadiusWithClipRRect(4)
                                              .visible(movie.postType ==
                                                  PostType.VIDEO),
                                          8.width.visible(
                                              movie.postType == PostType.VIDEO),
                                          itemTitle(
                                            context,
                                            snap.data!.data!.runTime.validate(),
                                            fontSize: 12.0,
                                          ).visible(snap.data!.data!.runTime
                                              .validate()
                                              .isNotEmpty),
                                        ],
                                      ),
                                    ],
                                  ),
                              ],
                            ).expand(),
                            if (movie.file.validate().isNotEmpty &&
                                appStore.isLogging &&
                                !movie.isPostRestricted.validate()) ...[
                              16.height,
                              DownloadButtonWidget(movie: movie),
                            ],
                          ],
                        ).paddingSymmetric(horizontal: 16),
                        HtmlWidget(
                          movie.description.validate(),
                          textStyle:
                              primaryTextStyle(color: Colors.white, size: 14),
                          onTapUrl: (s) {
                            try {
                              launchUrl(s, forceWebView: true);
                            } catch (e) {
                              print(e);
                            }
                            return true;
                          },
                        ).paddingSymmetric(horizontal: 16, vertical: 8),
                        8.height,
                        MovieDetailLikeWatchListWidget(movie)
                            .paddingSymmetric(horizontal: 16),
                        8.height,
                        Divider(thickness: 0.1, color: Colors.grey.shade500)
                            .visible(snap.hasData),
                        if (snap.hasData && movie.castsList!.isNotEmpty)
                          headingText(language!.starring)
                              .paddingOnly(right: 16, left: 16, top: 16),
                        if (snap.hasData && movie.castsList != null)
                          HorizontalList(
                            padding: EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 16.0),
                            itemCount: movie.castsList!.length,
                            itemBuilder: (context, index) {
                              Casts data = movie.castsList![index];
                              return Column(
                                children: [
                                  commonCacheImageWidget(data.image.validate(),
                                          fit: BoxFit.cover,
                                          width: 70,
                                          height: 70)
                                      .cornerRadiusWithClipRRect(60)
                                      .paddingOnly(left: 4, right: 4),
                                  4.height,
                                  Text(data.character.validate(),
                                      style: primaryTextStyle())
                                ],
                              ).onTap(() async {
                                youtubePlayerController!.pause();
                                await CastDetailScreen(castId: data.id)
                                    .launch(context);
                              },
                                  borderRadius:
                                      BorderRadius.circular(defaultRadius),
                                  highlightColor: Colors.transparent);
                            },
                          ),
                        if (snap.hasData && movie.castsList!.isNotEmpty)
                          Divider(thickness: 0.1, color: Colors.grey.shade500),
                        if (snap.hasData &&
                            movie.postType != PostType.TV_SHOW &&
                            movie.sourcesList!.isNotEmpty)
                          headingText(language!.sources)
                              .paddingOnly(right: 16, left: 16, top: 16),
                        if (snap.hasData &&
                            movie.postType != PostType.TV_SHOW &&
                            movie.sourcesList!.isNotEmpty)
                          SourcesDataWidget(
                            sourceList: movie.sourcesList,
                            onLinkTap: (sources) async {
                              youtubePlayerController!.pause();
                              movie.choice = sources.choice;
                              if (sources.choice == "movie_url") {
                                movie.urlLink = sources.link;
                              } else if (sources.choice == "movie_embed") {
                                movie.embedContent = sources.embedContent;
                              }
                              appStore.setTrailerVideoPlayer(false);
                              await MovieDetailScreen(
                                      movieData: widget.movieData)
                                  .launch(context);
                              youtubePlayerController!.play();
                            },
                          ).paddingSymmetric(horizontal: 12, vertical: 16),
                        if (snap.hasData &&
                            movie.postType != PostType.TV_SHOW &&
                            movie.sourcesList!.isNotEmpty)
                          Divider(thickness: 0.1, color: Colors.grey.shade500),
                        if (snap.hasData && movie.postType == PostType.TV_SHOW)
                          SeasonDataWidget(
                              snap.data!.seasons.validate(), widget.movieData),
                        if (snap.hasData)
                          UpcomingRelatedMovieListWidget(snap: snap),
                        if (snap.hasData &&
                            (snap.data!.upcomingMovie.validate().isNotEmpty ||
                                snap.data!.recommendedMovie
                                    .validate()
                                    .isNotEmpty ||
                                snap.data!.upcomingVideo.validate().isNotEmpty))
                          Divider(thickness: 0.1, color: Colors.grey.shade500),
                        /*CommentWidget(
                                postId: movie.id,
                                noOfComments: movie.noOfComments)
                            .paddingAll(16)
                            .visible(movie.isCommentOpen.validate()),
                        8.height,*/
                        if (!snap.hasData) LoadingDotsWidget(),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
