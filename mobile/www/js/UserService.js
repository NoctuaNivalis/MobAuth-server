var UserService = function() {

	this.initialize = function() {
        // No Initialization required
        var deferred = $.Deferred();
        deferred.resolve();
        return deferred.promise();
    }

    this.findById = function(id) {
        var deferred = $.Deferred();
        var employee = null;
        var l = users.length;
        for (var i=0; i < l; i++) {
            if (users[i].id === id) {
                employee = users[i];
                break;
            }
        }
        deferred.resolve(employee);
        return deferred.promise();
    }

    this.findAll = function() {
        var deferred = $.Deferred();
        var results = users;
        deferred.resolve(results);
        return deferred.promise();
    }

    var users = [
        {"id": 1, "userName": "James", "certificate": "certificate1", "private_key": "key1"},
        {"id": 2, "userName": "Julie", "certificate": "certificate2", "private_key": "key2"},
        {"id": 3, "userName": "Eugene", "certificate": "certificate3", "private_key": "key3"}
    ];
}