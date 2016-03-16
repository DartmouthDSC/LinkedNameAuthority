/*
 *  Project: Linked Name Authority Gateway
 *  Description: jquery plugin to mediate LDP-style communications with the
 *    Linked Name Authority server.
 *  Author: John Bell (@nmdjohn), Dartmouth College
 *  License: MIT License ( https://opensource.org/licenses/MIT )
 */

;(function ($, window, document, undefined){

	'use strict';

	var pluginName = "LNAGateway";
	var dataKey = "plugin_" + pluginName;

	/*
	 * LNAGateway plugin
	 */
	var Plugin = function (options){
	    //defaults
	    this.defaults = {
	      'baseURL': 'https://jb.dac.dartmouth.edu/lna/',    //trailing slash required
	      'lnaVersion': '0.2.0',
	      'authenticity_token': true                         //whether or not to add auth token field to all queries
	    };
	    this.options = this.defaults;
	    this.errors = [];

	    /*
	     * For all forms, data-lna-query must be set to a key in this array
	     *
	     * For templates, the given keys will always appear in submitted forms.
	     * Any null keys in a data array that the user tries to submit will
	     * cause that submission to be blocked, so a template key set to "" below
	     * is optional while a key set to null is not.
	     *
	     */
	    this.queries = {
	     	'newPerson':  {'method': 'POST', 'path': 'person/', 'template': {
	                      "foaf:name": null,
	                      "foaf:givenName": null,
	                      "foaf:familyName": null,
	                      "foaf:title": "",
	                      "foaf:mbox": null,
	                      "foaf:homepage": "",
	                      "org:reportsTo": ""}
	                    },
	    	'listPersons':{'method': 'GET', 'path': 'persons/', 'template': {}
	    				},
			'loadPerson': {'method': 'GET', 'path': 'person/', 'template': {}
	    				},	    				
			'newOrg':     {'method': 'POST', 'path': 'organization/', 'template': {
	                      "org:identifier": null,
	                      "skos:pref_label": null,
	                      "skos:alt_label": [],
	                      "owltime:hasBeginning": null,
	                      "owltime:hasEnd": ""}
	                    }                   
	    };
	};

  	Plugin.prototype = {

    	'init': function(opt){
	        var handle = this;
	        $.extend(this.options, opt);
	        var forms = $('form').filter(function(){return typeof $(this).data('lna-query') !== 'undefined'});
	        forms.each(function(){ handle.extendForm(this) });
	    },

	    //tk decide if I'm going to use these
	    'clearErrors': function(){
	      this.errors = [];
	    },

	    'getErrors': function(){
	      return this.errors;
	    },

	    //Queries associated with forms are mostly handled using extendForm below.
	    //Reading is handled with convenience functions
	    'listPersons': function(callback, page){
	    	if(typeof page === "undefined") page = 1;
	    	this.submitQuery('listPersons', {}, callback, page);
	    },

	    'loadPerson': function(callback, uid){
	    	if(typeof uid === "undefined") return false;
	    	this.submitQuery('loadPerson', {}, callback, uid);
	    },	    

	    //extendForm is called on all forms that have data-lna-query set on init
	    //it can also be run manually.
	    'extendForm': function(formElement){
    		var handle = this;
			var $formElement = $(formElement);

			//Validation
		    var query = $formElement.data('lna-query');
		    if(typeof query ==="undefined"){
		    	console.log('Tried to extend a form without an lna-query set');
		        return false;
		    }
		    if(typeof this.queries[query] === 'undefined'){
		        console.log('Tried to extend a form for which there is no query');
		        return false;
		    }
      

      		$formElement.submit(function(e){
        	e.preventDefault();

        	var formData = handle.readForm(this);

        	if(!formData) {
        		console.log(handle.getErrors());    //tk do something useful with errors
        		return false;
       		}

        	handle.submitQuery(query, formData);

        	return false;
			});
    	},

    	'readForm': function(formElement){
      		var handle = this;
    		var $formElement = $(formElement);

    		//Validation
    		var query = $formElement.data('lna-query');
    		if(typeof query === 'undefined'){
       			console.log('Form element needs a data-lna-query value.');
        		return false;
      		}
      		if(typeof this.queries[query] === 'undefined'){
        		console.log('Tried to read a form for which there is no query');
        		return false;
      		}

      		//merge form data into a copy of the template
      		var data = $.extend(true, {}, this.queries[query].template);
		    var formData = $formElement.serializeArray();
		    $.each(formData, function(k,v){
        		if(typeof data[v.name] !== 'undefined' && v.value != '') data[v.name]=v.value;
        		if(v.name == 'authenticity_token' && handle.options.authenticity_token) data[v.name] = v.value;
      		});

      		var fail = false;
      		$.each(data, function(k,v){
        		if(data[k]===null){
          			console.log("Form missing required field: "+k);
          			handle.errors.push("Missing required field, submission stopped.");
          			fail = true;
        		}
      		});

      		if(fail) return false;

      		return data;
    	},

    	'submitQuery': function(query, formData, fn, opt){
    		if(typeof opt === "undefined") opt = '';
	     	var queryData = this.queries[query];
    	 	$.ajax({
	    	    "url": this.options.baseURL + queryData.path + opt,
	        	"method": queryData.method,
		        "accepts": "application/ld+json",
		        "data": formData,
		        "dataType": "json",
		        "success": fn
      		});
    	},

    	//Reads linked data graphs and turns them into more useful arrays
    	'readLD': {
    		'persons': function(xhrData){
	    		var data = {'persons': [], 'orgs': []};
	    		$.each(xhrData['@graph'], function(i, v){
	    			if(v['@type']=='org:Organization') data.orgs.push(v);
	    		});
	    		$.each(xhrData['@graph'], function(i, v){
	    			if(v['@type']=='foaf:Person'){
	    				var org = $.grep(data.orgs, function(o){ return v['org:reportsTo'] == o['@id']});
	    				if(org.length > 0) v.orgLabel = org[0]['skos:prefLabel'];
	    				else v.orgLabel = '';
	    				data.persons.push(v);
	    			}
	    		});
	    		return data;
	    	},
    		'person': function(xhrData){
	    		var data = {'person': [], 'orgs': [], 'accounts': [], 'appointments': []};


// ************** LEFT OFF HERE  *******************

	    		return data;
	    	}	    	
    	},

    	//Utility function to parse link headers
    	'parseLink': function(linkText){
			if (linkText.length == 0) {
				return {};
			}

			// Split parts by comma
			var parts = linkText.split(',');
			var links = {};
	

			// Parse each part into a named link
			$.each(parts, function(i, p) {
				var section = p.split(';');
				if (section.length != 2) {
					console.log("section could not be split on ';'");
				}
				var url = section[0].replace(/<(.*)>/, '$1').trim();
				var name = section[1].replace(/rel="(.*)"/, '$1').trim();
				links[name] = url;
			});

			return links;
    	}
	};

	/*
	 * Plugin wrapper, preventing against multiple instantiations and
     * return plugin instance.
     */
	$.fn[pluginName] = function(opt) {

    	var plugin = this.data(dataKey);

    	// has plugin instantiated ?
    	if (plugin instanceof Plugin) {
        	// if we have options arguments, call plugin.init() again
        	if (typeof opt !== 'undefined') {
            	plugin.init(opt);
        	}
    	} else {
        	plugin = new Plugin(this, opt);
        	this.data(dataKey, plugin);
    	}

      	return plugin;
  	};

  	$('document').ready(function(){
    	var lna = $(document).LNAGateway();
    	lna.init();
  	});
}(jQuery, window, document));