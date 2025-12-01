error:
 Error: creating Key: keyvault.BaseClient#CreateKey: Failure responding to request: StatusCode=400 -- Original Error: autorest/azure: Service returned an error. Status=400 Code="BadParameter" Message="Property  has invalid value\r\n"
│
│   with azurerm_key_vault_key.postgresql_encryption_key,
│   on kv_keys.tf line 171, in resource "azurerm_key_vault_key" "postgresql_encryption_key":
│  171: resource "azurerm_key_vault_key" "postgresql_encryption_key" {

code:

# Create encryption key for PostgreSQL in Key Vault  
resource "azurerm_key_vault_key" "postgresql_encryption_key" {
  name         = "postgresql-encryption-key"
  key_vault_id = azurerm_key_vault.regional_kv.id
  key_type     = "RSA"
  key_size     = 3072 # Standard size for PostgreSQL encryption

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey"
  ]

  rotation_policy {
    automatic {
      time_before_expiry = "P30D" # Rotate 30 days before expiry
    }

    expire_after         = "P365D" # 1 year expiry
    notify_before_expiry = "P45D"  # Notify 45 days before expiry
  }

  tags = merge(local.common_tags, {
    Purpose = "PostgreSQL encryption at rest"
  })

  depends_on = [
    azurerm_key_vault.regional_kv
  ]
}
