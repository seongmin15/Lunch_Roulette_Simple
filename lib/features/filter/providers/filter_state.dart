enum PriceRange {
  all('전체'),
  cheap('저렴'),
  moderate('보통'),
  expensive('비싼');

  final String label;
  const PriceRange(this.label);
}

class FilterState {
  final int distance;
  final PriceRange priceRange;

  const FilterState({
    this.distance = 1000,
    this.priceRange = PriceRange.all,
  });

  FilterState copyWith({
    int? distance,
    PriceRange? priceRange,
  }) {
    return FilterState(
      distance: distance ?? this.distance,
      priceRange: priceRange ?? this.priceRange,
    );
  }

  bool get isDefault => distance == 1000 && priceRange == PriceRange.all;
}
