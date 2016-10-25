{% set minio = salt['pillar.get']('minio') %}


## User and group

minio_server_group:
  group.present:
    - name: minio
    - system: True

minio_server_user:
  user.present:
    - name: minio
    - system: True
    - home: /usr/share/minio/
    - createhome: True
    - groups:
      - minio


## General directories

{% for minio_server_dir in ['/usr/share/minio/bin', '/etc/default/minio', '/etc/minio'] %}
minio_server_directory_{{ minio_server_dir }}:
  file.directory:
    - name: {{ minio_server_dir }}
    - user: root
    - group: minio
    - mode: 770
{% endfor %}


## Minio server binary

minio_server_binary:
  file.managed:
    - name: /usr/share/minio/bin/minio
    - source: 'https://dl.minio.io/server/minio/release/linux-amd64/minio'
    - source_hash: 'md5={{ minio['config']['minio_binary_md5'] }}'
    - user: root
    - group: minio
    - mode: 750



## Setup multiple minio servers

{% for server in minio['servers'] %}
    {% set server_name = server['name'] %}

    ## Configuration directories and files

    {% for volume in server['volumes'] %}
        {% if ':' not in volume %}
minio_server_{{ server_name }}_volume-directory_{{ volume }}:
  file.directory:
    - name: {{ volume }}
    - user: minio
    - group: minio
    - mode: 770
    - makedirs: True
        {% endif %}
    {% endfor %}

minio_server_{{ server_name }}_directory_/etc/minio/{{ server_name }}:
  file.directory:
    - name: /etc/minio/{{ server_name }}
    - user: root
    - group: minio
    - mode: 770

minio_server_{{ server_name }}_config_/etc/default/minio/{{ server_name }}:
  file.managed:
    - name: /etc/default/minio/{{ server_name }}
    - user: root
    - group: minio
    - mode: 660
    - contents: |
        MINIO_ACCESS_KEY="{{ server['access_key'] }}"
        MINIO_SECRET_KEY="{{ server['secret_key'] }}"
        MINIO_CACHE_SIZE="{{ server['cache_size'] | default('8GB') }}"
        MINIO_CACHE_EXPIRY="{{ server['cache_expiry'] | default('72h') }}"
        MINIO_OPTS="--address {{ server['listen_address'] | default(':9000') }}"
        MINIO_VOLUMES="{{ server['volumes'] | join(' ') | default('/usr/share/minio/data') }}"

minio_server_{{ server_name }}_config_systemd:
  file.managed:
    - name: /etc/systemd/system/minio-{{ server_name }}.service
    - source: salt://minio/server/files/minio.service.jinja2
    - template: jinja
    - context:
        server: {{ server_name }}
    - user: root
    - group: root
    - mode: 644

minio_server_{{ server_name }}_config_systemd-enable:
  cmd.wait:
    - name: systemctl enable minio-{{ server_name }}.service
    - watch:
      - file: minio_server_{{ server_name }}_config_systemd


## Service

minio_server_{{ server_name }}_service:
  service.running:
    - name: minio-{{ server_name }}
    - enable: True
    - watch:
      - file: minio_server_{{ server_name }}_*

{% endfor %}
