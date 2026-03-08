import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lunch_roulette_app/features/roulette/providers/roulette_history_provider.dart';
import 'package:lunch_roulette_app/features/roulette/widgets/result_card.dart';
import 'package:lunch_roulette_app/features/roulette/widgets/roulette_wheel.dart';
import 'package:lunch_roulette_app/models/restaurant.dart';

class RouletteScreen extends ConsumerStatefulWidget {
  final List<Restaurant> restaurants;

  const RouletteScreen({super.key, required this.restaurants});

  @override
  ConsumerState<RouletteScreen> createState() => _RouletteScreenState();
}

class _RouletteScreenState extends ConsumerState<RouletteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final Random _random = Random();

  bool _isSpinning = false;
  Restaurant? _selectedRestaurant;
  double _currentRotation = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spin() {
    if (_isSpinning || widget.restaurants.isEmpty) return;

    setState(() {
      _isSpinning = true;
      _selectedRestaurant = null;
    });

    final selectedIndex = _random.nextInt(widget.restaurants.length);
    final sectionAngle = 2 * pi / widget.restaurants.length;

    // Calculate target rotation: multiple full spins + land on selected section
    // The arrow is at top (- pi/2), so we calculate the angle to align the selected section
    final targetSectionCenter = selectedIndex * sectionAngle + sectionAngle / 2;
    final fullSpins = (3 + _random.nextInt(3)) * 2 * pi;
    final targetRotation = fullSpins + (2 * pi - targetSectionCenter);

    _animation = Tween<double>(
      begin: 0,
      end: targetRotation,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    final startRotation = _currentRotation;

    _animation.addListener(() {
      setState(() {
        _currentRotation = startRotation + _animation.value;
      });
    });

    _controller.reset();
    _controller.forward().then((_) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('룰렛'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: RouletteWheel(
                restaurants: widget.restaurants,
                rotation: _currentRotation,
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
          Padding(
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
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
