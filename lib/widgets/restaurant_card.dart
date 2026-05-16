import 'package:flutter/material.dart';
import 'package:restaurant_task/screens/detail_screen.dart';

import '../models/restaurant.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantCard({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context);

    return Semantics(
      label: '${restaurant.name} restaurant card',
      button: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        ),
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RestaurantDetailScreen(restaurant: restaurant),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardImage(restaurant: restaurant),
                _CardDetails(restaurant: restaurant, textScale: textScale),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// image on the card
class _CardImage extends StatelessWidget {
  final Restaurant restaurant;

  const _CardImage({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Stack(
        children: [
          Hero(
            tag: restaurant.id,
            child: Semantics(
              label: '${restaurant.name} image',
              child: Image.network(
                restaurant.image,
                height: 230,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 230,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 230,
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Icon(Icons.restaurant, size: 50),
                  );
                },
              ),
            ),
          ),
          Container(
            height: 230,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.35),
                ],
              ),
            ),
          ),
          Positioned(
            top: 18,
            right: 18,
            child: Tooltip(
              message: 'Restaurant rating',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.orange),
                    const SizedBox(width: 5),
                    Text(
                      restaurant.rating.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// details on the card
class _CardDetails extends StatelessWidget {
  final Restaurant restaurant;
  final TextScaler textScale;

  const _CardDetails({required this.restaurant, required this.textScale});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            restaurant.name,
            style: TextStyle(
              fontSize: textScale.scale(24),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            restaurant.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.6,
              fontSize: textScale.scale(15),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _InfoChip(
                icon: Icons.access_time,
                text: '${restaurant.deliveryTime} mins',
                color: Colors.orange,
              ),
              const SizedBox(width: 12),
              _InfoChip(
                icon: Icons.location_on,
                text: '${restaurant.distance.toStringAsFixed(1)} km',
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// info chips on the card
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoChip({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}