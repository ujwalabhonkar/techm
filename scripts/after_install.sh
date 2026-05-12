#!/bin/bash

set +e  # <-- IMPORTANT: do NOT exit on metadata failure

# Request IMDSv2 token
TOKEN=$(curl -s -o /dev/null -w "%{http_code}" -X PUT \
  "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

if [ "$TOKEN" != "200" ]; then
  echo "IMDSv2 token request failed, using empty values"
  EC2_INSTANCE_ID="unknown-instance"
  EC2_AZ="unknown-az"
else
  TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

  EC2_INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
    http://169.254.169.254/latest/meta-data/instance-id)

  EC2_AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
    http://169.254.169.254/latest/meta-data/placement/availability-zone)
fi

sed -i "s/was deployed/was deployed on $EC2_INSTANCE_ID in $EC2_AZ/g" /var/www/html/index.html
chmod 664 /var/www/html/index.html