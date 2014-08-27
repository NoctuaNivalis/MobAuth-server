var HomeView = function(service) {

    var employeeListView;

    this.initialize = function() {
        // Define a div wrapper for the view (used to attach events)
        this.$el = $('<div/>');        
        employeeListView = new EmployeeListView();
        // Standard the complete list of users is generated
        this.findAll();
        this.render();
    };

    //to return a list of users filtered by name (currently not in use)
    this.findByName = function() {
        service.findByName($('.search-key').val()).done(function(employees) {
            employeeListView.setEmployees(employees);
        });
    };

    // to return the list of all users
    this.findAll = function() {
        service.findAll().done(function(employees) {
            employeeListView.setEmployees(employees)
        });
    }
    
    this.render = function() {
        this.$el.html(this.template());
        $('.content', this.$el).html(employeeListView.$el);
        return this;
    }

    this.initialize();

}
