var EmployeeListView = function () {

    this.initialize = function() {
        this.$el = $('<div/>');
        this.render();
    };

    this.render = function() {
        var ref = window.open('http://www.google.be','_blank','location=yes');
        this.$el.html(this.template());
        return this;
    };

    this.initialize();

}

