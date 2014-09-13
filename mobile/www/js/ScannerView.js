var ScannerView = function () {

    this.initialize = function() {
        this.$el = $('<div/>');
        this.render();
    };

    this.render = function() {
        cordova.plugins.barcodeScanner.scan(
            function(result) {
                window.location.href = $(location).attr('pathname') + "#inputQRCode";
                window.document.getElementById("normalCodeInput").value = result.text;
                window.document.getElementById("normalCodeInput").placeholder = result.text;
                //$("#normalCodeInput").val(result.text);
            },
            function(error) {
                alert("scanning failed: " + error);
                window.location.href = $(location).attr('pathname');
            }
        );
        return this;
    };

    this.initialize();

}