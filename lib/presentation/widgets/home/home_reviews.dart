// home_reviews.dart
import 'package:flutter/material.dart';
import 'package:dreamers_movies_app_bv/resources/styles/styles.dart';

class ReviewData {
  final String userName;
  final String userAvatar;
  final double rating;
  final String reviewText;
  final String movieTitle;
  final String? reviewDate;

  const ReviewData({
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.reviewText,
    required this.movieTitle,
    this.reviewDate,
  });
}

class HomeReviews extends StatelessWidget {
  final List<ReviewData> reviews;

  const HomeReviews({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _ReviewCard(
                userName: review.userName,
                userAvatar: review.userAvatar,
                rating: review.rating,
                reviewText: review.reviewText,
                movieTitle: review.movieTitle,
                reviewDate: review.reviewDate,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String userName;
  final String userAvatar;
  final double rating;
  final String reviewText;
  final String movieTitle;
  final String? reviewDate;

  const _ReviewCard({
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.reviewText,
    required this.movieTitle,
    this.reviewDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade900,
            Colors.grey.shade800,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: userAvatar.isNotEmpty ? NetworkImage(userAvatar) : null,
                  backgroundColor: Colors.grey.shade700,
                  child: userAvatar.isEmpty
                      ? Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          fontFamily: AppTheme.secondaryFont,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        movieTitle,
                        style: TextStyle(
                          fontFamily: AppTheme.secondaryFont,
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              reviewText,
              style: TextStyle(
                fontFamily: AppTheme.secondaryFont,
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                height: 1.5,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            if (reviewDate != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  reviewDate!,
                  style: TextStyle(
                    fontFamily: AppTheme.secondaryFont,
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}