import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/exception_handler.dart';
import '../models/restaurant.dart';
import '../models/restaurant_item.dart';
import '../widgets/detail_screen_widgets.dart';
import '../widgets/error_fallback_widget.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final ApiClient _apiClient = ApiClient();
  final ScrollController _scrollController = ScrollController();

  List<RestaurantItem> _items = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isLoadingMore = false;
  bool _hasMoreItems = true;
  int _currentVisibleItems = 6;

  @override
  void initState() {
    super.initState();
    _loadRestaurantDetails();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMoreItems &&
        !_isLoading) {
      _loadMoreItems();
    }
  }

 Future<void> _loadRestaurantDetails() async {
  setState(() {
    _isLoading = true;
    _errorMessage = '';
  });

  try {
    final response = await _apiClient.fetchRestaurantDetails(
      widget.restaurant.id,
    );

    setState(() {
      _items = response;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _isLoading = false;
      _errorMessage = ExceptionHandler.getMessage(e);
    });
  }
}

  Future<void> _loadMoreItems() async {
    setState(() => _isLoadingMore = true);

    await Future.delayed(const Duration(milliseconds: 700));

    if (_currentVisibleItems >= _items.length) {
      _hasMoreItems = false;
    } else {
      _currentVisibleItems += 4;
      if (_currentVisibleItems >= _items.length) {
        _currentVisibleItems = _items.length;
        _hasMoreItems = false;
      }
    }

    setState(() => _isLoadingMore = false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f6f6),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _RestaurantAppBar(restaurant: widget.restaurant),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RestaurantDescription(description: widget.restaurant.description),
                  const SizedBox(height: 15),
                  const MenuSectionHeader(),
                  const SizedBox(height: 5),
                MenuBody(
                    isLoading: _isLoading,
                    errorMessage: _errorMessage,
                    items: _items,
                    currentVisibleItems: _currentVisibleItems,
                    isLoadingMore: _isLoadingMore,
                    onRetry: _loadRestaurantDetails,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RestaurantAppBar extends StatelessWidget {
  final Restaurant restaurant;

  const _RestaurantAppBar({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: restaurant.id,
              child: Semantics(
                label: '${restaurant.name} restaurant image',
                child: Image.network(restaurant.image, fit: BoxFit.cover),
              ),
            ),
            const _GradientOverlay(),
            Positioned(
              left: 18,
              right: 18,
              bottom: 24,
              child: _RestaurantHeaderInfo(restaurant: restaurant),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientOverlay extends StatelessWidget {
  const _GradientOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.75),
          ],
        ),
      ),
    );
  }
}

class _RestaurantHeaderInfo extends StatelessWidget {
  final Restaurant restaurant;

  const _RestaurantHeaderInfo({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context);
    final isOpen = restaurant.isOpen == 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          restaurant.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: textScale.scale(29),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.orange, size: 20),
            const SizedBox(width: 5),
            Text(
              restaurant.rating.toString(),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 14),
            Tooltip(
              message: isOpen ? 'Restaurant is open' : 'Restaurant is closed',
              child: Icon(
                isOpen ? Icons.check_circle : Icons.cancel,
                color: isOpen ? Colors.green : Colors.red,
                size: 18,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isOpen ? 'Open' : 'Closed',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}

