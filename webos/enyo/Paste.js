/* Copyright 2009-2011 Hewlett-Packard Development Company, L.P. All rights reserved. */
enyo.kind({
	name: "Paste",
	kind: enyo.VFlexBox,
    components: [
        { kind: enyo.ApplicationEvents, onWindowActivated: "windowActivated" },
        {
            kind: enyo.SlidingPane,
            flex: 1,
            components: [
                { name: "left", kind: "SlidingView", components: [
                    { kind: "Header",  components: [
                        { kind: "Button", caption: "Clear", onclick: "clearPressed" },
                        { kind: "VFlexBox", flex: 1, align: "center", components: [
                            { content: "Paste" }
                        ] },
                        { kind: "Button", caption: "Done", className: "enyo-button-blue", onclick: "donePressed" }
                    ] },
                    { kind: "Scroller", flex: 1, style: "background-color: white", components: [
                        {
                            name: "text",
                            kind: "RichText",
                            flex: 1,
                            richContent: false,
                            autocorrect: false,
                            spellcheck: false,
                            autoWordComplete: false,
                            autoCapitalize: "lowercase",
                            style: "background-color: white; -webkit-border-image: none; font-family: monospace;",
                            hint: ""
                        }
                    ] }
                ] },
                { name: "right", kind: "SlidingView", fixedWidth: true, components: [
                    { kind: "Header", components: [
                        { content: "Language", align: "left" }
                    ] },
                    { kind: "Scroller", flex: 1, width: "320px", components: [
                        { kind: "RowGroup", defaultKind: "HFlexBox", caption: "Options", components: [
                            { align: "center", components: [
                                { content: "Private Paste", flex: 1, onclick: "privateItemPressed" },
                                { kind: "CheckBox", name: "privateCheckbox", onChange: "privateChanged" }
                            ] }
                        ] },
                        { name: "languages", kind: "RowGroup", caption: "Language", components: [
                        ] }
                    ] },
                    { kind: "Toolbar", className: "enyo-toolbar-light", components: [
                        { kind: "GrabButton" }
                    ] }
                ] }
            ]
        },
        { name: "progressDialog", kind: enyo.ModalDialog, caption: "Submitting Paste...", dismissWithClick: false, components: [
            { kind: enyo.HFlexBox, align: "center", pack: "center", components: [
                { name: "progressSpinner", kind: enyo.SpinnerLarge }
            ] }
        ] },
        { name: "errorDialog", kind: enyo.ModalDialog, caption: "Error", dismissWithClick: false, components: [
            { content: "An error occured while submitting your paste.", className: "enyo-paragraph" },
            { kind: enyo.Button, caption: "Continue", onclick: "closeErrorDialog" }
        ]}
    ],

    constructor: function() {
        this.inherited(arguments);
    },
    create: function() {
        this.inherited(arguments);

        var priv = enyo.getCookie("private");
        this.$.privateCheckbox.setChecked(priv);

        var languages = Pastie.languages();
        for (var i = 0; i < languages.length; i++) {
            var language = languages[i];
            var item = this.$.languages.createComponent({
                content: language,
                onclick: "languagePressed",
                language: language,
                owner: this
            });

            this.itemByLanguage[language] = item;
        }
    
        var language = enyo.getCookie("language");
        if (language !== undefined) this.setSelectedLanguage(language);
        else this.setSelectedLanguage("Plain Text");
    },
    windowActivated: function() {
        var text = this.$.text;
        enyo.dom.getClipboard(function(clip) {
            if (clip == "") return;
            text.setValue(clip);
            
            if (!text.hasFocus()) {
                text.forceFocus(function() {
                    // XXX: why doesn't this work? enyo bug?
                    text.setSelection({ start: text.getValue().length - 1, end: text.getValue().length - 1 });
                });
            }
        });
        
        if (!text.hasFocus()) {
            text.forceFocus();
        }
    },
   
    updatePrivate: function(checked) {
        this.$.privateCheckbox.setChecked(checked);
        enyo.setCookie("private", checked);
    },
    privateItemPressed: function(sender) {
        this.updatePrivate(!this.$.privateCheckbox.getChecked());
    },
    privateChanged: function(sender) {
        this.updatePrivate(this.$.privateCheckbox.getChecked());
    },

    itemByLanguage: {},
    selectedLanguage: undefined,
    setSelectedLanguage: function(language) {
        if (this.selectedLanguage !== undefined) {
            // This is an ugly hack.
            var oldItem = this.itemByLanguage[this.selectedLanguage];
            oldItem.removeClass("enyo-menucheckitem-caption");
            oldItem.removeClass("enyo-menuitem");
            oldItem.removeClass("enyo-checked");
        }
        
        this.selectedLanguage = language;
        enyo.setCookie("language", language);
        
        if (this.selectedLanguage !== undefined) {
            // This is an ugly hack.
            var item = this.itemByLanguage[this.selectedLanguage];
            item.addClass("enyo-menucheckitem-caption");
            item.addClass("enyo-menuitem");
            item.addClass("enyo-checked");
        }
    },
    languagePressed: function(sender) {
        this.setSelectedLanguage(sender.language);
    },

    clearPressed: function(sender) {
        this.$.text.setValue("");
        this.$.text.forceFocus();
    },

    donePressed: function(sender) {
        this.$.progressDialog.openAtCenter();
        this.$.progressSpinner.show();

        var pastie = new Pastie();
        pastie.text = this.$.text.getValue();
        pastie.language = this.selectedLanguage;
        pastie.privately = this.$.privateCheckbox.getChecked();
        pastie.submit(enyo.bind(this, function(url) {
            this.$.progressSpinner.hide();
            this.$.progressDialog.close();

            enyo.dom.setClipboard(url);
            enyo.windows.addBannerMessage("Pastie URL copied to clipboard!", "{}");
        }), enyo.bind(this, function(code) {
            this.$.progressSpinner.hide();
            this.$.progressDialog.close();

            this.$.errorDialog.openAtCenter();
        }));
    },

    closeErrorDialog: function() {
        this.$.errorDialog.close();
    },

    // This is taken from StyleMatters in the Enyo sample code.
    // (It makes the right panel only slide 320px from the right.)
    rendered: function() {
        this.inherited(arguments);

        this.adjustSlidingSize();
    },
    resizeHandler: function() {
        this.adjustSlidingSize();
    },
    adjustSlidingSize: function() {
        var s = enyo.fetchControlSize(this);
        var pcs = enyo.fetchControlSize(this.$.right.$.client);
        this.$.left.node.style.width = (s.w - 54) + "px";
        this.$.right.setPeekWidth(s.w - pcs.w);
    }
});
