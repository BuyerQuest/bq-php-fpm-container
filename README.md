# BuyerQuest PHP-FPM

This is a custom php-fpm container with an opinionated set of modules and little or no facilities for runtime customization.

If you want to use it, create a volume with your PHP application rooted at `/var/www/html` and connect this container to something like nginx.

### Example
```bash
docker run \
  --rm \
  -p 9000:9000 \
  -v $PWD/html:/var/www/html \
  -v $PWD/logs:/var/log/php \
  buyerquest/php-fpm:latest
```
