keepalived:
  pkg:
    - installed
    - file: /etc/keepalived/keepalived.conf
  service:
    - running
    - require:
      - pkg: keepalived
    - watch:
      - file: /etc/keepalived/keepalived.conf

/etc/keepalived/keepalived.conf:
  file.managed:
    - source: salt://galera-cluster/files/keepalived.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        priority: 101

/etc/sysctl.d/ip_bind.conf:
  file.managed:
    - source: salt://keepalived/sl/master/ip_bind.conf
    - user: root
    - group: root
    - mode: 644

