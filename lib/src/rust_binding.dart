import 'dart:typed_data';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

String getLibraryPath() {
  final String pubCacheDir = path.join(
    Platform.environment['HOME']!,
    '.pub-cache',
    'hosted',
    'pub.dev',
    'switch_camera-0.0.1',
    'lib',
    'src',
  );
  // Construct the full path to the shared library
  final String sourceLibPath =
      path.join(pubCacheDir, 'rust_native', 'librust_camera.so');

  // Construct the destination path
  final executableDir = path.dirname(Platform.resolvedExecutable);
  final destinationLibPath = path.join(
      executableDir, 'lib', 'src', 'rust_native', 'librust_camera.so');

  if (!File(destinationLibPath).existsSync()) {
    // Create the destination directories if they do not exist
    final destinationDir = path.dirname(destinationLibPath);
    Directory(destinationDir).createSync(recursive: true);
    // Copy the file to the new location
    File(sourceLibPath).copySync(destinationLibPath);
  }

  // Verify if the file exists at the new location
  if (File(destinationLibPath).existsSync()) {
    return destinationLibPath;
  } else {
    throw Exception('Failed to copy the library to $destinationLibPath');
  }
}

final DynamicLibrary _lib = Platform.isLinux
    ? DynamicLibrary.open(
        getLibraryPath()) // Update with the actual name of the compiled Rust library
    : DynamicLibrary.process();


base class FrCamera extends Opaque {}

typedef FrCameraNew = Pointer<FrCamera> Function();

typedef FrCameraFreeRust = Void Function(Pointer<FrCamera>);
typedef FrCameraFreeDart = void Function(Pointer<FrCamera>);

typedef FrCameraGetDevicesRust = Int32 Function(Int32, Pointer<Int32>);
typedef FrCameraGetDevicesDart = int Function(int, Pointer<Int32>);

typedef FrCameraReleaseCamRust = Void Function(Pointer<FrCamera>);
typedef FrCameraReleaseCamDart = void Function(Pointer<FrCamera>);

typedef FrCameraCamOpenRust = Void Function(Pointer<FrCamera>, Int32);
typedef FrCameraCamOpenDart = void Function(Pointer<FrCamera>, int);

typedef FrCameraRustCamRust = Void Function(Pointer<FrCamera>, Pointer<Uint8>, Pointer<Int32>);
typedef FrCameraRustCamDart = void Function(Pointer<FrCamera>, Pointer<Uint8>, Pointer<Int32>);

typedef FrCameraStartVideoWriterRust = Void Function(Pointer<FrCamera>, Pointer<Utf8>, Double, Int32, Int32);
typedef FrCameraStartVideoWriterDart = void Function(Pointer<FrCamera>, Pointer<Utf8>, double, int, int);

typedef FrCameraStartAVideoWriterRust = Void Function(Pointer<FrCamera>, Double, Int32, Int32);
typedef FrCameraStartAVideoWriterDart = void Function(Pointer<FrCamera>, double, int, int);

typedef FrCameraWriteFrameRust = Void Function(Pointer<FrCamera>);
typedef FrCameraWriteFrameDart = void Function(Pointer<FrCamera>);



final FrCameraNew frCameraNew = _lib
    .lookup<NativeFunction<FrCameraNew>>('fr_camera_new')
    .asFunction();

final FrCameraFreeDart frCameraFree = _lib
    .lookup<NativeFunction<FrCameraFreeRust>>('fr_camera_free')
    .asFunction();

final FrCameraGetDevicesDart frCameraGetDevices = _lib
    .lookup<NativeFunction<FrCameraGetDevicesRust>>('fr_camera_get_devices')
    .asFunction();
    
final FrCameraReleaseCamDart frCameraReleaseCam = _lib
    .lookup<NativeFunction<FrCameraReleaseCamRust>>('fr_camera_release_cam')
    .asFunction();

final FrCameraCamOpenDart frCameraCamOpen = _lib
    .lookup<NativeFunction<FrCameraCamOpenRust>>('fr_camera_cam_open')
    .asFunction();

final FrCameraRustCamDart frCameraRustCam = _lib
    .lookup<NativeFunction<FrCameraRustCamRust>>('fr_camera_rust_cam')
    .asFunction();

final FrCameraRustCamDart frCameraRustCamFlip = _lib
    .lookup<NativeFunction<FrCameraRustCamRust>>('fr_camera_rust_cam_flip')
    .asFunction();

final FrCameraStartVideoWriterDart frCameraStartVideoWriter = _lib
    .lookup<NativeFunction<FrCameraStartVideoWriterRust>>('fr_camera_start_video_writer')
    .asFunction();

final FrCameraStartAVideoWriterDart frCameraStartAVideoWriter = _lib
    .lookup<NativeFunction<FrCameraStartAVideoWriterRust>>('fr_camera_start_a_video_writer')
    .asFunction();
    
final FrCameraWriteFrameDart frCameraWriteFrame = _lib
    .lookup<NativeFunction<FrCameraWriteFrameRust>>('fr_camera_write_frame')
    .asFunction();

final FrCameraWriteFrameDart frCameraWriteFrameFlip = _lib
    .lookup<NativeFunction<FrCameraWriteFrameRust>>('fr_camera_write_frame_flip')
    .asFunction();


class Camera {
    Pointer<FrCamera> _camera;

    Camera() : _camera = frCameraNew();

    List<int> getDevices(int limit) {
        final devices = malloc<Int32>(limit);
        final count = frCameraGetDevices(limit, devices);
        final deviceList = devices.asTypedList(count).toList();
        malloc.free(devices);
        return deviceList;
    }

    void open(int index) {
        frCameraCamOpen(_camera, index);
    }

    void release() {
        frCameraReleaseCam(_camera);
    }

    Uint8List captureFrame() {
        final buffer = malloc<Uint8>(1024 * 1024); // Allocate 1MB buffer
        final bufferLen = malloc<Int32>();
        frCameraRustCam(_camera, buffer, bufferLen);
        final len = bufferLen.value;
        final frame = Uint8List.fromList(buffer.asTypedList(len));
        malloc.free(buffer);
        malloc.free(bufferLen);
        return frame;
    }

    Uint8List captureFrameFlip() {
        final buffer = malloc<Uint8>(1024 * 1024); // Allocate 1MB buffer
        final bufferLen = malloc<Int32>();
        frCameraRustCamFlip(_camera, buffer, bufferLen);
        final len = bufferLen.value;
        final frame = Uint8List.fromList(buffer.asTypedList(len));
        malloc.free(buffer);
        malloc.free(bufferLen);
        return frame;
    }

    // streamFrame function returns a Stream<Uint8List>
    Stream<Uint8List> streamFrames() async* {
      while (true) {
        yield captureFrame();
        // Simulate a delay for real-time data streaming
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    Stream<Uint8List> streamFramesFlip() async* {
      while (true) {
        yield captureFrameFlip();
        // Simulate a delay for real-time data streaming
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    void startVideoWriter(String filename, double fps, int width, int height) {
        final filenamePtr = filename.toNativeUtf8();
        frCameraStartVideoWriter(_camera, filenamePtr, fps, width, height);
        malloc.free(filenamePtr);
    }
    void startAVideoWriter( double fps, int width, int height) {
        frCameraStartAVideoWriter(_camera, fps, width, height);
    }

    void writeFrame() {
        frCameraWriteFrame(_camera);
    }

    void writeFrameFlip() {
        frCameraWriteFrameFlip(_camera);
    }

    void dispose() {
        frCameraFree(_camera);
    }
}




// ++++++++++++++++++++++++ AUDIO ++++++++++++++++++++++++++++++

// Define the Rust structs and functions

base class AudioRecorder extends Opaque {}

typedef NativeNewAudioRecorder = Pointer<AudioRecorder> Function();
typedef NewAudioRecorder = Pointer<AudioRecorder> Function();
final NewAudioRecorder newAudioRecorder = _lib
    .lookupFunction<NativeNewAudioRecorder, NewAudioRecorder>("new_audio_recorder");

typedef NativeStartRecording = Void Function(Pointer<AudioRecorder>);
typedef StartRecording = void Function(Pointer<AudioRecorder>);
final StartRecording audioRecorderStartRecording = _lib
    .lookupFunction<NativeStartRecording, StartRecording>("audio_recorder_start_recording");

typedef NativeStopRecording = Void Function(Pointer<AudioRecorder>);
typedef StopRecording = void Function(Pointer<AudioRecorder>);
final StopRecording audioRecorderStopRecording = _lib
    .lookupFunction<NativeStopRecording, StopRecording>("audio_recorder_stop_recording");

typedef NativePauseRecording = Void Function(Pointer<AudioRecorder>);
typedef PauseRecording = void Function(Pointer<AudioRecorder>);
final PauseRecording audioRecorderPauseRecording = _lib
    .lookupFunction<NativePauseRecording, PauseRecording>("audio_recorder_pause_recording");

typedef NativeResumeRecording = Void Function(Pointer<AudioRecorder>);
typedef ResumeRecording = void Function(Pointer<AudioRecorder>);
final ResumeRecording audioRecorderResumeRecording = _lib
    .lookupFunction<NativeResumeRecording, ResumeRecording>("audio_recorder_resume_recording");

// Dart wrapper for interacting with Rust FFI

class RustAudioRecorder {
  late Pointer<AudioRecorder> _recorder;

  RustAudioRecorder() {
    _recorder = newAudioRecorder();
  }

  void startRecording() {
    audioRecorderStartRecording(_recorder);
  }

  void stopRecording() {
    audioRecorderStopRecording(_recorder);
  }

  void pauseRecording() {
    audioRecorderPauseRecording(_recorder);
  }

  void resumeRecording() {
    audioRecorderResumeRecording(_recorder);
  }
}

// +++++++++++++++++++++++++++++ MERGE AUDIO AND VIDEO ++++++++++++++++++++++++++++++
typedef NativeMergeAudioVideo = Pointer<Utf8> Function(Pointer<Utf8>);
typedef MergeAudioVideo = Pointer<Utf8> Function(Pointer<Utf8>);

typedef NativeFreeString = Void Function(Pointer<Utf8>);
typedef FreeString = void Function(Pointer<Utf8>);

final MergeAudioVideo mergeAudioVideo = _lib
    .lookupFunction<NativeMergeAudioVideo, MergeAudioVideo>("merge_audio_video");

final FreeString freeString = _lib
    .lookupFunction<NativeFreeString, FreeString>("free_string");

String mergeCamAudioVideo(String outputFilePath) {
  final outputFilePathPtr = outputFilePath.toNativeUtf8();
  final resultPtr = mergeAudioVideo(outputFilePathPtr);
  calloc.free(outputFilePathPtr);

  final result = resultPtr.toDartString();
  freeString(resultPtr);

  return result;
}