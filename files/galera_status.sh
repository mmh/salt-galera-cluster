#!/bin/sh
#mysql -u root -e 'show status like "wsrep_%";'
mysql -u root -e "SHOW GLOBAL STATUS WHERE Variable_name IN ('wsrep_ready', 'wsrep_cluster_size', 'wsrep_cluster_status', 'wsrep_connected', 'wsrep_local_state_comment', 'wsrep_incoming_addresses')"
