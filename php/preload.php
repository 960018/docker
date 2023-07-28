<?php declare(strict_types = 1);

function bool(mixed $value): bool
{
    if (is_bool($value)) {
        return $value;
    }

    return filter_var(strtolower((string) $value), FILTER_VALIDATE_BOOL);
}

if (bool($_ENV['ENABLE_PRELOAD'] ?? true)) {
    $prefix = '/var/www/html';
    $dir = $_ENV['PRELOAD_DIR'] ?? (is_dir($short = $prefix . '/config') ? $short : (is_dir($long = $prefix . '/api/config') ? $long : null));

    if (null !== $dir) {
        if ('prod' === ($_ENV['APP_ENV'] ?? null) && file_exists($path = $dir . '/var/cache/prod/App_KernelProdContainer.preload.php')) {
            opcache_compile_file($path);
        }
    }
}
