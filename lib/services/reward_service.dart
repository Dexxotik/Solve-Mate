import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

class Reward {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int points;
  String? lastClaimedDate;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
    this.lastClaimedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'iconFontPackage': icon.fontPackage,
      'points': points,
      'lastClaimedDate': lastClaimedDate,
    };
  }

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: IconData(
        json['iconCodePoint'],
        fontFamily: json['iconFontFamily'],
        fontPackage: json['iconFontPackage'],
      ),
      points: json['points'],
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

class RewardService {
  static const String _rewardsKey = 'rewards';
  static const String _lastRewardInitKey = 'lastRewardInit';
  final Uuid _uuid = const Uuid();

  // Get all rewards
  Future<List<Reward>> getAllRewards() async {
    final prefs = await SharedPreferences.getInstance();
    final rewardsJson = prefs.getStringList(_rewardsKey) ?? [];

    return rewardsJson
        .map((json) => Reward.fromJson(jsonDecode(json)))
        .toList();
  }

  // Initialize default rewards if not already done
  Future<void> initializeDefaultRewards() async {
    final prefs = await SharedPreferences.getInstance();
    final lastInit = prefs.getString(_lastRewardInitKey);

    // Only initialize if not done before
    if (lastInit == null) {
      final defaultRewards = [
        Reward(
          id: _uuid.v4(),
          title: 'Extra 10 Minutes of Screen Time',
          description:
              'Earn 10 extra minutes of screen time as a reward for your hard work!',
          icon: Icons.timer,
          points: 100,
        ),
        Reward(
          id: _uuid.v4(),
          title: 'Choose a Special Snack',
          description: 'Pick your favorite snack as a reward for learning!',
          icon: Icons.fastfood,
          points: 200,
        ),
        Reward(
          id: _uuid.v4(),
          title: 'Game Time with Parents',
          description: 'Redeem for 30 minutes of game time with your parents!',
          icon: Icons.games,
          points: 300,
        ),
        Reward(
          id: _uuid.v4(),
          title: 'Trip to the Park',
          description: 'Earn a special trip to your favorite park!',
          icon: Icons.park,
          points: 500,
        ),
        Reward(
          id: _uuid.v4(),
          title: 'Small Toy or Book',
          description: 'Redeem for a small toy or book of your choice!',
          icon: Icons.toys,
          points: 1000,
        ),
      ];

      // Save default rewards
      final rewardsJson =
          defaultRewards.map((reward) => jsonEncode(reward.toJson())).toList();

      await prefs.setStringList(_rewardsKey, rewardsJson);
      await prefs.setString(
        _lastRewardInitKey,
        DateTime.now().toIso8601String(),
      );
    }
  }

  // Claim a reward
  Future<void> claimReward(String id, int currentPoints) async {
    final prefs = await SharedPreferences.getInstance();
    final rewardsJson = prefs.getStringList(_rewardsKey) ?? [];

    final rewards =
        rewardsJson.map((json) => Reward.fromJson(jsonDecode(json))).toList();

    final rewardIndex = rewards.indexWhere((r) => r.id == id);
    if (rewardIndex == -1) {
      throw Exception('Reward not found');
    }

    final reward = rewards[rewardIndex];

    // Check if already claimed and not available
    if (!reward.canBeClaimed) {
      throw Exception('Reward not available yet');
    }

    // Check if enough points
    if (currentPoints < reward.points) {
      throw Exception('Not enough points');
    }

    // Update reward to claimed
    final updatedReward = Reward(
      id: reward.id,
      title: reward.title,
      description: reward.description,
      icon: reward.icon,
      points: reward.points,
      lastClaimedDate: DateTime.now().toIso8601String(),
    );

    rewards[rewardIndex] = updatedReward;

    // Save updated rewards
    final updatedRewardsJson =
        rewards.map((r) => jsonEncode(r.toJson())).toList();

    await prefs.setStringList(_rewardsKey, updatedRewardsJson);

    // Deduct points
    final newPoints = currentPoints - reward.points;
    await prefs.setInt('totalPoints', newPoints);
  }

  // Add a custom reward
  Future<void> addReward(Reward reward) async {
    final prefs = await SharedPreferences.getInstance();
    final rewardsJson = prefs.getStringList(_rewardsKey) ?? [];

    final rewards =
        rewardsJson.map((json) => Reward.fromJson(jsonDecode(json))).toList();

    // Add new reward with unique ID
    final newReward = Reward(
      id: _uuid.v4(),
      title: reward.title,
      description: reward.description,
      icon: reward.icon,
      points: reward.points,
      lastClaimedDate: reward.lastClaimedDate,
    );

    rewards.add(newReward);

    // Save updated rewards
    final updatedRewardsJson =
        rewards.map((r) => jsonEncode(r.toJson())).toList();

    await prefs.setStringList(_rewardsKey, updatedRewardsJson);
  }

  // Reset claimed rewards
  Future<void> resetClaimedRewards() async {
    final prefs = await SharedPreferences.getInstance();
    final rewardsJson = prefs.getStringList(_rewardsKey) ?? [];

    final rewards =
        rewardsJson.map((json) => Reward.fromJson(jsonDecode(json))).toList();

    // Reset all rewards to unclaimed
    final updatedRewards =
        rewards
            .map(
              (r) => Reward(
                id: r.id,
                title: r.title,
                description: r.description,
                icon: r.icon,
                points: r.points,
                lastClaimedDate: null,
              ),
            )
            .toList();

    // Save updated rewards
    final updatedRewardsJson =
        updatedRewards.map((r) => jsonEncode(r.toJson())).toList();

    await prefs.setStringList(_rewardsKey, updatedRewardsJson);
  }
}
