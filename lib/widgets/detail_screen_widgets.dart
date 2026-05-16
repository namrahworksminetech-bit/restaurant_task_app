
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../models/restaurant.dart';
import '../models/restaurant_item.dart';
import 'error_fallback_widget.dart';

class RestaurantAppBar extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantAppBar({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: Colors.black,
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

class RestaurantDescription extends StatefulWidget {
  final String description;

  const RestaurantDescription({required this.description});

  @override
  State<RestaurantDescription> createState() => _RestaurantDescriptionState();
}

class _RestaurantDescriptionState extends State<RestaurantDescription> {
  bool _expanded = false;

  bool _overflows(double maxWidth) {
    final tp = TextPainter(
      text: TextSpan(
        text: widget.description,
        style: TextStyle(color: Colors.grey.shade700, fontSize: 15, height: 1.6),
      ),
      maxLines: 3,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    return tp.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(color: Colors.grey.shade700, fontSize: 15, height: 1.6);
    return LayoutBuilder(
      builder: (context, constraints) {
        final overflows = _overflows(constraints.maxWidth);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.description,
              maxLines: _expanded ? null : 2,
              overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: style,
            ),
            if (overflows) ...[
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Text(
                  _expanded ? 'Show less' : 'Read more',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class MenuSectionHeader extends StatelessWidget {
  const MenuSectionHeader();

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context);
    return Text(
      'Menu',
      style: TextStyle(
        fontSize: textScale.scale(23),
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class MenuBody extends StatelessWidget {
  final bool isLoading;
  final String errorMessage;
  final List<RestaurantItem> items;
  final int currentVisibleItems;
  final bool isLoadingMore;
  final VoidCallback onRetry;

  const MenuBody({
    required this.isLoading,
    required this.errorMessage,
    required this.items,
    required this.currentVisibleItems,
    required this.isLoadingMore,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage.isNotEmpty) {
      return ErrorFallbackWidget(message: errorMessage, onRetry: onRetry);
    }

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Center(
          child: Text(
            'No menu items available',
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: currentVisibleItems + (isLoadingMore ? 1 : 0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index >= currentVisibleItems) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _MenuItemCard(item: items[index]);
      },
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final RestaurantItem item;

  const _MenuItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        return Container(
          margin: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MenuItemImage(image: item.image, isWide: isWide),
              _MenuItemDetails(item: item, isWide: isWide),
            ],
          ),
        );
      },
    );
  }
}

class _MenuItemImage extends StatelessWidget {
  final String image;
  final bool isWide;

  const _MenuItemImage({required this.image, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final height = isWide ? 260.0 : 190.0;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      child: image.isEmpty
          ? Container(
              height: height,
              color: Colors.grey.shade200,
              child: const Icon(Icons.fastfood, size: 50),
            )
          : Image.network(
              image,
              height: height,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
    );
  }
}

class _MenuItemDetails extends StatelessWidget {
  final RestaurantItem item;
  final bool isWide;

  const _MenuItemDetails({required this.item, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context);
    return Padding(
      padding: EdgeInsets.all(isWide ? 22 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: textScale.scale(isWide ? 24 : 19),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '\$${item.price}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: textScale.scale(17),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ExpandableDescription(description: item.description),
          const SizedBox(height: 16),
          NutritionChips(item: item),
        ],
      ),
    );
  }
}

class _ExpandableDescription extends StatefulWidget {
  final String description;

  const _ExpandableDescription({required this.description});

  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool _expanded = false;

  bool _overflows(double maxWidth) {
    final tp = TextPainter(
      text: TextSpan(
        text: widget.description,
        style: TextStyle(color: Colors.grey.shade600, height: 1.5, fontSize: 13.5),
      ),
      maxLines: 2,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    return tp.didExceedMaxLines;
  }
@override
Widget build(BuildContext context) {
  final style = TextStyle(
    color: Colors.grey.shade600,
    height: 1.35,
    fontSize: 13.5,
  );

  return LayoutBuilder(
    builder: (context, constraints) {
      final overflows = _overflows(constraints.maxWidth);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.description,
            maxLines: _expanded ? 5 : 2,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
      
          if (overflows)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                child: Text(
                  _expanded ? 'Show less' : 'Read more',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}
}

class NutritionChips extends StatelessWidget {
  final RestaurantItem item;

  const NutritionChips({required this.item});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _NutritionChip(label: '${item.calories} cal', color: Colors.orange.shade50),
          const SizedBox(width: 8),
          _NutritionChip(label: '${item.proteins} protein', color: Colors.green.shade50),
          const SizedBox(width: 8),
          _NutritionChip(label: '${item.carbs} carbs', color: Colors.blue.shade50),
        ],
      ),
    );
  }
}
class _NutritionChip extends StatelessWidget {
  final String label;
  final Color color;

  const _NutritionChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12.5)),
    );
  }
}