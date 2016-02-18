haproxy:
  salt.state:
    - tgt: 'G@roles:haproxy and G@environment:production'
    - tgt_type: compound
    - sls:
      - galera-cluster.haproxy
      - galera-cluster.keepalived
setup:
  salt.state:
    - tgt: '( G@roles:db or G@roles:db_bootstrap ) and G@environment:production'
    - tgt_type: compound
    - sls:
      - galera-cluster
dbs-stop:
  salt.state:
    - tgt: '( G@roles:db or G@roles:db_bootstrap ) and G@environment:production'
    - tgt_type: compound
    - sls:
      - galera-cluster.stop-mysql
    - require:
      - salt: setup
bootstrap-start:
  salt.state:
    - tgt: 'G@roles:db_bootstrap and G@environment:production'
    - tgt_type: compound
    - sls:
      - galera-cluster.start-mysql
    - require:
      - salt: dbs-stop
non-bootstrap-start:
  salt.state:
    - tgt: 'G@roles:db and G@environment:production'
    - tgt_type: compound
    - sls:
      - galera-cluster.start-mysql
    - require:
      - salt: bootstrap-start
build-dbs:
  salt.state:
    - tgt: 'G@roles:db_bootstrap and G@environment:production'
    - tgt_type: compound
    - sls:
      - galera-cluster.build-dbs
    - require:
      - salt: non-bootstrap-start
