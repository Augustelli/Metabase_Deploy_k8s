resource "openstack_compute_instance_v2" "k8s_k8s" {
  name              = "vm-k8s"
  image_id          = data.openstack_images_image_v2.kube.id
  flavor_id         = data.openstack_compute_flavor_v2.xl.id
  key_pair          = var.key_name
  security_groups   = [openstack_compute_secgroup_v2.k8s_sg_k8s.name]
  availability_zone = "nodos-amd-2022"

  network {
    name = openstack_networking_network_v2.k8s_net.name
  }
  user_data = templatefile("${path.module}/templates/vm-k8s.init.sh", {
  })
  depends_on = [
    openstack_networking_subnet_v2.k8s_subnet,
  ]

}