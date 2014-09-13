var NewUserView = function(service) {
	
	this.initialize = function() {
		this.$el = $('<div/>');
        this.renderChoiceScreen();
        this.$el.on('click',"#normalCode", jQuery.proxy(function (e) {
            $("#load_gif").show();
        	e.preventDefault();
        	var code = $('#normalCodeInput').val();
        	this.addUser(code);
        }, this));
	}

	    // add new user
    this.addUser = function(code) { //TODO write to correct directory (works for android atm but ios? it has no/files)
        var i = 0;
        /* Configuration constants */
        var privateKeyFile = ".key.pem";
        var certificateFile = ".crt.pem";
        var keySize = 1024;
        var split = code.split(/ +/);
        var wizard_token = split[1];
        var ipstr = atob(split[0]);
        var ip = [];
        for(i = 0; i < ipstr.length; i++) ip.push(String(ipstr.charCodeAt(i)));
        var uri = "http://" + ip.join('.') + ":3000/certificates";
            // TODO change this to https without port on finale.
        var server = encodeURI(uri);

        /* Just some useful variables */
        var that = this;
        var opts = { create: true, exclusive: false };
    	var certificate = null;
    	var username = null;

        /* Generating keys and certificate request
         * Documentation: https://github.com/digitalbazaar/forge
         * The server should fill in the certificate details. */
        var keypair = forge.pki.rsa.generateKeyPair({ bits: keySize });
        var privPem = forge.pki.privateKeyToPem(keypair.privateKey);

        /* Write a file in the given directory. */
        var writeStringToFile = function(file, string, success, fail) {
            window.resolveLocalFileSystemURI(cordova.file.applicationStorageDirectory, function(root) {//TODO try to change this to cordova.file.dataDirectory
                root.getDirectory("files", opts, function(folder) {                                    //TODO this line will not be needed then, but replace (in line below) folder to root
                    folder.getFile(file, opts, function(file_) {
                        file_.createWriter(function(io) {
                            io.onwrite = success;
                            io.write(string);
                        }, function() {
                            fail("Failed to write in " + file);
                        });
                    }, function() {
                        fail("Failed to get file: " + file);
                    });
                }, function() {
                    fail("Failed to get folder `files`.");
                });
            }, function() {
                fail("Failed to get file system.");
            });
        };

        /* Creating the certificate signing request. */
        var csr = forge.pki.createCertificationRequest();
        csr.publicKey = keypair.publicKey;
        csr.sign(keypair.privateKey);
        var csrPem = forge.pki.certificationRequestToPem(csr);

        /* Post the given certification request to the server. */
        var postToServer = function(file, success, fail) {
            var options = new FileUploadOptions();
            options.fileKey = "csr";
            var params = {};
            params.wizard_token = wizard_token;
            options.params = params;
            var ft = new FileTransfer();
            ft.upload(file.toURL(), server, success, fail, options);
        };

        /* Saving and posting the certification request to the server. The response is saved to a file and the user added.*/
        var fail = alert;
        window.requestFileSystem = window.requestFileSystem || window.webkitRequestFileSystem;
        window.requestFileSystem(LocalFileSystem.TEMPORARY, 0, function(fileSystem) {
            var tempFile = "temp.csr";
            fileSystem.root.getFile(tempFile, opts, function(file) {
                file.createWriter(function(io) {
                    io.onwrite = function() {
                        postToServer(file, function(r) {
                            var response = $.parseJSON(r["response"]);
                            var username = response.username;
                            // save the certificate in username.crt.pem
                            writeStringToFile(username+certificateFile, response.certificate, function() {
                                alert("Saved.");
                                file.remove(function() {
                                    alert("And removed.");
                                }, fail);
                                // save the private key in username.key.pem
                                writeStringToFile(username+privateKeyFile, privPem, function() {
                                    service.addUser(username, username+certificateFile, username+privateKeyFile).done(function(){ 
                                        window.location.href = $(location).attr('pathname');
                                    }); 
                                }, alert);
                              }, alert);
                        }, function(error) {
                            fail("code=" + error.code);
                            fail("source=" + error.source);
                            fail("target=" + error.target);
                            fail("status=" + error.http_status);
                        });
                    };
                    io.write(csrPem);
                }, function() {
                    fail("Failed to open temporary file.");
                });
            });
        }, function() {
            fail("Failed to get temporary file system.");
        });

        return this;
    }


	this.renderChoiceScreen = function() {
		this.$el.html(this.templateChoiceScreen());
        return this;
	}

	this.renderInputNormalCodeScreen = function() {
		this.$el.html(this.templateInputNormalCode());
		return this;
	}

	this.initialize();
}
