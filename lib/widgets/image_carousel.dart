import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../config/api_config.dart';

class ImageCarousel extends StatefulWidget {
  final List<String> imagePaths;
  const ImageCarousel({super.key, required this.imagePaths});

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.imagePaths.isEmpty) {
      return AspectRatio(
        aspectRatio: 1.2,
        child: Container(color: Colors.grey.shade200,
            child: const Icon(Icons.image, size: 80, color: Colors.grey)),
      );
    }
    return AspectRatio(
      aspectRatio: 1.2,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: widget.imagePaths.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) {
              final url = ApiConfig.imageUrl(widget.imagePaths[i]);
              return CachedNetworkImage(
                imageUrl: url ?? '',
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.grey.shade200),
                errorWidget: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported, size: 60)),
              );
            },
          ),
          if (widget.imagePaths.length > 1)
            Positioned(
              bottom: 10, left: 0, right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.imagePaths.length, (i) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _index == i ? 18 : 8, height: 8,
                    decoration: BoxDecoration(
                        color: _index == i ? Colors.white : Colors.white54,
                        borderRadius: BorderRadius.circular(4)),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}