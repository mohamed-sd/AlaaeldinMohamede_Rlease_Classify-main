import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:Bareeq/data/model/data_output.dart';
import 'package:Bareeq/data/model/item/item_model.dart';
import 'package:Bareeq/data/model/item_filter_model.dart';
import 'package:Bareeq/utils/api.dart';
import 'package:path/path.dart' as path;

class ItemRepository {
  final cacheManager = DefaultCacheManager();

  /// Save response to cache
  Future<void> _cacheResponse(String key, Map<String, dynamic> response) async {
    await cacheManager.putFile(
      key,
      utf8.encode(jsonEncode(response)),
      fileExtension: "json",
    );
  }

  /// Load response from cache
  Future<Map<String, dynamic>?> _loadFromCache(String key) async {
    final file = await cacheManager.getFileFromCache(key);
    if (file != null) {
      return jsonDecode(await file.file.readAsString())
          as Map<String, dynamic>;
    }
    return null;
  }

  Future<ItemModel> createItem(
    Map<String, dynamic> itemDetails,
    File mainImage,
    List<File>? otherImages,
  ) async {
    try {
      Map<String, dynamic> parameters = {};
      parameters.addAll(itemDetails);

      MultipartFile image = await MultipartFile.fromFile(mainImage.path,
          filename: path.basename(mainImage.path));

      if (otherImages != null && otherImages.isNotEmpty) {
        List<Future<MultipartFile>> futures = otherImages.map((imageFile) {
          return MultipartFile.fromFile(imageFile.path,
              filename: path.basename(imageFile.path));
        }).toList();

        List<MultipartFile> galleryImages = await Future.wait(futures);

        if (galleryImages.isNotEmpty) {
          parameters["gallery_images"] = galleryImages;
        }
      }

      parameters.addAll({
        "image": image,
        "show_only_to_premium": 1,
      });

      Map<String, dynamic> response = await Api.post(
        url: Api.addItemApi,
        parameter: parameters,
      );

      return ItemModel.fromJson(response['data'][0]);
    } catch (e) {
      rethrow;
    }
  }

  Future<DataOutput<ItemModel>> fetchMyFeaturedItems({int? page}) async {
    final params = {"status": "featured", "page": page};
    final cacheKey = "my_featured_items_${params.toString()}";

    try {
      Map<String, dynamic> response = await Api.get(
        url: Api.getMyItemApi,
        queryParameters: params,
      );

      await _cacheResponse(cacheKey, response);

      List<ItemModel> itemList = (response['data']['data'] as List)
          .map((element) => ItemModel.fromJson(element))
          .toList();

      return DataOutput(
          total: response['data']['total'] ?? 0, modelList: itemList);
    } catch (_) {
      final cached = await _loadFromCache(cacheKey);
      if (cached != null) {
        List<ItemModel> itemList =
            (cached['data']['data'] as List).map((e) => ItemModel.fromJson(e)).toList();
        return DataOutput(total: cached['data']['total'] ?? 0, modelList: itemList);
      }
      rethrow;
    }
  }

  Future<DataOutput<ItemModel>> fetchMyItems(
      {String? getItemsWithStatus, int? page}) async {
    final params = {
      if (getItemsWithStatus != null && getItemsWithStatus != "") "status": getItemsWithStatus,
      if (page != null) Api.page: page
    };

    final cacheKey = "my_items_${params.toString()}";

    try {
      Map<String, dynamic> response = await Api.get(
        url: Api.getMyItemApi,
        queryParameters: params,
      );

      await _cacheResponse(cacheKey, response);

      List<ItemModel> itemList = (response['data']['data'] as List)
          .map((element) => ItemModel.fromJson(element))
          .toList();

      return DataOutput(
          total: response['data']['total'] ?? 0, modelList: itemList);
    } catch (_) {
      final cached = await _loadFromCache(cacheKey);
      if (cached != null) {
        List<ItemModel> itemList =
            (cached['data']['data'] as List).map((e) => ItemModel.fromJson(e)).toList();
        return DataOutput(total: cached['data']['total'] ?? 0, modelList: itemList);
      }
      rethrow;
    }
  }

  Future<DataOutput<ItemModel>> fetchItemFromItemId(int id) async {
    final params = {Api.id: id};
    final cacheKey = "item_by_id_$id";

    try {
      Map<String, dynamic> response = await Api.get(
        url: Api.getItemApi,
        queryParameters: params,
      );

      await _cacheResponse(cacheKey, response);

      List<ItemModel> modelList =
          (response['data'] as List).map((e) => ItemModel.fromJson(e)).toList();

      return DataOutput(total: modelList.length, modelList: modelList);
    } catch (_) {
      final cached = await _loadFromCache(cacheKey);
      if (cached != null) {
        List<ItemModel> modelList =
            (cached['data'] as List).map((e) => ItemModel.fromJson(e)).toList();
        return DataOutput(total: modelList.length, modelList: modelList);
      }
      rethrow;
    }
  }

  Future<DataOutput<ItemModel>> fetchItemFromItemSlug(String slug) async {
    final params = {"slug": slug};
    final cacheKey = "item_by_slug_$slug";

    try {
      Map<String, dynamic> response = await Api.get(
        url: Api.getItemApi,
        queryParameters: params,
      );

      await _cacheResponse(cacheKey, response);

      List<ItemModel> modelList = (response['data']['data'] as List)
          .map((e) => ItemModel.fromJson(e))
          .toList();

      return DataOutput(total: modelList.length, modelList: modelList);
    } catch (_) {
      final cached = await _loadFromCache(cacheKey);
      if (cached != null) {
        List<ItemModel> modelList =
            (cached['data']['data'] as List).map((e) => ItemModel.fromJson(e)).toList();
        return DataOutput(total: modelList.length, modelList: modelList);
      }
      rethrow;
    }
  }

  Future<DataOutput<ItemModel>> fetchItemFromCatId({
    required int categoryId,
    required int page,
    String? search,
    String? sortBy,
    String? country,
    String? state,
    String? city,
    int? areaId,
    ItemFilterModel? filter,
  }) async {
    Map<String, dynamic> parameters = {
      Api.categoryId: categoryId,
      Api.page: page,
    };

    if (filter != null) {
      parameters.addAll(filter.toMap());

      if (filter.radius != null) {
        if (filter.latitude != null && filter.longitude != null) {
          parameters['latitude'] = filter.latitude;
          parameters['longitude'] = filter.longitude;
        }

        parameters.remove('city');
        parameters.remove('area');
        parameters.remove('area_id');
        parameters.remove('country');
        parameters.remove('state');
      } else {
        if (city != null && city != "") parameters['city'] = city;
        if (areaId != null) parameters['area_id'] = areaId;
        if (country != null && country != "") parameters['country'] = country;
        if (state != null && state != "") parameters['state'] = state;
      }

      if (filter.areaId == null) {
        parameters.remove('area_id');
      }

      parameters.remove('area');

      if (filter.customFields != null) {
        filter.customFields!.forEach((key, value) {
          if (value is List) {
            parameters[key] = value.map((v) => v.toString()).join(',');
          } else {
            parameters[key] = value.toString();
          }
        });
      }
    }

    if (search != null) {
      parameters[Api.search] = search;
    }

    if (sortBy != null) {
      parameters[Api.sortBy] = sortBy;
    }

    final cacheKey = "items_by_cat_${parameters.toString()}";

    try {
      Map<String, dynamic> response =
          await Api.get(url: Api.getItemApi, queryParameters: parameters);

      await _cacheResponse(cacheKey, response);

      List<ItemModel> items = (response['data']['data'] as List)
          .map((e) => ItemModel.fromJson(e))
          .toList();

      return DataOutput(total: response['data']['total'] ?? 0, modelList: items);
    } catch (_) {
      final cached = await _loadFromCache(cacheKey);
      if (cached != null) {
        List<ItemModel> items =
            (cached['data']['data'] as List).map((e) => ItemModel.fromJson(e)).toList();
        return DataOutput(total: cached['data']['total'] ?? 0, modelList: items);
      }
      rethrow;
    }
  }

  Future<DataOutput<ItemModel>> fetchPopularItems({
    required String sortBy,
    required int page,
  }) async {
    Map<String, dynamic> parameters = {Api.sortBy: sortBy, Api.page: page};
    final cacheKey = "popular_items_${parameters.toString()}";

    try {
      Map<String, dynamic> response =
          await Api.get(url: Api.getItemApi, queryParameters: parameters);

      await _cacheResponse(cacheKey, response);

      List<ItemModel> items = (response['data']['data'] as List)
          .map((e) => ItemModel.fromJson(e))
          .toList();

      return DataOutput(total: response['data']['total'] ?? 0, modelList: items);
    } catch (_) {
      final cached = await _loadFromCache(cacheKey);
      if (cached != null) {
        List<ItemModel> items =
            (cached['data']['data'] as List).map((e) => ItemModel.fromJson(e)).toList();
        return DataOutput(total: cached['data']['total'] ?? 0, modelList: items);
      }
      rethrow;
    }
  }

  Future<DataOutput<ItemModel>> searchItem(
    String query,
    ItemFilterModel? filter, {
    required int page,
  }) async {
    Map<String, dynamic> parameters = {
      Api.search: query,
      Api.page: page,
      if (filter != null) ...filter.toMap(),
    };

    if (filter != null) {
      if (filter.areaId == null) {
        parameters.remove('area_id');
      }
      parameters.remove('area');
      if (filter.customFields != null) {
        parameters.addAll(filter.customFields!);
      }
    }

    final cacheKey = "search_${parameters.toString()}";

    try {
      Map<String, dynamic> response =
          await Api.get(url: Api.getItemApi, queryParameters: parameters);

      await _cacheResponse(cacheKey, response);

      List<ItemModel> items = (response['data']['data'] as List)
          .map((e) => ItemModel.fromJson(e))
          .toList();

      return DataOutput(total: response['data']['total'] ?? 0, modelList: items);
    } catch (_) {
      final cached = await _loadFromCache(cacheKey);
      if (cached != null) {
        List<ItemModel> items =
            (cached['data']['data'] as List).map((e) => ItemModel.fromJson(e)).toList();
        return DataOutput(total: cached['data']['total'] ?? 0, modelList: items);
      }
      rethrow;
    }
  }

  // Other methods (editItem, deleteItem, etc.) remain online-only
  // to avoid syncing issues, so no cache is applied there.
}
