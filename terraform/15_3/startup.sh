#!/bin/bash
# Скрипт для настройки веб-сервера при запуске ВМ

cat > /var/www/html/index.html <<HTML
<!DOCTYPE html>
<html>
<head>
    <title>Yandex Cloud Load Balancer Demo</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            text-align: center; 
            padding: 50px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        img { 
            max-width: 500px; 
            border-radius: 10px; 
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            margin: 20px;
        }
        .container {
            background: rgba(255,255,255,0.1);
            border-radius: 20px;
            padding: 30px;
            display: inline-block;
        }
        .server-info {
            margin-top: 20px;
            font-size: 14px;
            opacity: 0.8;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Добро пожаловать на мой сервер!</h1>
        <p>Эта картинка загружена из Yandex Object Storage:</p>
        <img src="http://${bucket_domain}/${image_key}" alt="Картинка из бакета">
        <div class="server-info">
            <p>Сервер работает в Yandex Cloud</p>
            <p>Host: \$(hostname)</p>
        </div>
    </div>
</body>
</html>
HTML

# Запускаем и настраиваем Apache
systemctl start httpd
systemctl enable httpd
