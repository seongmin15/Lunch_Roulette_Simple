import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lunch_roulette_app/app/theme.dart';
import 'package:lunch_roulette_app/models/restaurant.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: appGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('식당 상세'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _RestaurantDetailCard(restaurant: restaurant),
            const SizedBox(height: 16),
            _ActionButtons(restaurant: restaurant),
          ],
        ),
      ),
    );
  }
}

class _RestaurantDetailCard extends StatelessWidget {
  final Restaurant restaurant;

  const _RestaurantDetailCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              restaurant.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.category,
              text: restaurant.categoryName,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.location_on,
              text: restaurant.roadAddressName.isNotEmpty
                  ? restaurant.roadAddressName
                  : restaurant.addressName,
            ),
            if (restaurant.addressName.isNotEmpty &&
                restaurant.roadAddressName.isNotEmpty) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Text(
                  '(지번) ${restaurant.addressName}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.straighten,
              text: _formatDistance(restaurant.distance),
            ),
            if (restaurant.phone.isNotEmpty) ...[
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.phone,
                text: restaurant.phone,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDistance(int meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)}km';
    }
    return '${meters}m';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final Restaurant restaurant;

  const _ActionButtons({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: accentGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3D5AF1).withValues(alpha:0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FilledButton.icon(
            onPressed: () => _openNavigation(context),
            icon: const Icon(Icons.directions),
            label: const Text('길찾기'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
          ),
        ),
        if (restaurant.phone.isNotEmpty) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _callPhone(context),
            icon: const Icon(Icons.phone),
            label: const Text('전화하기'),
          ),
        ],
        if (restaurant.placeUrl.isNotEmpty) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _openPlaceUrl(context),
            icon: const Icon(Icons.open_in_new),
            label: const Text('카카오맵에서 보기'),
          ),
        ],
      ],
    );
  }

  Future<void> _openNavigation(BuildContext context) async {
    // Try Kakao Map first, fallback to Google Maps
    final kakaoUrl = Uri.parse(
      'kakaomap://look?p=${restaurant.latitude},${restaurant.longitude}',
    );
    final googleUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${restaurant.latitude},${restaurant.longitude}',
    );

    if (await canLaunchUrl(kakaoUrl)) {
      await launchUrl(kakaoUrl);
    } else {
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callPhone(BuildContext context) async {
    final url = Uri.parse('tel:${restaurant.phone}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _openPlaceUrl(BuildContext context) async {
    final url = Uri.parse(restaurant.placeUrl);
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
