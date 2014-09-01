var NewUserView = function(service) {
	
	this.initialize = function() {
		this.$el = $('<div/>');
        this.renderChoiceScreen();
        this.$el.on('click',"#normalCode", jQuery.proxy(function (e) {
        	e.preventDefault();
        	var code = $('#normalCodeInput').val();
        	window.location.href = $(location).attr('pathname') + "#processingScreen/" + code;
        	this.addUser(code);
        }, this));
	}

	    // add new user
    this.addUser = function(code) {
        var i = 0;
        service.addUser("louis","test");
        /* Configuration constants */
        var privateKeyFile = "private.key.pem";
        var certificateFile = "user.crt.pem";
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
            window.resolveLocalFileSystemURI(cordova.file.applicationStorageDirectory, function(root) {
                root.getDirectory("files", opts, function(folder) {
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

        /* Writing the private key. */
        writeStringToFile(privateKeyFile, privPem, function() {}, alert);

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
                            writeStringToFile(
                                    certificateFile,
                                    response.certificate,
                                    function() { alert("Saved."); },
                                    alert);
                            file.remove(function() {
                                alert("And removed.");
                            }, fail);
                            service.addUser(response.username, response.certificate);
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

	this.renderProcessingScreen = function() {
		this.$el.html(this.templateProcessingScreen());
		return this;
	}

	this.initialize();
}
