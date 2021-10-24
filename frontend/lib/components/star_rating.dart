import 'package:flutter/material.dart';

typedef RatingChangeCallback = void Function(double rating);

class StarRating extends StatelessWidget {
  final int starCount;
  final int rating;
  final RatingChangeCallback onRatingChanged;
  final Color color;
  final bool alterable;

  const StarRating(
      {Key? key,
      this.starCount = 5,
      this.rating = 0,
      required this.onRatingChanged,
      required this.color,
      required this.alterable})
      : super(key: key);

  Widget buildStar(BuildContext context, int index) {
    var size = alterable ? 25.0 : 15.0;
    Icon icon;
    if (index >= rating) {
      icon = Icon(
        Icons.star_border,
        color: Colors.brown,
        size: size,
      );
    } else {
      icon = Icon(
        Icons.star,
        color: color,
        size: size,
      );
    }
    if (!alterable) return icon;
    return InkResponse(
      onTap: () => onRatingChanged(index + 1.0),
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        children:
            List.generate(starCount, (index) => buildStar(context, index)));
  }
}
