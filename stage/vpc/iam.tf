resource "aws_iam_role" "ecs_events-stage" {
  name = "ecs_events-stage"

  assume_role_policy = <<DOC
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
DOC
}

resource "aws_iam_role_policy" "ecs_events_run_task_with_any_role-stage" {
  name = "ecs_events_run_task_with_any_role-stage"
  role = aws_iam_role.ecs_events-stage.id

  policy = <<DOC
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "ecs:RunTask",
            "Resource": "*"
        }
    ]
}
DOC
}

import {
  to = aws_iam_user.service-account-stage
  id = var.service_account
}

import {
  to = aws_s3_bucket.datafile-bucket-stage
  id = var.datafile_bucket
}


resource "aws_s3_bucket" "datafile-bucket-stage" {
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_iam_user" "service-account-stage" {
  name = var.service_account
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_iam_role" "datafile_readonly_access-stage" {
  name = "datafile_readonly_access-stage"
  description = "Read-only access role for the monthly data file S3 bucket"
  max_session_duration = 43200
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid = "AllowDatafileAccessRoleFromLupo"
        Principal = {
          AWS = aws_iam_user.service-account-stage.arn
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "datafile_readonly_access_s3-stage" {
  name = "datafile_readonly_access_s3-stage"
  role = aws_iam_role.datafile_readonly_access-stage.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "BucketAccess"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.datafile-bucket-stage.arn
        ]
      },
      {
        Sid = "S3ObjectAccess"
        Action = [
          "s3:GetObject",
          "s3:GetObjectAttributes"
        ]
        Resource = [
          "${aws_s3_bucket.datafile-bucket-stage.arn}/*"
        ]
      }
    ]
  })
}
