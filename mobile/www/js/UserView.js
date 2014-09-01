var UserView = function(user) {

    this.initialize = function() {
        this.$el = $('<div/>');
    };

    this.render = function() {
        this.$el.html(this.template(user));
        return this;
    };

    this.initialize();

}

