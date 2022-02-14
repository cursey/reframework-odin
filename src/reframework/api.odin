package reframework

import c "core:c/libc"

PLUGIN_VERSION_MAJOR :: 1
PLUGIN_VERSION_MINOR :: 1
PLUGIN_VERSION_PATCH :: 0

PreHookResult :: enum c.int {
    CALL_ORIGINAL = 0,
    SKIP_ORIGINAL = 1,
}

RendererType :: enum c.int {
    D3D11 = 0,
    D3D12 = 1,
}

VMObjectType :: enum c.uint {
    NULL = 0,
    OBJECT = 1,
    ARRAY = 2,
    STRING = 3,
    DELEGATE = 4,
    VALTYPE = 5,
}

Result :: distinct c.int

TypeDefinitionHandle :: distinct rawptr
MethodHandle :: distinct rawptr
FieldHandle :: distinct rawptr
PropertyHandle :: distinct rawptr
ManagedObjectHandle :: distinct rawptr
TDBHandle :: distinct rawptr
ResourceHandle :: distinct rawptr
ResourceManagerHandle :: distinct rawptr
VMContextHandle :: distinct rawptr
TypeInfoHandle :: distinct rawptr
ReflectionPropertyHandle :: distinct rawptr
ReflectionMethodHandle :: distinct rawptr

InvokeMethod :: proc "c" (stack_frame : rawptr, ctx : rawptr)
ReflectionPropertyMethod :: proc "c" (rp : ReflectionPropertyHandle, obj : ManagedObjectHandle, out_data : rawptr) -> rawptr
REFPreHookFn :: proc "c" (argc : c.int, argv : [^]rawptr, arg_tys : [^]TypeDefinitionHandle) -> PreHookResult
REFPostHookFn :: proc "c" (ret_val : rawptr, ret_ty : TypeDefinitionHandle)

PluginVersion :: struct {
    major : c.int,
    minor : c.int,
    patch : c.int,
    game_name : cstring,
}

PluginFunctions :: struct {
    on_lua_state_created : proc "c" (cb : proc "c" (l : rawptr)) -> bool,
    on_lua_state_destroyed : proc "c" (cb : proc "c" (l : rawptr)) -> bool,
    on_present : proc "c" (cb : proc "c" ()) -> bool,
    on_pre_application_entry : proc "c" (entry : cstring, cb: proc "c" ()) -> bool,
    on_post_application_entry : proc "c" (entry : cstring, cb: proc "c" ()) -> bool,
    lock_lua : proc "c" (),
    unlock_lua : proc "c" (),
    on_device_reset : proc "c" (cb : proc "c" ()) -> bool,
    on_message : proc "c" (cb : proc "c" (hwnd : rawptr, msg : c.uint, lparam : c.uintptr_t, wparam : c.uintptr_t)) -> bool,
    log_error : proc "c" (msg : cstring),
    log_warn : proc "c" (msg : cstring),
    log_info : proc "c" (msg : cstring),
}

RendererData :: struct {
    renderer_type : RendererType,
    device : rawptr,
    swapchain : rawptr,
    command_queue : rawptr,
}

TDBTypeDefinition :: struct {
    get_index : proc "c" (td : TypeDefinitionHandle) -> c.uint,
    get_size : proc "c" (td : TypeDefinitionHandle) -> c.uint,
    get_valuetype_size : proc "c" (td : TypeDefinitionHandle) -> c.uint,
    get_fqn : proc "c" (td : TypeDefinitionHandle) -> c.uint,

    get_name : proc "c" (td : TypeDefinitionHandle) -> cstring,
    get_namespace : proc "c" (td : TypeDefinitionHandle) -> cstring,
    get_full_name : proc "c" (td : TypeDefinitionHandle, out : [^]c.char, out_size : c.uint, out_len : ^c.uint) -> Result,

    has_fieldptr_offset : proc "c" (td : TypeDefinitionHandle) -> bool,
    get_fieldptr_offset : proc "c" (td : TypeDefinitionHandle) -> c.int,

    get_num_methods : proc "c" (td : TypeDefinitionHandle) -> c.uint,
    get_num_fields : proc "c" (td : TypeDefinitionHandle) -> c.uint,
    get_num_properties : proc "c" (td : TypeDefinitionHandle) -> c.uint,

    is_derived_from : proc "c" (td : TypeDefinitionHandle, base : TypeDefinitionHandle) -> bool,
    is_derived_from_by_name : proc "c" (td : TypeDefinitionHandle, base : cstring) -> bool,
    is_value_type : proc "c" (td : TypeDefinitionHandle) -> bool,
    is_enum : proc "c" (td : TypeDefinitionHandle) -> bool,
    is_by_ref : proc "c" (td : TypeDefinitionHandle) -> bool,
    is_pointer : proc "c" (td : TypeDefinitionHandle) -> bool,
    is_primitive : proc "c" (td : TypeDefinitionHandle) -> bool,

    get_vm_obj_type : proc "c" (td : TypeDefinitionHandle) -> rawptr,

    find_method : proc "c" (td : TypeDefinitionHandle, name : cstring) -> MethodHandle,
    find_field : proc "c" (td : TypeDefinitionHandle, name : cstring) -> FieldHandle,
    find_property : proc "c" (td : TypeDefinitionHandle, name : cstring) -> PropertyHandle,

    get_methods : proc "c" (td : TypeDefinitionHandle, out : ^MethodHandle, out_size : c.uint, out_len : ^c.uint) -> Result,
    get_fields : proc "c" (td : TypeDefinitionHandle, out : ^FieldHandle, out_size : c.uint, out_len : ^c.uint) -> Result,

    get_instance : proc "c" (td : TypeDefinitionHandle) -> rawptr,
    create_instance_deprecated : proc "c" (td : TypeDefinitionHandle) -> rawptr,
    create_instance : proc "c" (td : TypeDefinitionHandle, flags : c.uint) -> ManagedObjectHandle,

    get_parent_type : proc "c" (td : TypeDefinitionHandle) -> TypeDefinitionHandle,
    get_declaring_type : proc "c" (td : TypeDefinitionHandle) -> TypeDefinitionHandle,
    get_underlying_type : proc "c" (td : TypeDefinitionHandle) -> TypeDefinitionHandle,

    get_type_info : proc "c" (td : TypeDefinitionHandle) -> TypeInfoHandle,
}

MethodParameter :: struct {
    name : cstring,
    t : TypeDefinitionHandle,
    reserved : c.uint64_t,
}

TDBMethod :: struct {
    invoke : proc "c" (m : MethodHandle, obj : rawptr, args : [^]rawptr, args_size : c.uint, out : rawptr, out_size : c.uint) -> Result,
    get_function : proc "c" (m : MethodHandle) -> rawptr,
    get_name : proc "c" (m : MethodHandle) -> cstring,
    get_declaring_type : proc "c" (m : MethodHandle) -> TypeDefinitionHandle,
    get_return_type : proc "c" (m : MethodHandle) -> TypeDefinitionHandle,

    get_num_params : proc "c" (m : MethodHandle) -> c.uint,

    get_params : proc "c" (m : MethodHandle, out : [^]MethodParameter, out_size : c.uint, out_len : ^c.uint) -> Result,

    get_index : proc "c" (m : MethodHandle) -> c.uint,
    get_virtual_index : proc "c" (m : MethodHandle) -> c.int,
    is_static : proc "c" (m : MethodHandle) -> bool,
    get_flags : proc "c" (m : MethodHandle) -> c.ushort,
    get_impl_flags : proc "c" (m : MethodHandle) -> c.ushort,
    get_invoke_id : proc "c" (m : MethodHandle) -> c.uint,
}

TDBField :: struct {
    get_name : proc "c" (f : FieldHandle) -> cstring,
    
    get_declaring_type : proc "c" (f : FieldHandle) -> TypeDefinitionHandle,
    get_type : proc "c" (f : FieldHandle) -> TypeDefinitionHandle,

    get_offset_from_base : proc "c" (f : FieldHandle) -> c.uint,
    get_offset_from_fieldptr : proc "c" (f : FieldHandle) -> c.uint,
    get_flags : proc "c" (f : FieldHandle) -> c.uint,

    is_static : proc "c" (f : FieldHandle) -> bool,
    is_literal : proc "c" (f : FieldHandle) -> bool,

    get_init_data : proc "c" (f : FieldHandle) -> rawptr,
    get_data_raw : proc "c" (f : FieldHandle, obj: rawptr, is_value_type : bool) -> rawptr,
}

TDBProperty :: struct {
    // todo
}

TDB :: struct {
    get_num_types : proc "c" (tdb : TDBHandle) -> c.uint,
    get_num_methods : proc "c" (tdb : TDBHandle) -> c.uint,
    get_num_fields : proc "c" (tdb : TDBHandle) -> c.uint,
    get_num_properties : proc "c" (tdb : TDBHandle) -> c.uint,
    get_strings_size : proc "c" (tdb : TDBHandle) -> c.uint,
    get_raw_data_size : proc "c" (tdb : TDBHandle) -> c.uint,
    get_string_database: proc "c" (tdb : TDBHandle) -> c.uint,
    get_raw_database: proc "c" (tdb : TDBHandle) -> c.uint,

    get_type : proc "c" (tdb : TDBHandle, index : c.uint) -> TypeDefinitionHandle,
    find_type : proc "c" (tdb : TDBHandle, name : cstring) -> TypeDefinitionHandle,
    find_type_by_fqn : proc "c" (tdb : TDBHandle, fqn : c.uint) -> TypeDefinitionHandle,
    get_method : proc "c" (tdb : TDBHandle, index : c.uint) -> MethodHandle,
    find_method : proc "c" (tdb : TDBHandle, typename: cstring, name : cstring) -> MethodHandle,
    get_field : proc "c" (tdb : TDBHandle, index : c.uint) -> FieldHandle,
    find_field : proc "c" (tdb : TDBHandle, typename : cstring, name : cstring) -> FieldHandle,
    get_property : proc "c" (tdb : TDBHandle, index : c.uint) -> PropertyHandle,
}

ManagedObject :: struct {
    add_ref : proc "c" (obj : ManagedObjectHandle),
    release : proc "c" (obj : ManagedObjectHandle),
    get_type_definition : proc "c" (obj : ManagedObjectHandle) -> TypeDefinitionHandle,
    is_managed_object : proc "c" (obj : rawptr) -> bool,
    get_ref_count : proc "c" (obj : ManagedObjectHandle) -> c.uint,
    get_size : proc "c" (obj : ManagedObjectHandle) -> c.uint,
    get_vm_obj_type : proc "c" (obj : ManagedObjectHandle) -> VMObjectType,
    get_type_info : proc "c" (obj : ManagedObjectHandle) -> TypeInfoHandle,
    get_reflection_properties : proc "c" (obj : ManagedObjectHandle) -> rawptr,
    get_reflection_property_descriptor : proc "c" (obj : ManagedObjectHandle, name : cstring) -> ReflectionPropertyHandle,
    get_reflection_method_descriptor : proc "c" (obj : ManagedObjectHandle, name : cstring) -> ReflectionMethodHandle,
}

NativeSingleton :: struct {
    instance : rawptr,
    t : TypeDefinitionHandle,
    type_info : TypeInfoHandle,
    name : cstring,
}

ManagedSingleton :: struct {
    instance : ManagedObjectHandle,
    t : TypeDefinitionHandle,
    type_info : TypeInfoHandle,
}

ResourceManager :: struct {
    create_resource : proc "c" (rm : ResourceManagerHandle, typename : cstring, name : cstring) -> ResourceHandle,
}

Resource :: struct {
    add_ref : proc "c" (res : ResourceHandle),
    release : proc "c" (res : ResourceHandle),
}

TypeInfo :: struct {
    get_name : proc "c" (ti : TypeInfoHandle) -> cstring,
    get_type_definition : proc "c" (ti : TypeInfoHandle) -> TypeDefinitionHandle,
    is_clr_type : proc "c" (ti : TypeInfoHandle) -> bool,
    is_singleton : proc "c" (ti : TypeInfoHandle) -> bool,
    get_singleton_instance : proc "c" (ti : TypeInfoHandle) -> rawptr,
    create_instance : proc "c" (ti : TypeInfoHandle) -> rawptr,
    get_reflection_properties : proc "c" (ti : TypeInfoHandle) -> rawptr,
    get_reflection_property_descriptor : proc "c" (ti : TypeInfoHandle, name : cstring) -> ReflectionPropertyHandle,
    get_reflection_method_descriptor : proc "c" (ti : TypeInfoHandle, name : cstring) -> ReflectionMethodHandle,
    get_deserializer_fn : proc "c" (ti :  TypeInfoHandle) -> rawptr,
    get_parent : proc "c" (ti : TypeInfoHandle) -> TypeInfoHandle,
    get_crc : proc "c" (ti : TypeInfoHandle) -> c.uint,
}

VMContext :: struct {
    has_exception : proc "c" (vm : VMContextHandle) -> bool,
    unhandled_exception : proc "c" (vm : VMContextHandle),
    local_frame_gc : proc "c" (vm : VMContextHandle),
    cleanup_after_exception : proc "c" (vm : VMContextHandle, old_reference_count : c.int),
}

ReflectionMethod :: struct {
    get_function : proc "c" (rm : ReflectionMethodHandle) -> InvokeMethod,
}

ReflectionProperty :: struct {
    get_getter : proc "c" (rp : ReflectionPropertyHandle) -> ReflectionPropertyMethod,
    is_static : proc "c" (rp : ReflectionPropertyHandle) -> bool,
    get_size : proc "c" (rp : ReflectionPropertyHandle) -> c.uint,
}

SDKFunctions :: struct {
    get_tdb : proc "c" () -> TDBHandle,
    get_resource_manager : proc "c" () -> ResourceManagerHandle,
    get_vm_context : proc "c" () -> VMContextHandle,

    typeof : proc "c" (typename : cstring) -> ManagedObjectHandle,
    get_managed_singleton : proc "c" (typename : cstring) -> ManagedObjectHandle,
    get_native_singleton : proc "c" (typename : cstring) -> rawptr,

    get_managed_singletons : proc "c" (out : rawptr, out_size : c.uint, out_count : ^c.uint) -> Result,
    get_native_singletons : proc "c" (out : rawptr, out_size : c.uint, out_count : ^c.uint) -> Result,

    create_managed_string : proc "c" (str : [^]c.wchar_t) -> ManagedObjectHandle,
    create_managed_string_normal : proc "c" (str : cstring) -> ManagedObjectHandle,

    add_hook : proc "c" (fn : MethodHandle, pre_fn : REFPreHookFn, post_fn : REFPostHookFn, ignore_jmp : bool) -> c.uint,
    remove_hook : proc "c" (fn : MethodHandle, hook_id : c.uint),
}

SDKData :: struct {
    functions : ^SDKFunctions,
    tdb : ^TDB,
    type_definition : ^TDBTypeDefinition,
    method : ^TDBMethod,
    field : ^TDBField,
    property : ^TDBProperty,
    managed_object : ^ManagedObject,
    resource_manager : ^ResourceManager,
    resource : ^Resource,
    type_info : ^TypeInfo, // NOT a type definition
    vm_context : ^VMContext,
    reflection_method : ^ReflectionMethod, // NOT a TDB method
    reflection_property : ^ReflectionProperty, // NOT a TDB property
}

PluginInitializeParam :: struct {
    reframework_module : rawptr,
    version : ^PluginVersion,
    functions: ^PluginFunctions,
    renderer_data : ^RendererData,
    sdk : ^SDKData,
}