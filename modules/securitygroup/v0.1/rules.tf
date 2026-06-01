variable "rules" {
  description = "Map of known security group rules (define as 'name' = ['from port', 'to port', 'protocol', 'description'])"
  type        = map(list(any))
  default = {
    https-443 = [443, 443, "tcp", "HTTPS"]
    tcp-80  = [80, 80, "tcp", "HTTP"]
    high-ports =[1024, 65535, "tcp", "high ports for application"]
    all = [-1,-1,-1,""]
    ssh-22 = [22,22,"tcp","ssh"]
  }
}
