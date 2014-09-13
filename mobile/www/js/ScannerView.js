var ScannerView = function () {

    this.initialize = function() {
        this.$el = $('<div/>');
        this.render();
    };

    this.render = function() {
        cordova.plugins.barcodeScanner.scan(
            function(result) {
                alert("we got a barcode\n" +
                    "result: " + result.text + "\n" +
                    "format: " + result.format + "\n" +
                    "cancelled " + result.cancelled);
            },
            function(error) {
                alert("scanning failed: " + error);
            }
        );
        this.$el.html(this.template());
        return this;
    };

    this.initialize();

}