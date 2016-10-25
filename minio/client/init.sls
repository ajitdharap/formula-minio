{% set minio = salt['pillar.get']('minio') %}


minio_client_binary:
  file.managed:
    # I named this minio-mc as mc belongs to midnight commander
    - name: /usr/local/bin/minio-mc
    - source: https://dl.minio.io/client/mc/release/linux-amd64/mc
    - source_hash: 'md5={{ minio['config']['mc_binary_md5'] }}'
    - user: root
    - group: root
    - mode: 755


minio_client_config:
  file.managed:
    - name: /root/.mc/config.json
    - source: salt://minio/client/files/config.json.jinja2
    - context:
        servers: {{ minio['servers'] }}
    - template: jinja
    - user: root
    - group: root
    - mode: 600
