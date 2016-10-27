## Setup minio user and group

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
