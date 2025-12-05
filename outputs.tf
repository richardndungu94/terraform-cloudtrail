output "cloudtrail_name" {
  description = "Name of the CloudTrail"
  value       = aws_cloudtrail.main.name
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail"
  value       = aws_cloudtrail.main.arn
}

output "s3_bucket_name" {
  description = "S3 bucket where logs are stored"
  value       = aws_s3_bucket.cloudtrail_logs.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 logs bucket"
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group (if enabled)"
  value       = var.enable_cloudwatch_logs ? aws_cloudwatch_log_group.cloudtrail[0].name : "Not enabled"
}

output "aws_account_id" {
  description = "AWS Account ID being monitored"
  value       = data.aws_caller_identity.current.account_id
}

output "next_steps" {
  description = "What to do next"
  value       = <<-EOT
    ✅ CloudTrail is now logging all API activity!
    
    📊 View recent events:
      aws cloudtrail lookup-events --max-results 10
    
    🔍 Query specific events:
      ./scripts/query-logs.sh
    
    📁 S3 Bucket: ${aws_s3_bucket.cloudtrail_logs.id}
    
    🔐 What's being logged:
      ✓ All API calls across all regions
      ✓ IAM actions (who did what)
      ✓ EC2 instance launches/stops
      ✓ S3 bucket access
      ✓ Security group changes
      ✓ And much more...
    
    ⚠️  Important:
      - Logs appear within 15 minutes
      - Check S3 bucket for log files
      - Use CloudTrail console for advanced search
    
    🌐 CloudTrail Console:
      https://console.aws.amazon.com/cloudtrail/home?region=${var.aws_region}#/events
    
    💰 Estimated cost: ~$2/month
  EOT
}

output "query_examples" {
  description = "Example queries to try"
  value       = <<-EOT
    # Who created EC2 instances recently?
    aws cloudtrail lookup-events \
      --lookup-attributes AttributeKey=EventName,AttributeValue=RunInstances
    
    # Who modified security groups?
    aws cloudtrail lookup-events \
      --lookup-attributes AttributeKey=EventName,AttributeValue=AuthorizeSecurityGroupIngress
    
    # Show all failed login attempts
    aws cloudtrail lookup-events \
      --lookup-attributes AttributeKey=EventName,AttributeValue=ConsoleLogin \
      --max-results 20
    
    # Who accessed this specific resource?
    aws cloudtrail lookup-events \
      --lookup-attributes AttributeKey=ResourceName,AttributeValue=<resource-name>
  EOT
}
