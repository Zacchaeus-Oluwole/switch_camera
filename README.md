# switch_camera

**`switch_camera`** is a Dart library that provides a Dart FFI interface to interact with camera and audio recording functionalities from Rust. It supports video capturing, frame streaming, and video writing, as well as audio recording and merging video with audio.

## Features

- List available camera devices
- Open and release camera devices
- Capture video frames (with and without flip)
- Stream video frames (with and without flip)
- Start video writer
- Write video frames (with and without flip)
- Audio recording (start, stop, pause, resume)
- Merge audio and video

## Platform Support
- Linux


## Installation

To install **`switch_camera`**, use either `flutter pub add` or `dart pub add`, depending on your project type:

### Flutter

```bash
flutter pub add switch_camera
```

## Usage
### Camera
```dart
import 'package:switch_camera/switch_camera.dart';

void main() {
  final camera = Camera();

  // List available devices
  final devices = camera.getDevices(10);
  print('Available devices: $devices');

  // Open a camera device
  camera.open(0);

  // Capture a frame
  final frame = camera.captureFrame();
  print('Captured frame: ${frame.length} bytes');

  // Capture a flipped frame
  final flippedFrame = camera.captureFrameFlip();
  print('Captured flipped frame: ${flippedFrame.length} bytes');

  // Stream frames
  camera.streamFrames().listen((frame) {
    print('Streaming frame: ${frame.length} bytes');
  });

  // Stream flipped frames
  camera.streamFramesFlip().listen((frame) {
    print('Streaming flipped frame: ${frame.length} bytes');
  });

  // Start video writer
  camera.startVideoWriter('output.mp4', 30.0, 1920, 1080);

  // Write a frame
  camera.writeFrame();

  // Write a flipped frame
  camera.writeFrameFlip();

  // Release the camera
  camera.release();

  // Dispose the camera
  camera.dispose();
}

```

### Audio Recorder
```dart
import 'package:switch_camera/switch_camera.dart';

void main() {
  final recorder = RustAudioRecorder();

  // Start recording
  recorder.startRecording();

  // Pause recording
  recorder.pauseRecording();

  // Resume recording
  recorder.resumeRecording();

  // Stop recording
  recorder.stopRecording();
}
```

### Merge Audio and Video
```dart
import 'package:switch_camera/switch_camera.dart';

void main() {
  final result = mergeCamAudioVideo('output_with_audio.mp4');
  print('Merge result: $result');
}

```

## NB: Prepare Linux apps for distribution
To build flutter applciation as release run the following command:
```bash
flutter build linux --release
```
After that, go to **build/linux/release/bundle/** and run the application using the following command:
```bash
./projectname
```
"_By runnung the application in the directory, a file will be automatically copied to **lib** folder with the following directory **src/rust_native/librust_camera.so**. This file is responsible for this library to work in your application._"

## API Reference
### Camera
- `List<int> getDevices(int limit)`

    - Lists available camera devices up to the specified limit.
- `void open(int index)`

    - Opens a camera device by index.
- `void release()`

    - Releases the currently opened camera device.
- `Uint8List captureFrame()`

    - Captures a single video frame.
- `Uint8List captureFrameFlip()`

    - Captures a single flipped video frame.
- `Stream<Uint8List> streamFrames()`

    - Streams video frames.
- `Stream<Uint8List> streamFramesFlip()`

    - Streams flipped video frames.
- `void startVideoWriter(String filename, double fps, int width, int height)`

    - Starts video writing to the specified file.
- `void startAVideoWriter(double fps, int width, int height)`

    - Starts a video writer without specifying a filename.
- `void writeFrame()`

    - Writes a video frame.
- `void writeFrameFlip()`

    - Writes a flipped video frame.
- `void dispose()`

    - Disposes the camera resources.

### RustAudioRecorder
- `void startRecording()`
    - Starts audio recording.
- `void stopRecording()`
    - Stops audio recording.
- `void pauseRecording()`
    - Pauses audio recording.
- `void resumeRecording()`
    - Resumes audio recording.

### Merge Functions
- `String mergeCamAudioVideo(String outputFilePath)`
    - Merges the recorded camera video and audio into the specified output file.

## Author
### Zacchaeus Oluwole

LinkedIn: <https://www.linkedin.com/in/zacchaeus-oluwole/>

X: <https://x.com/ZTechPlus>

Email: <zacchaeusoluwole@gmail.com>

Github: <https://github.com/Zacchaeus-Oluwole>
