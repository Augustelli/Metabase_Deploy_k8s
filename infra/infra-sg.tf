resource "openstack_compute_secgroup_v2" "k8s_sg_bastion" {
  name        = "k8s_sg_bastion"
  description = "k8s_sg_bastion"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
  rule {
    ip_protocol = "icmp"
    from_port   = -1
    to_port     = -1
    cidr        = "0.0.0.0/0"
  }
}


resource "openstack_compute_secgroup_v2" "k8s_sg_k8s" {
  name        = "k8s_sg_k8s"
  description = "k8s_sg_k8s"

  rule {
    from_group_id = openstack_compute_secgroup_v2.k8s_sg_bastion.id
    from_port     = -1
    to_port       = -1
    ip_protocol   = "icmp"
  }
  rule {
    from_group_id = openstack_compute_secgroup_v2.k8s_sg_bastion.id
    from_port     = 22
    to_port       = 22
    ip_protocol   = "tcp"
  }
  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
  rule {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

}




