output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_cidr_block" {
  value = aws_vpc.this.cidr_block
}

output "subnet_ids" {
  value = {
    public  = [for s in aws_subnet.public : s.id]
    private = [for s in aws_subnet.private : s.id]
  }
}
