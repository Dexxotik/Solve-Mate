// lib/services/reward_manager.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

class Reward {
  final String id;
  final String title;
  final int points;
  final dynamic icon;
  String? lastClaimedDate;

  Reward({
    required this.id,
    required this.title,
    required this.points,
    required this.icon,
    this.lastClaimedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'points': points,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'iconFontPackage': icon.fontPackage,
      'lastClaimedDate': lastClaimedDate,
    };
  }

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'],
      title: json['title'],
      points: json['points'],
      icon: IconData(
        json['iconCodePoint'],
        fontFamily: json['iconFontFamily'],
        fontPackage: json['iconFontPackage'],
      ),
      lastClaimedDate: json['lastClaimedDate'],
    );
  }

  bool get canBeClaimed {
    if (lastClaimedDate == null) return true;

    final lastClaimed = DateTime.parse(lastClaimedDate!);
    final now = DateTime.now();
    final difference = now.difference(lastClaimed);

    // Can be claimed if 24 hours have passed
    return difference.inHours >= 24;
  }

  String get timeUntilAvailable {
    if (lastClaimedDate == null) return "Available now";

    final lastClaimed = DateTime.parse(lastClaimedDate!);
    final now = DateTime.now();
    final nextAvailable = lastClaimed.add(const Duration(hours: 24));
    final remainingTime = nextAvailable.difference(now);

    if (remainingTime.isNegative) return "Available now";

    final hours = remainingTime.inHours;
    final minutes = remainingTime.inMinutes % 60;
    return "$hours hours, $minutes minutes";
  }
}

class RewardManager {
  static const _rewardsKey = 'rewards';
  static const _pointsKey = 'userPoints';

  // Get all rewards
  static Future<List<Reward>> getRewards() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rewardsJson = prefs.getString(_rewardsKey);

    if (rewardsJson == null) {
      // We need to handle icon serialization differently
      // This is a placeholder that won't be saved yet
      return [];
    }

    List<dynamic> rewardsList = jsonDecode(rewardsJson);
    return rewardsList.map((reward) => Reward.fromJson(reward)).toList();
  }

  // Save rewards
  static Future<void> saveRewards(List<Reward> rewards) async {
    final prefs = await SharedPreferences.getInstance();
    final rewardsJson = jsonEncode(
      rewards.map((reward) => reward.toJson()).toList(),
    );
    await prefs.setString(_rewardsKey, rewardsJson);
  }

  // Claim a reward
  static Future<bool> claimReward(String rewardId) async {
    final rewards = await getRewards();
    final rewardIndex = rewards.indexWhere((reward) => reward.id == rewardId);

    if (rewardIndex != -1) {
      final reward = rewards[rewardIndex];

      if (reward.canBeClaimed) {
        // Check if user has enough points
        final points = await getUserPoints();
        if (points >= reward.points) {
          // Deduct points
          await updateUserPoints(points - reward.points);

          // Mark as claimed
          reward.lastClaimedDate = DateTime.now().toIso8601String();
          await saveRewards(rewards);
          return true;
        }
      }
    }
    return false;
  }

  // Get user points
  static Future<int> getUserPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_pointsKey) ?? 0;
  }

  // Update user points
  static Future<void> updateUserPoints(int points) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pointsKey, points);
  }

  // Add points to user
  static Future<void> addPoints(int points) async {
    final currentPoints = await getUserPoints();
    await updateUserPoints(currentPoints + points);
  }
}
