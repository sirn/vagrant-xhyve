#include <vmnet/vmnet.h>
#include <dispatch/dispatch.h>
#include "uuid.h"

struct vmr_state {
  interface_ref iface;
  uint8_t mac[6];
};

static int vmr_resolve(char *uuid_str, char **result) {
  uuid_t uuid;
  uint32_t uuid_status;

  uuid_from_string(uuid_str, &uuid, &uuid_status);
  if (uuid_status != uuid_s_ok) {
    return (-1);
  }

  xpc_object_t iface_desc = xpc_dictionary_create(NULL, NULL, 0);
  xpc_dictionary_set_uint64(iface_desc, vmnet_operation_mode_key, VMNET_SHARED_MODE);
  xpc_dictionary_set_uuid(iface_desc, vmnet_interface_id_key, uuid);

  struct vmr_state *vms = malloc(sizeof(struct vmr_state));
  if (!vms) {
    return (-1);
  }

  dispatch_queue_t if_create_q = dispatch_queue_create("th.gridth.vmnet.create", DISPATCH_QUEUE_SERIAL);
  dispatch_semaphore_t iface_created = dispatch_semaphore_create(0);
  __block vmnet_return_t iface_status = 0;
  __block interface_ref iface = vmnet_start_interface(iface_desc, if_create_q, ^(vmnet_return_t status, xpc_object_t iface_param) {
    iface_status = status;
    if (status != VMNET_SUCCESS || !iface_param) {
      dispatch_semaphore_signal(iface_created);
      return;
    }

    if (sscanf(xpc_dictionary_get_string(iface_param, vmnet_mac_address_key),
               "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx",
               &vms->mac[0], &vms->mac[1], &vms->mac[2], &vms->mac[3],
               &vms->mac[4], &vms->mac[5]) != 6) {
      return;
    }

    dispatch_semaphore_signal(iface_created);
  });

  dispatch_semaphore_wait(iface_created, DISPATCH_TIME_FOREVER);
  dispatch_release(if_create_q);

  if (iface == NULL || iface_status != VMNET_SUCCESS) {
    free(vms);
    return (-1);
  }

  *result = malloc(18);
  sprintf(*result,
          "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx",
          vms->mac[0], vms->mac[1], vms->mac[2],
          vms->mac[3], vms->mac[4], vms->mac[5]);

  return 0;
}
