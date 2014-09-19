// we need this globally
var service = new UserService();

// functions for the QUIT button
function showConfirm() {
    navigator.notification.confirm(
        'Do you really want to exit?',  // message
        exitFromApp,              // callback to invoke with index of button pressed
        'Exit',            // title
        'Cancel,OK'         // buttonLabels
    );
};
     
        
function exitFromApp(buttonIndex) {
    if (buttonIndex==2){
        navigator.app.exitApp();
    }
};
// functions for the remove user buttons
function removeUser(username) {
    navigator.notification.confirm(
        'Are you sure you want to delete ' + username + '?',  // message
        function(buttonIndex){
            deleteUser(buttonIndex, username);
        },              // callback to invoke with index of button pressed
       'Delete user',            // title
        'Cancel, I want to delete this user'         // buttonLabels
    );
    deleteUser(username);
};

function deleteUser(buttonIndex, username) {
    if (buttonIndex==2){
        var service = new UserService();
        service.deleteUser(username).done(function(){
            window.location.href = $(location).attr('pathname');
        });
    }
};

// We use an "Immediate Function" to initialize the application to avoid leaving anything behind in the global scope
(function () {

    /* ------------------------------------- Templates ------------------------------------- */
    HomeView.prototype.template = Handlebars.compile($("#home-tpl").html());
    UserListView.prototype.template = Handlebars.compile($("#user-list-tpl").html());
    NewUserView.prototype.templateChoiceScreen = Handlebars.compile($("#choice-screen-tpl").html());
    NewUserView.prototype.templateInputNormalCode = Handlebars.compile($("#input-normal-code-tpl").html());
    NewUserView.prototype.templateInputQRCode = Handlebars.compile($("#input-QR-code-tpl").html());
    AppBrowserView.prototype.template = Handlebars.compile($("#app-browser-tpl").html());
    ScannerView.prototype.template = Handlebars.compile($("#scanner-view-tpl").html());

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

        router.addRoute('inputQRCode', function() {
            $('body').html(new NewUserView(service).renderInputQRCodeScreen().$el);
        });

        router.addRoute('appBrowser', function() {
            $('body').html(new AppBrowserView().render().$el);
        });
        router.addRoute('scannerView', function() {
            $('body').html(new ScannerView().render().$el);
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

