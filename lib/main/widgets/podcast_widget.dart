import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:teb_package/teb_package.dart';

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
  var _initializing = true;
  var _audioSpeed = 1.0;

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      _audioPlayer
          .setAudioSource(AudioSource.uri(Uri.parse('asset:///audio/podcast.mp3')), initialPosition: Duration.zero, preload: true)
          .then((duration) {
            setState(() {
              _podcastLoaded = true;
            });
          });

      //_audioPlayer
      //    .setUrl(
      //      'https://firebasestorage.googleapis.com/v0/b/omarcosmhs.appspot.com/o/johari%2Fpodcast.mp3?alt=media&token=198ccf27-10ec-41c4-83eb-28683dc692df',
      //    )
      //    .then((duration) {
      //      setState(() => _podcastLoaded = true);
      //    });

      _initializing = false;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(FontAwesomeIcons.podcast, size: 40, color: Colors.yellowAccent.shade700),
            Expanded(
              child: TebText(
                'Podcast',
                textColor: Colors.yellowAccent.shade700,
                textSize: 24,
                textWeight: FontWeight.bold,
                padding: EdgeInsets.only(left: 20),
                textType: TextType.html,
              ),
            ),
          ],
        ),
        TebText(
          '<b>Ouça um podcast*</b> sobre a Janela de Johari que explica seu conceito, como funciona e o benefícios de se aplicar em seu time',
          textSize: 20,
          textWeight: FontWeight.normal,
          textType: TextType.html,
          padding: EdgeInsets.only(bottom: 10),
        ),
        if (_podcastLoaded)
          StreamBuilder<Duration?>(
            stream: _audioPlayer.durationStream,
            builder: (context, snapshot) {
              final mediaDurationState = snapshot.data;
              return StreamBuilder<Duration?>(
                stream: _audioPlayer.positionStream,
                builder: (context, snapshot) {
                  final mediaPositionState = snapshot.data;
                  return ProgressBar(
                    total: mediaDurationState ?? const Duration(),
                    progress: mediaPositionState ?? const Duration(),
                    barHeight: 2,
                    baseBarColor: Colors.black,
                    progressBarColor: Colors.black,
                    thumbColor: Colors.black,
                    timeLabelTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black),
                    timeLabelLocation: TimeLabelLocation.sides,
                    onSeek: (newPosition) {
                      _audioPlayer.seek(newPosition);
                    },
                  );
                },
              );
            },
          ),
        if (_podcastLoaded)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(onTap: () => _audioPlayer.seek(Duration(seconds: 0)), child: Icon(FontAwesomeIcons.backward)),

              const SizedBox(width: 20),

              GestureDetector(
                onTap: () async {
                  setState(() => _playing = false);
                  _audioPlayer.stop();
                },
                child: Icon(FontAwesomeIcons.stop),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () async {
                  if (_playing) {
                    setState(() => _playing = false);
                    await _audioPlayer.pause();
                  } else {
                    _audioPlayer.play().then((value) {
                      _audioPlayer.seek(Duration(seconds: 0));
                      setState(() => _playing = false);
                    });
                    setState(() => _playing = true);
                  }
                },
                child: Icon(_playing ? FontAwesomeIcons.pause : FontAwesomeIcons.play, size: 40),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () async {
                  _audioSpeed =
                      _audioSpeed == 1.0
                          ? 1.5
                          : _audioSpeed == 1.5
                          ? 2.0
                          : 1.0;

                  await _audioPlayer.setSpeed(_audioSpeed);
                  setState(() {});
                },
                child: TebText('${_audioSpeed.toStringAsPrecision(2)}x'),
              ),
            ],
          ),
        TebText(
          '* criado utilizando inteligência artificial',
          textSize: 12,
          textWeight: FontWeight.normal,
          textType: TextType.html,
        ),
      ],
    );
  }
}
