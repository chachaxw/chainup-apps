
enum MainState {
  MA("MA"),
  BOLL("BOLL"),
  EMA("EMA"),
  NONE("NONE");
  const MainState(this.value);
  final String value;
  static MainState getTypeByValue(String value) =>
      MainState.values.firstWhere((type) => type.value == value, orElse: () => MainState.MA);
}
