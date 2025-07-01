import 'package:Bareeq/app/routes.dart';
import 'package:Bareeq/data/cubits/category/fetch_category_cubit.dart';
import 'package:Bareeq/data/model/category_model.dart';
import 'package:Bareeq/ui/screens/home/home_screen.dart';
import 'package:Bareeq/ui/screens/home/widgets/category_home_card.dart';
import 'package:Bareeq/ui/screens/main_activity.dart';
import 'package:Bareeq/ui/screens/widgets/errors/no_data_found.dart';
import 'package:Bareeq/ui/theme/theme.dart';
import 'package:Bareeq/utils/app_icon.dart';
import 'package:Bareeq/utils/custom_text.dart';
import 'package:Bareeq/utils/extensions/extensions.dart';
import 'package:Bareeq/utils/hive_utils.dart';
import 'package:Bareeq/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

String expandedCategroryId = HiveUtils.getExpandedCategoryId() ?? "";
String categoryTitleHeader = 'Category Title Header';

class CategoryWidgetHome extends StatefulWidget {
  const CategoryWidgetHome({super.key});

  @override
  State<CategoryWidgetHome> createState() => _CategoryWidgetHomeState();
}

class _CategoryWidgetHomeState extends State<CategoryWidgetHome> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchCategoryCubit, FetchCategoryState>(
      builder: (context, state) {
        if (state is FetchCategorySuccess) {
          if (state.categories.isNotEmpty) {
            return Column(
              spacing: 12,
              children: [
                const SizedBox(height: 1),
                CustomText(
                  categoryTitleHeader,
                  height: 1,
                  customTextStyle: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                categoryWidget(state.categories),
              ],
            );

            /*  return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                width: context.screenWidth,
                height: 103,
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: sidePadding,
                  ),
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    if (state.categories.length > 10 &&
                        index == state.categories.length) {
                      return moreCategory(context);
                    } else {
                      return CategoryHomeCard(
                        title: state.categories[index].name!,
                        url: state.categories[index].url!,
                        onTap: () {
                          if (state.categories[index].children!.isNotEmpty) {
                            Navigator.pushNamed(
                                context, Routes.subCategoryScreen,
                                arguments: {
                                  "categoryList":
                                      state.categories[index].children,
                                  "catName": state.categories[index].name,
                                  "catId": state.categories[index].id,
                                  "categoryIds": [
                                    state.categories[index].id.toString()
                                  ]
                                });
                          } else {
                            Navigator.pushNamed(context, Routes.itemsList,
                                arguments: {
                                  'catID':
                                      state.categories[index].id.toString(),
                                  'catName': state.categories[index].name,
                                  "categoryIds": [
                                    state.categories[index].id.toString()
                                  ]
                                });
                          }
                        },
                      );
                    }
                  },
                  itemCount: state.categories.length > 10
                      ? state.categories.length + 1
                      : state.categories.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      width: 12,
                    );
                  },
                ),
              ),
            );
         */
          } else {
            return Padding(
              padding: const EdgeInsets.all(50.0),
              child: NoDataFound(
                onTap: () {},
              ),
            );
          }
        }
        if (state is FetchCategoryInProgress) {
          return UiUtils.progress();
        }
        if (state is FetchCategoryFailure) {
          return NoDataFound(
            mainMessage: state.errorMessage,
          );
        }
        return Container();
      },
    );
  }

  Widget moreCategory(BuildContext context) {
    return SizedBox(
      width: 70,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, Routes.categories,
              arguments: {"from": Routes.home}).then(
            (dynamic value) {
              if (value != null) {
                selectedCategory = value;
                //setState(() {});
              }
            },
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            children: [
              Container(
                clipBehavior: Clip.antiAlias,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color:
                          context.color.textLightColor.withValues(alpha: 0.33),
                      width: 1),
                  color: context.color.secondaryColor,
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      // color: Colors.blue,
                      width: 48,
                      height: 48,
                      child: Center(
                        child: RotatedBox(
                            quarterTurns: 1,
                            child: UiUtils.getSvg(AppIcons.more,
                                color: context.color.territoryColor)),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: CustomText(
                        "more".translate(context),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        color: context.color.textDefaultColor,
                      )))
            ],
          ),
        ),
      ),
    );
  }

  Widget categoryWidget(List<CategoryModel> categories) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        if (categories.length > 10 && index == categories.length) {
          return moreCategory(context);
        }
        final item = categories[index];
        bool isExpanded = expandedCategroryId == item.id.toString();
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          /*  decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber, width: 1),
          ), */
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  if (item.children!.isNotEmpty) {
                    setState(() {
                      expandedCategroryId =
                          isExpanded ? '' : item.id.toString();
                    });
                    HiveUtils.setExpandedCategoryId(expandedCategroryId);
                  } else {
                    Navigator.pushNamed(context, Routes.itemsList, arguments: {
                      'catID': item.id.toString(),
                      'catName': item.name,
                      "categoryIds": [item.id.toString()]
                    });
                  }
                },
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(AppIcons.categoryBg),
                          fit: BoxFit.fill,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.black,
                          ),
                          Expanded(
                            child: CustomText(
                              item.name ?? "",
                              textAlign: TextAlign.center,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (isExpanded)
                subCategoryWidget(item.children!, item.id ?? 0, item.name ?? "")
            ],
          ),
        );
      },
    );
  }

  Widget subCategoryWidget(
      List<CategoryModel> subcategories, int categoryId, String categoryName) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (subcategories.length > 6) ...[
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, Routes.subCategoryScreen,
                      arguments: {
                        "categoryList": subcategories,
                        "catName": categoryName,
                        "catId": categoryId,
                        "categoryIds": [categoryId.toString()]
                      });
                },
                child: CustomText(
                  "seeAll".translate(context),
                  showUnderline: true,
                  fontSize: context.font.smaller + 3,
                ),
              ),
            ),
            const SizedBox(height: 5)
          ],
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: List.generate(
              subcategories.length > 6 ? 6 : subcategories.length,
              (i) {
                final subcategory = subcategories[i];
                return GestureDetector(
                  onTap: () {
                    if (subcategory.children!.isEmpty &&
                        subcategory.subcategoriesCount == 0) {
                      Navigator.pushNamed(context, Routes.itemsList,
                          arguments: {
                            'catID': subcategory.id.toString(),
                            'catName': subcategory.name,
                            "categoryIds": [
                              categoryId.toString(),
                              subcategory.id.toString()
                            ]
                          });
                    } else {
                      Navigator.pushNamed(context, Routes.subCategoryScreen,
                          arguments: {
                            "categoryList": subcategory.children,
                            "catName": subcategory.name,
                            "catId": subcategory.id,
                            "categoryIds": [
                              categoryId.toString(),
                              subcategory.id.toString()
                            ]
                          });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: UiUtils.imageType(
                            subcategory.url ?? '',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.5),
                            padding: EdgeInsets.symmetric(
                                vertical: 6, horizontal: 8),
                            child: Text(
                              subcategory.name ?? '',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: context.font.small,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
