import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:fitnessapp/main.dart';
import 'package:fitnessapp/models/BaseResponse.dart';
import 'package:fitnessapp/models/CastModel.dart';
import 'package:fitnessapp/models/CommentModel.dart';
import 'package:fitnessapp/models/DashboardResponse.dart';
import 'package:fitnessapp/models/GenreData.dart';
import 'package:fitnessapp/models/LoginResponse.dart';
import 'package:fitnessapp/models/MovieData.dart';
import 'package:fitnessapp/models/MovieDetailResponse.dart';
import 'package:fitnessapp/models/ViewAllResponse.dart';
import 'package:fitnessapp/models/WatchListResponse.dart';
import 'package:fitnessapp/utils/AppWidgets.dart';
import 'package:fitnessapp/utils/Common.dart';
import 'package:fitnessapp/utils/Constants.dart';

import 'NetworkUtils.dart';

Future<LoginResponse> token(Map request) async {
  LoginResponse res = LoginResponse.fromJson(await (handleResponse(
      await postRequest('jwt-auth/v1/token',
          body: request, aAuthRequired: false))));

  await setValue(TOKEN, res.token);

  Map<String, dynamic>? decodedToken = JwtDecoder.decode(getStringAsync(TOKEN));
  if (decodedToken != null) {
    await setValue(EXPIRATION_TOKEN_TIME, decodedToken['exp']);
  }

  String userProfile = userProfileImage();

  getDetails(logRes: res, image: userProfile);

  await setValue(isLoggedIn, true);
  mIsLoggedIn = true;

  appStore.setFirstName(res.firstName.validate());
  appStore.setLastName(res.lastName.validate());
  appStore.setUserProfile(res.profileImage.validate().isEmpty
      ? userProfile
      : res.profileImage.validate());
  appStore.setLogging(true);

  return res;
}

Future<void> logout(BuildContext context) async {
  //await clearSharedPref();
  if (await isNetworkAvailable()) {
    mUserId = 0;
    await removeKey(TOKEN);
    await removeKey(USER_ID);
    await removeKey(NAME);
    await removeKey(LAST_NAME);
    await removeKey(USER_PROFILE);
    await removeKey(USER_EMAIL);
    await removeKey(USERNAME);
    await removeKey(SUBSCRIPTION_PLAN_ID);
    await removeKey(SUBSCRIPTION_PLAN_START_DATE);
    await removeKey(SUBSCRIPTION_PLAN_EXP_DATE);
    await removeKey(SUBSCRIPTION_PLAN_STATUS);
    await removeKey(SUBSCRIPTION_PLAN_TRIAL_STATUS);
    await removeKey(SUBSCRIPTION_PLAN_NAME);
    await removeKey(SUBSCRIPTION_PLAN_AMOUNT);
    await removeKey(SUBSCRIPTION_PLAN_TRIAL_END_DATE);

    await setValue(isFirstTime, false);
    await setValue(isLoggedIn, false);
    mIsLoggedIn = false;

    appStore.setLogging(false);
  } else {
    toast(errorInternetNotAvailable);
  }
}

Future<BaseResponse> forgotPassword(Map request) async {
  return BaseResponse.fromJson(await (handleResponse(await postRequest(
      'streamit-api/api/v1/streamit/forgot-password',
      body: request,
      aAuthRequired: false))));
}

Future register(Map request) async {
  return await handleResponse(await postRequest(
      'streamit-api/api/v1/auth/registration',
      body: request,
      aAuthRequired: false));
}

Future<BaseResponse> validateToken() async {
  return BaseResponse.fromJson(await (handleResponse(
      await postRequest('jwt-auth/v1/token/validate', body: {}))));
}

Future<BaseResponse> changePassword(Map request) async {
  return BaseResponse.fromJson(await (handleResponse(await postRequest(
      'streamit-api/api/v1/streamit/change-password',
      body: request))));
}

Future<DashboardResponse> getDashboardData(Map request,
    {String type = dashboardTypeHome}) async {
  return DashboardResponse.fromJson(await handleResponse(await postRequest(
      'streamit-api/api/v1/streamit/get-dashboard?type=$type',
      body: request,
      aAuthRequired: false)));
}

Future<MovieResponse> getWatchList() async {
  return MovieResponse.fromJson(await (handleResponse(
      await getRequest('streamit-api/api/v1/streamit/get-watchlist'))));
}

Future<List<MovieData>> searchMovie(String aSearchText,
    {int page = 1,
    required List<MovieData> movies,
    bool isLoading = true}) async {
  appStore.setLoading(isLoading);

  try {
    var res = MovieResponse.fromJson(await (handleResponse(await getRequest(
        'streamit-api/api/v1/streamit/search-list?search=$aSearchText&user_id=$mUserId&paged=$page&posts_per_page=$postPerPage'))));

    if (page == 1) movies.clear();

    if (res.data.validate().isNotEmpty) {
      movies.addAll(res.data!);
    }
  } catch (e) {
    throw e;
  } finally {
    appStore.setLoading(false);
  }

  return movies;
}

Future<ViewAllResponse> viewAll(int index, String type, {int page = 1}) async {
  return ViewAllResponse.fromJson(await (handleResponse(await getRequest(
      'streamit-api/api/v1/streamit/slider-view-all?user_id=$mUserId&paged=$page&posts_per_page=$postPerPage&slider_id=$index&type=$type'))));
}

Future<MovieDetailResponse> movieDetail(int aId) async {
  return MovieDetailResponse.fromJson(await (handleResponse(await getRequest(
      'streamit-api/api/v1/movie/get-detail?movie_id=$aId&user_id=$mUserId'))));
}

Future<MovieDetailResponse> tvShowDetail(int aId) async {
  return MovieDetailResponse.fromJson(await (handleResponse(await getRequest(
      'streamit-api/api/v1/tv_show/get_tv_show_detail?tv_show_id=$aId&user_id=$mUserId'))));
}

Future<MovieDetailResponse> episodeDetail(int? aId) async {
  return MovieDetailResponse.fromJson(await (handleResponse(await getRequest(
      'streamit-api/api/v1/tv_show_episode/get_episode_detail?episode_id=$aId&user_id=$mUserId'))));
}

Future<Episode> getEpisodeDetail(int? aId) async {
  return Episode.fromJson(await (handleResponse(await getRequest(
      'streamit-api/api/v1/tv_show_episode/get_episode_detail?episode_id=$aId&user_id=$mUserId'))));
}

Future<LikeAndWatchListResponse> likeMovie(Map request) async {
  return LikeAndWatchListResponse.fromJson(await (handleResponse(
      await postRequest('streamit-api/api/v1/streamit/like-movie-show',
          body: request))));
}

Future<LikeAndWatchListResponse> watchlistMovie(Map request) async {
  return LikeAndWatchListResponse.fromJson(await (handleResponse(
      await postRequest('streamit-api/api/v1/streamit/add-remove-watchlist',
          body: request))));
}

Future<LoginResponse> getUserProfileDetails() async {
  return LoginResponse.fromJson(await (handleResponse(
      await getRequest('streamit-api/api/v1/streamit/view-profile'))));
}

Future<MovieResponse> getVideos() async {
  return MovieResponse.fromJson(await (handleResponse(
      await getRequest('streamit-api/api/v1/video/get_list'))));
}

Future<MovieDetailResponse> getVideosDetail(int id) async {
  return MovieDetailResponse.fromJson(await (handleResponse(
      await getRequest('streamit-api/api/v1/video/get-detail?video_id=$id'))));
}

Future<List<CommentModel>> getComments(
    {int? postId, int? page, int? commentPerPage}) async {
  Iterable it = await (handleResponse(await getRequest(
      'wp/v2/comments?post=$postId&page=$page&per_page=$commentPerPage&order=asc')));
  return it.map((e) => CommentModel.fromJson(e)).toList();
}

Future<CommentModel> addComment(Map request) async {
  return CommentModel.fromJson(await (handleResponse(
      await postRequest('wp/v2/comments', body: request))));
}

Future<CastModel> getCastDetails(String castId) async {
  return CastModel.fromJson(await handleResponse(
      await getRequest('streamit-api/api/v1/cast/get-detail?cast_id=$castId')));
}

Future<List<MovieData>> getCastMovieTvShowList(
    {String? type = '', int? castId, int? page}) async {
  Iterable it = await (handleResponse(await getRequest(
      'streamit-api/api/v1/cast/get-movie-show-list?cast_id=$castId&type=$type&posts_per_page=$postPerPage&paged=$page')));
  return it.map((e) => MovieData.fromJson(e)).toList();
}

Future<List<GenreData>> getGenreList(
    {int? page = 1, String? type = dashboardTypeMovie}) async {
  Iterable it = await (handleResponse(await getRequest(
      'streamit-api/api/v1/streamit/get-genre-by-type?type=$type&paged=$page&posts_per_page=$postPerPage')));
  return it.map((e) => GenreData.fromJson(e)).toList();
}

Future<GenreMovieList> getMovieListByGenre(
    String genre, String type, int page) async {
  return GenreMovieList.fromJson(await handleResponse(await getRequest(
      'streamit-api/api/v1/streamit/get-list-by-genre?type=$type&paged=$page&posts_per_page=$genrePostPerPage&genre=$genre')));
}

Future<void> deleteUserAccount() async {
  await handleResponse(await postRequest(
      'streamit-api/api/v1/streamit/delete-account',
      body: {},
      aAuthRequired: true));
}
