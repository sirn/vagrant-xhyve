#include "ruby.h"
#include "support/vmr.h"

VALUE from_uuid(VALUE self, VALUE rb_uuid_str) {
  if (!RB_TYPE_P(rb_uuid_str, T_STRING)) {
    return Qnil;
  }

  char *uuid_str;
  uuid_str = calloc(RSTRING_LEN(rb_uuid_str), sizeof(char));
  memcpy(uuid_str, StringValuePtr(rb_uuid_str), RSTRING_LEN(rb_uuid_str));

  char *result_str;
  if (vmr_resolve(uuid_str, &result_str) == (-1)) {
    return Qnil;
  }

  VALUE rb_result_str = rb_str_new2(result_str);
  free(result_str);
  return rb_result_str;
}

void Init_vmnet_mac() {
  VALUE rb_VagrantPlugins = rb_define_module("VagrantPlugins");
  VALUE rb_Xhyve = rb_define_module_under(rb_VagrantPlugins, "Xhyve");
  VALUE rb_Support = rb_define_module_under(rb_Xhyve, "Support");
  VALUE rb_VmnetMac = rb_define_class_under(rb_Support, "VmnetMac", rb_cObject);
  rb_define_singleton_method(rb_VmnetMac, "from_uuid", from_uuid, 1);
}
