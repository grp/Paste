function MainAssistant() {
	/* this is the creator function for your scene assistant object. It will be passed all the 
	   additional parameters (after the scene name) that were passed to pushScene. The reference
	   to the scene controller (this.controller) has not be established yet, so any initialization
	   that needs the scene controller should be done in the setup function below. */
}

MainAssistant.prototype.setup = function() {
	this.menupanel = this.controller.sceneElement.querySelector('div[x-mojo-menupanel]');
	this.scrim = this.controller.get('scrim');

	this.controller.listen('palm-header-toggle-menupanel', Mojo.Event.tap, this.toggleMenuPanel.bindAsEventListener(this));
	this.controller.listen(this.scrim, Mojo.Event.tap, this.toggleMenuPanel.bindAsEventListener(this));
	this.controller.get('scrim2').hide();

	this.scrim.hide();
	this.scrim.style.opacity = 0;

	this.menuPanelVisibleTop = this.menupanel.offsetTop;
	this.menupanel.style.top = (0 - this.menupanel.offsetHeight - this.menupanel.offsetTop) + 'px';
	this.menuPanelHiddenTop = this.menupanel.offsetTop;
	this.menupanel.style.opacity = 0;

	this.panelOpen = false;
	this.submitting = false;

	this.text = this.controller.get('text');
	this.sceneTapped = this.sceneTapped.bind(this);
	this.controller.listen(this.controller.document, Mojo.Event.tap, this.sceneTapped.bindAsEventListener(this));
	this.controller.setupWidget('text', {
		textFieldName:'text',
		hintText:'',
		autoFocus:true,
		textCase:Mojo.Widget.steModeLowerCase,
		modelProperty:'value',
		multiline:true,
		limitResize:true
	}, { });
	this.controller.setInitialFocusedElement(this.text);
	this.controller.setupWidget(Mojo.Menu.commandMenu, undefined, { items:[
		{ label:"Clear", command:"clear" },
		{ label:"Submit", command:"submit" }
	]});

	this.spinner = this.controller.get('spinner');
	this.controller.setupWidget(this.spinner, {}, { spinning: true });
	this.spinner.hide();

	this.languages = {
		"ActionScript":2,
		"Bash (shell)":13,
		"C#":20,
		"C/C++":7,
		"CSS":8,
		"Diff":5,
		"Go":21,
		"HTML (ERB / Rails)":12,
		"HTML / XML":11,
		"Java":9,
		"JavaScript":10,
		"Objective-C/C++":1,
		"Perl":18,
		"PHP":15,
		"Plain Text":6,
		"Python":16,
		"Ruby":3,
		"Ruby on Rails":4,
		"SQL":14,
		"YAML":19
	};
	this.setLanguage("Plain Text");
	var sorted = new Array();
	for (k in this.languages) sorted.push(k);
	sorted.sort();

	var first = this.controller.get('firstrow'), last = this.controller.get('lastrow'), middle = this.controller.get('middlerow');
	var elements = [];
	var title_set = function(elem, t) {
		var title = elem.getElementsByClassName('title')[0];
		title.innerHTML = t;
	}
	for (var i = 0; i < sorted.length; i++) {
		if (i == 0) {
			title_set(first, sorted[i]);
			elements.push(first);
		} else if (i == sorted.length - 1) {
			title_set(last, sorted[i]);
			elements.push(last);
		} else {
			var elem = middle.cloneNode(true);
			title_set(elem, sorted[i]);
			elements.push(elem);
		}
	}
	var list = this.controller.get('list');
	list.innerHTML = "";
	for (var i = 0; i < elements.length; i++) {
		list.appendChild(elements[i]);		
		this.controller.listen(elements[i], Mojo.Event.tap, this.languageTapped.bindAsEventListener(this));		
	}

	
	setTimeout(function() {
		if (PalmSystem && PalmSystem.paste) PalmSystem.paste();
	}, 100);
};

MainAssistant.prototype.languageTapped = function(event) {
	var title = (event.target.getElementsByClassName('title')[0] || event.target).innerHTML;
	this.setLanguage(title);
	this.toggleMenuPanel(event);
}

MainAssistant.prototype.sceneTapped = function(event) {
	if (event.target !== this.text && !event.target.up('div#' + this.text.id)) {
		event.preventDefault();
	}
}

MainAssistant.prototype.setLanguage = function(name) {
	this.language = this.languages[name];
	var header = this.controller.get('palm-header-toggle-menupanel');
	header.getElementsByClassName('truncating-text')[0].innerHTML = "Paste: " + name;	
}

MainAssistant.prototype.handleCommand = function(event) {
	if (event.type == Mojo.Event.command) {
		if (event.command == "submit") this.submit(this.text.mojo.getValue(), this.language);
		else if (event.command == "clear") this.text.mojo.setValue("");
	}
}

MainAssistant.prototype.submit = function(text, language) {
	this.submitting = true;
	var that = this;
	
	this.spinner.show();
	this.spinner.mojo.start();
	
	var scrim = this.controller.get('scrim2');
	scrim.style.opacity = 0;
	scrim.style.zIndex = 99999;
	scrim.show();

	this.text.blur();	
	this.controller.setMenuVisible(Mojo.Menu.commandMenu, false);	

	var boundary = "_xuzz_productions_paste_";
	var body = "";
	var post = {
		"paste[body]":text,
		"paste[authorization]":"burger",
		"paste[restricted]":"1",
		"paste[parser_id]":"" + language
	};
	for (var key in post) {
		body += "--" + boundary + "\r\n";
		body += "Content-Disposition: form-data; name=\"" + key + "\"\r\n\r\n";
		body += post[key] + "\r\n";
	}
	body += "--" + boundary + "--\r\n";

	var complete = function() {
		that.spinner.hide();
		that.spinner.mojo.stop();
		scrim.hide();
		that.controller.setMenuVisible(Mojo.Menu.commandMenu, true);
		that.text.focus();

		that.submitting = false;
	};
	new Ajax.Request('http://xuzz.net/apps/paste.php', { //'http://pastie.org/pastes', {
		method:'post',
		contentType:'multipart/form-data; boundary=' + boundary,
		encoding:'',
		postBody:body,
		onSuccess:function(response) {
			var url = response.responseText;
			that.controller.stageController.setClipboard(url, false);
			that.controller.showAlertDialog({
				onChoose:function() { setTimeout(function() { that.text.focus(); }, 1000); },
				title:"Complete",
				message:"Your paste has been submitted and the URL has been copied to your clipboard.",
				choices:[{ label:"Continue", value:'continue' }]
			});
			complete();
		}.bind(this),
		onFailure:function(response) {
			Mojo.Controller.errorDialog("Unable to submit your paste. Error code " + response.status + response.responseText + ".");
			complete();
		}.bind(this)
	});
/*
	
	var http = new XMLHttpRequest();
	http.open("POST", "http://pastie.org/pastes", true);
	http.setRequestHeader("Content-Type", "multipart/form-data; charset=UTF-8; boundary=" + boundary);
	http.setRequestHeader("Content-Length", body.length);
	http.onreadystatechange = function() {
		if (http.readyState == 4) {
	
			console.log("ready, man: " + http.readyState + " blah " + http.status);
			if ((http.status == 200 || http.status == 0) && text != "") {
				var response = http.responseText;
				var url = response.match(/http:\/\/pastie\.org\/pastes\/(\d*)\/text/g);
				console.log("url: " + url + " form text: " + response);
				that.controller.stageController.setClipboard(false, response);
			} else {
				Mojo.Controller.errorDialog("Unable to submit your paste. Error code " + http.status + ".");
			}
			
			complete();
		}
	}

	http.send(body);
*/
}

MainAssistant.prototype.toggleMenuPanel = function(event) {
	var hidden = this.menuPanelHiddenTop, visible = this.menuPanelVisibleTop;
	
	var animate = function(menu, reverse, callback) {
		Mojo.Animation.animateStyle(menu, 'top', 'bezier', {
				from:hidden,
				to:visible,
				duration:0.12,
				curve:'over-easy',
				reverse:reverse,
				onComplete:callback
			}
		);
	};

	var panel = this.menupanel;
	var scrim = this.scrim;
	var controller = this.controller;

	if (this.panelOpen) {
		animate(panel, true, function() {
				controller.setMenuVisible(Mojo.Menu.commandMenu, true);	
				panel.hide();
				Mojo.Animation.Scrim.animate(scrim, 1, 0, scrim.hide.bind(scrim));
			}
		);
	} else {
		panel.style.opacity = 1;
		scrim.style.opacity = 0;
		scrim.show();
		controller.setMenuVisible(Mojo.Menu.commandMenu, false);	
		Mojo.Animation.Scrim.animate(scrim, 0, 1, function() {
				panel.show();
				animate(panel, false, Mojo.doNothing);
			}
		);
	}
	
	this.panelOpen = !this.panelOpen;
};

MainAssistant.prototype.activate = function(event) {
	//this.controller.sceneController.handleCommand(Mojo.Event.make(this.controller.document, Mojo.Event.command, { command:Mojo.Menu.pasteCommand }));
	//this.controller.stageController.paste();
};

MainAssistant.prototype.deactivate = function(event) {
	/* remove any event handlers you added in activate and do any other cleanup that should happen before
	   this scene is popped or another scene is pushed on top */
};

MainAssistant.prototype.cleanup = function(event) {
	/* this function should do any cleanup needed before the scene is destroyed as 
	   a result of being popped off the scene stack */
};

