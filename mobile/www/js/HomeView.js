var HomeView = function(service) {

    var userListview;

    this.initialize = function() {
        // Define a div wrapper for the view (used to attach events)
        this.$el = $('<div/>');        
        userListview = new UserListView();
        // Standard the complete list of users is generated
        this.findAll();
        this.render();
    };

    // to return the list of all users
    this.findAll = function() {
        service.findAll().done(function(users) {
            userListview.setUsers(users)
        });
    }
    
    this.render = function() {
        this.$el.html(this.template());
        $('.content', this.$el).html(userListview.$el);
        return this;
    }

    this.initialize();

}
