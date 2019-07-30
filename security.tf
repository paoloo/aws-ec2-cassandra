/* ==== security =========================================================== */
resource "aws_security_group" "cassandra-sg" {
  name = "cassandra-sg"
  description = "cassandra security group"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    self = true
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    self = true
  }
  ingress {
    from_port = 7000
    to_port = 7000
    protocol = "tcp"
    self = true
  }
  ingress {
    from_port = 7001
    to_port = 7001
    protocol = "tcp"
    self = true
  }
  ingress {
    from_port = 7199
    to_port = 7199
    protocol = "tcp"
    self = true
  }
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    self = true
  }
  ingress {
    from_port = 9042
    to_port = 9042
    protocol = "tcp"
    self = true
  }
  ingress {
    from_port = 9160
    to_port = 9160
    protocol = "tcp"
    self = true
  }
}

/* ==== IAM ================================================================ */
resource "aws_iam_role" "cassandra_role" {
  name = "cassandra_role"

  assume_role_policy = <<EOF
{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "ec2.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
    }
EOF
}

resource "aws_iam_policy" "cassandra_policy" {
  name        = "cassandra_policy"
  description = "cassandra_policy for eni attacment"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
                "logs:*",
                "events:*",
                "ec2:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cassandra_attach_rp" {
  role       = "${aws_iam_role.cassandra_role.name}"
  policy_arn = "${aws_iam_policy.cassandra_policy.arn}"
}

resource "aws_iam_instance_profile" "cassandra-instance-profile" {
  name  = "cassandra-instance-profile"
  role = "${aws_iam_role.cassandra_role.name}"
}
