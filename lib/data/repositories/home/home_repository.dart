import 'dart:convert';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:Bareeq/data/model/home/home_screen_section.dart';
import 'package:Bareeq/utils/api.dart';
import 'package:Bareeq/data/model/data_output.dart';
import 'package:Bareeq/data/model/item/item_model.dart';

class HomeRepository {
  final cacheManager = DefaultCacheManager();

  Future<List<HomeScreenSection>> fetchHome({
    String? country,
    String? state,
    String? city,
    int? areaId,
    int? radius,
    double? latitude,
    double? longitude,
  }) async {
    try {
      Map<String, dynamic> parameters = {
        if (radius == null) ...{
          if (city != null && city != "") 'city': city,
          if (areaId != null && areaId != "") 'area_id': areaId,
          if (country != null && country != "") 'country': country,
          if (state != null && state != "") 'state': state,
        },
        if (radius != null && radius != "") 'radius': radius,
        if (latitude != null && latitude != "") 'latitude': latitude,
        if (longitude != null && longitude != "") 'longitude': longitude,
      };

      final cacheKey = "home_sections_${parameters.toString()}";

      try {
        // Try fresh API first
        Map<String, dynamic> response = await Api.get(
            url: Api.getFeaturedSectionApi, queryParameters: parameters);

        // Save to cache
        await cacheManager.putFile(
          cacheKey,
          utf8.encode(jsonEncode(response)),
          fileExtension: "json",
        );

        return (response['data'] as List)
            .map((e) => HomeScreenSection.fromJson(e))
            .toList();
      } catch (e) {
        // Fallback to cache if no internet
        final file = await cacheManager.getFileFromCache(cacheKey);
        if (file != null) {
          final cachedJson =
              jsonDecode(await file.file.readAsString()) as Map<String, dynamic>;
          return (cachedJson['data'] as List)
              .map((e) => HomeScreenSection.fromJson(e))
              .toList();
        }
        rethrow;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<DataOutput<ItemModel>> fetchHomeAllItems({
    required int page,
    String? country,
    String? state,
    String? city,
    double? latitude,
    double? longitude,
    int? areaId,
    int? radius,
  }) async {
    try {
      Map<String, dynamic> parameters = {
        "page": page,
        if (radius == null) ...{
          if (city != null && city != "") 'city': city,
          if (areaId != null && areaId != "") 'area_id': areaId,
          if (country != null && country != "") 'country': country,
          if (state != null && state != "") 'state': state,
        },
        if (radius != null && radius != "") 'radius': radius,
        if (latitude != null && latitude != "") 'latitude': latitude,
        if (longitude != null && longitude != "") 'longitude': longitude,
        "sort_by": "new-to-old"
      };

      final cacheKey = "home_items_${parameters.toString()}";

      try {
        // Live API call
        Map<String, dynamic> response =
            await Api.get(url: Api.getItemApi, queryParameters: parameters);

        // Cache the response
        await cacheManager.putFile(
          cacheKey,
          utf8.encode(jsonEncode(response)),
          fileExtension: "json",
        );

        List<ItemModel> items = (response['data']['data'] as List)
            .map((e) => ItemModel.fromJson(e))
            .toList();

        return DataOutput(
          total: response['data']['total'] ?? 0,
          modelList: items,
        );
      } catch (e) {
        // Offline fallback
        final file = await cacheManager.getFileFromCache(cacheKey);
        if (file != null) {
          final cachedJson =
              jsonDecode(await file.file.readAsString()) as Map<String, dynamic>;

          List<ItemModel> items = (cachedJson['data']['data'] as List)
              .map((e) => ItemModel.fromJson(e))
              .toList();

          return DataOutput(
            total: cachedJson['data']['total'] ?? 0,
            modelList: items,
          );
        }
        rethrow;
      }
    } catch (error) {
      rethrow;
    }
  }

  // fetchSectionItems can be updated the same way if needed
}
