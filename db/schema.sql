CREATE TABLE user (
    `user_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(32) NOT NULL,
    PRIMARY KEY (user_id),
    UNIQUE KEY (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE entry (
    `entry_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `diary_id` BIGINT UNSIGNED NOT NULL,
    `title` VARCHAR(255) NOT NULL,
    `body` TEXT NOT NULL,
    `created_date` TIMESTAMP NOT NULL,
    PRIMARY KEY (entry_id),
    KEY (diary_id, created_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE diary (
    `diary_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id` BIGINT UNSIGNED NOT NULL,
    `title` VARCHAR(255) NOT NULL,
    PRIMARY KEY (diary_id),
    KEY (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
