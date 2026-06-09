# Бакет для статического сайта
resource "yandex_storage_bucket" "static_site" {
  bucket = "static-site-${substr(var.bucket_name, -10, -1)}"
  acl    = "public-read"
  
  access_key = yandex_iam_service_account_static_access_key.storage_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.storage_key.secret_key
  
  # Настройка для статического сайта
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

# Загружаем index.html
resource "yandex_storage_object" "index_html" {
  access_key = yandex_iam_service_account_static_access_key.storage_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.storage_key.secret_key
  bucket     = yandex_storage_bucket.static_site.bucket
  key        = "index.html"
  content    = <<-HTML
<!DOCTYPE html>
<html>
<head>
    <title>Защищенный сайт</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
        h1 { color: #667eea; }
        .secure { color: green; font-weight: bold; }
        img { max-width: 500px; border-radius: 10px; margin: 20px; }
    </style>
</head>
<body>
    <h1>Сайт с шифрованием</h1>
    <p class="secure">Бакет зашифрован с помощью KMS ключа</p>
    <p>Картинка загружена из зашифрованного бакета:</p>
    <img src="http://${var.bucket_name}.storage.yandexcloud.net/my-image.jpg" alt="Картинка">
    <p><small>Шифрование Server-Side Encryption (SSE-KMS)</small></p>
</body>
</html>
HTML
  content_type = "text/html"
}

# Загружаем error.html
resource "yandex_storage_object" "error_html" {
  access_key = yandex_iam_service_account_static_access_key.storage_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.storage_key.secret_key
  bucket     = yandex_storage_bucket.static_site.bucket
  key        = "error.html"
  content    = "<html><body><h1>404 - Страница не найдена</h1></body></html>"
  content_type = "text/html"
}

# Копируем картинку в бакет сайта
resource "yandex_storage_object" "site_image" {
  access_key = yandex_iam_service_account_static_access_key.storage_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.storage_key.secret_key
  bucket     = yandex_storage_bucket.static_site.bucket
  key        = "my-image.jpg"
  source     = "${path.module}/image.jpg"
  content_type = "image/jpeg"
}

# Вывод URL сайта
output "static_site_url" {
  value = "http://${yandex_storage_bucket.static_site.website_endpoint}"
  description = "URL статического сайта"
}
