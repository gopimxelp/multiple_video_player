

// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'package:dio/dio.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

// class VideoList extends StatefulWidget {
//   const VideoList({Key? key}) : super(key: key);

//   @override
//   _VideoListState createState() => _VideoListState();
// }

// class _VideoListState extends State<VideoList> {
//   late List<VideoPlayerController?> _controllers;
//   late List<bool> _showControls;
//   late List<Timer?> _timers;
//   late List<Duration> _positions;
//   late List<Duration> _durations;

//   @override
//   void initState() {
//     super.initState();
//     _controllers = List.generate(
//       videoUrls.length,
//       (index) => VideoPlayerController.network(videoUrls[index]),
//     );
//     _showControls = List.generate(videoUrls.length, (index) => true);
//     _timers = List.generate(
//       videoUrls.length,
//       (index) => null, // Initialize timers as null
//     );
//     _positions = List.generate(videoUrls.length, (index) => Duration.zero);
//     _durations = List.generate(videoUrls.length, (index) => Duration.zero);

//     for (int i = 0; i < _controllers.length; i++) {
//       _initializeControllerListeners(i);
//       _controllers[i]!.initialize().then((_) {
//         setState(() {
//           _durations[i] = _controllers[i]!.value.duration;
//         });
//       });
//     }
//   }

//   @override
//   void dispose() {
//     for (int i = 0; i < _controllers.length; i++) {
//       _controllers[i]!.removeListener(_updateState);
//       _controllers[i]!.dispose();
//       _timers[i]?.cancel();
//     }
//     super.dispose();
//   }

//   Future<void> downloadVideo(String videoUrl) async {
//     final dio = Dio();
//     final fileName = videoUrl.split('/').last;
//     final Directory? appDocDir = await getExternalStorageDirectory();
//     final String? appDocPath = appDocDir?.path;

//     // Check if permission to write to external storage is granted
//     if (await Permission.storage.request().isGranted) {
//       try {
//         // Download the file
//         await dio.download(videoUrl, '$appDocPath/$fileName',
//             onReceiveProgress: (received, total) {
//           print('Received: $received, Total: $total');
//         });
//         print('Download complete');
//          print('File saved at: $appDocPath/$fileName');
//       } catch (e) {
//         print('Download failed: $e');
//       }
//     } else {
//       print('Storage permission not granted');
//     }
//   }

//   void _initializeControllerListeners(int index) {
//     _controllers[index]!.addListener(_updateState);
//     _controllers[index]!.addListener(() {
//       if (_controllers[index]!.value.position == _durations[index]) {
//         setState(() {
//           _showControls[index] = true;
//         });
//       }
//     });
//   }

//   void _updateState() {
//     setState(() {});
//   }

//   void _toggleControls(int index) {
//     setState(() {
//       _showControls[index] = !_showControls[index];
//       if (_showControls[index]) {
//         _startTimer(index);
//       } else {
//         _timers[index]?.cancel(); // Cancel the timer if controls are manually shown
//       }
//     });
//   }

//   void _startTimer(int index) {
//     _timers[index]?.cancel(); // Cancel existing timer if it exists

//     if (!_durations[index].isNegative && _durations[index] != Duration.zero) {
//       // Start timer only if duration is not negative and not zero
//       _timers[index] = Timer(Duration(seconds: 2), () {
//         setState(() {
//           _showControls[index] = false;
//         });
//       });
//     }
//   }

//   double _playbackSpeed = 1.0;

//   void _changeSpeed(double speed) {
//     setState(() {
//       _playbackSpeed = speed;
//       for (var controller in _controllers) {
//         controller!.setPlaybackSpeed(speed);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Scrollable Video List'),
//       ),
//       body: ListView.separated(
//         itemCount: videoUrls.length,
//         separatorBuilder: (context, index) => SizedBox(height: 20),
//         itemBuilder: (context, index) {
//           return GestureDetector(
//             onTap: () {
//               _toggleControls(index);
//             },
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 _controllers[index]!.value.isInitialized
//                     ? AspectRatio(
//                         aspectRatio: _controllers[index]!.value.aspectRatio,
//                         child: Stack(
//                           children: [
//                             VideoPlayer(_controllers[index]!),
//                             if (_showControls[index])
//                               Positioned(
//                                 top: 0,
//                                 left: 0,
//                                 bottom: 0,
//                                 right: 0,
//                                 child: GestureDetector(
//                                   onTap: () {}, // Prevents tapping on the video to toggle controls
//                                   child: Container(
//                                     color: Colors.transparent,
//                                     child: Center(
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(8.0),
//                                         child: Column(
//                                           mainAxisAlignment: MainAxisAlignment.center,
//                                           crossAxisAlignment: CrossAxisAlignment.center,
//                                           children: [
//                                             Row(
//                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                               children: [
//                                                 IconButton(
//                                                   icon: Icon(Icons.replay_10, color: Colors.white),
//                                                   onPressed: () {
//                                                     setState(() {
//                                                       _positions[index] =
//                                                           _controllers[index]!.value.position - Duration(seconds: 10);
//                                                       _controllers[index]!.seekTo(_positions[index]);
//                                                     });
//                                                   },
//                                                 ),
//                                                 IconButton(
//                                                   icon: Icon(_controllers[index]!.value.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
//                                                   onPressed: () {
//                                                     setState(() {
//                                                       if (_controllers[index]!.value.isPlaying) {
//                                                         _controllers[index]!.pause();
//                                                       } else {
//                                                         _controllers[index]!.play();
//                                                         _startTimer(index); // Start timer when play icon is clicked
//                                                       }
//                                                     });
//                                                   },
//                                                 ),
//                                                 IconButton(
//                                                   icon: Icon(Icons.forward_10, color: Colors.white),
//                                                   onPressed: () {
//                                                     setState(() {
//                                                       _positions[index] =
//                                                           _controllers[index]!.value.position + Duration(seconds: 10);
//                                                       _controllers[index]!.seekTo(_positions[index]);
//                                                     });
//                                                   },
//                                                 ),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       )
//                     : Center(
//                         child: CircularProgressIndicator(),
//                       ),
//                 Positioned(
//                   left: 5,
//                   right: 5,
//                   bottom: 35,
//                   child: GestureDetector(
//                     onPanUpdate: (details) {
//                       setState(() {
//                         // Calculate the new position based on the drag
//                         double newPosition = _durations[index] != Duration.zero
//                             ? _controllers[index]!.value.position.inMilliseconds / _durations[index].inMilliseconds
//                             : 0.0;
//                         // Update the position based on the drag gesture
//                         newPosition += details.delta.dx / context.size!.width;
//                         // Ensure the position stays within bounds
//                         newPosition = newPosition.clamp(0.0, 1.0);
//                         // Seek to the new position in the video
//                         _controllers[index]!.seekTo(Duration(milliseconds: (newPosition * _durations[index].inMilliseconds).toInt()));
//                       });
//                     },
//                     child: LinearProgressIndicator(
//                       value: _durations[index] != Duration.zero
//                           ? _controllers[index]!.value.position.inMilliseconds / _durations[index].inMilliseconds
//                           : 0.0,
//                       color: Colors.white,
//                       backgroundColor: Colors.grey,
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   left: 5,
//                   right: 5,
//                   bottom: 0,
//                   child: AnimatedOpacity(
//                     opacity: _showControls[index] ? 1.0 : 0.0,
//                     duration: Duration(milliseconds: 300),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           '${_controllers[index]!.value.position.inSeconds} sec',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                         IconButton(
//                           icon: Icon(
//                             _controllers[index]!.value.volume == 0 ? Icons.volume_off : Icons.volume_up,
//                             color: Colors.white,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               if (_controllers[index]!.value.volume == 0) {
//                                 _controllers[index]!.setVolume(1.0);
//                               } else {
//                                 _controllers[index]!.setVolume(0.0);
//                               }
//                             });
//                           },
//                         ),
//                         DropdownButton<double>(
//                           value: _playbackSpeed,
//                           onChanged: (value) {
//                             _changeSpeed(value!);
//                           },
//                           items: [0.5, 1.0, 1.5, 2.0].map<DropdownMenuItem<double>>((double value) {
//                             return DropdownMenuItem<double>(
//                               value: value,
//                               child: Text('$value', style: TextStyle()),
//                             );
//                           }).toList(),
//                         ),
//                         Positioned(
//                           top: 5,
//                           right: 5,
//                           child: IconButton(
//                             icon: Icon(Icons.download, color: Colors.white),
//                             onPressed: () {
                              
//                               downloadVideo(videoUrls[index]);
//                             },
//                           ),
//                         ),
//                         Text(
//                           '${_durations[index].inSeconds} sec',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// final List<String> videoUrls = [
//   'https://signalstoragecontent.blob.core.windows.net/taskcompletionimages/img-63834663-f43d-4167-946a-08459325a736.mp4',
//   'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
//   'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
//   'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
//   'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
//   'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
//   'https://signalstoragecontent.blob.core.windows.net/taskcompletionimages/img-9e75027d-70c6-4f85-8d69-4431280f6e76.mp4',
//   'https://signalstoragecontent.blob.core.windows.net/taskcompletionimages/img-38f529ba-284b-453a-85c6-46c14f54f6e9.mp4',
//   'https://signalstoragecontent.blob.core.windows.net/taskcompletionimages/img-f95ee019-670b-46ba-9d93-bff3bb369d15.mp4',
// ];



// download feature implemented





// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'package:dio/dio.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

// class VideoList extends StatefulWidget {
//   const VideoList({Key? key}) : super(key: key);

//   @override
//   _VideoListState createState() => _VideoListState();
// }

// class _VideoListState extends State<VideoList> {
//   late List<VideoPlayerController?> _controllers;
//   late List<bool> _showControls;
//   late List<Timer?> _timers;
//   late List<Duration> _positions;
//   late List<Duration> _durations;

//   @override
//   void initState() {
//     super.initState();
//     _controllers = List.generate(
//       videoUrls.length,
//       (index) => VideoPlayerController.network(videoUrls[index]),
//     );
//     _showControls = List.generate(videoUrls.length, (index) => true);
//     _timers = List.generate(
//       videoUrls.length,
//       (index) => null, // Initialize timers as null
//     );
//     _positions = List.generate(videoUrls.length, (index) => Duration.zero);
//     _durations = List.generate(videoUrls.length, (index) => Duration.zero);

//     for (int i = 0; i < _controllers.length; i++) {
//       _initializeControllerListeners(i);
//       _controllers[i]!.initialize().then((_) {
//         setState(() {
//           _durations[i] = _controllers[i]!.value.duration;
//         });
//       });
//     }
//   }

//   @override
//   void dispose() {
//     for (int i = 0; i < _controllers.length; i++) {
//       _controllers[i]!.removeListener(_updateState);
//       _controllers[i]!.dispose();
//       _timers[i]?.cancel();
//     }
//     super.dispose();
//   }

//   Future<void> downloadVideo(String videoUrl) async {
//     final dio = Dio();
//     final fileName = videoUrl.split('/').last;
//     final Directory? appDocDir = await getExternalStorageDirectory();
//     final String? appDocPath = appDocDir?.path;

//     // Check if permission to write to external storage is granted
//     if (await Permission.storage.request().isGranted) {
//       try {
//         // Download the file
//         await dio.download(videoUrl, '$appDocPath/$fileName',
//             onReceiveProgress: (received, total) {
//           print('Received: $received, Total: $total');
//         });
//         print('Download complete');
//         print('File saved at: $appDocPath/$fileName');
//       } catch (e) {
//         print('Download failed: $e');
//       }
//     } else {
//       print('Storage permission not granted');
//     }
//   }

//   void _initializeControllerListeners(int index) {
//     _controllers[index]!.addListener(_updateState);
//     _controllers[index]!.addListener(() {
//       if (_controllers[index]!.value.position == _durations[index]) {
//         setState(() {
//           _showControls[index] = true;
//         });
//       }
//     });
//   }

//   void _updateState() {
//     setState(() {});
//   }

//   void _toggleControls(int index) {
//     setState(() {
//       _showControls[index] = !_showControls[index];
//       if (_showControls[index]) {
//         _startTimer(index);
//       } else {
//         _timers[index]?.cancel(); // Cancel the timer if controls are manually shown
//       }
//     });
//   }

//   void _startTimer(int index) {
//     _timers[index]?.cancel(); // Cancel existing timer if it exists

//     if (!_durations[index].isNegative && _durations[index] != Duration.zero) {
//       // Start timer only if duration is not negative and not zero
//       _timers[index] = Timer(Duration(seconds: 2), () {
//         setState(() {
//           _showControls[index] = false;
//         });
//       });
//     }
//   }

//   double _playbackSpeed = 1.0;

//   void _changeSpeed(double speed) {
//     setState(() {
//       _playbackSpeed = speed;
//       for (var controller in _controllers) {
//         controller!.setPlaybackSpeed(speed);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Scrollable Video List'),
//       ),
//       body: ListView.separated(
//         itemCount: videoUrls.length,
//         separatorBuilder: (context, index) => SizedBox(height: 20),
//         itemBuilder: (context, index) {
//           return GestureDetector(
//             onTap: () {
//               _toggleControls(index);
//             },
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 _controllers[index]!.value.isInitialized
//                     ? AspectRatio(
//                         aspectRatio: _controllers[index]!.value.aspectRatio,
//                         child: Stack(
//                           children: [
//                             VideoPlayer(_controllers[index]!),
//                             if (_showControls[index])
//                               Positioned.fill(
//                                 child: GestureDetector(
//                                   onTap: () {}, // Prevents tapping on the video to toggle controls
//                                   child: Container(
//                                     color: Colors.transparent,
//                                     child: Center(
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(8.0),
//                                         child: Column(
//                                           mainAxisAlignment: MainAxisAlignment.center,
//                                           crossAxisAlignment: CrossAxisAlignment.center,
//                                           children: [
//                                             Row(
//                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                               children: [
//                                                 IconButton(
//                                                   icon: Icon(Icons.replay_10, color: Colors.white),
//                                                   onPressed: () {
//                                                     setState(() {
//                                                       _positions[index] =
//                                                           _controllers[index]!.value.position - Duration(seconds: 10);
//                                                       _controllers[index]!.seekTo(_positions[index]);
//                                                     });
//                                                   },
//                                                 ),
//                                                 IconButton(
//                                                   icon: Icon(_controllers[index]!.value.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
//                                                   onPressed: () {
//                                                     setState(() {
//                                                       if (_controllers[index]!.value.isPlaying) {
//                                                         _controllers[index]!.pause();
//                                                       } else {
//                                                         _controllers[index]!.play();
//                                                         _startTimer(index); // Start timer when play icon is clicked
//                                                       }
//                                                     });
//                                                   },
//                                                 ),
//                                                 IconButton(
//                                                   icon: Icon(Icons.forward_10, color: Colors.white),
//                                                   onPressed: () {
//                                                     setState(() {
//                                                       _positions[index] =
//                                                           _controllers[index]!.value.position + Duration(seconds: 10);
//                                                       _controllers[index]!.seekTo(_positions[index]);
//                                                     });
//                                                   },
//                                                 ),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       )
//                     : Center(
//                         child: CircularProgressIndicator(),
//                       ),
//                       Positioned(
//   left: 5,
//   right: 5,
//   bottom: 35,
//   child: GestureDetector(
//     onPanUpdate: (details) {
//       setState(() {
//         // Calculate the new position based on the drag
//         double newPosition = _durations[index] != Duration.zero
//             ? _controllers[index]!.value.position.inMilliseconds / _durations[index].inMilliseconds
//             : 0.0;
//         // Update the position based on the drag gesture
//         newPosition += details.delta.dx / context.size!.width;
//         // Ensure the position stays within bounds
//         newPosition = newPosition.clamp(0.0, 1.0);
//         // Seek to the new position in the video
//         _controllers[index]!.seekTo(Duration(milliseconds: (newPosition * _durations[index].inMilliseconds).toInt()));
//       });
//     },
//     child: LinearProgressIndicator(
//       value: _durations[index] != Duration.zero
//           ? _controllers[index]!.value.position.inMilliseconds / _durations[index].inMilliseconds
//           : 0.0,
//       color: Colors.white,
//       backgroundColor: Colors.grey,
//     ),
//   ),
// ),

//                 Positioned(
//                   left: 5,
//                   right: 5,
//                   bottom: 0,
//                   child: AnimatedOpacity(
//                     opacity: _showControls[index] ? 1.0 : 0.0,
//                     duration: Duration(milliseconds: 300),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           '${_controllers[index]!.value.position.inSeconds} sec',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                         IconButton(
//                           icon: Icon(
//                             _controllers[index]!.value.volume == 0 ? Icons.volume_off : Icons.volume_up,
//                             color: Colors.white,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               if (_controllers[index]!.value.volume == 0) {
//                                 _controllers[index]!.setVolume(1.0);
//                               } else {
//                                 _controllers[index]!.setVolume(0.0);
//                               }
//                             });
//                           },
//                         ),
//                         DropdownButton<double>(
//                           value: _playbackSpeed,
//                           onChanged: (value) {
//                             _changeSpeed(value!);
//                           },
//                           items: [0.5, 1.0, 1.5, 2.0].map<DropdownMenuItem<double>>((double value) {
//                             return DropdownMenuItem<double>(
//                               value: value,
//                               child: Text('$value', style: TextStyle()),
//                             );
//                           }).toList(),
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.download, color: Colors.white),
//                           onPressed: () {
//                             downloadVideo(videoUrls[index]);
//                           },
//                         ),
//                         Text(
//                           '${_durations[index].inSeconds} sec',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// final List<String> videoUrls = [
//   'https://signalstoragecontent.blob.core.windows.net/taskcompletionimages/img-63834663-f43d-4167-946a-08459325a736.mp4',
//   'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
//   'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
//   'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
//   'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
//   'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
//   'https://signalstoragecontent.blob.core.windows.net/taskcompletionimages/img-9e75027d-70c6-4f85-8d69-4431280f6e76.mp4',
//   'https://signalstoragecontent.blob.core.windows.net/taskcompletionimages/img-38f529ba-284b-453a-85c6-46c14f54f6e9.mp4',
//   'https://signalstoragecontent.blob.core.windows.net/taskcompletionimages/img-f95ee019-670b-46ba-9d93-bff3bb369d15.mp4',
// ];








// border radius implemented

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoList extends StatefulWidget {
  const VideoList({Key? key}) : super(key: key);

  @override
  _VideoListState createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> {
  late List<VideoPlayerController?> _controllers;
  late List<bool> _showControls;
  late List<Timer?> _timers;
  late List<Duration> _positions;
  late List<Duration> _durations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      videoUrls.length,
          (index) => VideoPlayerController.network(videoUrls[index]),
    );
    _showControls = List.generate(videoUrls.length, (index) => true);
    _timers = List.generate(
      videoUrls.length,
          (index) => null, // Initialize timers as null
    );
    _positions = List.generate(videoUrls.length, (index) => Duration.zero);
    _durations = List.generate(videoUrls.length, (index) => Duration.zero);

    for (int i = 0; i < _controllers.length; i++) {
      _initializeControllerListeners(i);
      _controllers[i]!.initialize().then((_) {
        setState(() {
          _durations[i] = _controllers[i]!.value.duration;
        });
      });
    }
  }

  @override
  void dispose() {
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i]!.removeListener(_updateState);
      _controllers[i]!.dispose();
      _timers[i]?.cancel();
    }
    super.dispose();
  }

  Future<void> downloadVideo(String videoUrl) async {
    final dio = Dio();
    final fileName = videoUrl.split('/').last;
    final Directory? appDocDir = await getExternalStorageDirectory();
    final String? appDocPath = appDocDir?.path;

    // Check if permission to write to external storage is granted
    if (await Permission.storage.request().isGranted) {
      try {
       
        await dio.download(videoUrl, '$appDocPath/$fileName',
            onReceiveProgress: (received, total) {
              print('Received: $received, Total: $total');
            });
        print('Download complete');
        print('File saved in local storage of path : $appDocPath/$fileName');
      } catch (e) {
        print('Download failed: $e');
      }
    } else {
      print('Storage permission not granted');
    }
  }

  void _initializeControllerListeners(int index) {
    _controllers[index]!.addListener(_updateState);
    _controllers[index]!.addListener(() {
      if (_controllers[index]!.value.position == _durations[index]) {
        setState(() {
          _showControls[index] = true;
        });
      }
    });
  }

  void _updateState() {
    setState(() {});
  }

  void _toggleControls(int index) {
    setState(() {
      _showControls[index] = !_showControls[index];
      if (_showControls[index]) {
        _startTimer(index);
      } else {
        _timers[index]?.cancel(); // Cancel the timer if controls are manually shown
      }
    });
  }

  void _startTimer(int index) {
    _timers[index]?.cancel(); // Cancel existing timer if it exists

    if (!_durations[index].isNegative && _durations[index] != Duration.zero) {
      // Start timer only if duration is not negative and not zero
      _timers[index] = Timer(Duration(seconds: 2), () {
        setState(() {
          _showControls[index] = false;
        });
      });
    }
  }

  double _playbackSpeed = 1.0;

  void _changeSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
      for (var controller in _controllers) {
        controller!.setPlaybackSpeed(speed);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scrollable Video List'),
      ),
      body: ListView.separated(
        itemCount: videoUrls.length,
        separatorBuilder: (context, index) => SizedBox(height: 20),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _toggleControls(index);
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect( // ClipRRect to apply border radius
                  borderRadius: BorderRadius.circular(15), // Set your desired border radius here
                  child: _controllers[index]!.value.isInitialized
                      ? AspectRatio(
                    aspectRatio: _controllers[index]!.value.aspectRatio,
                    child: Stack(
                      children: [
                        VideoPlayer(_controllers[index]!),
                        if (_showControls[index])
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: () {}, // Prevents tapping on the video to toggle controls
                              child: Container(
                                color: Colors.transparent,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.replay_10, color: Colors.white),
                                              onPressed: () {
                                                setState(() {
                                                  _positions[index] =
                                                      _controllers[index]!.value.position - Duration(seconds: 10);
                                                  _controllers[index]!.seekTo(_positions[index]);
                                                });
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(_controllers[index]!.value.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                                              onPressed: () {
                                                setState(() {
                                                  if (_controllers[index]!.value.isPlaying) {
                                                    _controllers[index]!.pause();
                                                  } else {
                                                    _controllers[index]!.play();
                                                    _startTimer(index); // Start timer when play icon is clicked
                                                  }
                                                });
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.forward_10, color: Colors.white),
                                              onPressed: () {
                                                setState(() {
                                                  _positions[index] =
                                                      _controllers[index]!.value.position + Duration(seconds: 10);
                                                  _controllers[index]!.seekTo(_positions[index]);
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                      : Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                Positioned(
                  left: 5,
                  right: 5,
                  bottom: 35,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        // Calculate the new position based on the drag
                        double newPosition = _durations[index] != Duration.zero
                            ? _controllers[index]!.value.position.inMilliseconds / _durations[index].inMilliseconds
                            : 0.0;
                        // Update the position based on the drag gesture
                        newPosition += details.delta.dx / context.size!.width;
                        // Ensure the position stays within bounds
                        newPosition = newPosition.clamp(0.0, 1.0);
                        // Seek to the new position in the video
                        _controllers[index]!.seekTo(Duration(milliseconds: (newPosition * _durations[index].inMilliseconds).toInt()));
                      });
                    },
                    child: LinearProgressIndicator(
                      value: _durations[index] != Duration.zero
                          ? _controllers[index]!.value.position.inMilliseconds / _durations[index].inMilliseconds
                          : 0.0,
                      color: Colors.white,
                      backgroundColor: Colors.grey,
                    ),
                  ),
                ),

                Positioned(
                  left: 5,
                  right: 5,
                  bottom: 0,
                  child: AnimatedOpacity(
                    opacity: _showControls[index] ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 300),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_controllers[index]!.value.position.inSeconds} sec',
                          style: TextStyle(color: Colors.white),
                        ),
                        IconButton(
                          icon: Icon(
                            _controllers[index]!.value.volume == 0 ? Icons.volume_off : Icons.volume_up,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_controllers[index]!.value.volume == 0) {
                                _controllers[index]!.setVolume(1.0);
                              } else {
                                _controllers[index]!.setVolume(0.0);
                              }
                            });
                          },
                        ),
                        DropdownButton<double>(
                          value: _playbackSpeed,
                          onChanged: (value) {
                            _changeSpeed(value!);
                          },
                          items: [0.5, 1.0, 1.5, 2.0].map<DropdownMenuItem<double>>((double value) {
                            return DropdownMenuItem<double>(
                              value: value,
                              child: Text('$value', style: TextStyle()),
                            );
                          }).toList(),
                        ),
                        IconButton(
                          icon: Icon(Icons.download, color: Colors.white),
                          onPressed: () {
                            downloadVideo(videoUrls[index]);
                          },
                        ),
                        Text(
                          '${_durations[index].inSeconds} sec',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

final List<String> videoUrls = [
  'https://signalstoragecontent.blob.core.windows.net/taskcompletionimages/img-63834663-f43d-4167-946a-08459325a736.mp4',
  'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
  'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
  'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
  'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
  'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
  'https://signalstoragecontent.blob.core.windows.net/taskcompletionimages/img-9e75027d-70c6-4f85-8d69-4431280f6e76.mp4',
  'https://signalstoragecontent.blob.core.windows.net/taskcompletionimages/img-38f529ba-284b-453a-85c6-46c14f54f6e9.mp4',
  'https://signalstoragecontent.blob.core.windows.net/taskcompletionimages/img-f95ee019-670b-46ba-9d93-bff3bb369d15.mp4',
];




 



 // cache implemented

// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'package:dio/dio.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// class VideoList extends StatefulWidget {
//   const VideoList({Key? key}) : super(key: key);

//   @override
//   _VideoListState createState() => _VideoListState();
// }

// class _VideoListState extends State<VideoList> {
//   late List<VideoPlayerController?> _controllers;
//   late List<bool> _showControls;
//   late List<Timer?> _timers;
//   late List<Duration> _positions;
//   late List<Duration> _durations;

//   @override
//   void initState() {
//     super.initState();
//     _controllers = List.generate(
//       videoUrls.length,
//       (index) => VideoPlayerController.network(videoUrls[index]),
//     );
//     _showControls = List.generate(videoUrls.length, (index) => true);
//     _timers = List.generate(
//       videoUrls.length,
//       (index) => null, // Initialize timers as null
//     );
//     _positions = List.generate(videoUrls.length, (index) => Duration.zero);
//     _durations = List.generate(videoUrls.length, (index) => Duration.zero);

//     for (int i = 0; i < _controllers.length; i++) {
//       _initializeControllerListeners(i);
//       _controllers[i]!.initialize().then((_) {
//         setState(() {
//           _durations[i] = _controllers[i]!.value.duration;
//         });
//       });
//     }
//   }

//   @override
//   void dispose() {
//     for (int i = 0; i < _controllers.length; i++) {
//       _controllers[i]!.removeListener(_updateState);
//       _controllers[i]!.dispose();
//       _timers[i]?.cancel();
//     }
//     super.dispose();
//   }

//   Future<void> downloadVideo(String videoUrl) async {
//     final fileName = videoUrl.split('/').last;
//     final File videoFile = await DefaultCacheManager().getSingleFile(videoUrl);

//     print('Download complete');
//     print('File saved at: ${videoFile.path}');
//   }

//   void _initializeControllerListeners(int index) {
//     _controllers[index]!.addListener(_updateState);
//     _controllers[index]!.addListener(() {
//       if (_controllers[index]!.value.position == _durations[index]) {
//         setState(() {
//           _showControls[index] = true;
//         });
//       }
//     });
//   }

//   void _updateState() {
//     setState(() {});
//   }

//   void _toggleControls(int index) {
//     setState(() {
//       _showControls[index] = !_showControls[index];
//       if (_showControls[index]) {
//         _startTimer(index);
//       } else {
//         _timers[index]?.cancel(); // Cancel the timer if controls are manually shown
//       }
//     });
//   }

//   void _startTimer(int index) {
//     _timers[index]?.cancel(); // Cancel existing timer if it exists

//     if (!_durations[index].isNegative && _durations[index] != Duration.zero) {
//       // Start timer only if duration is not negative and not zero
//       _timers[index] = Timer(Duration(seconds: 2), () {
//         setState(() {
//           _showControls[index] = false;
//         });
//       });
//     }
//   }

//   double _playbackSpeed = 1.0;

//   void _changeSpeed(double speed) {
//     setState(() {
//       _playbackSpeed = speed;
//       for (var controller in _controllers) {
//         controller!.setPlaybackSpeed(speed);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Scrollable Video List'),
//       ),
//       body: ListView.separated(
//         itemCount: videoUrls.length,
//         separatorBuilder: (context, index) => SizedBox(height: 20),
//         itemBuilder: (context, index) {
//           return GestureDetector(
//             onTap: () {
//               _toggleControls(index);
//             },
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(15),
//                   child: _controllers[index]!.value.isInitialized
//                       ? AspectRatio(
//                           aspectRatio: _controllers[index]!.value.aspectRatio,
//                           child: Stack(
//                             children: [
//                               VideoPlayer(_controllers[index]!),
//                               if (_showControls[index])
//                                 Positioned.fill(
//                                   child: GestureDetector(
//                                     onTap: () {},
//                                     child: Container(
//                                       color: Colors.transparent,
//                                       child: Center(
//                                         child: Padding(
//                                           padding: const EdgeInsets.all(8.0),
//                                           child: Column(
//                                             mainAxisAlignment: MainAxisAlignment.center,
//                                             crossAxisAlignment: CrossAxisAlignment.center,
//                                             children: [
//                                               Row(
//                                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                 children: [
//                                                   IconButton(
//                                                     icon: Icon(Icons.replay_10, color: Colors.white),
//                                                     onPressed: () {
//                                                       setState(() {
//                                                         _positions[index] =
//                                                             _controllers[index]!.value.position - Duration(seconds: 10);
//                                                         _controllers[index]!.seekTo(_positions[index]);
//                                                       });
//                                                     },
//                                                   ),
//                                                   IconButton(
//                                                     icon: Icon(
//                                                       _controllers[index]!.value.isPlaying ? Icons.pause : Icons.play_arrow,
//                                                       color: Colors.white,
//                                                     ),
//                                                     onPressed: () {
//                                                       setState(() {
//                                                         if (_controllers[index]!.value.isPlaying) {
//                                                           _controllers[index]!.pause();
//                                                         } else {
//                                                           _controllers[index]!.play();
//                                                           _startTimer(index);
//                                                         }
//                                                       });
//                                                     },
//                                                   ),
//                                                   IconButton(
//                                                     icon: Icon(Icons.forward_10, color: Colors.white),
//                                                     onPressed: () {
//                                                       setState(() {
//                                                         _positions[index] =
//                                                             _controllers[index]!.value.position + Duration(seconds: 10);
//                                                         _controllers[index]!.seekTo(_positions[index]);
//                                                       });
//                                                     },
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         )
//                       : Center(
//                           child: CircularProgressIndicator(),
//                         ),
//                 ),
//                 Positioned(
//                   left: 5,
//                   right: 5,
//                   bottom: 35,
//                   child: GestureDetector(
//                     onPanUpdate: (details) {
//                       setState(() {
//                         double newPosition = _durations[index] != Duration.zero
//                             ? _controllers[index]!.value.position.inMilliseconds / _durations[index].inMilliseconds
//                             : 0.0;
//                         newPosition += details.delta.dx / context.size!.width;
//                         newPosition = newPosition.clamp(0.0, 1.0);
//                         _controllers[index]!.seekTo(Duration(milliseconds: (newPosition * _durations[index].inMilliseconds).toInt()));
//                       });
//                     },
//                     child: LinearProgressIndicator(
//                       value: _durations[index] != Duration.zero
//                           ? _controllers[index]!.value.position.inMilliseconds / _durations[index].inMilliseconds
//                           : 0.0,
//                       color: Colors.white,
//                       backgroundColor: Colors.grey,
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   left: 5,
//                   right: 5,
//                   bottom: 0,
//                   child: AnimatedOpacity(
//                     opacity: _showControls[index] ? 1.0 : 0.0,
//                     duration: Duration(milliseconds: 300),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           '${_controllers[index]!.value.position.inSeconds} sec',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                         IconButton(
//                           icon: Icon(
//                             _controllers[index]!.value.volume == 0 ? Icons.volume_off : Icons.volume_up,
//                             color: Colors.white,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               if (_controllers[index]!.value.volume == 0) {
//                                 _controllers[index]!.setVolume(1.0);
//                               } else {
//                                 _controllers[index]!.setVolume(0.0);
//                               }
//                             });
//                           },
//                         ),
//                         DropdownButton<double>(
//                           value: _playbackSpeed,
//                           onChanged: (value) {
//                             _changeSpeed(value!);
//                           },
//                           items: [0.5, 1.0, 1.5, 2.0].map<DropdownMenuItem<double>>((double value) {
//                             return DropdownMenuItem<double>(
//                               value: value,
//                               child: Text('$value', style: TextStyle()),
//                             );
//                           }).toList(),
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.download, color: Colors.white),
//                           onPressed: () {
//                             downloadVideo(videoUrls[index]);
//                           },
//                         ),
//                         Text(
//                           '${_durations[index].inSeconds} sec',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// final List<String> videoUrls = [
//   'https://signalstoragecontent.blob.core.windows.net/taskcompletionimages/img-63834663-f43d-4167-946a-08459325a736.mp4',
//   'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
//   'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
//   'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
//   'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
//   'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
//   'https://signalstoragecontent.blob.core.windows.net/taskcompletionimages/img-9e75027d-70c6-4f85-8d69-4431280f6e76.mp4',
//   'https://signalstoragecontent.blob.core.windows.net/taskcompletionimages/img-38f529ba-284b-453a-85c6-46c14f54f6e9.mp4',
//   'https://signalstoragecontent.blob.core.windows.net/taskcompletionimages/img-f95ee019-670b-46ba-9d93-bff3bb369d15.mp4',
// ];
