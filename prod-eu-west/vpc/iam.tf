resource "aws_iam_role" "ecs_events" {
  name = "ecs_events"

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

resource "aws_iam_role_policy" "ecs_events_run_task_with_any_role" {
  name = "ecs_events_run_task_with_any_role"
  role = aws_iam_role.ecs_events.id

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
  to = aws_iam_user.service-account-prod
  id = var.service_account
}

import {
  to = aws_s3_bucket.datafile-bucket-prod
  id = var.datafile_bucket
}


resource "aws_s3_bucket" "datafile-bucket-prod" {
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_iam_user" "service-account-prod" {
  name = var.service_account
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_iam_role" "datafile_readonly_access-prod" {
  name = "datafile_readonly_access-prod"
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
          AWS = aws_iam_user.service-account-prod.arn
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "datafile_readonly_access_s3-prod" {
  name = "datafile_readonly_access_s3-prod"
  role = aws_iam_role.datafile_readonly_access-prod.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "BucketAccess"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.datafile-bucket-prod.arn
        ]
        Effect = "Allow"
      },
      {
        Sid = "S3ObjectAccess"
        Action = [
          "s3:GetObject",
          "s3:GetObjectAttributes"
        ]
        Resource = [
          "${aws_s3_bucket.datafile-bucket-prod.arn}/*"
        ]
        Effect = "Allow"
      }
    ]
  })
}
