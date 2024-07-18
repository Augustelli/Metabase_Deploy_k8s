data "openstack_networking_network_v2" "ext_net" {
  name = "ext_net"
}

data "openstack_compute_flavor_v2" "small" {
  vcpus = 1
  ram   = 2048
}

data "openstack_compute_flavor_v2" "xl" {
  vcpus = 8
  ram   = 16384
}

data "openstack_images_image_v2" "ubuntu_2204" {
  name        = "ubuntu_2204"
  most_recent = true
}

data "openstack_images_image_v2" "kube" {
  name        = "um-kube-tools"
  most_recent = true
}




