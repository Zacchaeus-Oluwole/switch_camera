import 'package:switch_camera/switch_camera.dart';

void main() {
    final camera = Camera();
    final devices = camera.getDevices(10);
    // ignore: avoid_print
    print('Devices: $devices');

    if (devices.isNotEmpty) {
        camera.open(devices[0]);
        camera.startVideoWriter('output.mp4', 30.0, 640, 480);

        for (int i = 0; i < 100; i++) {
            camera.writeFrame();
        }

        camera.release();
    }

    camera.dispose();
}