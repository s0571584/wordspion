import 'package:flutter/material.dart';
import 'package:wortspion/presentation/themes/app_typography.dart';

class RoleDistributionVisualizer extends StatelessWidget {
  final int totalPlayers;
  final int spyCount;
  final int saboteurCount;
  final bool showAnimation;

  const RoleDistributionVisualizer({
    super.key,
    required this.totalPlayers,
    required this.spyCount,
    required this.saboteurCount,
    this.showAnimation = true,
  });

  int get civilianCount => totalPlayers - spyCount - saboteurCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Visual representation of roles
        Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              // Role icons row
              _buildRoleIconsRow(),
              const SizedBox(height: 16),

              // Progress bar showing distribution
              _buildDistributionBar(),
              const SizedBox(height: 12),

              // Role count details
              _buildRoleDetails(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleIconsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildRoleIcon(
            icon: Icons.person,
            color: Colors.blue,
            count: civilianCount,
            label: 'Zivilisten',
          ),
          _buildRoleIcon(
            icon: Icons.search,
            color: Colors.red,
            count: spyCount,
            label: 'Spione',
          ),
          if (saboteurCount > 0)
            _buildRoleIcon(
              icon: Icons.warning,
              color: Colors.orange,
              count: saboteurCount,
              label: 'Saboteure',
            ),
        ],
      ),
    );
  }

  Widget _buildRoleIcon({
    required IconData icon,
    required Color color,
    required int count,
    required String label,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Column(
        children: [
          SizedBox(
            height: 50,
            width: 50,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: color.withOpacity(0.8),
                ),
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        height: 24,
        child: Row(
          children: [
            // Civilians
            if (civilianCount > 0)
              Expanded(
                flex: civilianCount,
                child: Container(
                  color: Colors.blue.shade400,
                  child: Center(
                    child: civilianCount > 2
                        ? Text(
                            '$civilianCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            // Spies
            if (spyCount > 0)
              Expanded(
                flex: spyCount,
                child: Container(
                  color: Colors.red.shade400,
                  child: Center(
                    child: spyCount > 1
                        ? Text(
                            '$spyCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            // Saboteurs
            if (saboteurCount > 0)
              Expanded(
                flex: saboteurCount,
                child: Container(
                  color: Colors.orange.shade400,
                  child: Center(
                    child: saboteurCount > 1
                        ? Text(
                            '$saboteurCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleDetails() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Gesamte Spieler:', style: AppTypography.body2),
            Text(
              '$totalPlayers',
              style: AppTypography.body2.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (civilianCount < 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, size: 16, color: Colors.red.shade700),
                const SizedBox(width: 4),
                Text(
                  'Mindestens 1 Zivilist erforderlich!',
                  style: AppTypography.caption.copyWith(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
