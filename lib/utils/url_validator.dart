// Checks if a given URL is a valid image URL.
bool isValidImageUrl(String? url) {
  if (url == null || url.trim().isEmpty) return false;
  final uri = Uri.tryParse(url);
  if (uri == null || !(uri.isAbsolute)) return false;
  final lower = url.toLowerCase();
  return lower.endsWith('.png') || lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.gif') || lower.endsWith('.webp');
}
