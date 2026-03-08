enum FoodCategory {
  korean('한식', '한식', 'FD6'),
  chinese('중식', '중식', 'FD6'),
  japanese('일식', '일식', 'FD6'),
  western('양식', '양식', 'FD6'),
  snack('분식', '분식', 'FD6'),
  chicken('치킨', '치킨', 'FD6'),
  pizza('피자', '피자', 'FD6'),
  cafe('카페', '카페', 'CE7');

  final String label;
  final String keyword;
  final String categoryGroupCode;
  const FoodCategory(this.label, this.keyword, this.categoryGroupCode);
}

class FilterState {
  final int distance;
  final Set<FoodCategory> selectedCategories;

  const FilterState({
    this.distance = 1000,
    this.selectedCategories = const {},
  });

  FilterState copyWith({
    int? distance,
    Set<FoodCategory>? selectedCategories,
  }) {
    return FilterState(
      distance: distance ?? this.distance,
      selectedCategories: selectedCategories ?? this.selectedCategories,
    );
  }

  bool get isDefault => distance == 1000 && selectedCategories.isEmpty;
}
