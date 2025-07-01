// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:Bareeq/app/routes.dart';
import 'package:Bareeq/data/cubits/category/fetch_category_cubit.dart';
import 'package:Bareeq/data/cubits/chat/blocked_users_list_cubit.dart';
import 'package:Bareeq/data/cubits/chat/get_buyer_chat_users_cubit.dart';
import 'package:Bareeq/data/cubits/favorite/favorite_cubit.dart';
import 'package:Bareeq/data/cubits/fetch_blogs_cubit.dart';
import 'package:Bareeq/data/cubits/slider_cubit.dart';
import 'package:Bareeq/data/cubits/system/fetch_system_settings_cubit.dart';
import 'package:Bareeq/data/model/item/item_model.dart';
import 'package:Bareeq/data/model/system_settings_model.dart';
import 'package:Bareeq/ui/screens/home/slider_widget.dart';
import 'package:Bareeq/ui/screens/home/widgets/category_widget_home.dart';
import 'package:Bareeq/ui/screens/home/widgets/location_widget.dart';
import 'package:Bareeq/ui/screens/widgets/marqeeWidget.dart';
import 'package:Bareeq/ui/theme/theme.dart';
//import 'package:uni_links/uni_links.dart';
import 'package:Bareeq/utils/app_icon.dart';
import 'package:Bareeq/utils/constant.dart';
import 'package:Bareeq/utils/custom_text.dart';
import 'package:Bareeq/utils/extensions/extensions.dart';
import 'package:Bareeq/utils/hive_utils.dart';
import 'package:Bareeq/utils/notification/awsome_notification.dart';
import 'package:Bareeq/utils/notification/notification_service.dart';
import 'package:Bareeq/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

const double sidePadding = 10;

class HomeScreen extends StatefulWidget {
  final String? from;

  const HomeScreen({super.key, this.from});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<HomeScreen> {
  //
  @override
  bool get wantKeepAlive => true;

  //
  List<ItemModel> itemLocalList = [];

  //
  bool isCategoryEmpty = false;

  //
  late final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Color mainColor = Color(0xff271301);
  Color marqueeBgColor = Color(0xff150900);
  @override
  void initState() {
    super.initState();
    initializeSettings();
    addPageScrollListener();
    notificationPermissionChecker();
    LocalAwesomeNotification().init(context);
    ///////////////////////////////////////
    NotificationService.init(context);
    //for marquee
    context.read<FetchBlogsCubit>().fetchBlogs();
    //
    loadItemData();
    if (HiveUtils.isUserAuthenticated()) {
      context.read<FavoriteCubit>().getFavorite();
      //fetchApiKeys();
      context.read<GetBuyerChatListCubit>().fetch();
      context.read<BlockedUsersListCubit>().blockedUsersList();
    }
    /* 
  
    _scrollController.addListener(() {
      if (_scrollController.isEndReached()) {
        if (context.read<FetchHomeAllItemsCubit>().hasMoreData()) {
          context.read<FetchHomeAllItemsCubit>().fetchMore(
                city: HiveUtils.getCityName(),
                radius: HiveUtils.getNearbyRadius(),
                longitude: HiveUtils.getLongitude(),
                latitude: HiveUtils.getLatitude(),
                country: HiveUtils.getCountryName(),
                stateName: HiveUtils.getStateName(),
              );
        }
      }
    }); */
  }

  void loadItemData() {
    context.read<SliderCubit>().fetchSlider(
          context,
        );
    context.read<FetchCategoryCubit>().fetchCategories();
    /*  context.read<FetchHomeScreenCubit>().fetch(
          city: HiveUtils.getCityName(),
          country: HiveUtils.getCountryName(),
          state: HiveUtils.getStateName(),
          radius: HiveUtils.getNearbyRadius(),
          longitude: HiveUtils.getLongitude(),
          latitude: HiveUtils.getLatitude(),
        );
    context.read<FetchHomeAllItemsCubit>().fetch(
        city: HiveUtils.getCityName(),
        radius: HiveUtils.getNearbyRadius(),
        longitude: HiveUtils.getLongitude(),
        latitude: HiveUtils.getLatitude(),
        country: HiveUtils.getCountryName(),
        state: HiveUtils.getStateName()); */
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initializeSettings() {
    final settingsCubit = context.read<FetchSystemSettingsCubit>();
    if (!const bool.fromEnvironment("force-disable-demo-mode",
        defaultValue: false)) {
      Constant.isDemoModeOn =
          settingsCubit.getSetting(SystemSetting.demoMode) ?? false;
    }
  }

  void addPageScrollListener() {
    //homeScreenController.addListener(pageScrollListener);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          //leadingWidth: double.maxFinite,
          titleSpacing: 0,
          title: Padding(
              padding: EdgeInsetsDirectional.only(end: sidePadding),
              child: appbarTitleWidget()),
          backgroundColor: mainColor,
          foregroundColor: Colors.white,
          // backgroundColor: const Color.fromARGB(0, 0, 0, 0),
          actions: appbarActionsWidget(),
        ),
        backgroundColor: mainColor,
        //backgroundColor: context.color.primaryColor,
        drawer: Drawer(),

        body: Column(
          children: [
            blogMarqueeWidget(),
            Container(
                color: mainColor,
                padding: const EdgeInsetsDirectional.only(
                    start: sidePadding, end: sidePadding, bottom: 10, top: 8),
                alignment: AlignmentDirectional.centerStart,
                child: LocationWidget()),
            Expanded(
              child: Container(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                padding: EdgeInsetsDirectional.only(top: 30, bottom: 80),
                decoration: BoxDecoration(
                    color: context.color.primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    )),
                child: RefreshIndicator(
                  triggerMode: RefreshIndicatorTriggerMode.anywhere,
                  key: _refreshIndicatorKey,
                  color: context.color.territoryColor,
                  onRefresh: () async {
                    print("refresh-------");
                    loadItemData();
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    controller: _scrollController,
                    children: [
                      const SliderWidget(),
                      const CategoryWidgetHome(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget appbarTitleWidget() {
    return Row(children: [
      CustomText(
        Constant.appName,
        fontSize: context.font.large,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      // UiUtils.getSvg(AppIcons.appbarLogo, height: 30, width: 30),
    ]);
  }

  Widget appbarIconWidget(IconData icon, Function callback) {
    return IconButton(
        onPressed: () {
          callback();
        },
        icon: Icon(
          icon,
        ));
  }

  List<Widget> appbarActionsWidget() {
    return [
      appbarIconWidget(Icons.favorite_border, () {
        UiUtils.checkUser(
            onNotGuest: () {
              Navigator.pushNamed(context, Routes.favoritesScreen);
            },
            context: context);
      }),
      appbarIconWidget(Icons.search, () {
        Navigator.pushNamed(context, Routes.searchScreenRoute, arguments: {
          "autoFocus": true,
        });
      }),
      appbarIconWidget(Icons.notifications_active_outlined, () {
        UiUtils.checkUser(
            onNotGuest: () {
              Navigator.pushNamed(context, Routes.notificationPage);
            },
            context: context);
      }),
    ];
  }

  Widget blogMarqueeWidget() {
    return BlocBuilder<FetchBlogsCubit, FetchBlogsState>(
        builder: (context, state) {
      if (state is FetchBlogsSuccess) {
        String mergedTitle = state.blogModel.map((e) => e.title).join('\t\t\t');
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.blogsScreenRoute,
            );
          },
          child: Container(
            color: marqueeBgColor,
            padding: EdgeInsetsDirectional.symmetric(vertical: 5),
            child: MarqueeText(
              text: mergedTitle,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Colors.white),
              velocity: 50,
            ),
          ),
        );
      } else {
        return SizedBox.shrink();
      }
    });
  }
}

Future<void> notificationPermissionChecker() async {
  if (!(await Permission.notification.isGranted)) {
    await Permission.notification.request();
  }
}
