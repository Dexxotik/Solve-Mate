import 'package:flutter/material.dart';
import '../services/reward_service.dart';

class RewardCard extends StatelessWidget {
  final Reward reward;
  final int userPoints;
  final Function(Reward) onClaim;

  const RewardCard({
    super.key,
    required this.reward,
    required this.userPoints,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final bool canAfford = userPoints >= reward.points;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.deepPurple[400],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(reward.icon, size: 40, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    reward.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              reward.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${reward.points} points',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  reward.canBeClaimed
                      ? 'Available now'
                      : 'Available in: ${reward.timeUntilAvailable}',
                  style: TextStyle(
                    color:
                        reward.canBeClaimed
                            ? Colors.green[200]
                            : Colors.orange[200],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (reward.canBeClaimed && canAfford)
                        ? () => onClaim(reward)
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepPurple,
                  disabledBackgroundColor: Colors.grey[400],
                  disabledForegroundColor: Colors.grey[700],
                ),
                child: Text(
                  reward.canBeClaimed
                      ? canAfford
                          ? 'Claim Reward'
                          : 'Need ${reward.points - userPoints} more points'
                      : 'Unavailable',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
