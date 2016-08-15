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
			{'title': 'All Rights Reserved', 
			 'value': 'All Rights Reserved',
			 'class': 'closedAccess', 
			 'type': 'ali:license_ref',
			 'uri': 'http://www.copyright.gov/title17/'},
			{'title': 'Embargoed', 
			 'value': 'Embargoed',
			 'class': 'closedAccess', 
			 'type': 'ali:license_ref',
			 'uri': 'http://www.copyright.gov/title17/'},
			 {'title': 'CC-BY 2.0', 
			 'value': 'CC-BY 2.0', 
			 'class': 'openAccess',
			 'type': 'ali:license_ref',
			 'uri': 'https://creativecommons.org/licenses/by/2.0/'},
			 {'title': 'CC-BY-NC 2.0', 
			 'value': 'CC-BY-NC 2.0', 
			 'class': 'openAccess',
			 'type': 'ali:license_ref',
			 'uri': 'https://creativecommons.org/licenses/by-nc/2.0/'},
			 {'title': 'CC-BY-ND 2.0', 
			 'value': 'CC-BY-ND 2.0', 
			 'class': 'openAccess',
			 'type': 'ali:license_ref',
			 'uri': 'https://creativecommons.org/licenses/by-nd/2.0/'},
			 {'title': 'CC-BY 4.0', 
			 'value': 'CC-BY 4.0', 
			 'class': 'openAccess',
			 'type': 'ali:license_ref',
			 'uri': 'https://creativecommons.org/licenses/by/4.0/'},
			 {'title': 'CC-BY-NC 4.0', 
			 'value': 'CC-BY-NC 4.0', 
			 'class': 'openAccess',
			 'type': 'ali:license_ref',
			 'uri': 'https://creativecommons.org/licenses/by-nc/4.0/'},
			 {'title': 'CC-BY-ND 4.0', 
			 'value': 'CC-BY-ND 4.0', 
			 'class': 'openAccess',
			 'type': 'ali:license_ref',
			 'uri': 'https://creativecommons.org/licenses/by-nd/4.0/'}
		],		
		'fuzzySearch' : ''		//Add ~2 or something here to make some searches fuzzy by default
	},
	'errors': [],
	'params': {},

	//this set of functions are callbacks for LNAGateway.*()
	'loadPersonCards': function(data, textStatus, xhr){
		var dataArray = $.fn['LNAGateway']().readLD.persons(data);
		if(typeof xhr != "undefined") var links = $.fn['LNAGateway']().parseLink(xhr.getResponseHeader('link'));
		LNA.fillPager(links);
		$(dataArray.persons).each(function(i, person){
			var node = $('#templates .person').clone();
			node.find('h1').text(person['foaf:givenName']+' '+person['foaf:familyName']);
			if(person['foaf:image'] != ''){
				node.find('img').attr('src', person['foaf:image']);
			}
			node.attr('href', LNA.convertPath(person['@id']));
			if(person['foaf:title']!=''){
				node.find('p[property="title"]').text(person['foaf:title']+', '+person['orgLabel']);
			} else {
				node.find('p[property="title"]').text(person['orgLabel']);
			}
			$('.cardContainer').append(node);
		});
	},
	'loadOrgCards': function(data, textStatus, xhr){
		var dataArray = $.fn['LNAGateway']().readLD.orgs(data);
		if(typeof xhr != "undefined") var links = $.fn['LNAGateway']().parseLink(xhr.getResponseHeader('link'));	
		LNA.fillPager(links);
		$(dataArray).each(function(i, org){
			var node = $('#templates .org').clone();
			node.find('h1').text(org['skos:prefLabel']);
			node.attr('href', LNA.convertPath(org['@id']));
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
		var dataArray = $.fn['LNAGateway']().readLD.works(data);
		if(typeof xhr != "undefined") var links = $.fn['LNAGateway']().parseLink(xhr.getResponseHeader('link'));
		LNA.fillPager(links);
		$(dataArray).each(function(i, work){
			var node = $('#templates .work').clone();
			node.find('h1').text(work['dc:title']);
			node.attr('href', LNA.convertPath(work['@id']));
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
		var dataArray = $.fn['LNAGateway']().readLD.org(data);	

		console.log(dataArray)

		//render org record
		$('.crumbHere').children().first().text(dataArray.org['skos:prefLabel']);
		$('.record h3').text(dataArray.org['skos:prefLabel']);
		$('.orgAltLabels').text(dataArray.org['skos:altLabel'].join(', '));
		$('.orgPurpose').text(dataArray.org['org:purpose']);
		if(typeof dataArray.parent['skos:prefLabel'] != "undefined"){
			$('.orgParent').text(dataArray.parent['skos:prefLabel']);
			$('.parent button').click(function(e){LNA.openLink(e, LNA.convertPath(dataArray.parent['@id']))});
		} else {
			$('.parent').hide();
		}
		if(dataArray.org['owltime:hasEnd'] != ''){
			$('.orgDateRange').text(dataArray.org['owltime:hasBeginning'].substr(0,4) + '-' + dataArray.org['owltime:hasEnd'].substr(0,4) );	
		} else {
			$('.orgDateRange').text(dataArray.org['owltime:hasBeginning'].substr(0,4) + '-Present');
		}
		$('.orgData .edit').data('formData', dataArray);

		//clear all spinners
		$('main .spinner').parent().remove();

		//If it exists, insert the name of the org in the changeEvent form field
		$('#changedFromField').val(dataArray.org['skos:prefLabel']);

		//render change event names
		if(Object.keys(dataArray.resultedFrom).length > 0) $('.resultedFrom').empty();
		$.each(dataArray.resultedFrom, function(k, v){ LNA.fillChange($('.resultedFrom'), k, v)});
		$.each(dataArray.changedBy, function(k, v){ LNA.fillChange($('.changedBy'), k, v)});

		//render OnlineAccounts
		$.each(dataArray.accounts, function(k, v){ LNA.fillAccount($('.orgData .iconList'), v) });

		//render Suborgs
		$.each(dataArray.children, function(k, v){ LNA.fillSuborgs($('.children .iconList'), v) });

		LNA.activateModals();
	},

	'loadOrgPersons': function(data, textStatus, xhr){
		var dataArray = $.fn['LNAGateway']().readLD.persons(data);		

		//clear all spinners
		$('.related .spinner').parent().remove();

		//render Person list
		$.each(dataArray.persons, function(k, v){ LNA.fillPersons($('.members .iconList'), v) });

		LNA.activateModals();
	},

	'loadWork': function(data, textStatus, xhr){
		var dataArray = $.fn['LNAGateway']().readLD.work(data);	

		//render work record
		var ellipsis = dataArray.work['dc:title'].length > 10 ? '...' : '';
		$('.crumbHere').children().first().text(dataArray.work['dc:title'].slice(0,10)+ellipsis);
		$('h3').text(dataArray.work['dc:title']);
		$('.workCreator').text(dataArray.person['foaf:name']);
		$('.creator button').click(function(e){ LNA.openLink(e, LNA.convertPath(dataArray.person['@id']))});
		$('.workAuthorList').text(dataArray.work['bibo:authorList'].join(', '));
		$('.workDate').text(dataArray.work['dc:date'].slice(0,10));
		$('.workDOI').append($('<a>').attr('href', LNA.convertPath(dataArray.work['bibo:doi'])).text(dataArray.work['bibo:doi']));
		$('.workAbstract').text(dataArray.work['dc:abstract']);
		$('.workPublisher').text(dataArray.work['dc:publisher']);
		$('.workCitation').text(dataArray.work['dc:bibliographicCitation']);
		$('.workURIs').html(dataArray.work['bibo:uri'].join('<br>'));

		$('button.edit').data('formData', dataArray);

		//render License list
		$.each(dataArray.licenses, function(k, v){ LNA.fillLicense($('.sidebar .iconList'), v) });

		//clear all spinners
		$('main .spinner').parent().remove();

		LNA.activateModals();
	},

	'loadPerson': function(data, textStatus, xhr){
		var dataArray = $.fn['LNAGateway']().readLD.person(data);		

		console.log(dataArray)

		//render person data
		$('.sidebar h1').text(dataArray.person['foaf:name']);
		$('#rssLink').attr('href', dataArray.person['@id'] + '/works/feed.atom')
		$('.crumbHere').children().first().text(dataArray.person['foaf:name']);
		if(dataArray.person['foaf:image'] != '') $('.sidebar img').attr('src', dataArray.person['foaf:image']);

		$('button.edit').data('formData', dataArray.person);

		$('.personName').html('Title: '+dataArray.person['foaf:title']+'<br>'+'Given: '+dataArray.person['foaf:givenName']+'<br>'+'Family: '+dataArray.person['foaf:familyName']+'<br>'+'Written: '+dataArray.person['foaf:name']);
		$('.personEmail').text(dataArray.person['foaf:mbox']);
		$('.personImage').text(dataArray.person['foaf:image']);
		$('.personHomepage').html(dataArray.person['foaf:homepage'].join('<br />'));

		$('.personPrimary').text(dataArray.person['orgLabel']);
		$('.parent button').click(function(e){LNA.openLink(e, LNA.convertPath(dataArray.person['org:reportsTo']))});

		//clear all spinners
		$('.sidebar .spinner, .affiliations .spinner').parent().remove();

		//render affiliations
		$.each(dataArray.memberships, function(k, v){ LNA.fillMembership($('.affiliations .iconList'), v) });

		//render OnlineAccounts
		$.each(dataArray.accounts, function(k, v){ LNA.fillAccount($('.sidebar .iconList'), v) });

		LNA.activateModals();
	},
	'loadPersonWorks': function(data, textStatus, xhr){
		var dataArray = $.fn['LNAGateway']().readLD.personWorks(data);	

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
		viewButton.click(function(e){ LNA.openLink(e, LNA.convertPath(data['org:organization']))});
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
		button.data('formData', data);
		var icon = LNA.isCurrentDate(data['ali:start_date'], data['ali:end_date']) ? "<i class='fa fa-check-circle green' aria-hidden='true'></i>" : "<i class='fa fa-ban red' aria-hidden='true'></i>";
		label.html(icon + " " + data['dc:title']);
		parent.prepend(node);
	},	
	'fillSuborgs': function(parent, data){
		var node = $('#templates .subOrg').clone();
		node.find('[property="name"]').text(data['skos:prefLabel']);
		node.find('button').click(function(e){ LNA.openLink(e, LNA.convertPath(data['@id'])) });

		parent.append(node);
	},		

	'fillChange': function(parent, id, written){
		var node = $('#templates .subOrg').clone();
		node.find('[property="name"]').text(written);
		node.find('button').click(function(e){ LNA.openLink(e, LNA.convertPath(id)) });

		parent.append(node);
	},	

	'fillPersonWorks': function(parent, data){
		var node = $('#templates .work').clone();
		var title = node.find('.itemTitle').first();
		var authorList = node.find('.itemAuthors').first();
		var viewButton = node.find('.view').first();

		var date = data['dc:date'].substr(0,4);
		var authors = data['bibo:authorList'].join(', ');
		viewButton.click(function(e){ LNA.openLink(e, LNA.convertPath(data['@id']))});

		title.text(data['dc:title'] + ' (' + date + ')');
		authorList.text(authors);

		parent.append(node);
	},		

	'fillPersons': function(parent, data){
		var node = $('#templates .person').clone();
		node.find('[property="name"]').text(data['foaf:givenName']+' '+data['foaf:familyName']);
		node.find('button').click(function(e){ LNA.openLink(e, LNA.convertPath(data['@id'])) });

		$(parent).append(node);
	},

	'fillPager': function(pageArray){
		if(typeof pageArray == "undefined" || pageArray.total == 1) {
			return true;
		};

		//We can't just use the links because a search will have form data that needs to be resubmitted.
		//This handler overrides the standard anchor tags and submits the form for the correct page of search results.
		var pageHandler = function(e, path){
			e.preventDefault();
			$('#pagerForm').attr('method', 'POST');
			$('#pagerForm').attr('action', path);
			$('#pagerForm').submit();
		};

		if(pageArray.current > 1) $('.firstPage').click(function(e){ pageHandler(e, LNA.convertPath(pageArray.first))});
		else $('.firstPage').hide();

		if(pageArray.current < pageArray.total) $('.lastPage').click(function(e){ pageHandler(e, LNA.convertPath(pageArray.last))});
		else $('.lastPage').hide();

		$('.currentPage').find('span').text(pageArray.current + ' of ' + pageArray.total);
		
		if(pageArray.prev && pageArray.first != pageArray.prev) $('.previousPage').click(function(e){ pageHandler(e, LNA.convertPath(pageArray.prev))});
		else $('.previousPage').hide();
		
		if(pageArray.next && pageArray.next != pageArray.last) $('.nextPage').click(function(e){ pageHandler(e, LNA.convertPath(pageArray.next))});
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
			if(v && (k=='owltime:hasBeginning' || k=='owltime:hasEnd')) data[k] = data[k].split('T')[0];			
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
	editWork: function(targetForm, data){
		var $targetForm = $(targetForm);
		$.each(data.work, function(k, v){
			if(v && k=='dc:date') data.work[k] = data.work[k].split('T')[0];			
			$targetForm.find('[name="'+k+'"]').val(data.work[k]);
		});
		$targetForm.find('[name="foaf:name"]').val(data.person['foaf:name']);

		var authorList = $targetForm.find('[name="bibo:authorList"]');
		authorList.importTags('');
		$(data.work['bibo:authorList']).each(function(i, v) {authorList.addTag(v)});

		var uri = $targetForm.find('[name="bibo:uri"]');
		uri.importTags('');
		$(data.work['bibo:uri']).each(function(i, v) {uri.addTag(v)});

		var subject = $targetForm.find('[name="dc:subject"]');
		subject.importTags('');
		$(data.work['dc:subject']).each(function(i, v) {subject.addTag(v)});
	},

	editOrg: function(targetForm, data){
		var $targetForm = $(targetForm);
		$.each(data.org, function(k, v){
			if(v && (k=='owltime:hasBeginning' || k=='owltime:hasEnd')) data.org[k] = data.org[k].split('T')[0];	
			$targetForm.find('[name="'+k+'"]').val(data.org[k]);
		});

		var akaList = $targetForm.find('[name="skos:altLabel"]');
		akaList.importTags('');
		$(data.org['skos:altLabel']).each(function(i, v) {akaList.addTag(v)});
	},	

	'editLicense': function(targetForm, data){
		var $targetForm = $(targetForm);
		$targetForm.find("[value='"+data['dc:description']+"']").attr('checked', true);		
		$.each(data, function(k, v){
			if(v && (k=='ali:start_date' || k=='ali:end_date')) data[k] = data[k].split('T')[0];				
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
	'convertPath': function(pid){
		//This takes an LNA ID (which is a path on the same system as this app) and turns it into a link to the corresponding admin page
		var len = _base_url.length;
		if(pid.substring(0,len) == _base_url && pid.indexOf('admin') == -1) pid = _base_url + 'admin/' + pid.substring(len);
		return(pid);
	},

	'openLink': function(e, link){
		if(e.ctrlKey || e.metaKey){
			window.open(link, '_new');
		}
		else window.location.href = link;
	},

	'goHome': function(){
		location.href=LNA.convertPath(_base_url);
	},

	'goToID': function(pid){
		location.href=LNA.convertPath(pid);	
	},

	'checkErrors': function(){
		if(LNA.errors.length > 0){
			var errors = LNA.errors.join('<br>');
			$('#errorModalBody').html(errors);
			$('#errorModal').dialog("open");
			LNA.errors = [];
			return false;
		} else return true;
	},

	'replaceOptPlaceholder': function(targetForm, id){
		var $targetForm = $(targetForm);
		var oldOpt = $targetForm.data('opt').split('/');
		oldOpt.pop();
		oldOpt.push(id);
		var newOpt = oldOpt.join('/')
		$targetForm.data('opt', newOpt);
	},

	'isCurrentDate': function(start, end){
		//assumes dates are YYYY-MM-DDT...
		if(typeof start == "undefined" || start == "" || start == null) return false;
		//end date may be empty
		if(typeof end == "undefined" || end == "" || end == null) end = "2999-12-31T00:00:00Z";
		start = start.split('T')[0];
		end = end.split('T')[0];
		var startArray = start.split('-');
		var startDate = new Date(startArray[0], startArray[1]-1, startArray[2]);
		var endArray = end.split('-');
		var endDate = new Date(endArray[0], endArray[1]-1, endArray[2]);
		var today = new Date();

		return today >= startDate && today <= endDate;
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
	//Find any inputs that use tag suggestion behavior and activate them
	'activateSuggestionTags': function(){
		$('.tagSuggestionBehavior').not('[data-ready="true"]').tagsInput({
			'delimiter': ';;;',
			'width': '90%',
			'height': '3em',
			'defaultText': '',
			'autocomplete': {'organization1': '1', 'organization2': '2'}
		});
		$('.tagSuggestionBehavior').attr('data-ready', 'true');
	},	
	'activateWidgets': function(){
		$('.dateBehavior').not('[data-ready="true"]').datepicker({
			'dateFormat': 'yy-mm-dd',
			'changeMonth': true,
			'changeYear': true,
			'yearRange': '1900:2020',
			'selectOtherMonths': true,
			'showOtherMonths': true,
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
			$(field).focusout(function(e){ LNA.autocompletes[$(field).data('autocomplete-type')].verify(e, field); });
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
		},
		'setChangeEventTarget': function(e){
			var selected = $(e.target);
			var formNode = selected.parents('form');

			// LNA.replaceOptPlaceholder
		}
	},

	//Autocompletes need specific instructions on setting values, so this is an index of those
	'autocompletes': {
		'org': {
			'source': function(request, response){
				$.fn['LNAGateway']().findOrgs(function(data){
					var orgArray = $.fn['LNAGateway']().readLD.orgs(data);
					var newArray = $.map(orgArray, function(item){ return {'label': item['skos:prefLabel'], 'value': item['@id']}});
					response(newArray)
					return newArray;
				}, this.element[0].value + LNA.constants.fuzzySearch, 1, true) 
			},
			'select': function(e, ui){
				e.preventDefault();
				$(this).val(ui.item.label);
				$(this).parents('form').children('input[name="org:organization"]').val(ui.item.value);
			},
			'verify': function(e, field){
				e.preventDefault();
				if($(field).parents('form').children('input[name="org:organization"]').val() == ''){
					LNA.errors.push('You must click on an item from the dropdown list to select the organization. Typed names will not be accepted.');
					LNA.checkErrors();
				}
			}
		},
		'changeOrg': {
			'source': function(request, response){
				$.fn['LNAGateway']().findOrgs(function(data){
					var orgArray = $.fn['LNAGateway']().readLD.orgs(data);
					var newArray = $.map(orgArray, function(item){ return {'label': item['skos:prefLabel'], 'value': item['@id']}});
					response(newArray)
					return newArray;
				}, this.element[0].value + LNA.constants.fuzzySearch, 1, true) 
			},
			'select': function(e, ui){
				e.preventDefault();
				var orgID = ui.item.value.split('/').pop()
				$(this).val(ui.item.label);
				LNA.replaceOptPlaceholder($(this).parents('form'), orgID);
			},
			'verify': function(e, field){
				e.preventDefault();
				if($(field).parents('form').data('opt').slice(-3) == ';;;'){
					LNA.errors.push('You must click on an item from the dropdown list to select the organization. Typed names will not be accepted.');
					LNA.checkErrors();
				}
			}
		},		
		'reportsTo': {
			'source': function(request, response){
				$.fn['LNAGateway']().findOrgs(function(data){
					var orgArray = $.fn['LNAGateway']().readLD.orgs(data);
					var newArray = $.map(orgArray, function(item){ return {'label': item['skos:prefLabel'], 'value': item['@id']}});
					response(newArray);
					return newArray;
				}, this.element[0].value + LNA.constants.fuzzySearch, 1, true) 
			},
			'select': function(e, ui){
				e.preventDefault();
				$(this).val(ui.item.label);
				$(this).parents('form').children('input[name="org:reportsTo"]').val(ui.item.value);
			},
			'verify': function(e, field){
				e.preventDefault();
				if($(field).parents('form').children('input[name="org:reportsTo"]').val() == ''){
					LNA.errors.push('You must click on an item from the dropdown list to select the reporting organization. Typed names will not be accepted.');
					LNA.checkErrors();
				}
			}			
		},
		'person': {
			'source': function(request, response){
				$.fn['LNAGateway']().findPersons(function(data){
					var personArray = $.fn['LNAGateway']().readLD.persons(data);
					var newArray = $.map(personArray.persons, function(item){ return {'label': item['foaf:name'], 'value': item['@id']}});
					response(newArray);
					return newArray;
				}, this.element[0].value + LNA.constants.fuzzySearch, 1, true) 
			},
			'select': function(e, ui){
				e.preventDefault();
				$(this).val(ui.item.label);
				$(this).parents('form').children('input[name="dc:creator"]').val(ui.item.value);
			},
			'verify': function(e, field){
				e.preventDefault();
				if($(field).parents('form').children('input[name="dc:creator"]').val() == ''){
					LNA.errors.push('You must click on an item from the dropdown list to select the creator. Typed names will not be accepted.');
					LNA.checkErrors();
				}
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
		LNA.activateSuggestionTags();
		LNA.activateDropdowns();
		LNA.activateOnChanges();

		$.fn['LNAGateway']().extendForms();

		LNA.checkErrors();
	}
}

LNA.init();


//Find login form button and attach the toggle behavior
// $('button[data-toggle="loginForm"]').click(function (e){
// 	e.preventDefault();
// 	$('#loginForm').toggleClass('loginVisible');
// 	return false;
// });