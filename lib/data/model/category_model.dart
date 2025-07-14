import 'package:Bareeq/utils/api.dart';

class Type {
  String? id;
  String? type;

  Type({this.id, this.type});

  Type.fromJson(Map<String, dynamic> json) {
    id = json[Api.id].toString();
    type = json[Api.type];
  }
}

class CategoryModel {
  final int? id;
  final String? name;
  final String? url;
  final List<CategoryModel>? children;
  final String? description;
  final int? subcategoriesCount;

  CategoryModel({
    this.id,
    this.name,
    this.url,
    this.description,
    this.children,
    this.subcategoriesCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    try {
      List<dynamic> childData = json['subcategories'] ?? [];
      List<CategoryModel> children =
      childData.map((child) => CategoryModel.fromJson(child)).toList();

      return CategoryModel(
        id: _parseInt(json['id']),
        name: json['translated_name'],
        url: json['image'],
        subcategoriesCount: _parseInt(json['subcategories_count']) ?? 0,
        children: children,
        description: json['description'] ?? "",
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'translated_name': name,
      'image': url,
      'subcategories_count': subcategoriesCount,
      'description': description,
      'subcategories': children?.map((child) => child.toJson()).toList() ?? [],
    };
  }

  @override
  String toString() {
    return 'CategoryModel( id: $id, translated_name:$name, url: $url, description:$description, children: $children, subcategories_count:$subcategoriesCount)';
  }
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}
