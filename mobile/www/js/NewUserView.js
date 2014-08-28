var NewUserView = function() {
	
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

        /* Configuration constants */
        var folderName = "Android/data/com.deloitte.mobauth/files/";
            // TODO this works only for android! See:
            // https://github.com/apache/cordova-plugin-file/blob/master/doc/index.md
        var privateKeyFile = "private.key.pem";
        var certificateFile = "user.crt.pem";
        var keySize = 1024;
        var wizard_token = code;
        var uri = "10.1.2.248:3000/certificates";
            // TODO Get the host and token from the code?
        var server = encodeURI(uri);

        /* Just some useful variables */
        var that = this;
        var opts = { create: true, exclusive: false };
    	var certificate = null;
    	var username = null;

        /* Generating keys and certificate request
         * Documentation: https://github.com/digitalbazaar/forge
         * The server should fill in the certificate details. */
        alert("about to generate keys");
        var keypair = forge.pki.rsa.generateKeyPair({ bits: keySize });
        alert("keys generated");
        var privPem = forge.pki.privateKeyToPem(keypair.privateKey);
        alert(privPem);

        /* Write a file in the given directory. */
        var writeStringToFile = function(folder, file, string, success, fail) {
            window.requestFileSystem = window.requestFileSystem || window.webkitRequestFileSystem;
            window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, function(fileSystem) {
                fileSystem.root.getDirectory(folder, opts, function(folder_) {
                    folder_.getFile(file, opts, function(file_) {
                        file_.createWriter(function(io) {
                            //io.truncate(0);
                            //io.seek(0);
                            io.onwrite = success;
                            io.write(string);
                        }, function() {
                            fail("Failed to write in " + file);
                        });
                    }, function() {
                        fail("Failed to get file: " + file);
                    });
                }, function() {
                    fail("Failed to get folder: " + folderName);
                });
            }, function() {
                fail("Failed to get file system.");
            });
        };

        /* Writing the private key. */
        writeStringToFile(folderName, privateKeyFile, privPem, function() { alert("sup"); }, alert);

        /* Creating the certificate signing request. */
        //var csr = forge.pki.createCertificationRequest();
        //var csrPem = forge.pki.certificationRequestToPem(csr);
        //csr.publicKey = keypair.publicKey;
        //csr.sign(keypair.privateKey);
        //alert("signed csr");

        ///* Post the given certification request to the server. */
        //var postToServer = function(file, success, fail) {
        //    var options = new FileUploadOptions();
        //    options.filekey = "csr";
        //    var params = {};
        //    params.wizard_token = wizard_token;
        //    options.params = params;
        //    var ft = new FileTransfer();
        //    ft.upload(file.toURL(), server, success, fail, options);
        //};

        ///* Saving and posting the certification request to the server. */
        //var fail = alert;
        //window.requestFileSystem = window.requestFileSystem || window.webkitRequestFileSystem;
        //window.requestFileSystem(LocalFileSystem.TEMPORARY, 0, function(fileSystem) {
        //    var tempFile = "temp.csr";
        //    fileSystem.root.getFile(tempFile, opts, function(file) {
        //        file.createWriter(function(io) {
        //            io.truncate(0);
        //            io.onwrite = function() {
        //                postToServer(file, function(response) {
        //                    alert("Code = " = response.code);
        //                    alert(r.response);
        //                }, function() {
        //                    fail("Failed post to server.");
        //                });
        //            };
        //            io.write(csrPem);
        //        }, function() {
        //            fail("Failed to open temporary file.");
        //        });
        //    });
        //}, function() {
        //    fail("Failed to get temporary file system.");
        //});

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
