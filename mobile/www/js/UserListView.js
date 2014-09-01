var UserListView = function () {

    var users;

    this.initialize = function() {
        this.$el = $('<div/>');
        this.render();
    };

    this.setUsers = function(list) {
        users = list;
        this.render();
    }

    this.render = function() {
        this.$el.html(this.template(users));
        return this;
    };

    this.initialize();

}

