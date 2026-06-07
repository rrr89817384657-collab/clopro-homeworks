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

# Создание бакета
resource "yandex_storage_bucket" "images" {
  bucket     = var.bucket_name
  access_key = yandex_iam_service_account_static_access_key.storage_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.storage_key.secret_key
  
  # Делаем бакет публичным
  anonymous_access_flags {
    read = true
    list = false
  }
}

# Загружаем картинку в бакет
resource "yandex_storage_object" "picture" {
  access_key = yandex_iam_service_account_static_access_key.storage_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.storage_key.secret_key
  bucket     = yandex_storage_bucket.images.bucket
  key        = "my-image.jpg"
  source     = "${path.module}/image.jpg"
  
  depends_on = [yandex_storage_bucket.images]
}

# Даем сервисному аккаунту права на создание ВМ
resource "yandex_resourcemanager_folder_iam_member" "compute_editor" {
  folder_id = var.folder_id
  role      = "compute.editor"
  member    = "serviceAccount:${yandex_iam_service_account.storage_sa.id}"
}

# Даем сервисному аккаунту права на работу с сетью
resource "yandex_resourcemanager_folder_iam_member" "vpc_user" {
  folder_id = var.folder_id
  role      = "vpc.user"
  member    = "serviceAccount:${yandex_iam_service_account.storage_sa.id}"
}

# Даем сервисному аккаунту полный доступ к папке
resource "yandex_resourcemanager_folder_iam_member" "full_editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.storage_sa.id}"
}
