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
		console.log(dataArray);
		//clear all spinners
		$('.spinner').parent().remove();

		//render person data
		$('.sidebar h1').text(dataArray.person['foaf:name']);
		$('.crumbHere').children().first().text(dataArray.person['foaf:name']);
		if(dataArray.person['foaf:image'] != '') $('.sidebar img').attr('src', dataArray.person['foaf:image']);

		//render affiliations
		$.each(dataArray.memberships, function(k, v){ LNA.fillMembership($('.affiliations .iconList'), v) });

		//render OnlineAccounts
		$.each(dataArray.accounts, function(k, v){ LNA.fillAccount($('.sidebar .iconList'), v) });

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
		parent.prepend(node);
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
	'init': function(){
		LNA.activateTags();
		LNA.activateModals();
		LNA.activateControls();
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