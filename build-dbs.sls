{% for databases, name in pillar['databases'].iteritems() %}
# the database
db_{{ name['dbname'] }}:
  mysql_database.present:
    - name: {{ name ['dbname'] }}
    - connection_user: root
    - connection_pass: {{ pillar['mysql_config']['admin_password'] }}
    - connection_charset: utf8
    - require: 
      - mysql_user: dbuser_{{ name['dbuser'] }}

# the db user
dbuser_{{ name['dbuser'] }}:
  mysql_user.present:
    - name: {{ name ['dbuser'] }}
    - host: '{{ name['remotehost'] }}'
    - password: "{{ name['dbpasswd'] }}"
    - connection_user: root
    - connection_pass: {{ pillar['mysql_config']['admin_password'] }}
    - connection_charset: utf8

# grants for the db user
grants_{{ name['dbuser'] }}:
  mysql_grants.present:
    - grant: all privileges
    - database: '{{ name['dbname'] }}.*'
    - user: {{ name['dbuser'] }}
    - host: '{{ name['remotehost'] }}'
    - connection_user: root
    - connection_pass: {{ pillar['mysql_config']['admin_password'] }}
    - connection_charset: utf8
    - require:
      - mysql_user: dbuser_{{ name['dbuser'] }}
      - mysql_database: db_{{ name['dbname'] }}
{% endfor %}
