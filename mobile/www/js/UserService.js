var UserService = function() {

	this.initialize = function() {
        // No Initialization required
        var deferred = $.Deferred();
        window.localStorage.setItem("users", JSON.stringify(
            [
		        {"id": 1, "userName": "James", "certificate": "certificate1", "private_key": "key1"},
		        {"id": 2, "userName": "Julie", "certificate": "certificate2", "private_key": "key2"},
		        {"id": 3, "userName": "Eugene", "certificate": "certificate3", "private_key": "key3"}
            ]
        ));
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

    this.addUser = function(username, certificate) {	//probably also add keyfilename
    	var deferred = $.Deferred();
    	var users = JSON.parse(window.localStorage.getItem("users"));
    	users[users.length] = {"id": users.length+1,
    						 	"userName": username,
    						 	"certificate" : certificate,
    						 	"private_key": "not_yet_impl"};
    	window.localStorage.setItem("users", JSON.stringify(users));
    	deferred.resolve();
        return deferred.promise();
    }
}