# docker-php

Custom PHP builds

## php-fpm pool (fpm-alpine, PHP 8.2 and later)

The pool is read from these environment variables when php-fpm starts, so
they can be set on the container without rebuilding the image:

| Variable                | Default | php-fpm setting        |
|-------------------------|---------|------------------------|
| `FPM_MAX_CHILDREN`      | 300     | `pm.max_children`      |
| `FPM_START_SERVERS`     | 50      | `pm.start_servers`     |
| `FPM_MIN_SPARE_SERVERS` | 20      | `pm.min_spare_servers` |
| `FPM_MAX_SPARE_SERVERS` | 50      | `pm.max_spare_servers` |
| `FPM_MAX_REQUESTS`      | 10000   | `pm.max_requests`      |
| `FPM_PROCESS_MAX`       | 512     | `process.max`          |

php-fpm refuses to start when `FPM_START_SERVERS`, `FPM_MIN_SPARE_SERVERS`
or `FPM_MAX_SPARE_SERVERS` is greater than `FPM_MAX_CHILDREN`, so lower them
together. php-fpm reads `/usr/local/etc/php-fpm.d/*.conf` in alphabetical
order and the last value of a key wins: a pool file of your own that sorts
after `www.conf` (such as `zzz-pool.conf`) overrides these variables, one
that sorts before it is overridden by them.
