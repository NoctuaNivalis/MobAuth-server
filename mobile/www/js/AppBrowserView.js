var AppBrowserView = function () {

    this.initialize = function() {
        this.$el = $('<div/>');
        this.render();
    };

    this.render = function() {
        var ref = window.open('https://localhost:3000/clientauth','_system','location=yes');
        this.$el.html(this.template());
        return this;
    };

    this.initialize();

}