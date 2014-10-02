----------------------------Server (Ruby on Rails with Nginx)

---------Git, npm, ruby on rails

$ sudo apt-get install git

$ git clone http://github.com/FelixVanderJeugt/MobAuth-Server.git

$ sudo apt-get install curl

$ sudo apt-get install npm

$ \curl -sSL https://get.rvm.io | bash -s stable --ruby --rails
(duurt héél lang)

$ sudo apt-get install bundler 

$ bundle install

(you will have to close and open the terminal again for the next step because he won't recognize rvmsudo yet)

---------Nginx

$ rvmsudo passenger-install-nginx-module

(select Ruby)
(if you had to install any dependencies, just install them like asked and restart with the command used as above.)
(pick Yes: download, compile and install Nginx for me. (recommended))
(use defaults everywhere)

$ sudo ln -s /opt/nginx/sbin/nginx /usr/sbin/

edit config with vim, can be done by gedit/nano too

$ sudo vim /opt/nginx/conf/nginx.conf 

(for the following step we used the information on this link: http://jiachengpark.com/articles/2014/07/28/Run-Rails-Web-App-on-Nginx-with-Passenger.html )

Replace:
	server {
		listen       80;
		server_name  localhost;

		#charset koi8-r;

		#access_log  logs/host.access.log  main;

		location / {
		    root   html;
		    index  index.html index.htm;
		}
With:
	server {
		listen 8080;
		server_name localhost;
		
		location / {
root /path/to/rails/app/dir/MobAuth-server/public; #e.g. /home/Documents/MobAuth-Server
			passenger_enabled on;
			rails_env development;
		}
	}

(sudo nginx -t can be used to check if the syntax is alright)

Before you start the server do this to prevent pendingMigrationError

$ rake db:migrate

to start server: 

$ rails s 

and if there are other problems, using the following might help

$ bundle exec rails s

IMPORTANT: the following error could happen further on any of the coming steps involving opening the website at http://localhost:8080 or https://localhost
“Web application could not be started  ...  could not find rake-10.3.2 in any of the sources(Bundler::GemNotFound)” 

then try 

$ bundle install --path vendor/cache

and then try again to connect to the server, should be fixed now

to start the server

$ sudo nginx

(after editing the config file you can use sudo nginx -s reload to reload)

(sudo nginx -s stop will stop the server)

Now you should be able to reach the application through  localhost:3000(RoR) and localhost:8080 (nginx)

To set up https we based our way of working on the following links
- Use step 2.1 (part of, no p12) 3.1 on http://users.skynet.be/pascalbotte/art/book1.htm
- and step 3 should be replaced by http://blog.55minutes.com/2013/09/setting-up-https-with-nginx
These steps are summed up:

(self signed way first, after that with the given files by Jan)
$ openssl genrsa -des3 -out private/ca.key 4096
$ openssl req -new -x509 -key private/ca.key -out public/ca.crt -days 3600
$ openssl genrsa -des3 -out private/server.key 4096
$ openssl req -new -key private/server.key -out server.csr
$ # common name must be localhost
$ openssl x509 -req -days 3600 -in server.csr -CA public/ca.crt -CAkey private/ca.key -CAcreateserial -out public/server.crt
$ cat public/server.crt public/ca.crt > MobAuth.crt
$ sudo mv MobAuth.crt /etc/ssl/
$ sudo chmod 600 /etc/ssl/MobAuth.crt
$ sudo cp private/server.key /etc/ssl/MobAuth.key
$ sudo chmod 600 /etc/ssl/MobAuth.key

(with the files provided by Jan)
in firefox Fedict-IAM-INT-RootCA.crt importeren bij authorities (enablen voor servers)
Fedict-IAM-INT-MobileAuthAppPOCCA.crt.pem importeren bij authorities (enablen voor servers)
Fedict-IAM-INT-MobileAuthAppPOCCA.key.pem in map private zetten
Fedict-IAM-INT-MobileAuthAppPOCCA.crt.pem in map public zetten
$ openssl genrsa -des3 -out private/server.key 4096
$ openssl req -new -key private/server.key -out server.csr
$ openssl x509 -req -days 365 -in server.csr -CA public/Fedict-IAM-INT-MobileAuthAppPOCCA.crt.pem -CAkey private/Fedict-IAM-INT-MobileAuthAppPOCCA.key.pem -CAcreateserial -out public/server.crt
$ cat public/server.crt public/ca.crt > MobAuth.crt
$ sudo mv MobAuth.crt /etc/ssl/
$ sudo chmod 600 /etc/ssl/MobAuth.crt
$ sudo cp private/server.key /etc/ssl/MobAuth.key
$ sudo chmod 600 /etc/ssl/MobAuth.key

edit config with vim, can be done by gedit/nano too

$ sudo vim /opt/nginx/conf/nginx.conf

(at the end of the file there will be a HTTPS server in comment, just comment it out and make sure everything summed up below is in it)

server {
	listen	443 ssl;
	server_name localhost;

	ssl_certificate		/etc/ssl/MobAuth.crt;
	ssl_certificate_key	/etc/ssl/MobAuth.key;
	
	ssl_session_cache	shared:SSL:1m;
	ssl_session_timeout	5m;
	
	ssl_ciphers		HIGH:!aNULL:!MD5;
	ssl_prefer_server_ciphers on;
	
	location / {
		proxy_pass http://localhost:8080;
		passenger_enabled on;
		rails_env development;
	}
}

$ sudo nginx -s reload; 

(it might be needed to stop the nginx server and start it up again)

----------------------------Cordova

This installation can give a lot of issues, I personally had a lot of troubles (did 3 installations, 2 worked and one did not). Some stackoverflow posts suggest that the source of the problem is the following command

$ sudo npm install -g cordova

And that the sudo should not be used. The following links show how you can do it without sudo if you’re unable to. The last two installs I’m 100% sure I did with the sudo and one worked and the other didn’t. (“worked” after messing around a lot) 

http://cordova.apache.org/docs/en/3.5.0/guide_cli_index.md.html
http://justjs.com/posts/npm-link-developing-your-own-npm-modules-without-tears

If cordova is not recognized after installing(e.g. $ cordova), adjusting some paths might help:
adjusting the paths using $ nano ~/.bashrc  and copy pasting the following statements at the bottom of the file and then using $ source ~/.bashrc :

$ export PATH="$PATH:$HOME/.npm/"
$ export PATH="$PATH:/usr/local/lib/node_modules/cordova/bin"
$ export PATH="$PATH:/usr/local/share/npm/bin"

If adjusting the paths doesn’t work you’ll need to reinstall node.js

download the source code on the website

$ tar vxzf the-tar-gz-file-from-nodejs.tar.gz
$ cd the-tar-gz-file-extracted-to-folder
$ ./configure
$ make
(this will take a while)
$ sudo make install

reinstall cordova

$ sudo npm install -g cordova

Then it should work (try $ cordova)

---------Android
Download SDK-tools for Android (you can also download the ADT (android development tools bundle) but then you will have to reference to the sdk in that ADT folder): http://developer.android.com/sdk/installing/index.html 

Put the unzipped tar.gz (unzip via $ tar vxzf sdk-tools-file.tar.gz) where you want it
then we need to add the path to this new directory to our PATH, this can/will give lots of problems

$ export ANDROID_TOOLS="/path/to/androidsdk/tools/"
$ export ANDROID_PLATFORM_TOOLS="/path/to/androidsdk/platform-tools/"
$ export ANDROID_HOME="/path/to/androidsdk"
$ export PATH="$PATH:$ANDROID_HOME:$ANDROID_TOOLS:$ANDROID_PLATFORM_TOOLS"

in case you are working with the ADT you will probably have to do /androidsdk/sdk/tools instead of androidsdk/tools for example

(because of this PATH adjusting you will now be able to run "android "command)

$ sudo apt-get install openjdk-7-jdk

find where jdk is (/usr/lib/jvm/??/ probably)

$ export JAVA_HOME="/path/to/jdk/"

$ export PATH="$PATH:$JAVA_HOME"

if you can so $ android and it launches a GUI (android SDK manager) then it should be okay.

$ sudo apt-get install ant

use $ which ant to see where ant was installed

$ export ANT_HOME="/path/to/ant"
$ export PATH="$PATH:$ANT_HOME/bin"

$ android

this wil give you a GUI, select the following
Android SDK Build-Tools 19
Android 4.4.2 (API 19)

click on Install .. packages

Go to the git repository you cloned. (MobAuth-server)

$ cd mobile

(you need to be in this folder or it’s subfolders to use cordova)

$ cordova platform add android
(adds android, works the same for ios and different platforms cordova supports)

this should work, after this you can test the application in your browser (until a certain point as plugins only work on real devices): in the directory mobile there is a file index.html, open this with your browser.

To create the .apk file (that can be installed)

$ sudo cordova build android

To solve a listing android devices problem or errors, either some path variables might be wrong or
you need to 
delete all the plugins (org.apache....)
delete android.json
run install.sh that you can find in /plugins/

OR

sudo rm -rf plugins
sudo rm -rf platforms
cordova platform add android
cordova plugin install [plugin_here] (manually do all plugins or try git checkout plugins/install.sh and then run bash install.sh)
cordova build
cordova build android


it could happen that building works but the app doesn't work, this happened to work


To get the apk to your device
From normal pc: $ cordova run android
From virtual box: You will need VMware tools installed and then use shared folders to copy the apk to a shared folder
(preferably Dropbox so you can download the file from dropbox, but you can also transmit it from the chosen folder through cable to your device)

----------------------------Client authentication voor nginx

Find the following in the nginx conf file

server {
	listen  443 ssl;
	server_name  localhost;

	ssl_certificate      /etc/ssl/MobAuth.crt;
      	 ssl_certificate_key  /etc/ssl/MobAuth.key;
	...

Add:

	ssl_client_certificate /etc/ssl/verification.pem;
        	ssl_verify_client optional; 
        	ssl_verify_depth 3;

verification.pem is the chain of certificates from root to signing certificate of the user client certificates. In our case you make it by doing:

(intermediate.crt contains the intermediate certificate that is created by the root ca and that is used to sign client certificates) 

$ cp public/intermediate.crt public/verification.pem
$ cat Fedict-IAM-INT-MobileAuthAppPOCCA.crt.pem >> verification.pem
$ cat Fedict-IAM-INT-RootCA.crt >> verification.pem

To have the CN of the client certificate in the ruby on rails server, http headers can be used:

In

location / {
	proxy_pass http://localhost:8080;
}

add

proxy_set_header ClientSslCn $ssl_client_s_dn;

----------------------------generating the p12 in terminal (including password)

openssl pkcs12 -passout pass:test -export -out louisva.p12 -inkey nameofkey.key.pem -in nameofcertificate.crt.pem 



