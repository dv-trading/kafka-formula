{%- from 'zookeeper/settings.sls' import zk with context %}

include:
  - kafka

kafka-systemd-unit:
  file.managed:
    - name: /lib/systemd/system/kafka.service
    - source: salt://kafka/files/kafka.service.systemd

kafka-config:
  file.managed:
    - name: /etc/kafka/server.properties
    - source: salt://kafka/files/server.properties
    - template: jinja
    - context:
      zookeepers: {{ zk.connection_string }}
    - require:
      - pkg: confluent-kafka-2.11

kafka-environment:
  file.managed:
    - name: /etc/default/kafka
    - source: salt://kafka/files/kafka.default
    - template: jinja

kafka-service:
  service.running:
    - name: kafka
    - enable: True
    - require:
      - pkg: confluent-kafka-2.11
      - file: kafka-config
      - file: kafka-environment
      - file: kafka-systemd-unit
