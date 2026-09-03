region = "ap-south-1"

tags = {
  Env       = "test"
  ManagedBy = "terraform"
}

# ==============================================================================
# VPCs - Multiple VPCs supported, use key to reference in downstream resources
# ==============================================================================
vpcs = {
  main = {
    cidr_block                           = "10.1.0.0/16"
    instance_tenancy                     = "default"
    enable_dns_support                   = true
    enable_dns_hostnames                 = true
    enable_network_address_usage_metrics = false
    tags = {
      Purpose = "primary-workloads"
    }
  }

  shared-services = {
    cidr_block           = "10.2.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = {
      Purpose = "shared-services"
    }
  }
}

# ==============================================================================
# Subnets - Use vpc_ref_key to reference VPC by key
# ==============================================================================
subnets = {
  # Main VPC - Public Subnets
  main-public-1a = {
    vpc_ref_key             = "main"
    cidr_block              = "10.1.0.0/24"
    availability_zone       = "ap-south-1a"
    map_public_ip_on_launch = true
    tags = {
      Tier = "public"
    }
  }

  main-public-1b = {
    vpc_ref_key             = "main"
    cidr_block              = "10.1.1.0/24"
    availability_zone       = "ap-south-1b"
    map_public_ip_on_launch = true
    tags = {
      Tier = "public"
    }
  }

  main-public-1c = {
    vpc_ref_key             = "main"
    cidr_block              = "10.1.2.0/24"
    availability_zone       = "ap-south-1c"
    map_public_ip_on_launch = true
    tags = {
      Tier = "public"
    }
  }

  # Main VPC - Private App Subnets
  main-private-1a = {
    vpc_ref_key       = "main"
    cidr_block        = "10.1.10.0/24"
    availability_zone = "ap-south-1a"
    tags = {
      Tier = "private"
    }
  }

  main-private-1b = {
    vpc_ref_key       = "main"
    cidr_block        = "10.1.11.0/24"
    availability_zone = "ap-south-1b"
    tags = {
      Tier = "private"
    }
  }

  main-private-1c = {
    vpc_ref_key       = "main"
    cidr_block        = "10.1.12.0/24"
    availability_zone = "ap-south-1c"
    tags = {
      Tier = "private"
    }
  }

  # Main VPC - Database Subnets
  main-db-1a = {
    vpc_ref_key       = "main"
    cidr_block        = "10.1.20.0/24"
    availability_zone = "ap-south-1a"
    tags = {
      Tier = "database"
    }
  }

  main-db-1b = {
    vpc_ref_key       = "main"
    cidr_block        = "10.1.21.0/24"
    availability_zone = "ap-south-1b"
    tags = {
      Tier = "database"
    }
  }

  main-db-1c = {
    vpc_ref_key       = "main"
    cidr_block        = "10.1.22.0/24"
    availability_zone = "ap-south-1c"
    tags = {
      Tier = "database"
    }
  }

  # Shared Services VPC - Subnets
  shared-private-1a = {
    vpc_ref_key       = "shared-services"
    cidr_block        = "10.2.0.0/24"
    availability_zone = "ap-south-1a"
    tags = {
      Tier = "private"
    }
  }

  shared-private-1b = {
    vpc_ref_key       = "shared-services"
    cidr_block        = "10.2.1.0/24"
    availability_zone = "ap-south-1b"
    tags = {
      Tier = "private"
    }
  }
}

# ==============================================================================
# Internet Gateways - Use vpc_ref_key to reference VPC by key
# ==============================================================================
internet_gateways = {
  main-igw = {
    vpc_ref_key = "main"
    tags = {
      Purpose = "internet-access"
    }
  }
}

# ==============================================================================
# Elastic IPs - For NAT Gateways
# ==============================================================================
elastic_ips = {
  nat-eip-1a = {
    tags = {
      Purpose = "nat-gateway"
    }
  }

  nat-eip-1b = {
    tags = {
      Purpose = "nat-gateway"
    }
  }
}

# ==============================================================================
# NAT Gateways - Use subnet_ref_key and eip_ref_key to reference by key
# ==============================================================================
nat_gateways = {
  main-nat-1a = {
    subnet_ref_key = "main-public-1a"
    eip_ref_key    = "nat-eip-1a"
    tags = {
      AZ = "ap-south-1a"
    }
  }

  main-nat-1b = {
    subnet_ref_key = "main-public-1b"
    eip_ref_key    = "nat-eip-1b"
    tags = {
      AZ = "ap-south-1b"
    }
  }
}

# ==============================================================================
# Route Tables - Use vpc_ref_key, igw_ref_key, nat_gateway_ref_key, subnet_ref_key
# ==============================================================================
route_tables = {
  main-public = {
    vpc_ref_key = "main"
    routes = [
      {
        destination_cidr_block = "0.0.0.0/0"
        igw_ref_key            = "main-igw"
      }
    ]
    subnet_associations = [
      { subnet_ref_key = "main-public-1a" },
      { subnet_ref_key = "main-public-1b" },
      { subnet_ref_key = "main-public-1c" }
    ]
    tags = {
      Tier = "public"
    }
  }

  main-private-1a = {
    vpc_ref_key = "main"
    routes = [
      {
        destination_cidr_block = "0.0.0.0/0"
        nat_gateway_ref_key    = "main-nat-1a"
      }
    ]
    subnet_associations = [
      { subnet_ref_key = "main-private-1a" },
      { subnet_ref_key = "main-db-1a" }
    ]
    tags = {
      Tier = "private"
      AZ   = "ap-south-1a"
    }
  }

  main-private-1b = {
    vpc_ref_key = "main"
    routes = [
      {
        destination_cidr_block = "0.0.0.0/0"
        nat_gateway_ref_key    = "main-nat-1b"
      }
    ]
    subnet_associations = [
      { subnet_ref_key = "main-private-1b" },
      { subnet_ref_key = "main-db-1b" }
    ]
    tags = {
      Tier = "private"
      AZ   = "ap-south-1b"
    }
  }

  main-private-1c = {
    vpc_ref_key = "main"
    routes = [
      {
        destination_cidr_block = "0.0.0.0/0"
        nat_gateway_ref_key    = "main-nat-1a"
      }
    ]
    subnet_associations = [
      { subnet_ref_key = "main-private-1c" },
      { subnet_ref_key = "main-db-1c" }
    ]
    tags = {
      Tier = "private"
      AZ   = "ap-south-1c"
    }
  }

  shared-private = {
    vpc_ref_key = "shared-services"
    routes      = []
    subnet_associations = [
      { subnet_ref_key = "shared-private-1a" },
      { subnet_ref_key = "shared-private-1b" }
    ]
    tags = {
      Tier = "private"
    }
  }
}

# ==============================================================================
# VPC Endpoints - Use vpc_ref_key, subnet_ref_keys, route_table_ref_keys
# ==============================================================================
vpc_endpoints = {
  main-s3 = {
    vpc_ref_key       = "main"
    service_name      = "com.amazonaws.ap-south-1.s3"
    vpc_endpoint_type = "Gateway"
    route_table_ref_keys = [
      "main-public",
      "main-private-1a",
      "main-private-1b",
      "main-private-1c"
    ]
    tags = {
      Service = "s3"
    }
  }

  main-dynamodb = {
    vpc_ref_key       = "main"
    service_name      = "com.amazonaws.ap-south-1.dynamodb"
    vpc_endpoint_type = "Gateway"
    route_table_ref_keys = [
      "main-private-1a",
      "main-private-1b",
      "main-private-1c"
    ]
    tags = {
      Service = "dynamodb"
    }
  }

  # Example Interface endpoint (requires security groups in practice)
  # main-ssm = {
  #   vpc_ref_key         = "main"
  #   service_name        = "com.amazonaws.ap-south-1.ssm"
  #   vpc_endpoint_type   = "Interface"
  #   private_dns_enabled = true
  #   subnet_ref_keys = [
  #     "main-private-1a",
  #     "main-private-1b",
  #     "main-private-1c"
  #   ]
  #   security_group_ids = ["sg-xxxxxxxx"]
  #   tags = {
  #     Service = "ssm"
  #   }
  # }
}
