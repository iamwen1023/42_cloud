mysql -u $SQL_USER -p$SQL_PASSWORD -e "INSERT INTO "test.wp_posts" (post_author, post_content, post_title, post_excerpt, to_ping, pinged, post_content_filtered) VALUES(1, 'new', 'new', 'new', 'y', 'y','y');"

mysql -u $SQL_USER -p$SQL_PASSWORD -e "INSERT INTO "test.wp_posts" (post_author, post_content, post_title, post_excerpt, to_ping, pinged, post_content_filtered) VALUES(2, 'new32', 'new22', 'new22', 'y', 'y','y');"
select Host, User from mysql.user;
wordpress connect mariadb syntax: -u -p --host=mariadb