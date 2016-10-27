## Mirror from a s3 server or directory to a s3 server or directory

include:
  - minio.client

{% set minio = salt['pillar.get']('minio') %}


{% for mirror in minio['mirror']['config'] %}

# Setup systemd services
'minio_client_mirror_config_systemd_minio-mirror-{{ mirror['name'] }}':
  file.managed:
    - name: /etc/systemd/system/minio-mirror-{{ mirror['name'] }}.service
    - source: salt://minio/client/files/minio-mirror.service.jinja2
    - template: jinja
    - context:
        source: {{ mirror['source'] }}
        target: {{ mirror['target'] }}
    - user: root
    - group: root
    - mode: 644

# Enable the service
'minio_client_mirror_service-enable_minio-mirror-{{ mirror['name'] }}':
  cmd.wait:
    - name: systemctl enable minio-mirror-{{ mirror['name'] }}.service
    - watch:
      - file: 'minio_client_mirror_config_systemd_minio-mirror-{{ mirror['name'] }}'

# Start / Restart the service
'minio_client_mirror_service_minio-mirror-{{ mirror['name'] }}':
  service.running:
    - name: minio-{{ mirror['name'] }}
    - enable: True
    - watch:
      - file: 'minio_client_mirror_config_systemd_minio-mirror-{{ mirror['name'] }}'


{% endif %}
