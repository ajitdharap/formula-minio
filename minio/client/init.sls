{% set minio = salt['pillar.get']('minio') %}
{% from 'minio/versions.yaml' import minio_versions %}


# Take care of installing the version specified in the pillar files
{% set client_base_url = minio_versions['client']['base_url'] %}
{% set client_version = minio['config']['mc_version'] %}
{% set client_binary_md5 = minio_versions['client']['versions'][client_version] %}

minio_server_binary:
  file.managed:
    # I named this minio-mc as mc belongs to midnight commander
    - name: /usr/local/bin/minio-mc
    - name: /usr/share/minio/bin/minio
    - source: '{{ client_base_url }}{{ client_version }}'
    - source_hash: 'md5={{ client_binary_md5 }}'
    - user: root
    - group: minio
    - mode: 750

# Manage the config file containing credentials
minio_client_config_directory:
  file.directory:
    - name: /usr/share/minio/.mc
    - user: minio
    - group: minio
    - mode: 700

minio_client_config:
  file.managed:
    - name: /usr/share/minio/.mc/config.json
    - source: salt://minio/client/files/config.json.jinja2
    - template: jinja
    - context:
        servers: {{ minio['servers'] }}
        additional_credentials: {{ minio['mirror']['additional_credentials'] | default({})  }}
    - user: minio
    - group: minio
    - mode: 600
