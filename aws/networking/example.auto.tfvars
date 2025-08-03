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

igw = {
  create = true
  vpc_id = null # Set to null if VPC is created in the same module
  # tags = {
  #   Name = "test-igw"
  # }
}

nacl = {}

sgs = {}

nat_gateways = {}

vpc_peerings = {}

transit_gateway = {}

vpn = {}

endpoints = {}

private_link = {}


route_tables = {
  public = {
    vpc_id = null # Set to null if VPC is created in the same module
    routes = [
      {
        destination_cidr_block = "0.0.0.0/0"
        igw                    = true
      }
    ]
    subnet_ref_keys = [
      "public-ap-south-1a",
      "public-ap-south-1b",
      "public-ap-south-1c"
    ]
    subnet_ids = []
  }

  private = {
    vpc_id = null # Set to null if VPC is created in the same module
    routes = []
    subnet_ref_keys = [
      "private-ap-south-1a",
      "private-ap-south-1b",
      "private-ap-south-1c"
    ]
    subnet_ids = []
  }

  db = {
    vpc_id = null # Set to null if VPC is created in the same module
    routes = []
    subnet_ref_keys = [
      "db-ap-south-1a",
      "db-ap-south-1b",
      "db-ap-south-1c"
    ]
    subnet_ids = []
  }
}