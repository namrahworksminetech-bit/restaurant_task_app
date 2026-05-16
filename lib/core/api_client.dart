import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/restaurant.dart';
import '../models/restaurant_item.dart';
import 'app_config.dart';

class ApiClient {
  final HttpClient _client = HttpClient();

  Future<List<Restaurant>> fetchRestaurants({
    String query = '',
    int page = 1,
  }) async {
    try {
      final url = Uri.parse(
        '${AppConfig.baseUrl}/restaurant/search'
        '?lang=en'
        '&storeCode=KW'
        '&page=$page'
        '&perPage=20'
        '&q=$query'
        '&categoryId='
        '&macroCategoryId='
        '&nearBy='
        '&sortBy=1'
        '&homeManagementId='
        '&latlng=29.3800453,47.9744896'
        '&userId=1f60cddc-ae03-4430-b8d7-deb6bf63846c'
        '&calories='
        '&carbs='
        '&proteins='
        '&fats='
        '&isCheat=0',
      );

      final request = await _client.postUrl(url);

      AppConfig.headers.forEach((key, value) {
        request.headers.set(key, value);
      });

      request.write(
        jsonEncode({
          "categoryId": "",
        }),
      );

      final response =
          await request.close();

      if (response.statusCode == 200) {
        final responseBody =
            await response
                .transform(
                  utf8.decoder,
                )
                .join();

        final decoded =
            jsonDecode(responseBody);

        final restaurantsJson =
            decoded['data']['restaurants']
                as List;

        return restaurantsJson
            .map(
              (e) =>
                  Restaurant.fromJson(e),
            )
            .toList();
      } else {
        throw Exception(
          'Failed to load restaurants',
        );
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  
Future<List<RestaurantItem>>
    fetchRestaurantDetails(
  int restaurantId,
) async {
  try {
    final url = Uri.parse(
      '${AppConfig.baseUrl}/restaurant/details'
      '?lang=en'
      '&storeCode=KW'
      '&currencyCode=KD'
      '&restaurantId=$restaurantId'
      '&userId=1f60cddc-ae03-4430-b8d7-deb6bf63846c'
      '&latlng=29.3800453,47.9744896',
    );

    final request =
        await _client.getUrl(url);

    AppConfig.headers.forEach(
      (key, value) {
        request.headers.set(
          key,
          value,
        );
      },
    );

    final response =
        await request.close();

    if (response.statusCode == 200) {
      final responseBody =
          await response
              .transform(
                utf8.decoder,
              )
              .join();

      final decoded =
          jsonDecode(responseBody);

      final data = decoded['data'];

      if (data == null) {
        return [];
      }

      final itemList =
          (data['itemList'] ?? [])
              as List;

      return itemList
          .map(
            (e) =>
                RestaurantItem.fromJson(
              e,
            ),
          )
          .toList();
    } else {
      throw Exception(
        'Failed to load details',
      );
    }
  } catch (e) {
    throw Exception(e.toString());
  }
}
}