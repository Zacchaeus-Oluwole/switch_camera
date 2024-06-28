import 'package:switch_camera/switch_camera.dart';
import 'dart:io';

void main() {
    final camera = Camera();
    final devices = camera.getDevices(10);
    // ignore: avoid_print
    print('Devices: $devices');

    if (devices.isNotEmpty) {
        camera.open(devices[0]);
        final frame = camera.captureFrame();
        print('Captured frame with length: ${frame.length}');
        File('frame.jpg').writeAsBytesSync(frame);
        camera.release();
    }

    camera.dispose();
}