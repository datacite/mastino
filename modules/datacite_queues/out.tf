output "dead_letter_arn" {
  value = aws_sqs_queue.dead-letter.arn
}

output "events_queue_name" {
  value = aws_sqs_queue.events.name
}
