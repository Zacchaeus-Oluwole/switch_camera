//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <switch_camera/switch_camera_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) switch_camera_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "SwitchCameraPlugin");
  switch_camera_plugin_register_with_registrar(switch_camera_registrar);
}
