//main.js handles rendering for the LNA web interface
//Interactions with the LNA API are handled in jquery.lnagateway.js

LNA = {
	'constants': {
		//Translates org dc:title to CSS classes
		'onlineAccounts':[
			{'title': 'Dartmouth', 
			 'value': 'netID',
			 'class': 'netID',
			 'homepage': 'http://tech.dartmouth.edu/its/services-support/help-yourself/netid-lookup',
			 'accountRoot': 'http://lna.dartmouth.edu/person/'},  //tk accountRoot isn't right
			{'title': 'ORCiD',
			 'value': 'orcid',
		     'class': 'orcid',
		     'homepage': 'http://orcid.org/',
		     'accountRoot': 'http://orcid.org/'}
		    //tk add more accounts
		],
		'fuzzySearch' : ''
	},
	//this set of functions are callbacks for LNAGateway.*()
	'loadPersonCards': function(data, textStatus, xhr){
		var dataArray = $().LNAGateway().readLD.persons(data);
		if(typeof xhr != "undefined") var links = $().LNAGateway().parseLink(xhr.getResponseHeader('link'));
		$(dataArray.persons).each(function(i, person){
			var node = $('#templates .person').clone();
			node.find('h1').text(person['foaf:givenName']+' '+person['foaf:familyName']);
			if(person['foaf:image'] != ''){
				node.find('img')[0].attr('src', person['foaf:image']);
			}
			node.attr('href', person['@id']);
			if(person['foaf:title']!=''){
				node.find('p[property="title"]').text(person['foaf:title']+', '+person['orgLabel']);
			} else {
				node.find('p[property="title"]').text(person['orgLabel']);
			}
			// node.children('p[name="dateRange"]').text(person['foaf:title']);
			$('main').append(node);
		});
	},
	'loadOrgCards': function(data, textStatus, xhr){
		var dataArray = $().LNAGateway().readLD.orgs(data);
		if(typeof xhr != "undefined") var links = $().LNAGateway().parseLink(xhr.getResponseHeader('link'));		
		$(dataArray).each(function(i, org){
			var node = $('#templates .org').clone();
			node.find('h1').text(org['skos:prefLabel']);
			node.attr('href', org['@id']);
			if(org['skos:altLabel'].length > 0){
				node.find('p[property="altLabels"]').text(org['skos:altLabel'].join(', '));
			} 
			if(org['owltime:hasEnd'] != '') {
				node.find('p[name="dateRange"]').text(org['owltime:hasBeginning'].substr(0,4)+'-'+org['owltime:hasEnd'].substr(0,4));
			} else {
				node.find('p[name="dateRange"]').text(org['owltime:hasBeginning'].substr(0,4)+'-');
			}
			$('main').append(node);
		});
	},	

	'loadWorkCards': function(data, textStatus, xhr){
		var dataArray = $().LNAGateway().readLD.works(data);
		if(typeof xhr != "undefined") var links = $().LNAGateway().parseLink(xhr.getResponseHeader('link'));
		$(dataArray).each(function(i, work){
			var node = $('#templates .work').clone();
			node.find('h1').text(work['dc:title']);
			node.attr('href', work['@id']);
			if(work['bibo:authorList'].length > 0){
				node.find('p[property="authors"]').text(work['bibo:authorList'].join(', '));
			} 
			if(work['dc:date'] != '') {
				node.find('p[name="date"]').text(work['dc:date'].substr(0,4));
			}
			$('main').append(node);
		});
	},	

	'loadOrg': function(data, textStatus, xhr){
		var dataArray = $().LNAGateway().readLD.org(data);	

		//render org record
		$('.crumbHere').children().first().text(dataArray.org['skos:prefLabel']);
		$('.record h3').text(dataArray.org['skos:prefLabel']);
		$('.orgAltLabels').text(dataArray.org['skos:altLabel'].join(', '));
		$('.orgParent').text(dataArray.org['org:subOrganizationOf']);
		if(dataArray.org['owltime:hasEnd'] != ''){
			$('.orgDateRange').text(dataArray.org['owltime:hasBeginning'].substr(0,4) + '-' + dataArray.org['owltime:hasEnd'].substr(0,4) );	
		} else {
			$('.orgDateRange').text(dataArray.org['owltime:hasBeginning'].substr(0,4) + '-Present');
		}

		//clear all spinners
		$('.sidebar .spinner, .affiliations .spinner').parent().remove();

		//render OnlineAccounts
		$.each(dataArray.accounts, function(k, v){ LNA.fillAccount($('.orgData .iconList'), v) });

		LNA.activateModals();
	},

	'loadOrgPersons': function(data, textStatus, xhr){
		var dataArray = $().LNAGateway().readLD.persons(data);		

		//clear all spinners
		$('.related .spinner').parent().remove();

		//render Person list
		$.each(dataArray.persons, function(k, v){ LNA.fillPersons($('.related .iconList'), v) });

		LNA.activateModals();
	},	

	'loadPerson': function(data, textStatus, xhr){
		var dataArray = $().LNAGateway().readLD.person(data);		

		//render person data
		$('.sidebar h1').text(dataArray.person['foaf:name']);
		$('.crumbHere').children().first().text(dataArray.person['foaf:name']);
		if(dataArray.person['foaf:image'] != '') $('.sidebar img').attr('src', dataArray.person['foaf:image']);

		//clear all spinners
		$('.sidebar .spinner, .affiliations .spinner').parent().remove();

		//render affiliations
		$.each(dataArray.memberships, function(k, v){ LNA.fillMembership($('.affiliations .iconList'), v) });

		//render OnlineAccounts
		$.each(dataArray.accounts, function(k, v){ LNA.fillAccount($('.sidebar .iconList'), v) });

		LNA.activateModals();
	},
	'loadPersonWorks': function(data, textStatus, xhr){
		var dataArray = $().LNAGateway().readLD.personWorks(data);	

		//clear all spinners
		$('.works .spinner').parent().remove();

		$.each(dataArray, function(k, v){ LNA.fillPersonWorks($('.works .iconList'), v) });

		LNA.activateModals();
	},	

	//Fill functions fill in templates/partials based on passed data
	'fillAccount': function(parent, data){
		var node = $('#templates .onlineAccount').clone();
		var button = node.children().first();
		var iconClass = $.grep(LNA.constants.onlineAccounts, function(o){ return data['dc:title'] == o['title']});
		if(iconClass.length > 0) node.addClass(iconClass[0].class);
		button.attr('title', 'edit '+ data['dc:title'] + ' account');
		button.text(data['foaf:accountName']);
		parent.prepend(node);
	},
	'fillMembership': function(parent, data){
		var node = $('#templates .membership').clone();
		var label = node.children('.affiliation').first();
		var editButton = node.children('.edit').first();
		var viewButton = node.children('.view').first();

		var hrStart = data['owltime:hasBeginning'].split('-')[0];
		var hrStop = data['owltime:hasEnd'].split('-')[0];
		if(hrStop == '') hrStop = 'Present'
		label.text(hrStart +'–' + hrStop + ': ' + data['vcard:title'] + ', ' + data['orgLabel']);
		viewButton.attr('title', 'view '+ data['orgLabel'] + ' organization');
		viewButton.children('.helpText').text('view '+ data['orgLabel'] + ' organization');
		viewButton.click(function(e){ LNA.openLink(e, data['org:organization'])});
		editButton.attr('title', 'edit '+ data['orgLabel'] + ' affiliation');
		editButton.children('.helpText').text('edit '+ data['orgLabel'] + ' affiliation');
		editButton.click(function(e){ LNA.editAffiliation(e, data['org:organization'])});
		parent.prepend(node);
	},

	'fillPersonWorks': function(parent, data){
		var node = $('#templates .work').clone();
		var title = node.find('.itemTitle').first();
		var authorList = node.find('.itemAuthors').first();
		var editButton = node.find('.edit').first();
		var viewButton = node.find('.view').first();

		var date = data['dc:date'].substr(0,4);
		var authors = data['bibo:authorList'].join(', ');

		title.text(data['dc:title'] + ' (' + date + ')');
		authorList.text(authors);

		parent.prepend(node);
	},		

	'fillPersons': function(parent, data){
		var node = $('#templates .person').clone();
		node.find('[property="name"]').text(data['foaf:givenName']+' '+data['foaf:familyName']);
		node.find('button').click(function(e){ LNA.openLink(e, data['@id']) });

		$(parent).append(node);
	},

	//edit functions load data into edit modals, open the modal, and set the save handler
	editAffilication: function(e, org){
		// var editForm = $('#modals ')
	},

	//helpers
	'openLink': function(e, link){
		if(e.ctrlKey || e.metaKey){
			window.open(link, '_new');
		}
		else window.location.href = link;
	},

	//Find corresponding buttons and attach the open event
	'activateModals': function(){
		$('[data-toggle="modal"]').not('[data-ready="true"]').click(function (e) { 
			e.preventDefault();
			$($(this).data('target')).dialog("open");
			return false;
		});
		$('[data-toggle="modal"]').attr('data-ready', 'true');
	},
	//Find control panel buttons and attach the toggle behavior
	'activateControls': function(){
		$('button[data-toggle="controlPanel"]').not('[data-ready="true"]').click(function (e){
			e.preventDefault();
			$('#controlPanel').toggleClass('cpVisible');
			return false;
		});
		$('button[data-toggle="controlPanel"]').attr('data-ready', 'true');
	},
	//Find any inputs that use tag behavior and activate them
	'activateTags': function(){
		$('.tagBehavior').not('[data-ready="true"]').tagsInput({
			'delimiter': ';;;',
			'width': '90%',
			'height': '3em',
			'defaultText': ''
		});
		$('.tagBehavior').attr('data-ready', 'true');
	},
	'activateWidgets': function(){
		$('.dateBehavior').not('[data-ready="true"]').datepicker({
			'dateFormat': 'yy-mm-dd'
		});
		$('.dateBehavior').attr('data-ready', 'true');
	},
	'activateAutocompletes': function(){
		$('.autocompleteBehavior').not('[data-ready="true"]').each(function(i, field){
			$(field).autocomplete({
				'minLength': 3,
				'delay': 100,
				'source': LNA.autocompletes[$(field).data('autocomplete-type')].source,
				'select': LNA.autocompletes[$(field).data('autocomplete-type')].select
			});
		});
		$('.autocompleteBehavior').attr('data-ready', 'true');
	},
	'activateDropdowns': function(){
		$('.dropdownBehavior').not('[data-ready="true"]').each(function(i, field){
			var srcConfig = LNA.constants[$(field).data('opt')];
			if(typeof srcConfig === "undefined") return false;
			$(srcConfig).each(function(j, opt){
				var optionTag = $('<option>');
				optionTag.html(opt.title);
				optionTag.val(opt.value);
				$(field).append(optionTag);
			});
			if(typeof $(field).data('onchange') != "undefined" && typeof LNA.changeBehaviors[$(field).data('onchange')] != "undefined"){
				$(field).change(LNA.changeBehaviors[$(field).data('onchange')]);
			}
		});
		$('.dropdownBehavior').attr('data-ready', 'true');
	},
	'activateOnChanges': function(){
		$('.changeBehavior').not('[data-ready="true"]').each(function(i, field){
			if(typeof $(field).data('onchange') != "undefined" && typeof LNA.changeBehaviors[$(field).data('onchange')] != "undefined"){
				$(field).change(LNA.changeBehaviors[$(field).data('onchange')]);
			}
		});
		$('.changeBehavior').attr('data-ready', 'true');
	},

	//Dropdowns may have specific behaviors associated with them, so this is an index of those
	'changeBehaviors': {
		'prefillAccounts': function(e){
			var selected = $(e.target);
			var formNode = selected.parents('form');
			var accountType = $.grep(LNA.constants.onlineAccounts, function(o){ return selected.val() == o['value']});

			formNode.find('input[name="dc:title"]').val(accountType[0].title);
			formNode.find('input[name="foaf:accountServiceHomepage"]').val(accountType[0].homepage);
			formNode.find('input[name="accountID"]').val("");
		},
		'mergeAccountName': function(e){
			var selected = $(e.target);
			var formNode = selected.parents('form');
			var accountValue = formNode.find('select[name="template"]').val();
			var merge = selected.val();
			if(accountValue != ""){
				var accountType = $.grep(LNA.constants.onlineAccounts, function(o){ return accountValue == o['value']});
				if(accountType.length > 0){
					merge = accountType[0].accountRoot + merge;
				}
			}
			formNode.find('input[name="foaf:accountName"]').val(merge);
		}
	},

	//Autocompletes need specific instructions on setting values, so this is an index of those
	'autocompletes': {
		'org': {
			'source': function(request, response){
				$().LNAGateway().findOrgs(function(data){
					var orgArray = $().LNAGateway().readLD.orgs(data);
					var newArray = $.map(orgArray, function(item){ return {'label': item['skos:prefLabel'], 'value': item['@id']}});
					response(newArray)
					return newArray;
				}, this.element[0].value + LNA.constants.fuzzySearch) 
			},
			'select': function(e, ui){
				e.preventDefault();
				$(this).val(ui.item.label);
				$(this).parents('form').children('input[name="org:organization"]').val(ui.item.value);
			}
		},
		'reportsTo': {
			'source': function(request, response){
				$().LNAGateway().findOrgs(function(data){
					var orgArray = $().LNAGateway().readLD.orgs(data);
					var newArray = $.map(orgArray, function(item){ return {'label': item['skos:prefLabel'], 'value': item['@id']}});
					response(newArray);
					return newArray;
				}, this.element[0].value + LNA.constants.fuzzySearch) 
			},
			'select': function(e, ui){
				e.preventDefault();
				$(this).val(ui.item.label);
				$(this).parents('form').children('input[name="org:reportsTo"]').val(ui.item.value);
			}
		},
		'person': {
			'source': function(request, response){
				$().LNAGateway().findPersons(function(data){
					var personArray = $().LNAGateway().readLD.persons(data);
					var newArray = $.map(personArray.persons, function(item){ return {'label': item['foaf:name'], 'value': item['@id']}});
					response(newArray);
					return newArray;
				}, this.element[0].value + LNA.constants.fuzzySearch) 
			},
			'select': function(e, ui){
				e.preventDefault();
				$(this).val(ui.item.label);
				$(this).parents('form').children('input[name="dc:creator"]').val(ui.item.value);
			}
		}		
	},

	'init': function(){
		LNA.activateTags();
		LNA.activateModals();
		LNA.activateControls();
		LNA.activateWidgets();
		LNA.activateAutocompletes();
		LNA.activateDropdowns();
		LNA.activateOnChanges();
	}
}

//Create dialogs from modal form elements
if($('.formModal').size()>0){
	$('.formModal').dialog({
		autoOpen: false,
		width: '80%',
	    modal: true,
	    show: {
	    	effect: "drop",
			duration: 300,
			direction: "up"
		},
		hide: {
			effect: "drop",
			duration: 300,
			direction: "up"
		}
	});
};

LNA.init();


//Find login form button and attach the toggle behavior
// $('button[data-toggle="loginForm"]').click(function (e){
// 	e.preventDefault();
// 	$('#loginForm').toggleClass('loginVisible');
// 	return false;
// });