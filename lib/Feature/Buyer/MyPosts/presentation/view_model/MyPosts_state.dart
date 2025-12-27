
class MyPostsState {
  final List<Map<String, dynamic>> ads;
  MyPostsState(this.ads);

  MyPostsState copyWith({List<Map<String, dynamic>>? ads}) {
    return MyPostsState(ads ?? this.ads);
  }
}