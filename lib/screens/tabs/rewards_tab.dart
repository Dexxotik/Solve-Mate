import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/reward_service.dart';

class RewardsTab extends StatefulWidget {
  const RewardsTab({super.key});

  @override
  State<RewardsTab> createState() => _RewardsTabState();
}

class _RewardsTabState extends State<RewardsTab> {
  final List<Reward> _rewards = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _totalPoints = 0;
  final RewardService _rewardService = RewardService();

  @override
  void initState() {
    super.initState();
    _loadRewards();
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final points = prefs.getInt('totalPoints') ?? 0;

      if (!mounted) return;

      setState(() {
        _totalPoints = points;
      });
    } catch (e) {
      // Silently handle error
      print('Error loading points: $e');
    }
  }

  Future<void> _loadRewards() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Initialize default rewards if needed
      await _rewardService.initializeDefaultRewards();
      
      // Get all rewards
      final rewards = await _rewardService.getAllRewards();

      if (!mounted) return;

      setState(() {
        _rewards.clear();
        _rewards.addAll(rewards);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Error loading rewards: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _claimReward(Reward reward) async {
    if (!mounted) return;

    // Check if reward can be claimed
    if (!reward.canBeClaimed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('This reward is not available yet. ${reward.timeUntilAvailable} remaining.'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Check if user has enough points
    if (_totalPoints < reward.points) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough points to claim this reward!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      // Deduct points and mark reward as claimed
      await _rewardService.claimReward(reward.id, _totalPoints);
      
      // Reload points and rewards
      await _loadPoints();
      await _loadRewards();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reward claimed successfully! ${reward.points} points deducted.'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error claiming reward: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5E35B1),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[700],
        title: const Text('Your Rewards', style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  '$_totalPoints',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadRewards,
            tooltip: 'Refresh Rewards',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadRewards,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple[400],
                        ),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : _rewards.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No rewards available yet!',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Complete tasks to earn points and unlock rewards!',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _rewards.length,
                      itemBuilder: (context, index) {
                        final reward = _rewards[index];
                        final bool canClaim = _totalPoints >= reward.points && reward.canBeClaimed;
                        final bool alreadyClaimed = !reward.canBeClaimed && reward.lastClaimedDate != null;
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          color: alreadyClaimed 
                              ? Colors.green[400] 
                              : canClaim 
                                  ? Colors.deepPurple[400] 
                                  : Colors.deepPurple[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(
                                            reward.icon,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              reward.title,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.purple[800],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.yellow,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${reward.points}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  reward.description,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                                if (!reward.canBeClaimed && reward.lastClaimedDate != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      'Available again in: ${reward.timeUntilAvailable}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: alreadyClaimed 
                                        ? null 
                                        : canClaim 
                                            ? () => _claimReward(reward) 
                                            : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: alreadyClaimed 
                                          ? Colors.grey 
                                          : Colors.amber,
                                      disabledBackgroundColor: Colors.grey[400],
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                    child: Text(
                                      alreadyClaimed 
                                          ? 'Claimed' 
                                          : canClaim 
                                              ? 'Claim Reward' 
                                              : _totalPoints < reward.points
                                                  ? 'Not Enough Points'
                                                  : 'Not Available Yet',
                                      style: TextStyle(
                                        color: alreadyClaimed 
                                            ? Colors.white70 
                                            : Colors.deepPurple[900],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
