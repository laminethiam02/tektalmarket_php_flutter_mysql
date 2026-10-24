import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // Requis pour XFile
import '../config/api_config.dart';
import '../models/product.dart';
import 'api_service.dart';

class ProductService {
  Future<List<Product>> getAll() async {
    final res = await http.get(Uri.parse(ApiConfig.productsEndpoint), headers: ApiService.jsonHeaders);
    final data = await ApiService.handleResponse(res) as List;
    return data.map((e) => Product.fromJson(e)).toList();
  }

  Future<Product> getById(int id) async {
    final res = await http.get(Uri.parse('${ApiConfig.productsEndpoint}/$id'), headers: ApiService.jsonHeaders);
    final data = await ApiService.handleResponse(res);
    return Product.fromJson(data);
  }

  Future<List<Product>> search(String kw) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.productsEndpoint}/search?keyword=${Uri.encodeComponent(kw)}'),
      headers: ApiService.jsonHeaders,
    );
    final data = await ApiService.handleResponse(res) as List;
    return data.map((e) => Product.fromJson(e)).toList();
  }

  Future<List<Product>> getByCategory(int id) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.productsEndpoint}/category/$id'),
      headers: ApiService.jsonHeaders,
    );
    final data = await ApiService.handleResponse(res) as List;
    return data.map((e) => Product.fromJson(e)).toList();
  }

  Future<List<Product>> getByUser(int id) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.productsEndpoint}/user/$id'),
      headers: ApiService.jsonHeaders,
    );
    final data = await ApiService.handleResponse(res) as List;
    return data.map((e) => Product.fromJson(e)).toList();
  }

  Future<Product> create({
    required String productTitle,
    String? productDescription,
    required double productPrice,
    required String ville,
    required int categoryId,
    required List<XFile> images, // <-- XFile
  }) async {
    final req = http.MultipartRequest('POST', Uri.parse(ApiConfig.productsEndpoint));
    req.headers.addAll(await ApiService.authMultipartHeaders());

    req.fields['productTitle'] = productTitle;
    if (productDescription != null) req.fields['productDescription'] = productDescription;
    req.fields['productPrice'] = productPrice.toString();
    req.fields['ville'] = ville;
    req.fields['categoryId'] = categoryId.toString();

    // Envoi compatible Web & Mobile
    for (final file in images.take(5)) {
      final bytes = await file.readAsBytes();
      req.files.add(http.MultipartFile.fromBytes(
        'productImages[]',
        bytes,
        filename: file.name,
      ));
    }

    final s = await req.send();
    final res = await http.Response.fromStream(s);
    final d = await ApiService.handleResponse(res);
    return Product.fromJson(d);
  }

  Future<Product> update({
    required int id,
    String? productTitle,
    String? productDescription,
    double? productPrice,
    String? ville,
    int? categoryId,
    bool? isActive,
    List<XFile>? images, // <-- XFile
  }) async {
    final req = http.MultipartRequest('POST', Uri.parse('${ApiConfig.productsEndpoint}/$id'));
    req.headers.addAll(await ApiService.authMultipartHeaders());
    req.fields['_method'] = 'PUT';

    if (productTitle != null) req.fields['productTitle'] = productTitle;
    if (productDescription != null) req.fields['productDescription'] = productDescription;
    if (productPrice != null) req.fields['productPrice'] = productPrice.toString();
    if (ville != null) req.fields['ville'] = ville;
    if (categoryId != null) req.fields['categoryId'] = categoryId.toString();
    if (isActive != null) req.fields['isActive'] = isActive.toString();

    if (images != null && images.isNotEmpty) {
      for (final file in images.take(5)) {
        final bytes = await file.readAsBytes();
        req.files.add(http.MultipartFile.fromBytes(
          'productImages[]',
          bytes,
          filename: file.name,
        ));
      }
    }

    final s = await req.send();
    final res = await http.Response.fromStream(s);
    final d = await ApiService.handleResponse(res);
    return Product.fromJson(d);
  }

  Future<void> delete(int id) async {
    final res = await http.delete(
      Uri.parse('${ApiConfig.productsEndpoint}/$id'),
      headers: await ApiService.authHeaders(),
    );
    await ApiService.handleResponse(res);
  }
}