#!/bin/bash
# Query CloudTrail logs - Interactive menu

set -e

echo "=========================================="
echo "CloudTrail Log Query Tool"
echo "=========================================="
echo ""

# Check if AWS CLI is available
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found"
    exit 1
fi

# Check AWS authentication
aws sts get-caller-identity &> /dev/null || {
    echo "❌ Not authenticated with AWS"
    exit 1
}

echo "Select query type:"
echo ""
echo "1. Recent activity (last 10 events)"
echo "2. EC2 instance launches"
echo "3. Security group changes"
echo "4. IAM changes"
echo "5. S3 bucket access"
echo "6. Failed login attempts"
echo "7. Root account usage"
echo "8. Resource deletions"
echo "9. Custom query"
echo ""
read -p "Enter choice (1-9): " choice

echo ""
echo "Querying CloudTrail..."
echo ""

case $choice in
  1)
    echo "📋 Last 10 events:"
    aws cloudtrail lookup-events --max-results 10 \
      --query 'Events[*].[EventTime,EventName,Username]' \
      --output table
    ;;
  
  2)
    echo "🖥️  EC2 Instance Launches:"
    aws cloudtrail lookup-events \
      --lookup-attributes AttributeKey=EventName,AttributeValue=RunInstances \
      --max-results 20 \
      --query 'Events[*].[EventTime,Username,EventName]' \
      --output table
    ;;
  
  3)
    echo "🛡️  Security Group Changes:"
    echo ""
    echo "Authorizations (allow rules added):"
    aws cloudtrail lookup-events \
      --lookup-attributes AttributeKey=EventName,AttributeValue=AuthorizeSecurityGroupIngress \
      --max-results 10 \
      --query 'Events[*].[EventTime,Username,EventName]' \
      --output table
    echo ""
    echo "Revocations (rules removed):"
    aws cloudtrail lookup-events \
      --lookup-attributes AttributeKey=EventName,AttributeValue=RevokeSecurityGroupIngress \
      --max-results 10 \
      --query 'Events[*].[EventTime,Username,EventName]' \
      --output table
    ;;
  
  4)
    echo "👤 IAM Changes:"
    echo ""
    echo "User creation:"
    aws cloudtrail lookup-events \
      --lookup-attributes AttributeKey=EventName,AttributeValue=CreateUser \
      --max-results 10 \
      --query 'Events[*].[EventTime,Username,EventName]' \
      --output table
    echo ""
    echo "Policy attachments:"
    aws cloudtrail lookup-events \
      --lookup-attributes AttributeKey=EventName,AttributeValue=AttachUserPolicy \
      --max-results 10 \
      --query 'Events[*].[EventTime,Username,EventName]' \
      --output table
    ;;
  
  5)
    echo "🪣 S3 Bucket Access:"
    echo ""
    echo "Bucket creation:"
    aws cloudtrail lookup-events \
      --lookup-attributes AttributeKey=EventName,AttributeValue=CreateBucket \
      --max-results 10 \
      --query 'Events[*].[EventTime,Username,EventName]' \
      --output table
    echo ""
    echo "Public access changes:"
    aws cloudtrail lookup-events \
      --lookup-attributes AttributeKey=EventName,AttributeValue=PutBucketPublicAccessBlock \
      --max-results 10 \
      --query 'Events[*].[EventTime,Username,EventName]' \
      --output table
    ;;
  
  6)
    echo "🚫 Failed Login Attempts:"
    aws cloudtrail lookup-events \
      --lookup-attributes AttributeKey=EventName,AttributeValue=ConsoleLogin \
      --max-results 20 \
      --query 'Events[?contains(CloudTrailEvent, `"Failed"`)][EventTime,Username,EventName]' \
      --output table
    ;;
  
  7)
    echo "⚠️  Root Account Usage (SECURITY ALERT!):"
    aws cloudtrail lookup-events \
      --max-results 50 \
      --query 'Events[?contains(Username, `root`)][EventTime,Username,EventName,EventSource]' \
      --output table
    ;;
  
  8)
    echo "🗑️  Resource Deletions:"
    echo ""
    echo "EC2 terminations:"
    aws cloudtrail lookup-events \
      --lookup-attributes AttributeKey=EventName,AttributeValue=TerminateInstances \
      --max-results 10 \
      --query 'Events[*].[EventTime,Username,EventName]' \
      --output table
    echo ""
    echo "S3 bucket deletions:"
    aws cloudtrail lookup-events \
      --lookup-attributes AttributeKey=EventName,AttributeValue=DeleteBucket \
      --max-results 10 \
      --query 'Events[*].[EventTime,Username,EventName]' \
      --output table
    ;;
  
  9)
    echo "Custom Query"
    echo ""
    read -p "Enter event name (e.g., CreateBucket): " event_name
    read -p "Max results (default 10): " max_results
    max_results=${max_results:-10}
    
    echo ""
    echo "Results for: $event_name"
    aws cloudtrail lookup-events \
      --lookup-attributes AttributeKey=EventName,AttributeValue=$event_name \
      --max-results $max_results \
      --query 'Events[*].[EventTime,Username,EventName]' \
      --output table
    ;;
  
  *)
    echo "Invalid choice"
    exit 1
    ;;
esac

echo ""
echo "=========================================="
echo "✅ Query complete"
echo ""
echo "💡 Tips:"
echo "  - Events appear within 15 minutes"
echo "  - Use CloudTrail console for detailed analysis"
echo "  - Check S3 bucket for raw log files"
echo ""
echo "🌐 CloudTrail Console:"
echo "  https://console.aws.amazon.com/cloudtrail/home"
echo "=========================================="
