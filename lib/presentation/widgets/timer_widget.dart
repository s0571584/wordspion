import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wortspion/blocs/timer/timer_bloc.dart';
import 'package:wortspion/core/services/timer_service.dart';

class TimerWidget extends StatelessWidget {
  final bool showControls;
  final Color? backgroundColor;
  final Color? progressColor;
  final double height;
  final double width;
  final TextStyle? textStyle;

  const TimerWidget({
    super.key,
    this.showControls = true,
    this.backgroundColor,
    this.progressColor,
    this.height = 80,
    this.width = double.infinity,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<TimerBloc, TimerStateBloc>(
      builder: (context, state) {
        if (state is TimerRunInProgress || state is TimerRunPaused) {
          final timerState = state is TimerRunInProgress ? (state).timerState : (state as TimerRunPaused).timerState;

          final minutes = (timerState.remainingSeconds / 60).floor();
          final seconds = timerState.remainingSeconds % 60;

          final isWarningTime = timerState.isWarningTime;
          final isPaused = state is TimerRunPaused;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: height,
                width: width,
                decoration: BoxDecoration(
                  color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    // Progress Bar
                    FractionallySizedBox(
                      widthFactor: timerState.progressPercentage,
                      heightFactor: 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isWarningTime ? Colors.red : progressColor ?? theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    // Timer Text
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isPaused)
                            Icon(
                              Icons.pause,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 24,
                            ),
                          const SizedBox(width: 8),
                          Text(
                            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                            style: textStyle ??
                                theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (showControls) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isPaused)
                      _TimerControlButton(
                        icon: Icons.play_arrow,
                        label: 'Fortsetzen',
                        onPressed: () => context.read<TimerBloc>().add(ResumeTimer()),
                      )
                    else
                      _TimerControlButton(
                        icon: Icons.pause,
                        label: 'Pause',
                        onPressed: () => context.read<TimerBloc>().add(PauseTimer()),
                      ),
                    const SizedBox(width: 16),
                    _TimerControlButton(
                      icon: Icons.stop,
                      label: 'Beenden',
                      onPressed: () => context.read<TimerBloc>().add(StopTimer()),
                    ),
                    const SizedBox(width: 16),
                    _TimerControlButton(
                      icon: Icons.add,
                      label: '+30s',
                      onPressed: () => context.read<TimerBloc>().add(AddExtraTime(30)),
                    ),
                  ],
                ),
              ],
            ],
          );
        } else if (state is TimerRunComplete) {
          return Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Zeit abgelaufen!',
                style: textStyle ??
                    theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          );
        } else {
          return Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '00:00',
                style: textStyle ??
                    theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          );
        }
      },
    );
  }
}

class _TimerControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _TimerControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
