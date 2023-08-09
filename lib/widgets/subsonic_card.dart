import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SubsonicCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final List<Widget> content;
  final String? cacheKey;
  final bool? isThreeLines;
  final void Function()? onTap;

  const SubsonicCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.content,
    this.cacheKey,
    this.isThreeLines,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
      child: Card(
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: FractionallySizedBox(
              widthFactor: 0.17,
              heightFactor: 1,
              child: CachedNetworkImage(
                fadeInCurve: Curves.fastLinearToSlowEaseIn,
                //placeholder: (context, url) => const SizedBox(height: 72),
                cacheKey: cacheKey ?? imageUrl,
                maxHeightDiskCache: 72,
                imageUrl: imageUrl,
                //height: 72,
                fit: BoxFit.cover,
              ),
            ),
          ),
          onTap: onTap,
          title: Text(title, overflow: TextOverflow.ellipsis, maxLines: 1),
          subtitle: Column(
            children: content,
          ),
          isThreeLine: isThreeLines ?? false,
        ),
      ),
    );
  }
}
