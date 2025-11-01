
class MyStoreState {
  final List<Map<String, dynamic>> ads;
  MyStoreState(this.ads);

  MyStoreState copyWith({List<Map<String, dynamic>>? ads}) {
    return MyStoreState(ads ?? this.ads);
  }
}