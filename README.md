
## Prerequisites:

* CentOS 7
* SELinux disabled
* `yum install -y httpd`
* `systemctl start httpd`

## Installation:

```
cp -p upload_image.pl   /var/www/cgi-bin/
chmod +x                /var/www/cgi-bin/upload_image.pl
cp -p upload_image.html /var/www/html/
mkdir                   /var/www/html/upload_images
chown root:apache       /var/www/html/upload_images
chmod 775               /var/www/html/upload_images
```

## Configuration settings:

* UPLOAD_DIR
* UPLOAD_URL
* Allowed_extensions
* Allowed_mimetypes

## Parts of target filename:

* Timestamp in YYYY-MM-DD-HHMMSS format
* Process id
* Original extension
* `__meta__` suffix for additional file containing POST form headers
