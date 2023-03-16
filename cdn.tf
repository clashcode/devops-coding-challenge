# Cloudfront CDN serving the load balancer from the ECS service

resource "aws_cloudfront_distribution" "cloudfront" {

  comment                        = "testapp"
  enabled                        = true
  http_version                   = "http2"

  default_cache_behavior {
    target_origin_id         = aws_lb.testapp.dns_name
    allowed_methods          = [ "DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT" ]
    cached_methods           = [ "GET", "HEAD" ]
    viewer_protocol_policy   = "redirect-to-https"

    forwarded_values {
      query_string            = true
      cookies {
        forward           = "all"
      }
    }
  }

  origin {
    domain_name         = aws_lb.testapp.dns_name
    origin_id           = aws_lb.testapp.dns_name
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "http-only"
      origin_ssl_protocols     = [ "TLSv1", "TLSv1.1", "TLSv1.2" ]
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

}
