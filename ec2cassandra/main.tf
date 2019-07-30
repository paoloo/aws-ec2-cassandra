/* ========================================================================= */
/* ==== cassandra setup ==================================================== */
/* ========================================================================= */

/* ==== variables and locals =============================================== */
variable "region"           { }
variable "instance_type"    { }
variable "key_name"         { }
variable "security_group"   { }
variable "cassandra_role"   { }
variable "private_key"      { }
variable "append2cluster"   { type = "list" }
locals {
  installer_script = "${file("./ec2cassandra/setup_cassandra.sh")}"
  procd_append     = "${length(var.append2cluster)==0 ? "" : format(",%s", join(",", var.append2cluster))}"
}

/* ==== data recv ========================================================== */
data "aws_ami" "awslinux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"]
}

data "aws_availability_zones" "available" {}

/* ==== instance setup ===================================================== */
resource "aws_instance" "app_node" {
  ami                    = "${data.aws_ami.awslinux.id}"
  instance_type          = "${var.instance_type}"
  availability_zone      = "${element(data.aws_availability_zones.available.names, 0)}"
  vpc_security_group_ids = ["${var.security_group}"]
  key_name               = "${var.key_name}"
  iam_instance_profile   = "${var.cassandra_role}"
  user_data              = "${local.installer_script}"

  connection {
               user        = "ec2-user"
               private_key = "${file("${var.private_key}")}"
               timeout     = "1m"
  }

  provisioner "remote-exec" {
    inline = [<<-EOF
date
echo "waiting for Cassandra to finish installing"
WAIT=#
while [ ! -f /etc/cassandra/conf/cassandra.yaml ]
do
  echo -ne "$WAIT\r"
  WAIT=$(echo $WAIT)#
    sleep 5
done
echo 'instance private ip - ${self.private_ip}' | sudo tee testing.txt
sudo sed -i "s/- seeds: \"127.0.0.1\"/- seeds: \"${self.private_ip}${local.procd_append}\"/g" /etc/cassandra/conf/cassandra.yaml
echo 'SED complete!'
sudo reboot
                EOF
]
  }
}

/* ==== output ============================================================= */
output "uri"     { value = "${aws_instance.app_node.public_dns}" }
output "address" { value = "${aws_instance.app_node.private_ip}" }
