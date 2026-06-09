# Сервисный аккаунт для работы с Object Storage
resource "yandex_iam_service_account" "storage_sa" {
  name      = "storage-service-account"
  folder_id = var.folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "storage_editor" {
  folder_id = var.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.storage_sa.id}"
}

# Статический ключ для доступа к Object Storage
resource "yandex_iam_service_account_static_access_key" "storage_key" {
  service_account_id = yandex_iam_service_account.storage_sa.id
  description        = "Static access key for object storage"
}

# Создаем KMS ключ для шифрования бакета
resource "yandex_kms_symmetric_key" "bucket_key" {
  name              = "bucket-encryption-key"
  description       = "Key for bucket encryption"
  default_algorithm = "AES_256"
  rotation_period   = "8760h"
}

# Создание бакета с шифрованием
resource "yandex_storage_bucket" "images" {
  bucket     = var.bucket_name
  access_key = yandex_iam_service_account_static_access_key.storage_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.storage_key.secret_key
  acl        = "public-read"
  
  anonymous_access_flags {
    read = true
    list = false
  }
  
  # Шифрование с помощью KMS ключа
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.bucket_key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

# Загружаем картинку в бакет
resource "yandex_storage_object" "picture" {
  access_key = yandex_iam_service_account_static_access_key.storage_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.storage_key.secret_key
  bucket     = yandex_storage_bucket.images.bucket
  key        = "my-image.jpg"
  source     = "${path.module}/image.jpg"
  acl        = "public-read"
  depends_on = [yandex_storage_bucket.images]
}

# Вывод ID ключа KMS
output "kms_key_id" {
  value = yandex_kms_symmetric_key.bucket_key.id
  description = "ID of KMS key for bucket encryption"
}

output "bucket_url" {
  value = "http://${yandex_storage_bucket.images.bucket_domain_name}/my-image.jpg"
  description = "URL картинки в Object Storage"
}

# Даем сервисному аккаунту права admin на storage
resource "yandex_resourcemanager_folder_iam_member" "storage_admin" {
  folder_id = var.folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.storage_sa.id}"
}

# Даем сервисному аккаунту полный доступ
resource "yandex_resourcemanager_folder_iam_member" "full_editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.storage_sa.id}"
}
