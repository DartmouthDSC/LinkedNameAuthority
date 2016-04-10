//main.js handles rendering for the LNA web interface
//Interactions with the LNA API are handled in jquery.lnagateway.js

LNA = {
	'constants': {
		//Translates org dc:title to CSS classes
		'onlineAccountIcons':[
			{'title': 'Dartmouth', 'class': 'netID'}
			//todo: fill this in
		]
	},
	//this function is a callback for LNAGateway.listPersons
	'loadPersonCards': function(data, textStatus, xhr){
		var dataArray = $().LNAGateway().readLD.persons(data);
		var links = $().LNAGateway().parseLink(xhr.getResponseHeader('link'));
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
		var iconClass = $.grep(LNA.constants.onlineAccountIcons, function(o){ return data['dc:title'] == o['title']});
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
	//tk
	'fillPersonWorks': function(parent, data){
		var node = $('#templates .work').clone();
		var title = node.find('.itemTitle').first();
		var authorList = node.find('.itemAuthors').first();
		var editButton = node.find('.edit').first();
		var viewButton = node.find('.view').first();

		var date = data['dc:date'].substr(0,4);
		var authors = data['bibo:authorsList'].join(', ');

		title.text(data['dc:title'] + ' (' + date + ')');
		authorList.text(authors);

		parent.prepend(node);
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
		$('button[data-toggle="modal"]').not('[data-ready="true"]').click(function (e) { 
			e.preventDefault();
			$($(this).data('target')).dialog("open");
			return false;
		});
		$('button[data-toggle="modal"]').attr('data-ready', 'true');
	},
	//Find control panel buttons and attach the toggle behavior
	'activateControls': function(){
		$('button[data-toggle="controlPanel"]').click(function (e){
			e.preventDefault();
			$('#controlPanel').toggleClass('cpVisible');
			return false;
		});		
	},
	//Find any inputs that use tag behavior and activate them
	'activateTags': function(){
		$('.tagBehavior').tagsInput({
			'delimiter': ';;;',
			'width': '90%',
			'height': '3em',
			'defaultText': ''
		});
	},
	'activateWidgets': function(){
		$('.dateBehavior').datepicker({
			'dateFormat': 'yy-mm-dd'
		});
	},
	'activateAutocompletes': function(){
		$('.autocompleteBehavior').each(function(i, field){
			$(field).autocomplete({
				'minLength': 3,
				'delay': 100,
				'source': LNA.autocompletes[$(field).data('autocomplete-type')].source,
				'select': LNA.autocompletes[$(field).data('autocomplete-type')].select
			});
		});
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
				}, this.element[0].value) 
			},
			'select': function(e, ui){
				e.preventDefault();
				$(this).val(ui.item.label);
				$(this).parents('form').children('input[name="org:organization"]').val(ui.item.value);
			}
		}
	},

	'init': function(){
		LNA.activateTags();
		LNA.activateModals();
		LNA.activateControls();
		LNA.activateWidgets();
		LNA.activateAutocompletes();
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