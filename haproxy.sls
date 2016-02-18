include:
  - galera-cluster.mysql

haproxy-pkg:
  pkg.installed:
    - pkgs:
      - haproxy

/etc/haproxy/haproxy.cfg:
  file.managed:
    - source: salt://galera-cluster/files/haproxy/haproxy.cfg
    - template: jinja
    - makedirs: True

haproxy-service:
  service:
    - name: haproxy
    - running
    - enable: True
    - require:
      - pkg: haproxy-pkg
    - watch:
      - file: /etc/haproxy/haproxy.cfg
