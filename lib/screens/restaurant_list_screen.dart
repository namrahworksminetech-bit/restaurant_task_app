import 'dart:async';

import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/exception_handler.dart';
import '../models/restaurant.dart';
import '../widgets/category_filter_widget.dart';
import '../widgets/empty_widget.dart';
import '../widgets/error_fallback_widget.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/search_bar_widget.dart';


const _categories = ['All', 'Burger', 'Pizza', 'Coffee', 'Healthy', 'Dessert'];

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key});

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Restaurant> _restaurants = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isPaginationLoading = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  Timer? _debounce;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 250 &&
        !_isPaginationLoading &&
        _hasMoreData &&
        !_isLoading) {
      _loadMoreRestaurants();
    }
  }

  Future<void> _loadRestaurants({String query = ''}) async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMoreData = true;
      _errorMessage = '';
    });

    try {
      final data = await _apiClient.fetchRestaurants(query: query, page: 1);
      setState(() {
        _restaurants = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = ExceptionHandler.getMessage(e);
      });
    }
  }

  Future<void> _loadMoreRestaurants() async {
    setState(() => _isPaginationLoading = true);

    try {
      _currentPage++;
      final nextPageData = await _apiClient.fetchRestaurants(
        page: _currentPage,
        query: _selectedCategory == 'All' ? _searchController.text : _selectedCategory,
      );

      if (nextPageData.isEmpty) {
        _hasMoreData = false;
      } else {
        _restaurants.addAll(nextPageData);
      }
    } catch (e) {
      debugPrint('pagination error $e');
    } finally {
      setState(() => _isPaginationLoading = false);
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 700),
      () => _loadRestaurants(query: value),
    );
  }

  void _filterByCategory(String category) {
    setState(() => _selectedCategory = category);
    if (category == 'All') {
      _loadRestaurants(query: _searchController.text);
    } else {
      _loadRestaurants(query: category);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Restaurants',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.4,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          SearchBarWidget(
            controller: _searchController,
            onChanged: _onSearchChanged,
          ),
          CategoryFilterWidget(
            categories: _categories,
            selectedCategory: _selectedCategory,
            onSelected: _filterByCategory,
          ),
          Expanded(
            child: _RestaurantListBody(
              isLoading: _isLoading,
              errorMessage: _errorMessage,
              restaurants: _restaurants,
              isPaginationLoading: _isPaginationLoading,
              scrollController: _scrollController,
              onRetry: () => _loadRestaurants(query: _searchController.text),
            ),
          ),
        ],
      ),
    );
  }
}

class _RestaurantListBody extends StatelessWidget {
  final bool isLoading;
  final String errorMessage;
  final List<Restaurant> restaurants;
  final bool isPaginationLoading;
  final ScrollController scrollController;
  final VoidCallback onRetry;

  const _RestaurantListBody({
    required this.isLoading,
    required this.errorMessage,
    required this.restaurants,
    required this.isPaginationLoading,
    required this.scrollController,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (isLoading) {
      child = const Center(
        key: ValueKey('loading'),
        child: CircularProgressIndicator(),
      );
    } else if (errorMessage.isNotEmpty) {
      child = ErrorFallbackWidget(
        key: const ValueKey('error'),
        message: errorMessage,
        onRetry: onRetry,
      );
    } else if (restaurants.isEmpty) {
      child = const EmptyWidget(key: ValueKey('empty'));
    } else {
      child = _RestaurantList(
        key: const ValueKey('list'),
        restaurants: restaurants,
        isPaginationLoading: isPaginationLoading,
        scrollController: scrollController,
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      child: child,
    );
  }
}

class _RestaurantList extends StatelessWidget {
  final List<Restaurant> restaurants;
  final bool isPaginationLoading;
  final ScrollController scrollController;

  const _RestaurantList({
    super.key,
    required this.restaurants,
    required this.isPaginationLoading,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(top: 14, bottom: 20),
      itemCount: restaurants.length + (isPaginationLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= restaurants.length) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return RestaurantCard(restaurant: restaurants[index]);
      },
    );
  }
}