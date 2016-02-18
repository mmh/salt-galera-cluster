{% set admin_password = pillar['mysql_config']['admin_password'] %}
{% set haproxy_ip = pillar['mysql_config']['haproxy_ip'] %}

# MariaDB Repo
mariadb-repo:
  pkgrepo.managed:
    - comments:
      - '# MariaDB 10.1 Debian repository list - managed by salt {{ grains['saltversion'] }}'
    - name: deb [arch=i386,amd64] http://mirror.one.com/mariadb/repo/10.1/debian jessie main
    - dist: jessie
    - file: /etc/apt/sources.list.d/mariadb.list
    - key_url: salt://galera-cluster/files/repo.mariadb.ubuntu.com.key
    - require_in:
      - pkg: mariadb-pkgs

# Favor the MariaDB repo over the Debian one 
/etc/apt/preferences.d/MariaDB.pref:
  file.managed:
    - source: salt://galera-cluster/files/MariaDB.pref
    - group: root
    - mode: 644
    - template: jinja

# need to get the mariadb repos version of mysql-common
mysql-common:
  pkg.latest:
    - only_upgrade: True

libmysqlclient18:
  pkg:
    - installed

rsync:
  pkg.installed

python-mysqldb:
  pkg.installed

apt_update: 
  cmd.run: 
    - name: apt-get update
    - require: 
      - pkgrepo: mariadb-repo 

# Pre-seed MariaDB install prompts
mariadb-debconf: 
  debconf.set:
    - name: mariadb-galera-server
    - data:
        'mysql-server/root_password': {'type':'string','value':{{ admin_password }}}
        'mysql-server/root_password_again': {'type':'string','value':{{ admin_password }}}
    - require:
      - pkg: debconf-utils
      - file: /etc/apt/preferences.d/MariaDB.pref

mariadb-pkgs:
  pkg.installed:
    - names:
      - mariadb-server-10.1
    - require:
      - pkgrepo: mariadb-repo
      - debconf: mariadb-debconf
      - cmd: apt_update

{% for cfgfile, info in pillar['cfg_files'].iteritems() %}
{{ info['path'] }}:
  file.managed:
    - source: {{ info['source'] }}
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - pkg: mariadb-pkgs
{% endfor %}

ensure_running:
  service: 
    - name: mysql
    - running
    - require: 
      - pkg: mariadb-pkgs

mysql_update_maint:
  cmd.run:
    - name: mysql -u root -p{{ admin_password }} -e "GRANT ALL PRIVILEGES ON *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY '{{ pillar['mysql_config']['maintenance_password'] }}';"
    - require:
      - pkg: mariadb-pkgs
      - service: ensure_running

mysql_update_haproxy:
  cmd.run:
    - name: mysql -u root -p{{ admin_password }} mysql -e "INSERT INTO user (Host,User) values ('{{ haproxy_ip }}','haproxy');" || echo true
    - require:
      - pkg: mariadb-pkgs
      - service: ensure_running

socat:
  pkg.installed

netcat:
  pkg.installed

python-software-properties: 
  pkg: 
    - installed

debconf-utils:
  pkg:
    - installed

debconf:
  pkg: 
    - installed

/root/galera_status.sh:
  file.managed:
    - mode: 750
    - source: salt://galera-cluster/files/galera_status.sh

/root/.my.cnf:
  file.managed:
    - mode: 700
    - source: salt://galera-cluster/files/root-my.cnf
    - template: jinja

