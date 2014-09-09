var UserService = function() {

	this.initialize = function() {
        // No Initialization required
        var deferred = $.Deferred();
        if (window.localStorage.getItem("users") == null) {
            window.localStorage.setItem("users", JSON.stringify(
                []
            ));
        }
        deferred.resolve();
        return deferred.promise();
    }

    this.findById = function (id) {

        var deferred = $.Deferred(),
            users = JSON.parse(window.localStorage.getItem("users")),
            user = null,
            l = users.length;

        for (var i = 0; i < l; i++) {
            if (users[i].id === id) {
                user = users[i];
                break;
            }
        }

        deferred.resolve(user);
        return deferred.promise();
    }

    this.findAll = function() {
        var deferred = $.Deferred();
        var results = JSON.parse(window.localStorage.getItem("users"));
        deferred.resolve(results);
        return deferred.promise();
    }

    this.addUser = function(username, certificate, privateKey) {
    	var deferred = $.Deferred();
    	var users = JSON.parse(window.localStorage.getItem("users"));
    	users[users.length] = {"id": users.length+1,
    						 	"userName": username,
    						 	"certificate" : certificate,
    						 	"private_key": privateKey};
    	window.localStorage.setItem("users", JSON.stringify(users));
    	deferred.resolve();
        return deferred.promise();
    }
}