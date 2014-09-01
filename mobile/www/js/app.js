// We use an "Immediate Function" to initialize the application to avoid leaving anything behind in the global scope
(function () {

    /* ------------------------------------- Templates ------------------------------------- */
    HomeView.prototype.template = Handlebars.compile($("#home-tpl").html());
    UserListView.prototype.template = Handlebars.compile($("#user-list-tpl").html());
    UserView.prototype.template = Handlebars.compile($("#user-tpl").html());
    NewUserView.prototype.templateChoiceScreen = Handlebars.compile($("#choice-screen-tpl").html());
    NewUserView.prototype.templateInputNormalCode = Handlebars.compile($("#input-normal-code-tpl").html());
    NewUserView.prototype.templateProcessingScreen = Handlebars.compile($("#processing-screen-tpl").html());
    AppBrowserView.prototype.template = Handlebars.compile($("#app-browser-tpl").html());

    /* ---------------------------------- Local Variables ---------------------------------- */
    var service = new UserService();

    /* -------------------------------------- Routing -------------------------------------- */
    service.initialize().done(function () {

        router.addRoute('', function() {
            $('body').html(new HomeView(service).render().$el);
        });

        router.addRoute('users/:id', function(id) {
            service.findById(parseInt(id)).done(function(user) {
                $('body').html(new UserView(user).render().$el);
            });
        });

        router.addRoute('choiceScreen', function() {
            $('body').html(new NewUserView(service).renderChoiceScreen().$el);
        });

        router.addRoute('inputNormalCode', function() {
            $('body').html(new NewUserView(service).renderInputNormalCodeScreen().$el);
        });

        router.addRoute('processingScreen/:code', function(code) {
            $('body').html(new NewUserView(service).renderProcessingScreen().$el);
        });

        router.addRoute('appBrowser', function() {
            $('body').html(new AppBrowserView().render().$el);
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

