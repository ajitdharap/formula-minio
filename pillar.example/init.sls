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
      # Minio server implements three modes of operation:
      #
      # Regular FS backend - single node
      # $ minio server /path
      #
      # Minimum of 4 and up to 16 maximum local disks - single node
      # $ minio server /path1 /path2 /path3 /path4 ...
      #
      # Using minio dsync: https://github.com/minio/dsync up to 16 distributed master master n-master nodes
      # $ minio server http://access_key:secret_key@host:9000/path http://access_key2:secret_key2@host2:9000/path ...
      #
      # You can NOT MIX local and remote volumes! You can run a single node or join a multi master cluster.
      #
      # If a ":" is detected, saltstack will not create a directory for the list item.
      volumes:
        # One local filesystem volume - single node
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



    - name: staging
      listen_address: '0.0.0.0:9003'
      url: 'http://127.0.0.1:9003'
      access_key: 'k291sdczs'
      secret_key: '6kaskjw8598sgjsv0q'
      volumes:
        - '/usr/share/minio/volumes/staging/disk1'
        - '/usr/share/minio/volumes/staging/disk2'
        - '/usr/share/minio/volumes/staging/disk3'
        - '/usr/share/minio/volumes/staging/disk4'

if you have 8 hosts, it is better to pass those same keys as ENV variable for all the 8 hosts.
This way, you can use round-robin DNS or reverse proxy load balancer across those hosts.
Applications can use the same KEYS to access.

after 16 drives performance problems:
Minio limits max of 16 drives per tenant. This limit is derived from operational experience.

8 servers each 2 drives:
minio servrer http://192.168.1.11:/media/myvol1 http://192.168.1.11:/media/myvol2 ... http://192.168.1.18:/media/myvol1 http://192.168.1.18:/media/myvol2


# If you use cluster you have to start the exact same config on all servers!


minio server https://play.minio.io:9000:/mnt/disk" starts a server on 9000 on localhost that proxies play




    - name: production
      listen_address: '0.0.0.0:9004'
      url: 'http://127.0.0.1:9004'
      access_key: 'ILJX17QKYKB'
      secret_key: '60hL6VIfmE0HRWB21jCsN3gM7hzziF'
      volumes:
          # Minio will detect if an IP is locally bound to any interface - if so, it will start that volume locally and have it join the cluster
          # TODO salt has to take care that s3-one.example.com for example is in /etc/hosts so minio will detect it as local
          # This way you can have the exact same config on all hosts

        - 'http://access_key_one:secret_key_one@s3-one.example.com:9000/srv'
        - 'http://access_key_two:secret_key_two@s3-two.example.com:9000/srv'
        - 'http://access_key_three:secret_key_three@s3-three.example.com:9000/srv'

