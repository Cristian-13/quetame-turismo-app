import 'package:flutter/material.dart';
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.headphones, color: AppColors.flagGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  audioProvider.currentTrackTitle,
                  style: AppTextStyles.bodyMuted.copyWith(
                    color: const Color(0xFF2E3740),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${_formatDuration(audioProvider.currentPosition)} / ${_formatDuration(audioProvider.totalDuration)}',
                style: const TextStyle(
                  color: Color(0xFF7A828A),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: const Color(0xFFE2E7EA),
            valueColor: const AlwaysStoppedAnimation(AppColors.flagGreen),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => context.read<AudioProvider>().skipBackward(),
                icon: const Icon(Icons.replay_10),
                color: const Color(0xFF44505A),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primaryTerracotta,
                child: IconButton(
                  onPressed: () {
                    context.read<AudioProvider>().toggleRoutePlayPause(
                          routeId,
                          toggleUrl,
                          trackTitle: trackTitle,
                        );
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
                color: const Color(0xFF44505A),
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
