
resource "openstack_networking_floatingip_v2" "bastion_fip" {
  description = "bastion-ip"
  pool        = "ext_net"
}

