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

    //to return a list of users filtered by name
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

    // add new user
    this.addUser = function() {
        
        //sturen naar server van de code+ CSR
        //na bevestiging + naam gebruiker
        //gebruiker toevoegen
        //bevestiging succes
    }

    this.render = function() {
        this.$el.html(this.template());
        $('.content', this.$el).html(employeeListView.$el);
        return this;
    }

    this.initialize();

}
