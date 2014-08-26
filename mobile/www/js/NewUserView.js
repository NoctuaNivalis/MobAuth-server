var NewUserView = function() {
	
	this.initialize = function() {
		this.$el = $('<div/>');
        this.renderChoiceScreen();

	};

	this.renderChoiceScreen = function() {
		this.$el.html(this.templateChoiceScreen());
        return this;
	};

	this.renderInputNormalCodeScreen = function() {
		this.$el.html(this.templateInputNormalCode());
		return this;
	}

	this.renderProcessingScreen = function() {
		this.$el.html(this.templateProcessingScreen());
		return this;
	}

	this.initialize();
}