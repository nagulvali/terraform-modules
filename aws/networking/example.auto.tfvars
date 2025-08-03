region = "ap-south-1"
tags = {
  Env = "test"
}
vpc = {
  create                               = true
  cidr_block                           = "10.1.0.0/16"
  instance_tenancy                     = "default"
  enable_dns_support                   = true
  enable_dns_hostnames                 = true
  ipv4_ipam_pool_id                    = null
  ipv4_netmask_length                  = null
  enable_network_address_usage_metrics = false
  tags = {
    Name = "test-vpc"
  }
}

subnets = {
  create = true
  vpc_id = null # Set to null if VPC is created in the same module

  subnet_configs = {
    # Public Subnets
    public-ap-south-1a = {
      cidr_block              = "10.1.0.0/24"
      availability_zone       = "ap-south-1a"
      map_public_ip_on_launch = true
      tags = {
        Name = "public-ap-south-1a"
        Tier = "public"
      }
    }

    public-ap-south-1b = {
      cidr_block              = "10.1.1.0/24"
      availability_zone       = "ap-south-1b"
      map_public_ip_on_launch = true
      tags = {
        Name = "public-ap-south-1b"
        Tier = "public"
      }
    }

    public-ap-south-1c = {
      cidr_block              = "10.1.2.0/24"
      availability_zone       = "ap-south-1c"
      map_public_ip_on_launch = true
      tags = {
        Name = "public-ap-south-1c"
        Tier = "public"
      }
    }

    # Private App Subnets
    private-ap-south-1a = {
      cidr_block              = "10.1.10.0/24"
      availability_zone       = "ap-south-1a"
      map_public_ip_on_launch = false
      tags = {
        Name = "private-ap-south-1a"
        Tier = "private"
      }
    }

    private-ap-south-1b = {
      cidr_block              = "10.1.11.0/24"
      availability_zone       = "ap-south-1b"
      map_public_ip_on_launch = false
      tags = {
        Name = "private-ap-south-1b"
        Tier = "private"
      }
    }

    private-ap-south-1c = {
      cidr_block              = "10.1.12.0/24"
      availability_zone       = "ap-south-1c"
      map_public_ip_on_launch = false
      tags = {
        Name = "private-ap-south-1c"
        Tier = "private"
      }
    }

    # Database Subnets (no internet access)
    db-ap-south-1a = {
      cidr_block              = "10.1.20.0/24"
      availability_zone       = "ap-south-1a"
      map_public_ip_on_launch = false
      tags = {
        Name = "db-ap-south-1a"
        Tier = "database"
      }
    }

    db-ap-south-1b = {
      cidr_block              = "10.1.21.0/24"
      availability_zone       = "ap-south-1b"
      map_public_ip_on_launch = false
      tags = {
        Name = "db-ap-south-1b"
        Tier = "database"
      }
    }

    db-ap-south-1c = {
      cidr_block              = "10.1.22.0/24"
      availability_zone       = "ap-south-1c"
      map_public_ip_on_launch = false
      tags = {
        Name = "db-ap-south-1c"
        Tier = "database"
      }
    }
  }
}

igw = {
  create = true
  vpc_id = null # Set to null if VPC is created in the same module
  # tags = {
  #   Name = "test-igw"
  # }
}


route_tables = {
  create = true
  vpc_id = null # Set to null if VPC is created in the same module
  tables = [
    {
      name = "public"
      routes = [
        {
          cidr_block = "0.0.0.0/0"
        }
      ]
    }
  ]
  }
}