package weapon_stay_big

import c "core:c/libc"
import ref "src:reframework"

g_param : ^ref.PluginInitializeParam

pre_start :: proc "c" (argc : c.int, argv : [^]rawptr, arg_tys : [^]ref.TypeDefinitionHandle) -> ref.PreHookResult {
    obj := cast(ref.ManagedObjectHandle)argv[1]
    obj_ty := g_param.sdk.managed_object.get_type_definition(obj)
    field := g_param.sdk.type_definition.find_field(obj_ty, "_bodyConstScale")
    data := g_param.sdk.field.get_data_raw(field, obj, false)
    scale := cast(^f32)data
    scale^ = 1.0
    return ref.PreHookResult.CALL_ORIGINAL
}

@export
reframework_plugin_required_version :: proc "c" (version : ^ref.PluginVersion) {
    version.major = ref.PLUGIN_VERSION_MAJOR
    version.minor = ref.PLUGIN_VERSION_MINOR
    version.patch = ref.PLUGIN_VERSION_PATCH
}

@export
reframework_plugin_initialize :: proc "c" (param : ^ref.PluginInitializeParam) -> bool {
    g_param = param
    tdb := param.sdk.functions.get_tdb()
    fn := param.sdk.tdb.find_method(tdb, "snow.player.PlayerWeaponCtrl", "start")
    param.sdk.functions.add_hook(fn, pre_start, nil, false)
    return true
}

