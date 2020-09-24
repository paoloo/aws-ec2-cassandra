/* ========================================================================= */
variable "region"           { default     = "us-west-2"                      }
variable "instance_type"    { default     = "t2.micro"                       }
variable "public_key"       { default     = "paolo-ff" }
variable "private_key"      { default     = "/Users/paolo/.ssh/aws-key.pem" }
/* ========================================================================= */
provider "aws" {
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "aws-test"
  region                  = "${var.region}"
}
/* ========================================================================= */
/* resource "aws_key_pair" "deployer" {                                      */
/*   key_name                = "base-paolo-key"                              */
/*   public_key              = "${file("${var.public_key}")}"                */
/* }                                                                         */
/* ========================================================================= */

module "node1" {
  source                  = "./ec2cassandra"
  region                  = "${var.region}"
  instance_type           = "${var.instance_type}"
  key_name                = "${var.public_key}"
  private_key             = "${var.private_key}"
  security_group          = "${aws_security_group.cassandra-sg.id}"
  cassandra_role          = "${aws_iam_instance_profile.cassandra-instance-profile.id}"
  append2cluster          = []
}

module "node2" {
  source                  = "./ec2cassandra"
  region                  = "${var.region}"
  instance_type           = "${var.instance_type}"
  key_name                = "${var.public_key}"
  private_key             = "${var.private_key}"
  security_group          = "${aws_security_group.cassandra-sg.id}"
  cassandra_role          = "${aws_iam_instance_profile.cassandra-instance-profile.id}"
  append2cluster          = ["${module.node1.address}"]
}

module "node3" {
  source                  = "./ec2cassandra"
  region                  = "${var.region}"
  instance_type           = "${var.instance_type}"
  key_name                = "${var.public_key}"
  security_group          = "${aws_security_group.cassandra-sg.id}"
  private_key             = "${var.private_key}"
  cassandra_role          = "${aws_iam_instance_profile.cassandra-instance-profile.id}"
  append2cluster          = ["${module.node1.address}", "${module.node2.address}"]
}
/* ========================================================================= */
output "node1" { value    = "${module.node1.uri}"                            }
output "node2" { value    = "${module.node2.uri}"                            }
output "node3" { value    = "${module.node3.uri}"                            }
/* ========================================================================= */
