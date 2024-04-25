<?php declare(strict_types = 1);

function bool(mixed $value): bool
{
    if (is_bool($value)) {
        return $value;
    }

    return filter_var(strtolower((string) $value), FILTER_VALIDATE_BOOL);
}

if (bool($_ENV['ENABLE_PRELOAD'] ?? true)) {
    if (null === ($_ENV['PRELOAD_FILE'] ?? null)) {
        $prefix = '/var/www/html';
        $path = '/var/cache/prod/';
        $filename = 'App_KernelProdContainer.preload.php';
        $dir = $_ENV['PRELOAD_DIR'] ?? (is_dir($short = $prefix . $path) ? $short : (is_dir($long = $prefix . '/api' . $path) ? $long : null));

        if (null !== $dir) {
            if ('prod' === ($_ENV['APP_ENV'] ?? null) && file_exists($dir . $path)) {
                opcache_compile_file($dir . $path);
            }
        }
    } else {
        opcache_compile_file($_ENV['PRELOAD_FILE']);
    }
}
