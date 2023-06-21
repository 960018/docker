<?php declare(strict_types = 1);

$prefix = '/var/www/html';
$dir = $_ENV['PRELOAD_DIR'] ?? (is_dir($short = $prefix . '/config') ? $short : (is_dir($long = $prefix . '/api/config') ? $long : null));

if (null !== $dir) {
    if ('prod' === ($_ENV['APP_ENV'] ?? null) && file_exists($path = $dir . '/var/cache/prod/App_KernelProdContainer.preload.php')) {
        opcache_compile_file($path);
    }
}
