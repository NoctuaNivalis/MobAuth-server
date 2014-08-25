
First, set up nginx with rails. Follow
[this](http://jjachenpark.com/articles/2014/07/28/Run-Rails-Web-App-on-Nginx-with-Passenger.html]
guide from step 4 on. (Although you may want to install another database as in
step 3.)

Commands used:

    $ echo "gem 'passenger'" >> Gemfile
    $ bundle install
    $ rvmsudo passenger-install-nginx-module
    $ # if you had to install dependencies, just restart with the same command.
    $ # use defaults everywhere
    $ sudo ln -s /opt/nginx/sbin/nginx /usr/sbin/
    $ sudo vim /opt/nginx/conf/nginx.conf # write config
    $ sudo nginx

Our config difference with the example online:

    server {
        listen 80;
        server_name localhost;

        location / {
            root /path/to/rails/app/dir/MobAuth-server/public;
            passenger_enable on;
            rails_env development;
        }
    }

Next, set up nginx with https. Use step 2.1 and (part of, no p12) 3.1 on [this
site](http://users.skynet.be/pascalbotte/art/book1.htm) and step 3 should bere
followed [here](http://blog.55minutes.com/2013/09/seting-up-https-with-nginx).

    $ mkdir private
    $ openssl genrsa -des3 -out private/ca.key 4096
    $ mkdir public
    $ openssl req -new -x509 -key private/ca.key -out public/ca.crt -days 3600
    $ openssl genrsa -des3 -out private/server.key 4096
    $ openssl req -new -key private/server.key -out serser.csr
    $ # Common Name must be localhost
    $ openssl x509 -req -days 360 -in serser.csr -CA public/ca.crt -CAkey private/ca.key -CAcreateserial -out public/server.crt
    $ cat public/server.crt public/ca.crt > MobAuth.crt
    $ sudo mv MobAuth.crt /etc/ssl/
    $ sudo chmod 600 /etc/ssl/MobAuth.crt 
    $ sudo cp private/server.key /etc/ssl/MobAuth.key
    $ sudo chmod 600 /etc/ssl/MobAuth.key 
    $ sudo vim /opt/nginx/conf/nginx.conf

    server {
        listen       443 ssl;
        server_name  localhost;

        ssl_certificate      /etc/ssl/MobAuth.crt;
        ssl_certificate_key  /etc/ssl/MobAuth.key;

        ssl_session_cache    shared:SSL:1m;
        ssl_session_timeout  5m;

        ssl_ciphers  HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers  on;

        location / {
            root /path/to/rails/app/dir/MobAuth-server/public;
            passenger_enabled on;
            rails_env development;
        }
    }

    $ sudo nginx -s reload
