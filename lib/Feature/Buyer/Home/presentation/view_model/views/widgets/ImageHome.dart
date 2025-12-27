class ImageHome {
  static String getValidImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://via.placeholder.com/400x200.png?text=No+Image';
    }
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    if (url.startsWith('/')) {
      return 'https://toknagah.viking-iceland.online$url';
    }

    return 'https://via.placeholder.com/400x200.png?text=No+Image';
  }

  static List<String> processImageList(List<dynamic>? rawImages) {
    if (rawImages == null || rawImages.isEmpty) {
      return ['https://via.placeholder.com/400x200.png?text=No+Image'];
    }

    return rawImages.map((image) {
      final imageUrl = image.toString();
      return getValidImageUrl(imageUrl);
    }).toList();
  }
}
