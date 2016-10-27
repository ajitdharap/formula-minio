# Minio saltstack pillar file
minio:


  # General formula configuration
  config:
    # Pin the installations to specific versions of packages
    # You can just specify the version here. md5 hashes for the files (saltstacks file.managed needs that)
    # and the versions available and tested with this formula can be found in /srv/salt/minio/versions.yaml
    # If you want to test a newer version, just add it in /srv/salt/minio/versions.yaml and change the versions here.
    # Note that you can state "latest", but you will have to update the hash all the time. We think pinning versions
    # here is better, as we can keep the formula updated with versions that were working in our vagrant dev setups
    # and that passed our saltstack test environments.
    # Please omit the minio. and mc. at the beginning of the versions
    server_version: 'RELEASE.2016-10-24T21-23-47Z'
    mc_version:  'RELEASE.2016-10-07T01-56-22Z'


  # Using this, multiple systemd daemonized `minio-mc mirror -w` will be setup on the targeted machine. Using this,
  # you can make backups or setup master slave mirror: https://docs.minio.io/docs/minio-client-complete-guide#mirror
  mirror:
    config:
        # The name has to be filename suitable and the service will be called like: systemctl start minio-mirror-{ name }.service
        # NOTE: If you specify local directories, this formula DOES NOT create them! Create them and make them writable to the minio user
      - name: 'play-to-s3'
        source: 'play/test1'
        target: 'play/test2'

    # If you want to replicate to / from an AWS S3 bucket, specify additional credentials here, they will be put in /root/.mc/config.json
    additional_credentials:
      play:
        url: 'https://play.minio.io:9000'
        secret_key: 'zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG'
        access_key: 'Q3AM3UQ867SPQQA43P2F'
        api: 'S3v4'


  # Minio server configuration
  servers:

    # Define multiple servers
    # https://github.com/krishnasrinivas/minio/blob/c9d5586e1bd59f820528d547e833c138dcf52254/docs/multi-tenancy-in-minio-1.md
    # This will create multiple systemd scripts, use `systemctl restart { name }.service`

      # The name of your minio server
    - name: develop

      # On what address and port to listen
      listen_address: '0.0.0.0:9002'

      # Access and secret key for this server instance
      # Access key string of 5 to 20 characters in length
      access_key: 'NR3rBJkmKw1'
      # Secret key string of 8 to 40 characters in length
      secret_key: 'xTMp07fy6xiUtACubVAW754oTJYHd1gPhY'

      # This has defaults, usually no need to modify or state this at all
      cache_size: 8GB
      cache_expiry: 72h

      # This is only required for minio.client to setup ~/.mc/config.json
      url: 'http://127.0.0.1:9002'

      # Minio server implements four modes of operation that are determined by the given volumes
      #
      # (1) Regular FS backend - single local node
      # $ minio server /path
      #
      # (2) Multiple FS backend - single local node
      # $ minio server /path1 /path2 /path3 /path4 ...
      #
      # (3) Cluster - multiple Nodes using minio dsync
      # $ minio server http://access_key:secret_key@host:9000/path http://access_key2:secret_key2@host2:9000/path ...
      #
      # (4) Proxy mode - one or multiple Nodes proxied
      # $ minio server https://play.minio.io:9000:/mnt/disk ...
      #
      # NOTE:
      # - You can NOT MIX local and remote volumes! You can run a single node or join a multi master cluster
      # - If a ":" is detected in any of the volume names, saltstack will not create a directory for the list item (as its remote)
      # - You can specify one OR four to 16 volumes. Two or three wont work. Use multiple disks for this to make sense with local deployment.
      #   https://github.com/minio/minio/tree/master/docs/erasure
      # - Make the volume directories are mounted (this formula does not take care of that, it will only create and chown the directories)
      # - If you have multpile hosts, you HAVE to specify the same access credentials for all of them - This way, you can use round-robin
      #   DNS or reverse proxy load balancer across those hosts and applications can use the same KEYS to access.
      # - Minio will detect if an IP or hostname given as volume is locally bound to a network interface - if so, it will start that
      #   volume locally and have it join the cluster. 
      volumes:
        # One local filesystem volume - single node
        - '/usr/share/minio/volumes/data'
       

    - name: staging
      listen_address: '0.0.0.0:9003'
      url: 'http://127.0.0.1:9003'
      access_key: 'k291sdczs'
      secret_key: '6kaskjw8598sgjsv0q'
      volumes:
        # Multiple local disks
        - '/usr/share/minio/volumes/staging/disk1'
        - '/usr/share/minio/volumes/staging/disk2'
        - '/usr/share/minio/volumes/staging/disk3'
        - '/usr/share/minio/volumes/staging/disk4'


    - name: production
      listen_address: '0.0.0.0:9004'
      url: 'http://127.0.0.1:9004'
      access_key: 'ILJX17QKYKB'
      secret_key: '60hL6VIfmE0HRWB21jCsN3gM7hzziF'
      volumes:
          # Note that when you use hostnames and you deploy to AWS EC2 for example, the hostname might not resolve to an IP locally bound
          # This way minio will not start a local FS volume but try to talk to itself and expect a volume - this wont work. It is therefore
          # Important that if you specify "s3-one.example.com" as hostname, that "s3-one.example.com" is set to a local IP in /etc/hosts!
          # This formula does not take care of that. In a normal setup, this should be done after installation already. We recommend to use
          # the hostnames that { grains['id'] } would return.
        - 'http://access_key_one:secret_key_one@s3-one.example.com:9000/srv'
        - 'http://access_key_two:secret_key_two@s3-two.example.com:9000/srv'
        - 'http://access_key_three:secret_key_three@s3-three.example.com:9000/srv'



