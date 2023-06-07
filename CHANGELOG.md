# Changelog

All notable changes to this project will be documented in this file.

## 0.0.1

First release consisted of:

- RDS Custom for Oracle primary instance using a precreated Custom Engine Version (CEV)
- (optional) RDS Custom for Oracle replica instance(s) from the primary
- (optional) IAM Role and Instance Profile for the primary and replicas
- (optional) DBSubnet Group for the primary and replicas
- (optional) Security Group for the VPC endpoints, allowing the primary and replica instance(s) to communicate with dependent AWS services
- (optional) VPC endpoints, which are rquired for primary and replica instance(s) to communicate with dependent AWS services: 
