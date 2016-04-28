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
			 'accountRoot': ''},  
			{'title': 'ORCiD',
			 'value': 'orcid',
		     'class': 'orcid',
		     'homepage': 'http://orcid.org/',
		     'accountRoot': 'http://orcid.org/'},
		    {'title': 'Academia.edu',
			 'value': 'academia',
		     'class': 'academia',
		     'homepage': 'http://academia.edu/',
		     'accountRoot': 'http://dartmouth.academia.edu/'},
			{'title': 'Plum',
			 'value': 'plum',
		     'class': 'plum',
		     'homepage': 'http://plu.mx/dartmouth/',
		     'accountRoot': 'http://plu.mx/dartmouth/u/'}
		],
		'licenses':[
			{'title': 'Dartmouth OA', 
			 'value': 'Dartmouth OA',
			 'class': 'openAccess',
			 'type': 'ali:license_ref',
			 'uri': 'https://creativecommons.org/licenses/by-nc/4.0/'},
			{'title': 'CC-BY 2.0', 
			 'value': 'CC-BY 2.0', 
			 'class': 'openAccess',
			 'type': 'ali:license_ref',
			 'uri': 'https://creativecommons.org/licenses/by/2.0/'},
			{'title': 'All Rights Reserved', 
			 'value': 'All Rights Reserved',
			 'class': 'closedAccess', 
			 'type': 'ali:license_ref',
			 'uri': 'http://www.copyright.gov/title17/'}
		],		
		'fuzzySearch' : ''		//Add ~2 or something here to make some searches fuzzy by default
	},
	//this set of functions are callbacks for LNAGateway.*()
	'loadPersonCards': function(data, textStatus, xhr){
		var dataArray = $().LNAGateway().readLD.persons(data);
		if(typeof xhr != "undefined") var links = $().LNAGateway().parseLink(xhr.getResponseHeader('link'));
		LNA.fillPager(links);
		$(dataArray.persons).each(function(i, person){
			var node = $('#templates .person').clone();
			node.find('h1').text(person['foaf:givenName']+' '+person['foaf:familyName']);
			if(person['foaf:image'] != ''){
				node.find('img').attr('src', person['foaf:image']);
			}
			node.attr('href', person['@id']);
			if(person['foaf:title']!=''){
				node.find('p[property="title"]').text(person['foaf:title']+', '+person['orgLabel']);
			} else {
				node.find('p[property="title"]').text(person['orgLabel']);
			}
			$('.cardContainer').append(node);
		});
	},
	'loadOrgCards': function(data, textStatus, xhr){
		var dataArray = $().LNAGateway().readLD.orgs(data);
		if(typeof xhr != "undefined") var links = $().LNAGateway().parseLink(xhr.getResponseHeader('link'));	
		LNA.fillPager(links);
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
			$('.cardContainer').append(node);
		});
	},	

	'loadWorkCards': function(data, textStatus, xhr){
		var dataArray = $().LNAGateway().readLD.works(data);
		if(typeof xhr != "undefined") var links = $().LNAGateway().parseLink(xhr.getResponseHeader('link'));
		LNA.fillPager(links);
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
			$('.cardContainer').append(node);
		});
	},	

	'loadOrg': function(data, textStatus, xhr){
		var dataArray = $().LNAGateway().readLD.org(data);	

		//render org record
		$('.crumbHere').children().first().text(dataArray.org['skos:prefLabel']);
		$('.record h3').text(dataArray.org['skos:prefLabel']);
		$('.orgAltLabels').text(dataArray.org['skos:altLabel'].join(', '));
		$('.orgPurpose').text(dataArray.org['org:purpose']);
		if(typeof dataArray.parent['skos:prefLabel'] != "undefined"){
			$('.orgParent').text(dataArray.parent['skos:prefLabel']);
			$('.parent button').click(function(e){LNA.openLink(e, dataArray.parent['@id'])});
		} else {
			$('.parent').hide();
		}
		if(dataArray.org['owltime:hasEnd'] != ''){
			$('.orgDateRange').text(dataArray.org['owltime:hasBeginning'].substr(0,4) + '-' + dataArray.org['owltime:hasEnd'].substr(0,4) );	
		} else {
			$('.orgDateRange').text(dataArray.org['owltime:hasBeginning'].substr(0,4) + '-Present');
		}

		//clear all spinners
		$('main .spinner').parent().remove();

		//render OnlineAccounts
		$.each(dataArray.accounts, function(k, v){ LNA.fillAccount($('.orgData .iconList'), v) });

		//render Suborgs
		$.each(dataArray.children, function(k, v){ LNA.fillSuborgs($('.children .iconList'), v) });

		LNA.activateModals();
	},

	'loadOrgPersons': function(data, textStatus, xhr){
		var dataArray = $().LNAGateway().readLD.persons(data);		

		//clear all spinners
		$('.related .spinner').parent().remove();

		//render Person list
		$.each(dataArray.persons, function(k, v){ LNA.fillPersons($('.members .iconList'), v) });

		LNA.activateModals();
	},

	'loadWork': function(data, textStatus, xhr){
		var dataArray = $().LNAGateway().readLD.work(data);	

		//render work record
		var ellipsis = dataArray.work['dc:title'].length > 10 ? '...' : '';
		$('.crumbHere').children().first().text(dataArray.work['dc:title'].slice(0,10)+ellipsis);
		$('h3').text(dataArray.work['dc:title']);
		$('.workCreator').text(dataArray.person['foaf:name']);
		$('.creator button').click(function(e){ LNA.openLink(e, dataArray.person['@id'])});
		$('.workAuthorList').text(dataArray.work['bibo:authorList'].join(', '));
		$('.workDate').text(dataArray.work['dc:date'].slice(0,10));
		$('.workDOI').append($('<a>').attr('href', dataArray.work['bibo:doi']).text(dataArray.work['bibo:doi']));
		$('.workAbstract').text(dataArray.work['dc:abstract']);
		$('.workPublisher').text(dataArray.work['dc:publisher']);
		$('.workCitation').text(dataArray.work['dc:bibliographicCitation']);

		//render License list
		$.each(dataArray.licenses, function(k, v){ LNA.fillLicense($('.sidebar .iconList'), v) });

		//clear all spinners
		$('main .spinner').parent().remove();

		LNA.activateModals();
	},

	'loadPerson': function(data, textStatus, xhr){
		var dataArray = $().LNAGateway().readLD.person(data);		

		//render person data
		$('.sidebar h1').text(dataArray.person['foaf:name']);
		$('.crumbHere').children().first().text(dataArray.person['foaf:name']);
		if(dataArray.person['foaf:image'] != '') $('.sidebar img').attr('src', dataArray.person['foaf:image']);

		$('button.edit').data('formData', dataArray.person);

		$('.personName').html('Title: '+dataArray.person['foaf:title']+'<br>'+'Given: '+dataArray.person['foaf:givenName']+'<br>'+'Family: '+dataArray.person['foaf:familyName']+'<br>'+'Written: '+dataArray.person['foaf:name']);
		$('.personEmail').text(dataArray.person['foaf:mbox']);
		$('.personImage').text(dataArray.person['foaf:image']);
		$('.personHomepage').html(dataArray.person['foaf:homepage'].join('<br />'));

		$('.personPrimary').text(dataArray.person['orgLabel']);
		$('.parent button').click(function(e){LNA.openLink(e, dataArray.person['org:reportsTo'])});

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
		var button = node.find('button').first();
		var label = node.find('.accountName').first();
		var iconClass = $.grep(LNA.constants.onlineAccounts, function(o){ return data['dc:title'] == o['title']});
		if(iconClass.length > 0) node.addClass(iconClass[0].class);
		button.attr('title', 'edit '+ data['dc:title'] + ' account');
		button.data('formData', data);
		label.text(data['foaf:accountName'].split('/').pop());
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
		editButton.data('formData', data);
		parent.prepend(node);
	},
	'fillLicense': function(parent, data){
		var node = $('#templates .license').clone();
		var button = node.find('button').first();
		var label = node.find('.licenseName').first();
		var iconClass = $.grep(LNA.constants.licenses, function(o){ return data['dc:title'] == o['title']});
		if(iconClass.length > 0) node.addClass(iconClass[0].class);		
		button.attr('title', 'edit '+ data['dc:title'] + ' account');
		button.data('formData', data)
		label.text(data['dc:title']);
		parent.prepend(node);
	},	
	'fillSuborgs': function(parent, data){
		var node = $('#templates .subOrg').clone();
		node.find('[property="name"]').text(data['skos:prefLabel']);
		node.find('button').click(function(e){ LNA.openLink(e, data['@id']) });

		parent.append(node);
	},		

	'fillPersonWorks': function(parent, data){
		var node = $('#templates .work').clone();
		var title = node.find('.itemTitle').first();
		var authorList = node.find('.itemAuthors').first();
		var viewButton = node.find('.view').first();

		var date = data['dc:date'].substr(0,4);
		var authors = data['bibo:authorList'].join(', ');
		viewButton.click(function(e){ LNA.openLink(e, data['@id'])});

		title.text(data['dc:title'] + ' (' + date + ')');
		authorList.text(authors);

		parent.append(node);
	},		

	'fillPersons': function(parent, data){
		var node = $('#templates .person').clone();
		node.find('[property="name"]').text(data['foaf:givenName']+' '+data['foaf:familyName']);
		node.find('button').click(function(e){ LNA.openLink(e, data['@id']) });

		$(parent).append(node);
	},

	'fillPager': function(pageArray){
		if(typeof pageArray == "undefined" || pageArray.total == 1) {
			return true;
		}
		if(pageArray.current > 1) $('.firstPage').attr('href', pageArray.first);
		else $('.firstPage').hide();

		if(pageArray.current < pageArray.total) $('.lastPage').attr('href', pageArray.last);
		else $('.lastPage').hide();

		$('.currentPage').find('span').text(pageArray.current + ' of ' + pageArray.total);
		
		if(pageArray.prev && pageArray.first != pageArray.prev) $('.previousPage').attr('href', pageArray.prev)
		else $('.previousPage').hide();
		
		if(pageArray.next && pageArray.next != pageArray.last) $('.nextPage').attr('href', pageArray.next);
		else $('.nextPage').hide();

		$('.pager').show();
	},

	//edit functions load data into edit modals
	editPerson: function(targetForm, data){
		var $targetForm = $(targetForm);
		$.each(data, function(k, v){
			$targetForm.find('[name="'+k+'"]').val(data[k]);
		});
		$targetForm.find('[name="skos:prefLabel"]').val(data['orgLabel']);
		var homepage = $targetForm.find('[name="foaf:homepage"]');
		homepage.importTags('');
		$(data['foaf:homepage']).each(function(i, v){ homepage.addTag(v)});
	},	
	editAffiliation: function(targetForm, data){
		var $targetForm = $(targetForm);
		$.each(data, function(k, v){
			$targetForm.find('[name="'+k+'"]').val(data[k]);
		});
		$targetForm.find('[name="skos:prefLabel"]').val(data['orgLabel']);

		//data-opt on this form has a placeholder (;;;) for the account ID. Replace it with the actual ID
		LNA.replaceOptPlaceholder(targetForm, data['@id'].substr(1));
	},

	'editAccount': function(targetForm, data){
		var $targetForm = $(targetForm);
		$targetForm.find('[name="dc:title"]').val(data['dc:title']);
		var accountParts = data['foaf:accountName'].split('/')
		$targetForm.find('[name="accountID"]').val(accountParts.pop());
		$targetForm.find('[name="accountRoot"]').val(accountParts.join('/'));
		$targetForm.find('[name="foaf:accountServiceHomepage"]').val(data['foaf:accountServiceHomepage']);

		//data-opt on this form has a placeholder (;;;) for the account ID. Replace it with the actual ID
		LNA.replaceOptPlaceholder(targetForm, data['@id'].substr(1));
	},
	'editLicense': function(targetForm, data){
		var $targetForm = $(targetForm);
		console.log(data)
		$targetForm.find("[value='"+data['dc:description']+"']").attr('checked', true);		
		$.each(data, function(k, v){
			$targetForm.find('[name="'+k+'"]').val(data[k]);
		});

		//data-opt on this form has a placeholder (;;;) for the account ID. Replace it with the actual ID
		LNA.replaceOptPlaceholder(targetForm, data['@id'].substr(1));
	},	
	'deleteAccount': function(targetForm, data){
		var $targetForm = $(targetForm);

		//data-opt on this form has a placeholder (;;;) for the account ID. Replace it with the actual ID
		LNA.replaceOptPlaceholder(targetForm, data['@id'].substr(1));
	},	
	'deleteAffiliation': function(targetForm, data){
		var $targetForm = $(targetForm);

		//data-opt on this form has a placeholder (;;;) for the account ID. Replace it with the actual ID
		LNA.replaceOptPlaceholder(targetForm, data['@id'].substr(1));
	},
	//deletePerson is not necessary
	'deleteLicense': function(targetForm, data){
		var $targetForm = $(targetForm);

		//data-opt on this form has a placeholder (;;;) for the account ID. Replace it with the actual ID
		LNA.replaceOptPlaceholder(targetForm, data['@id'].substr(1));
	},	


	//helpers
	'openLink': function(e, link){
		if(e.ctrlKey || e.metaKey){
			window.open(link, '_new');
		}
		else window.location.href = link;
	},

	'goHome': function(){
		location.href=_base_url;
	},

	'replaceOptPlaceholder': function(targetForm, id){
		var $targetForm = $(targetForm);
		var oldOpt = $targetForm.data('opt').split('/');
		oldOpt.pop();
		oldOpt.push(id);
		var newOpt = oldOpt.join('/')
		$targetForm.data('opt', newOpt);
	},

	//Find corresponding buttons and attach the open event
	'activateModals': function(){
		//activateModals may be called more than once, so undo whatever was done before.
		$('[data-toggle="modal"]').unbind("click");

		$('[data-toggle="modal"]').click(function (e) { 
			e.preventDefault();
			$($(this).data('target')).dialog("open");
			var formData = $($(this).data('formData'))[0]
			var forms = $($(this).data('target')).find('form');
			forms.each(function(i, v){
				if(typeof $(v).data('load') != "undefined"){
					LNA[$(v).data('load')]($(v), formData);
				}
			});
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
		'prefillLicenses': function(e){
			var selected = $(e.target);
			var formNode = selected.parents('form');
			var licenseType = $.grep(LNA.constants.licenses, function(o){ return selected.val() == o['title']});

			if(typeof licenseType[0] == "undefined") return false;

			formNode.find('input[name="dc:title"]').val(licenseType[0].title);
			formNode.find('input[name="ali:uri"]').val(licenseType[0].uri);
			formNode.find('input[name="dc:description"]').filter('[value="'+licenseType[0].type+'"]').attr('checked', true);
		},		
		'mergeAccountName': function(e){
			var selected = $(e.target);
			var formNode = selected.parents('form');
			var merge = selected.val();
			var accountValue = formNode.find('select[name="template"]').val();
			if(typeof accountValue != "undefined"){
				//this should be the case for adds
				var accountType = $.grep(LNA.constants.onlineAccounts, function(o){ return accountValue == o['value']});
				if(accountType.length > 0){
					merge = accountType[0].accountRoot + merge;
				}
			} else if (typeof formNode.find('input[name="accountRoot"]').val() != "undefined"){
				//this should be the case for edits
				merge = formNode.find('input[name="accountRoot"]').val() + '/' + merge;
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

		LNA.activateModals();

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

		LNA.activateTags();

		LNA.activateControls();
		LNA.activateWidgets();
		LNA.activateAutocompletes();
		LNA.activateDropdowns();
		LNA.activateOnChanges();
		$().LNAGateway().extendForms();
	}
}

LNA.init();


//Find login form button and attach the toggle behavior
// $('button[data-toggle="loginForm"]').click(function (e){
// 	e.preventDefault();
// 	$('#loginForm').toggleClass('loginVisible');
// 	return false;
// });