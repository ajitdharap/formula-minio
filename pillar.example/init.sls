minio:

  config:
    # md5 for https://dl.minio.io/server/minio/release/linux-amd64/minio
    minio_binary_md5: '49fd5f7a46c46d11bff64ad87d328d47'
    # md5 for https://dl.minio.io/client/mc/release/linux-amd64/mc
    mc_binary_md5: '6f7ecc23dba7f99703316a5afd3ff9d5'


  servers:

    # Define multiple servers
    # https://github.com/krishnasrinivas/minio/blob/c9d5586e1bd59f820528d547e833c138dcf52254/docs/multi-tenancy-in-minio-1.md
    # This will create multiple systemd scripts, use `systemctl restart { name }.service`

      # The name of your minio server
    - name: develop

      # On what address and port to listen
      listen_address: '0.0.0.0:9002'

      # You can specify one OR for to 16 volumes. Two or three wont work. Use multiple disks.
      # https://github.com/minio/minio/tree/master/docs/erasure
      # Make sure those are mounted (this formula does not take care of that, it will only create and chown the directories)
      #
      # NOTE: Using dsync https://github.com/minio/dsync minio server implements three modes of operation:
      # minio server <dir>                       (regular FS backend)
      # minio server <di1r>... <dirN>            ( N = 16 maximum) (Single node XL backend)
      # minio server ip1:<dir1> .... ipN:<dirN>  (N = 16 maximum) (Distributed XL backend)
      # You can mix the volumes local and remote as you like. Including remotes will create master master read/write lock replication.
      # If a ":" is detected, saltstack will not create a directory for the list item.
      volumes:
        - '/usr/share/minio/volumes/data'

      # Access and secret key for this server instance
      # Access key string of 5 to 20 characters in length
      access_key: 'NR3rBJkmKw1'
      # Secret key string of 8 to 40 characters in length
      secret_key: 'xTMp07fy6xiUtACubVAW754oTJYHd1gPhY'

      # Has defaults, usually no need to modify or state this at all
      cache_size: 8GB
      cache_expiry: 72h

      # This is only required for minio.client to setup ~/.mc/config.json
      url: 'http://127.0.0.1:9002'



    - name: production
      listen_address: '0.0.0.0:9005'
      url: 'http://127.0.0.1:9005'
      access_key: 'ILJX17QKYKB'
      secret_key: '60hL6VIfmE0HRWB21jCsN3gM7hzziF'
      volumes:
        - '/usr/share/minio/volumes/production/disk1'
        - '/usr/share/minio/volumes/production/disk2'
        - '/usr/share/minio/volumes/production/disk3'
        - '/usr/share/minio/volumes/production/disk4'

