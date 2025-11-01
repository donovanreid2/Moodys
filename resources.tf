locals {
  resource_types = {
    active_directory_domain_services = {
      name     = "active_directory_domain_services"
      alphanum = false
      global   = false
      abbr     = "adds"
    }
    api_management = {
      name     = "api_management"
      alphanum = false
      global   = false
      abbr     = "apim"
    }
    app_configuration = {
      name     = "app_configuration"
      alphanum = false
      global   = false
      abbr     = "appc"
    }
    app_service = {
      name     = "app_service"
      alphanum = false
      global   = false
      abbr     = "app"
    }
    app_service_certificates = {
      name     = "app_service_certificates"
      alphanum = false
      global   = false
      abbr     = "asc"
    }
    app_service_domain = {
      name     = "app_service_domain"
      alphanum = false
      global   = false
      abbr     = "apdr"
    }
    app_service_plan = {
      name     = "app_service_plan"
      alphanum = false
      global   = false
      abbr     = "asp"
    }
    application_gateway = {
      name     = "application_gateway"
      alphanum = false
      global   = false
      abbr     = "agw"
    }
    application_insights = {
      name     = "application_insights"
      alphanum = false
      global   = false
      abbr     = "ai"
    }
    application_registration = {
      name     = "application_registration"
      alphanum = false
      global   = false
      abbr     = "appreg"
    }
    application_security_group = {
      name     = "application_security_group"
      alphanum = false
      global   = false
      abbr     = "asg"
    }
    automation_account = {
      name     = "automation_account"
      alphanum = false
      global   = false
      abbr     = "aa"
    }
    automation_runbook = {
      name     = "automation_runbook"
      alphanum = false
      global   = false
      abbr     = "rb"
    }
    availability_set = {
      name     = "availability_set"
      alphanum = false
      global   = false
      abbr     = "as"
    }
    azure_file_sync = {
      name     = "azure_file_sync"
      alphanum = false
      global   = false
      abbr     = "afs"
    }
    azure_media_services_account = {
      name     = "azure_media_services_account"
      alphanum = true
      global   = true
      abbr     = "ams"
    }
    azuread_group = {
      name     = "azuread_group"
      alphanum = false
      global   = false
      abbr     = "azgrp"
    }
    backup_container_storage_account = {
      name     = "backup_container_storage_account"
      alphanum = false
      global   = false
      abbr     = "st"
    }
    backup_policy_vm = {
      name     = "backup_policy_vm"
      alphanum = false
      global   = false
      abbr     = "bpv"
    }
    bastion_host = {
      name     = "bastion_host"
      alphanum = false
      global   = false
      abbr     = "bas"
    }
    batch_account = {
      name     = "batch_account"
      alphanum = false
      global   = false
      abbr     = "ba"
    }
    cdn_endpoint = {
      name     = "cdn_endpoint"
      alphanum = false
      global   = false
      abbr     = "cdne"
    }
    cdn_profile = {
      name     = "cdn_profile"
      alphanum = false
      global   = false
      abbr     = "cdn"
    }
    container_instance = {
      name     = "container_instance"
      alphanum = false
      global   = false
      abbr     = "cnt"
    }
    container_registry = {
      name     = "container_registry"
      alphanum = true
      global   = false
      abbr     = "ci"
    }
    cosmosdb_account = {
      name     = "cosmosdb_account"
      alphanum = false
      global   = false
      abbr     = "cdb"
    }
    cosmosdb_sql_database = {
      name     = "cosmosdb_sql_database"
      alphanum = false
      global   = false
      abbr     = "cosmos"
    }
    data_factory = {
      name     = "data_factory"
      alphanum = false
      global   = false
      abbr     = "df"
    }
    data_factory_integration_runtime_managed = {
      name     = "data_factory_integration_runtime_managed"
      alphanum = false
      global   = false
      abbr     = "dfirm"
    }
    data_factory_linked_service_data_lake_storage_gen2 = {
      name     = "data_factory_linked_service_data_lake_storage_gen2"
      alphanum = true
      global   = true
      abbr     = "lsdlg2"
    }
    data_factory_linked_service_keyvault = {
      name     = "data_factory_linked_service_keyvault"
      alphanum = false
      global   = false
      abbr     = "lskv"
    }
    data_factory_linked_service_sql_database = {
      name     = "data_factory_linked_service_sql_database"
      alphanum = false
      global   = false
      abbr     = "lssqldb"
    }
    data_lake_analytics_account = {
      name     = "data_lake_analytics_account"
      alphanum = false
      global   = false
      abbr     = "adla"
    }
    data_lake_store = {
      name     = "data_lake_store"
      alphanum = true
      global   = false
      abbr     = "adl"
    }
    data_protection_backup_instance_blob_storage = {
      name     = "data_protection_backup_instance_blob_storage"
      alphanum = false
      global   = false
      abbr     = "bib"
    }
    data_protection_backup_policy_blob_storage = {
      name     = "data_protection_backup_policy_blob_storage"
      alphanum = false
      global   = false
      abbr     = "bpb"
    }
    data_protection_backup_vault = {
      name     = "data_protection_backup_vault"
      alphanum = false
      global   = false
      abbr     = "bv"
    }
    databricks_workspace = {
      name     = "databricks_workspace"
      alphanum = false
      global   = false
      abbr     = "adbr"
    }
    eventgrid = {
      name     = "eventgrid"
      alphanum = false
      global   = false
      abbr     = "evg"
    }
    eventhub = {
      name     = "eventhub"
      alphanum = false
      global   = false
      abbr     = "eh"
    }
    eventhub_consumer_group = {
      name     = "eventhub_consumer_group"
      alphanum = false
      global   = false
      abbr     = "ehcg"
    }
    eventhub_namespace = {
      name     = "eventhub_namespace"
      alphanum = false
      global   = false
      abbr     = "eh"
    }
    express_route_circuit = {
      name     = "express_route_circuit"
      alphanum = false
      global   = false
      abbr     = "erc"
    }
    express_route_gateway = {
      name     = "express_route_gateway"
      alphanum = false
      global   = false
      abbr     = "egw"
    }
    firewall = {
      name     = "firewall"
      alphanum = false
      global   = false
      abbr     = "afw"
    }
    frontdoor = {
      name     = "frontdoor"
      alphanum = false
      global   = false
      abbr     = "ftd"
    }
    function_app = {
      name     = "function_app"
      alphanum = false
      global   = false
      abbr     = "func"
    }
    key_vault = {
      name     = "key_vault"
      alphanum = true
      global   = false
      abbr     = "kv"
    }
    key_vault_access_policy = {
      name     = "key_vault_access_policy"
      alphanum = false
      global   = false
      abbr     = "kvap"
    }
    key_vault_certificate = {
      name     = "key_vault_certificate"
      alphanum = false
      global   = false
      abbr     = "kvcert"
    }
    key_vault_key = {
      name     = "key_vault_key"
      alphanum = false
      global   = false
      abbr     = "kvk"
    }
    key_vault_secret = {
      name     = "key_vault_secret"
      alphanum = false
      global   = false
      abbr     = "kvs"
    }
    kubernetes_cluster = {
      name     = "kubernetes_cluster"
      alphanum = false
      global   = false
      abbr     = "aks"
    }
    kusto_cluster = {
      name     = "kusto_cluster"
      alphanum = false
      global   = false
      abbr     = "kusto"
    }
    lb_backend_address_pool = {
      name     = "lb_backend_address_pool"
      alphanum = false
      global   = false
      abbr     = "lbp"
    }
    load_balancer = {
      name     = "load_balancer"
      alphanum = false
      global   = false
      abbr     = "lb"
    }
    load_balancer_virtual_ip = {
      name     = "load_balancer_virtual_ip"
      alphanum = false
      global   = false
      abbr     = "lbv"
    }
    log_analytics_linked_service = {
      name     = "log_analytics_linked_service"
      alphanum = false
      global   = false
      abbr     = "logls"
    }
    log_analytics_workspace = {
      name     = "log_analytics_workspace"
      alphanum = false
      global   = false
      abbr     = "log"
    }
    managed_disk = {
      name     = "managed_disk"
      alphanum = false
      global   = false
      abbr     = "disk"
    }
    managed_identity = {
      name     = "managed_identity"
      alphanum = false
      global   = false
      abbr     = "mid"
    }
    management_group = {
      name     = "management_group"
      alphanum = false
      global   = true
      abbr     = "mg"
    }
    mysql_database = {
      name     = "mysql_database"
      alphanum = false
      global   = false
      abbr     = "mysql"
    }
    mysql_server = {
      name     = "mysql_server"
      alphanum = false
      global   = false
      abbr     = "mysqls"
    }
    nat_gateway = {
      name     = "nat_gateway"
      alphanum = false
      global   = false
      abbr     = "natgw"
    }
    network_ddos_protection_plan = {
      name     = "network_ddos_protection_plan"
      alphanum = false
      global   = false
      abbr     = "ddp"
    }
    network_interface = {
      name     = "network_interface"
      alphanum = false
      global   = false
      abbr     = "nic"
    }
    network_security_group = {
      name     = "network_security_group"
      alphanum = false
      global   = false
      abbr     = "nsg"
    }
    network_security_rule = {
      name     = "network_security_rule"
      alphanum = false
      global   = false
      abbr     = "nsgr"
    }
    network_watcher = {
      name     = "network_watcher"
      alphanum = false
      global   = false
      abbr     = "nw"
    }
    network_watcher_flow_log = {
      name     = "network_watcher_flow_log"
      alphanum = false
      global   = false
      abbr     = "flow"
    }
    postgresql_server = {
      name     = "postgresql_server"
      alphanum = false
      global   = false
      abbr     = "psql"
    }
    postgresql_database = {
      name     = "postgresql_database"
      alphanum = false
      global   = false
      abbr     = "psqldb"
    }
    private_dns_a_record = {
      name     = "private_dns_a_record"
      alphanum = false
      global   = false
      abbr     = "pdnsar"
    }
    private_dns_resolver = {
      name     = "private_dns_resolver"
      alphanum = false
      global   = false
      abbr     = "pdnsr"
    }
    private_dns_resolver_forwarding_ruleset = {
      name     = "private_dns_resolver_forwarding_ruleset"
      alphanum = false
      global   = false
      abbr     = "ruleset"
    }
    private_dns_zone = {
      name     = "private_dns_zone"
      alphanum = false
      global   = false
      abbr     = "pdnsz"
    }
    private_endpoint = {
      name     = "private_endpoint"
      alphanum = false
      global   = false
      abbr     = "pe"
    }
    public_ip = {
      name     = "public_ip"
      alphanum = false
      global   = false
      abbr     = "pip"
    }
    public_ip_prefix = {
      name     = "public_ip_prefix"
      alphanum = false
      global   = false
      abbr     = "ippre"
    }
    purview_account = {
      name     = "purview_account"
      alphanum = false
      global   = false
      abbr     = "pur"
    }
    recovery_services_vault = {
      name     = "recovery_services_vault"
      alphanum = false
      global   = false
      abbr     = "rsv"
    }
    redis_cache = {
      name     = "redis_cache"
      alphanum = false
      global   = false
      abbr     = "arc"
    }
    redis_firewall_rule = {
      name     = "redis_firewall_rule"
      alphanum = false
      global   = false
      abbr     = "redisfwr"
    }
    redis_linked_server = {
      name     = "redis_linked_server"
      alphanum = false
      global   = false
      abbr     = "redisls"
    }
    resource_group = {
      name     = "resource_group"
      alphanum = false
      global   = false
      abbr     = "rg"
    }
    route_table = {
      name     = "route_table"
      alphanum = false
      global   = false
      abbr     = "udr"
    }
    service_fabric_cluster = {
      name     = "service_fabric_cluster"
      alphanum = false
      global   = false
      abbr     = "svfc"
    }
    service_principal = {
      name     = "service_principal"
      alphanum = false
      global   = false
      abbr     = "svp"
    }
    servicebus_namespace = {
      name     = "servicebus_namespace"
      alphanum = false
      global   = false
      abbr     = "sbn"
    }
    servicebus_queue = {
      name     = "servicebus_queue"
      alphanum = false
      global   = false
      abbr     = "sbq"
    }
    shared_image_gallery = {
      name     = "shared_image_gallery"
      alphanum = true
      global   = false
      abbr     = "sig"
    }
    signalr = {
      name     = "signalr"
      alphanum = false
      global   = false
      abbr     = "sr"
    }
    sql_data_warehouse = {
      name     = "sql_data_warehouse"
      alphanum = false
      global   = false
      abbr     = "sqdw"
    }
    sql_database = {
      name     = "sql_database"
      alphanum = false
      global   = false
      abbr     = "sqdb"
    }
    sql_managed_database = {
      name     = "SQL Managed Database"
      alphanum = false
      global   = false
      abbr     = "sqmdb"
    }
    sql_managed_instance = {
      name     = "sql_managed_instance"
      alphanum = false
      global   = false
      abbr     = "sqmi"
    }
    sql_server = {
      name     = "sql_server"
      alphanum = false
      global   = false
      abbr     = "sql"
    }
    storage_account = {
      name     = "storage_account"
      alphanum = true
      global   = true
      abbr     = "sa"
    }
    storage_account_network_rules = {
      name     = "storage_account_network_rules"
      alphanum = true
      global   = true
      abbr     = "sanr"
    }
    storage_blob = {
      name     = "storage_blob"
      alphanum = true
      global   = true
      abbr     = "sb"
    }
    storage_container = {
      name     = "storage_container"
      alphanum = true
      global   = true
      abbr     = "sc"
    }
    storage_management_policy = {
      name     = "storage_management_policy"
      alphanum = true
      global   = true
      abbr     = "samp"
    }
    subnet = {
      name     = "subnet"
      alphanum = false
      global   = false
      abbr     = "snet"
    }
    subscription = {
      name     = "subscription"
      alphanum = false
      global   = false
      abbr     = "sub"
    }
    synapse_firewall_rule = {
      name     = "synfw"
      alphanum = false
      global   = false
      abbr     = "synfw"
    }
    synapse_managed_private_endpoint = {
      name     = "synapse_managed_private_endpoint"
      alphanum = false
      global   = false
      abbr     = "synmpe"
    }
    synapse_spark_pool = {
      name     = "synapse_spark_pool"
      alphanum = false
      global   = false
      abbr     = "synspp"
    }
    synapse_sql_pool = {
      name     = "synapse_sql_pool"
      alphanum = false
      global   = false
      abbr     = "synsqlp"
    }
    synapse_workspace = {
      name     = "synapse_workspace"
      alphanum = false
      global   = false
      abbr     = "synw"
    }
    traffic_manager_profile = {
      name     = "traffic_manager_profile"
      alphanum = false
      global   = false
      abbr     = "tm"
    }
    user_assigned_identity = {
      name     = "user_assigned_identity"
      alphanum = false
      global   = false
      abbr     = "id"
    }
    virtual_hub = {
      name     = "virtual_hub"
      alphanum = false
      global   = false
      abbr     = "vhub"
    }
    virtual_machine = {
      name     = "virtual_machine"
      alphanum = false
      global   = false
      abbr     = "vm"
    }
    virtual_machine_scale_set = {
      name     = "virtual_machine_scale_set"
      alphanum = false
      global   = false
      abbr     = "ss"
    }
    virtual_network = {
      name     = "virtual_network"
      alphanum = false
      global   = false
      abbr     = "vnet"
    }
    virtual_wan = {
      name     = "virtual_wan"
      alphanum = false
      global   = false
      abbr     = "vwan"
    }
    vpn_gateway = {
      name     = "vpn_gateway"
      alphanum = false
      global   = false
      abbr     = "vpn"
    }
  }
}
