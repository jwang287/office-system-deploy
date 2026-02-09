<?php
/**
 * Nextcloud 自定义配置
 * 针对装修公司办公场景优化
 */

$CONFIG = array (
  // 内存缓存
  'memcache.local' => '\OC\Memcache\Redis',
  'memcache.locking' => '\OC\Memcache\Redis',
  'redis' => array(
    'host' => 'redis',
    'port' => 6379,
  ),

  // 文件版本控制
  'versions_retention_obligation' => 'auto, 10',
  'file_storage.save_version_author' => true,

  // 大文件上传
  'max_filesize_animated_gifs_public_sharing' => 10,

  // 分享设置
  'sharing.enable_share_mail' => true,
  'sharing.allow_group_sharing' => true,
  'sharing.enable_link_password_by_default' => true,
  'sharing.min_search_string_length' => 2,

  // 日志
  'logtimezone' => 'Asia/Shanghai',
  'logfile' => '/var/log/nextcloud/nextcloud.log',
  'loglevel' => 2,
  'log_rotate_size' => 104857600,

  // 安全
  'auth.bruteforce.protection.enabled' => true,
  'auth.bruteforce.attempts' => 5,
  'auth.bruteforce.delay' => 600,
  'password_policy.min_length' => 8,
  'password_policy.enforce_non_common_password' => true,
  'password_policy.enforce_numeric_characters' => true,
  'password_policy.enforce_special_characters' => true,
  'password_policy.enforce_upper_and_lower_case' => true,

  // 预览设置
  'enabledPreviewProviders' => array(
    'OC\Preview\PNG',
    'OC\Preview\JPEG',
    'OC\Preview\GIF',
    'OC\Preview\HEIC',
    'OC\Preview\BMP',
    'OC\Preview\XBitmap',
    'OC\Preview\MP3',
    'OC\Preview\TXT',
    'OC\Preview\MarkDown',
    'OC\Preview\PDF',
    'OC\Preview\MSOfficeDoc',
    'OC\Preview\MSOffice2003',
    'OC\Preview\MSOffice2007',
    'OC\Preview\OpenDocument',
    'OC\Preview\Movie',
    'OC\Preview\Krita',
  ),
  'preview_max_x' => 2048,
  'preview_max_y' => 2048,
  'preview_max_filesize_image' => 50,

  // 默认语言
  'default_language' => 'zh_CN',
  'default_locale' => 'zh_CN',
  'force_locale' => 'zh_CN',

  // 邮件通知（可选配置）
  // 'mail_smtpmode' => 'smtp',
  // 'mail_smtpsecure' => 'ssl',
  // 'mail_sendmailmode' => 'smtp',

  // 性能优化
  'maintenance_window_start' => 2,
  'activity_expire_days' => 365,
  'trashbin_retention_obligation' => 'auto, 30',
  'files_external_allow_create_new_local' => false,
);
