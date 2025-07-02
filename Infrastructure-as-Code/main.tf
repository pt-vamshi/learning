# Terraform AWS Serverless Media Streaming App (Minimal)

provider "aws" {
  region = "us-east-1"
}

# S3 bucket for static website hosting
resource "aws_s3_bucket" "media" {
  bucket = "media-streaming-app-bucket-${random_id.suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "media" {
  bucket = aws_s3_bucket.media.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

# S3 bucket policy to allow only CloudFront OAI
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for media streaming CloudFront"
}

resource "aws_s3_bucket_policy" "media_policy" {
  bucket = aws_s3_bucket.media.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.media.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
}

# CloudFront distribution for S3 (with OAI)
resource "aws_cloudfront_distribution" "media_cdn" {
  origin {
    domain_name = aws_s3_bucket.media.bucket_regional_domain_name
    origin_id   = "s3-media"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-media"
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  price_class = "PriceClass_100"
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# Lambda function for listing videos in S3
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_list_videos_exec" {
  name = "lambda_list_videos_exec_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_list_videos_s3" {
  role       = aws_iam_role.lambda_list_videos_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_lambda_function" "list_videos" {
  function_name = "list-videos"
  role          = aws_iam_role.lambda_list_videos_exec.arn
  handler       = "lambda_list_videos.handler"
  runtime       = "python3.11"
  filename      = "lambda_list_videos.zip"
  source_code_hash = filebase64sha256("lambda_list_videos.zip")
  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.media.bucket
      CLOUDFRONT_URL = "https://${aws_cloudfront_distribution.media_cdn.domain_name}"
    }
  }
}

# API Gateway for Lambda
resource "aws_api_gateway_rest_api" "media_api" {
  name        = "MediaStreamingAPI"
  description = "API Gateway for media streaming app"
}

resource "aws_api_gateway_resource" "videos" {
  rest_api_id = aws_api_gateway_rest_api.media_api.id
  parent_id   = aws_api_gateway_rest_api.media_api.root_resource_id
  path_part   = "videos"
}

resource "aws_api_gateway_method" "get_videos" {
  rest_api_id   = aws_api_gateway_rest_api.media_api.id
  resource_id   = aws_api_gateway_resource.videos.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_list_videos" {
  rest_api_id = aws_api_gateway_rest_api.media_api.id
  resource_id = aws_api_gateway_resource.videos.id
  http_method = aws_api_gateway_method.get_videos.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.list_videos.invoke_arn
}

resource "aws_lambda_permission" "apigw_list_videos" {
  statement_id  = "AllowAPIGatewayInvokeListVideos"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_videos.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.media_api.execution_arn}/*/*"
}
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.media.id
  key          = "index.html"
  source       = "${path.module}/index.html"
  content_type = "text/html"
}



resource "aws_api_gateway_deployment" "media_api" {
  rest_api_id = aws_api_gateway_rest_api.media_api.id
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.media_api.body))
  }
  depends_on = [
    aws_api_gateway_integration.lambda_list_videos
  ]
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.media_api.id
  rest_api_id   = aws_api_gateway_rest_api.media_api.id
  stage_name    = "prod"
}

resource "aws_wafv2_web_acl" "cloudfront_waf" {
  name        = "cloudfront-waf"
  description = "WAF for CloudFront distribution"
  scope       = "CLOUDFRONT"
  default_action {
    allow {}
  }
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "cloudfront-waf"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "cloudfront" {
  resource_arn = aws_cloudfront_distribution.media_cdn.arn
  web_acl_arn  = aws_wafv2_web_acl.cloudfront_waf.arn
} 