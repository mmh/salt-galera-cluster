## Salt formula for setting up a HA Galera Cluster using MariaDB 10.1 and 2 small Haproxy/Keepalived frontends

Tested on Debian 8 (Jessie)

### Start up 5 servers. Assign roles using grains like this. The environment makes it possible to use the formula for several clusters.
```shell
salt <haproxy node> grains.setval roles ['haproxy']
salt <db1> grains.setval roles ['db_bootstrap']
salt <other dbs> grains.setval roles ['db']
salt <all servers> grains.setval environment 'production'
```

### Set up a pillar like this and add it to the servers. Set new passwords, a keepalived IP and the databases you need.
```
interfaces:
    private: eth0
    public: eth0
mine_functions:
    network.ip_addrs: [eth0]
    network.interfaces: []
mine_interval: 1
cfg_files:
    debian_cluster:
        path: /etc/mysql/conf.d/cluster.cnf
        source: salt://galera-cluster/files/cluster.cnf
    debian_maintenance:
        path: /etc/mysql/debian.cnf
        source: salt://galera-cluster/files/debian.cnf
    utf8-default:
        path: /etc/mysql/conf.d/utf8-default.cnf
        source: salt://galera-cluster/files/utf8-default.cnf
haproxy:
    stats_password: haproxystatspassword
keepalived:
    ip: 192.168.1.100
mysql_config:
    maintenance_password: rootpassword
    admin_password: randompassword
    haproxy_ip: 192.168.1.%
databases:
    database1:
        dbname: databasename
        dbuser: username
        dbpasswd: xxxx
        remotehost: "192.168.1.%"
```

### Create an orchestration file, the example in /orchestration can be used if the correct environment is set. Then run

```shell
salt-run state.orch galera-cluster.orchestration.prod test=true
```

Based on the great work of [rcbops](https://github.com/rcbops/galera)

