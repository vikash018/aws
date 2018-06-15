#!bin/bash
yum update -y
yum install httpd -y
service httpd start
chkconfig httpd on
aws s3 cp s3://test4-mywebsitebucket/index.html /var/www/html


#!bin/bash
yum update -y
yum install httpd python35 git -y
service httpd start
chkconfig httpd on
cd /var/www/html
git clone https://github.com/vikash018/aws/s3

scp -i /Users/vikashkumarsingh/SSH/MyEC2KeyPair.pem *.py ec2-user@54.146.175.77:~

cp -p /usr/local/bin/pip* /usr/bin/