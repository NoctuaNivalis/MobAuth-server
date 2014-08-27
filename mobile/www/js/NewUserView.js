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
    	var certificate = null;
    	var username = null;
        // genereren keys en CSR
        // sturen naar server van de code+ CSR via plugin
        var uri = "10.1.2.248:3000/certificates" //moet nog aangepast worden voor ssl ?
        var res = encodeURI(uri);

        var fileURL = "asssets/testCertificate.csr";

        var win = function(response) {
        	certificate = response.certificate;
        	username = response.username;
        	alert(username);
        }

        var fail = function(error) {
        	alert("an error has occurred: Code = " + error.code);
        	console.log("upload error source " + error.source);
        	console.log("upload error target " + error.target);
        }

        var options = new FileUploadOptions();
        options.filekey = "csr";
        options.fileName = fileURL.substr(fileURL.lastIndexOf('/') + 1);

        var params = {};
        params.wizard_token = code;

        options.params = params;

        var ft = new FileTransfer();
        ft.upload(fileURL, res, win, fail, options);
        // wachten op bevestiging + naam gebruiker
        // gebruiker toevoegen
        // bevestiging succes
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