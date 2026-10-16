import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:teb_janelajohari/theme/app_theme.dart';

class PodcastArea extends StatefulWidget {
  final bool mobile;
  final Size size;
  const PodcastArea({super.key, required this.mobile, required this.size});

  @override
  State<PodcastArea> createState() => _PodcastAreaState();
}

class _PodcastAreaState extends State<PodcastArea> {
  final _audioPlayer = AudioPlayer();
  var _podcastLoaded = false;
  var _playing = false;
  var _audioSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _audioPlayer
        .setAudioSource(AudioSource.uri(Uri.parse('asset:///audio/podcast.mp3')), initialPosition: Duration.zero, preload: true)
        .then((_) {
          if (mounted) setState(() => _podcastLoaded = true);
        });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_playing) {
      setState(() => _playing = false);
      await _audioPlayer.pause();
    } else {
      setState(() => _playing = true);
      // play() só conclui quando o áudio termina: volta ao início.
      _audioPlayer.play().then((_) {
        _audioPlayer.seek(Duration.zero);
        if (mounted) setState(() => _playing = false);
      });
    }
  }

  Future<void> _stop() async {
    setState(() => _playing = false);
    await _audioPlayer.stop();
    await _audioPlayer.seek(Duration.zero);
  }

  Future<void> _cycleSpeed() async {
    _audioSpeed = _audioSpeed == 1.0 ? 1.5 : (_audioSpeed == 1.5 ? 2.0 : 1.0);
    await _audioPlayer.setSpeed(_audioSpeed);
    setState(() {});
  }

  Widget _iconButton(IconData icon, String tooltip, VoidCallback? onTap) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      color: AppColors.onPanel,
      disabledColor: AppColors.onPanel.withValues(alpha: 0.35),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: AppColors.panel, borderRadius: BorderRadius.circular(AppRadius.card)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.panelSoft, borderRadius: BorderRadius.circular(14)),
                child: const Icon(FontAwesomeIcons.podcast, size: 20, color: AppColors.gold),
              ),
              const SizedBox(width: 14),
              Text(
                'PODCAST',
                style: AppTheme.body(
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.gold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Ouça sobre a Janela de Johari',
            style: AppTheme.display(const TextStyle(fontSize: 24, color: Colors.white, height: 1.15, letterSpacing: -0.3)),
          ),
          const SizedBox(height: 10),
          Text(
            'O conceito, como funciona e os benefícios de aplicar no seu time.',
            style: AppTheme.body(const TextStyle(fontSize: 15, color: AppColors.onPanel, height: 1.5)),
          ),
          const SizedBox(height: 22),
          if (!_podcastLoaded)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.tealOnDark),
                  ),
                  const SizedBox(width: 12),
                  Text('Carregando...', style: AppTheme.body(const TextStyle(fontSize: 14, color: AppColors.onPanel))),
                ],
              ),
            )
          else ...[
            StreamBuilder<Duration?>(
              stream: _audioPlayer.durationStream,
              builder: (context, durationSnapshot) {
                return StreamBuilder<Duration>(
                  stream: _audioPlayer.positionStream,
                  builder: (context, positionSnapshot) {
                    return ProgressBar(
                      total: durationSnapshot.data ?? Duration.zero,
                      progress: positionSnapshot.data ?? Duration.zero,
                      barHeight: 4,
                      thumbRadius: 7,
                      baseBarColor: AppColors.panelSoft,
                      progressBarColor: AppColors.tealOnDark,
                      thumbColor: Colors.white,
                      thumbGlowColor: AppColors.tealOnDark.withValues(alpha: 0.25),
                      timeLabelTextStyle: AppTheme.body(const TextStyle(fontSize: 12, color: AppColors.onPanel)),
                      timeLabelLocation: TimeLabelLocation.below,
                      onSeek: _audioPlayer.seek,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Material(
                  color: AppColors.gold,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _togglePlay,
                    child: SizedBox(
                      width: 52,
                      height: 52,
                      child: Icon(_playing ? FontAwesomeIcons.pause : FontAwesomeIcons.play, size: 18, color: AppColors.ink),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _iconButton(FontAwesomeIcons.backward, 'Voltar ao início', () => _audioPlayer.seek(Duration.zero)),
                _iconButton(FontAwesomeIcons.stop, 'Parar', _stop),
                const Spacer(),
                OutlinedButton(
                  onPressed: _cycleSpeed,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    side: const BorderSide(color: AppColors.panelSoft, width: 1.5),
                    textStyle: AppTheme.body(const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                  child: Text('${_audioSpeed.toStringAsPrecision(2)}x'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Text(
            '* criado utilizando inteligência artificial',
            style: AppTheme.body(TextStyle(fontSize: 12, color: AppColors.onPanel.withValues(alpha: 0.7))),
          ),
        ],
      ),
    );
  }
}
