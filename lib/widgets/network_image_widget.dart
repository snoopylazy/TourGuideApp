import 'package:flutter/material.dart';

class NetworkImageWidget extends StatelessWidget {
  final String? url;
  final double? height;
  final double? width;
  final BoxFit fit;

  const NetworkImageWidget({super.key, this.url, this.height, this.width, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.trim().isEmpty) {
      return Container(
        height: height ?? 120,
        width: width ?? double.infinity,
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported),
      );
    }
    return Image.network(
      url!,
      height: height,
      width: width,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          height: height ?? 120,
          width: width ?? double.infinity,
          child: const Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (context, error, stack) => Container(
        height: height ?? 120,
        width: width ?? double.infinity,
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image),
      ),
    );
  }
}
