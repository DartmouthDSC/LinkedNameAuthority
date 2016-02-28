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
      'baseURL': 'https://lna.dartmouth.edu/',    //trailing slash required
      'lnaVersion': '0.2.0'
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
      'newPerson': {'method': 'POST', 'path': 'person/', 'template': {
                      "foaf:name": null,
                      "foaf:givenName": null,
                      "foaf:familyName": null,
                      "foaf:title": "",
                      "foaf:mbox": null,
                      "foaf:homepage": "",
                      "org:reportsTo": ""}
                   }
    };

    // this.init(options);
  };

  Plugin.prototype = {

    'init': function(opt){
        var handle = this;
        $.extend(this.options, opt);
        var forms = $('form').filter(function(){return typeof $(this).data('lna-query') !== 'undefined'});
        forms.each(function(){ handle.extendForm(this) });
    },

    'clearErrors': function(){
      this.errors = [];
    },

    'getErrors': function(){
      return this.errors;
    },

    //extendForm is called on all forms that have data-lna-query set on init
    //it can also be run manually.
    'extendForm': function(formElement){
      var handle = this;
      var $formElement = $(formElement);

      if(typeof $.data($formElement, 'lna-query')===undefined){
        console.log('Tried to extend a form without an lna-query set');
        return false;
      }

      $formElement.submit(function(e){
        e.preventDefault();

        var formData = handle.readForm(this);
        if(!formData) {
          console.log(handle.getErrors());    //tk do something useful with errors
          return false;
        }

//**************************************LEFT OFF HERE

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

      data.ready = true;

      return data;
    },

    'submitQuery': function(query, formData){

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
