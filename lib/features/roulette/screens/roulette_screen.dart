import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import 'package:lunch_roulette_app/app/theme.dart';
import 'package:lunch_roulette_app/features/roulette/providers/roulette_history_provider.dart';
import 'package:lunch_roulette_app/features/roulette/widgets/result_card.dart';
import 'package:lunch_roulette_app/features/roulette/widgets/slot_machine.dart';
import 'package:lunch_roulette_app/models/restaurant.dart';

class RouletteScreen extends ConsumerStatefulWidget {
  final List<Restaurant> restaurants;

  const RouletteScreen({super.key, required this.restaurants});

  @override
  ConsumerState<RouletteScreen> createState() => _RouletteScreenState();
}

class _RouletteScreenState extends ConsumerState<RouletteScreen> {
  late FixedExtentScrollController _scrollController;
  final Random _random = Random();

  bool _isSpinning = false;
  Restaurant? _selectedRestaurant;

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _share(Restaurant restaurant) {
    final lines = <String>[
      '[점심 룰렛 결과]',
      '${restaurant.name} (${restaurant.categoryName})',
      restaurant.roadAddressName.isNotEmpty
          ? restaurant.roadAddressName
          : restaurant.addressName,
      '거리: ${restaurant.distance}m',
    ];
    if (restaurant.placeUrl.isNotEmpty) {
      lines.add(restaurant.placeUrl);
    }
    Share.share(lines.join('\n'));
  }

  void _spin() {
    if (_isSpinning || widget.restaurants.isEmpty) return;

    setState(() {
      _isSpinning = true;
      _selectedRestaurant = null;
    });

    final selectedIndex = _random.nextInt(widget.restaurants.length);
    final count = widget.restaurants.length;
    // Add multiple full loops for visual effect + land on selected index
    final targetItem =
        _scrollController.selectedItem + count * (3 + _random.nextInt(3)) + selectedIndex;

    _scrollController
        .animateToItem(
      targetItem,
      duration: const Duration(milliseconds: 3000),
      curve: Curves.easeOutCubic,
    )
        .then((_) {
      if (!mounted) return;
      setState(() {
        _isSpinning = false;
        _selectedRestaurant = widget.restaurants[selectedIndex];
      });
      ref
          .read(rouletteHistoryProvider.notifier)
          .addEntry(widget.restaurants[selectedIndex]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: appGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('룰렛'),
        ),
        body: Column(
        children: [
          Expanded(
            child: Center(
              child: SlotMachine(
                restaurants: widget.restaurants,
                controller: _scrollController,
              ),
            ),
          ),
          if (_selectedRestaurant != null) ...[
            GestureDetector(
              onTap: () => context.push(
                '/restaurant-detail',
                extra: _selectedRestaurant,
              ),
              child: ResultCard(restaurant: _selectedRestaurant!),
            ),
            const SizedBox(height: 16),
          ],
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isSpinning ? null : _spin,
                      icon: Icon(_selectedRestaurant != null
                          ? Icons.refresh
                          : Icons.play_arrow),
                      label: Text(
                          _selectedRestaurant != null ? '다시 돌리기' : '돌리기'),
                    ),
                  ),
                  if (_selectedRestaurant != null) ...[
                    const SizedBox(width: 12),
                    FilledButton.tonalIcon(
                      onPressed: () => context.push(
                        '/restaurant-detail',
                        extra: _selectedRestaurant,
                      ),
                      icon: const Icon(Icons.info_outline),
                      label: const Text('상세'),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      onPressed: () => _share(_selectedRestaurant!),
                      icon: const Icon(Icons.share),
                      tooltip: '공유',
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
