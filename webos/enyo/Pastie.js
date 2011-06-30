enyo.kind({
    name: "Pastie",
    kind: enyo.Object,

    statics: {
        _languages: {
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
        },
        languages: function() {
            var names = [];
            for (var name in this._languages) {
                if (this._languages.hasOwnProperty(name))
                    names.push(name);
            }
            return names;
        },
        languageNamed: function(name) {
            return this._languages[name];
        }
    },

    published: {
        language: undefined,
        text: "",
        privately: false
    },
    constructor: function() {
        this.inherited(arguments);
    },

    submit: function(finished, failed) {
	    var boundary = "_xuzz_productions_paste_";
	    var body = "";
	    var post = {
		    "paste[body]": this.text,
		    "paste[authorization]": "burger",
		    "paste[restricted]": this.privately ? "1" : "0",
		    "paste[parser_id]": Pastie.languageNamed(this.language)
	    };
	    
        for (var key in post) {
		    body += "--" + boundary + "\r\n";
		    body += "Content-Disposition: form-data; name=\"" + key + "\"\r\n\r\n";
		    body += post[key] + "\r\n";
	    }

	    body += "--" + boundary + "--\r\n";
    
	    var http = new XMLHttpRequest();
	    http.open("POST", "http://xuzz.net/apps/paste.php", true); //"http://pastie.org/pastes", true);
	    http.setRequestHeader("Content-Type", "multipart/form-data; charset=UTF-8; boundary=" + boundary);
	    http.setRequestHeader("Content-Length", body.length);
	    
        http.onreadystatechange = function() {
		    if (http.readyState == 4) {
				var response = http.responseText;

			    if ((http.status == 200 || http.status == 0) && response != "") {
				    // var url = response.match(/http:\/\/pastie\.org\/pastes\/(\d*)\/text/g);
			        finished(response);
                } else {
			        failed(http.status);
                }
		    }
	    }
    
	    http.send(body);
    }
});
