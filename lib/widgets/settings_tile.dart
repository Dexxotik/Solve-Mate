import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool hasSwitch;

  const SettingsTile({
    super.key,
    required this.title,
    required this.icon,
    required this.hasSwitch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.deepPurple[400],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        trailing:
            hasSwitch
                ? Switch(
                  value: true,
                  onChanged: (value) {},
                  activeColor: Colors.white,
                  activeTrackColor: Colors.deepPurple[300],
                )
                : const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
      ),
    );
  }
}
