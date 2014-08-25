// We use an "Immediate Function" to initialize the application to avoid leaving anything behind in the global scope
(function () {

    /* ------------------------------------- Templates ------------------------------------- */
    HomeView.prototype.template = Handlebars.compile($("#home-tpl").html());
    EmployeeListView.prototype.template = Handlebars.compile($("#employee-list-tpl").html());
    EmployeeView.prototype.template = Handlebars.compile($("#employee-tpl").html());

    /* ---------------------------------- Local Variables ---------------------------------- */
    var service = new EmployeeService();

    /* -------------------------------------- Routing -------------------------------------- */
    service.initialize().done(function () {

        router.addRoute('', function() {
            $('body').html(new HomeView(service).render().$el);
        });

        router.addRoute('employees/:id', function(id) {
            service.findById(parseInt(id)).done(function(employee) {
                $('body').html(new EmployeeView(employee).render().$el);
            });
        });

        router.start();
    });

    /* --------------------------------- Event Registration -------------------------------- */
    document.addEventListener('deviceready', function () {

        // Fix statusbar in iOS7
        StatusBar.overlaysWebView( false );
        StatusBar.backgroundColorByHexString('#ffffff');
        StatusBar.styleDefault();

        // Override default HTML alert with native dialog
        if (navigator.notification) {
            window.alert = function (message) {
                navigator.notification.alert(
                    message,    // message
                    null,       // callback
                    "Workshop", // title
                    'OK'        // buttonName
                );
            };
        }

        // Use fast clicks.
        FastClick.attach(document.body);

    }, false);

}());

