import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:quetame_turismo/providers/audio_provider.dart';
import 'package:quetame_turismo/theme/app_colors.dart';
import 'package:quetame_turismo/theme/app_theme.dart';

class FloatingAudioPlayer extends StatelessWidget {
  const FloatingAudioPlayer({
    super.key,
    required this.routeId,
    required this.toggleUrl,
    required this.trackTitle,
  });

  final String routeId;
  final String toggleUrl;
  final String trackTitle;

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioProvider>();
    final totalSeconds = audioProvider.totalDuration.inSeconds;
    final currentSeconds = audioProvider.currentPosition.inSeconds;
    final progress = totalSeconds == 0 ? 0.0 : currentSeconds / totalSeconds;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.headphones, color: AppColors.goldPrimary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  audioProvider.currentTrackTitle,
                  style: AppTextStyles.bodyMuted.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${_formatDuration(audioProvider.currentPosition)} / ${_formatDuration(audioProvider.totalDuration)}',
                style: AppTextStyles.bodyMuted.copyWith(
                  color: AppColors.onSurfaceMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: const AlwaysStoppedAnimation(AppColors.goldPrimary),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => context.read<AudioProvider>().skipBackward(),
                icon: const Icon(Icons.replay_10),
                color: AppColors.onSurface,
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.earthAccent,
                child: IconButton(
                  onPressed: () async {
                    try {
                      await context.read<AudioProvider>().toggleRoutePlayPause(
                            routeId,
                            toggleUrl,
                            trackTitle: trackTitle,
                          );
                    } on AudioAutoplayBlockedException {
                      if (!context.mounted) return;
                      final messenger = ScaffoldMessenger.of(context);
                      messenger.hideCurrentSnackBar();
                      messenger.showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Toca cualquier parte para habilitar la audio-guía',
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor:
                              Theme.of(context).colorScheme.surface.withValues(alpha: 0.82),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: AppColors.goldPrimary.withValues(alpha: 0.4),
                            ),
                          ),
                          margin: const EdgeInsets.fromLTRB(24, 0, 24, 96),
                        ),
                      );
                    } catch (_) {
                      if (!context.mounted) return;
                      if (!kIsWeb) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No se pudo iniciar la audio-guía.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  icon: Icon(
                    audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () => context.read<AudioProvider>().skipForward(),
                icon: const Icon(Icons.forward_10),
                color: AppColors.onSurface,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
