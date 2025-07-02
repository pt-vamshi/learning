# Infrastructure-as-Code: AWS Serverless Media Streaming Application

## 🎯 Overview

A complete serverless media streaming application deployed on AWS using Terraform. This project demonstrates modern cloud architecture with security, scalability, and cost-effectiveness in mind.

## 🏗️ Architecture

### Scenario
Host a media streaming application on AWS using a secure, highly available, and serverless architecture. The stack supports 200 users per hour and uses S3, CloudFront (with WAF), Lambda, and API Gateway.

### Architecture Components
- **Amazon S3**: Stores static website (index.html) and videos (in a videos/ folder). Private bucket with static website hosting enabled.
- **Amazon CloudFront**: CDN providing the only public access to S3 (via OAI), protected by AWS WAF.
- **AWS WAF**: Web Application Firewall protecting CloudFront from common web exploits.
- **AWS Lambda**: Lists videos in the S3 bucket (videos/ folder) and returns full CloudFront URLs.
- **API Gateway**: Exposes a /prod/videos endpoint for the frontend to fetch the video list.

### Architecture Diagram
```
[User Request]
       |
       v
[CloudFront CDN + WAF] <---OAI---> [S3 Bucket (private, static site, videos/)]
       |
       v
[API Gateway /prod/videos] ---> [Lambda: List S3 videos]
```

## 🚀 Quick Start

### Prerequisites
- Terraform CLI (v1.0+)
- AWS CLI configured with appropriate permissions
- AWS account with access to S3, CloudFront, Lambda, API Gateway, and WAF

### Deployment Steps

1. **Package Lambda Function**
   ```bash
   cd Infrastructure-as-Code
   zip lambda_list_videos.zip lambda_list_videos.py
   ```

2. **Initialize Terraform**
   ```bash
   terraform init
   ```

3. **Review the Plan**
   ```bash
   terraform plan
   ```

4. **Deploy Infrastructure**
   ```bash
   terraform apply
   ```

5. **Upload Content to S3**
   ```bash
   # Upload the frontend
   aws s3 cp index.html s3://$(terraform output -raw s3_bucket_name)/
   
   # Upload sample videos (replace with your videos)
   aws s3 cp sample1.mp4 s3://$(terraform output -raw s3_bucket_name)/videos/
   aws s3 cp sample2.mp4 s3://$(terraform output -raw s3_bucket_name)/videos/
   ```

6. **Update Frontend Configuration**
   - Update the `API_URL` in `index.html` with your actual API Gateway endpoint
   - Re-upload the updated `index.html` to S3

7. **Access Your Application**
   - Use your CloudFront distribution URL to access the UI
   - Videos will stream securely via CloudFront

## 📸 Screenshots

### 1. Application Interface
![Media Streaming App Interface](Screenshot%202025-07-02%20at%2010.33.41%E2%80%AFPM%20(2).png)

*The main application interface showing the media streaming app with video controls and responsive design.*

### 2. Infrastructure Deployment
![ Architecture Diagram](Screenshot%202025-07-02%20at%2010.14.42%E2%80%AFPM%20(2).png)

*Successful Terraform deployment showing all AWS resources being created and configured.*

## 🔧 Configuration

### Terraform Variables
The main configuration is in `main.tf` with the following key resources:

- **S3 Bucket**: `media-streaming-app-bucket-{random_suffix}`
- **CloudFront Distribution**: With OAI and WAF protection
- **Lambda Function**: `list-videos` with S3 read access
- **API Gateway**: REST API with `/prod/videos` endpoint
- **WAF Web ACL**: AWS managed rules for security

### Environment Variables
The Lambda function uses these environment variables:
```bash
S3_BUCKET = aws_s3_bucket.media.bucket
CLOUDFRONT_URL = https://${aws_cloudfront_distribution.media_cdn.domain_name}
```

## 🔒 Security Features

### WAF Protection
- **AWS Managed Rules**: Common web exploits protection
- **CloudWatch Metrics**: Monitoring and alerting capabilities
- **Sampled Requests**: Request inspection for debugging

### S3 Security
- **Private Bucket**: No direct public access
- **Origin Access Identity (OAI)**: Only CloudFront can access S3
- **Bucket Policy**: Restricts access to CloudFront OAI only

### API Security
- **Lambda Permissions**: Minimal required permissions
- **API Gateway**: Secure endpoint with proper CORS handling
- **HTTPS Only**: All traffic encrypted in transit

## 📊 Monitoring & Logging

### CloudWatch Metrics
- WAF request counts and blocked requests
- CloudFront distribution metrics
- Lambda function invocations and errors
- API Gateway request counts

### Logging
- CloudFront access logs (optional)
- Lambda function logs
- WAF logs for security analysis

## 🧪 Testing

### Manual Testing
1. **Upload Test Videos**: Add sample MP4 files to S3 `videos/` folder
2. **Test API Endpoint**: 
   ```bash
   curl https://your-api-gateway-url/prod/videos
   ```
3. **Test Frontend**: Access CloudFront URL and verify video playback
4. **Test WAF**: Attempt common attack patterns (should be blocked)

### Automated Testing
```bash
# Validate Terraform configuration
terraform validate

# Check plan without applying
terraform plan

# Test Lambda function locally (if needed)
python3 lambda_list_videos.py
```

## 🔄 Maintenance

### Updates
```bash
# Update Lambda function
zip lambda_list_videos.zip lambda_list_videos.py
terraform apply

# Update frontend
aws s3 cp index.html s3://$(terraform output -raw s3_bucket_name)/
```

### Scaling
- **Automatic**: CloudFront handles global distribution
- **Manual**: Add more Lambda functions for different operations
- **Storage**: S3 automatically scales with content

## 💰 Cost Optimization

### Current Architecture Benefits
- **Pay-per-use**: Lambda only charges for actual invocations
- **CDN Caching**: CloudFront reduces origin requests
- **Serverless**: No EC2 instances to manage
- **WAF**: Pay only for requests processed

### Cost Monitoring
- Set up CloudWatch billing alerts
- Monitor Lambda function duration and memory usage
- Track CloudFront data transfer costs

## 🚨 Troubleshooting

### Common Issues

1. **Lambda Function Errors**
   ```bash
   # Check Lambda logs
   aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/list-videos"
   ```

2. **S3 Access Denied**
   - Verify bucket policy allows CloudFront OAI
   - Check IAM role permissions for Lambda

3. **API Gateway 500 Errors**
   - Check Lambda function logs
   - Verify API Gateway integration settings

4. **CloudFront Not Updating**
   - Invalidate CloudFront cache
   - Check S3 object permissions

### Debug Commands
```bash
# Check Terraform state
terraform show

# List S3 objects
aws s3 ls s3://$(terraform output -raw s3_bucket_name) --recursive

# Test API endpoint
curl -v https://your-api-gateway-url/prod/videos

# Check CloudFront distribution
aws cloudfront get-distribution --id $(terraform output -raw cloudfront_distribution_id)
```

## 🔮 Future Enhancements

### Potential Improvements
- **Authentication**: Add Cognito for user management
- **Video Processing**: Lambda functions for video transcoding
- **Database**: Add DynamoDB for video metadata
- **Analytics**: CloudWatch dashboards for usage metrics
- **Backup**: Automated S3 lifecycle policies
- **CDN**: Multi-region CloudFront distribution

### Advanced Features
- **Live Streaming**: Add MediaLive for live content
- **DRM**: Implement content protection
- **Multi-tenancy**: Support for multiple organizations
- **API Versioning**: Multiple API Gateway stages

## 📚 Resources

- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)
- [AWS CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)
- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [AWS WAF Documentation](https://docs.aws.amazon.com/waf/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

---

**Note**: This infrastructure is designed for educational and demonstration purposes. For production use, review security configurations, add proper monitoring, and implement backup strategies. 