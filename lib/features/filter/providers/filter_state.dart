enum FoodCategory {
  korean('한식', '한식'),
  chinese('중식', '중식'),
  japanese('일식', '일식'),
  western('양식', '양식'),
  snack('분식', '분식'),
  chicken('치킨', '치킨'),
  pizza('피자', '피자');

  final String label;
  final String keyword;
  const FoodCategory(this.label, this.keyword);
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
