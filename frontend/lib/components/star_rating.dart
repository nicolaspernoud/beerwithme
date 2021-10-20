import 'package:flutter/material.dart';

typedef void RatingChangeCallback(double rating);

class StarRating extends StatelessWidget {
  final int starCount;
  final int rating;
  final RatingChangeCallback onRatingChanged;
  final Color color;
  final bool alterable;

  StarRating(
      {this.starCount = 10,
      this.rating = 0,
      required this.onRatingChanged,
      required this.color,
      required this.alterable});

  Widget buildStar(BuildContext context, int index) {
    var size = alterable ? 25.0 : 15.0;
    Icon icon;
    if (index >= rating) {
      icon = new Icon(
        Icons.star_border,
        color: Theme.of(context).buttonColor,
        size: size,
      );
    } else {
      icon = new Icon(
        Icons.star,
        color: color,
        size: size,
      );
    }
    if (!alterable) return icon;
    return new InkResponse(
      onTap: () => onRatingChanged(index + 1.0),
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
        children:
            new List.generate(starCount, (index) => buildStar(context, index)));
  }
}
