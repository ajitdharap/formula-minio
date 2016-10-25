{% set minio = salt['pillar.get']('minio') %}


## User and group

minio_group:
  group.present:
    - name: minio
    - system: True

minio_user:
  user.present:
    - name: minio
    - system: True
    - home: /usr/share/minio/
    - createhome: True
    - groups:
      - minio


## Configuration directories and files

{% for minio_dir in ['data', 'bin'] %}
minio_directory_/usr/share/minio/{{ minio_dir }}:
  file.directory:
    - name: /usr/share/minio/{{ minio_dir }}
    - user: minio
    - group: minio
    - mode: 770
{% endfor %}

minio_config_/etc/minio:
  file.directory:
    - name: /etc/minio
    - user: root
    - group: minio
    - mode: 660

minio_config_/etc/default/minio:
  file.managed:
    - name: /etc/default/minio
    - user: root
    - group: minio
    - mode: 660
    - contents: |
        MINIO_OPTS="--address {{ minio['listen_address'] | default(':9000') }}"
        MINIO_VOLUMES="{{ minio['volumes'] | default('/usr/share/minio/data') }}"
   
minio_config_systemd:
  file.managed:
    - name: /etc/systemd/system/minio.service
    - source: https://raw.githubusercontent.com/minio/minio/master/dist/linux-systemd/minio.service
    - source_hash: 'md5=6a36efbe8e8759b59feb5d2b8cc9da76'
    - user: root
    - group: root
    - mode: 644

minio_config_systemd_enable:
  cmd.wait:
    - name: systemctl enable minio.service
    - watch:
      - file: minio_config_systemd


## Binary

minio_binary:
  file.managed:
    - name: /usr/share/minio/bin/minio
    - source: 'https://dl.minio.io/server/minio/release/linux-amd64/minio'
    - source_hash: 'md5={{ minio_binary_md5 }}'
    - user: root
    - group: minio
    - mode: 750


## Service

minio_service:
  service.running:
    - name: minio
    - enable: True
