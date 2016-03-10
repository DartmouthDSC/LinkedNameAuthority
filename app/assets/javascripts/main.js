LNA = {
	//this function is a callback for LNAGateway.listPersons
	'loadPersonCards': function(data, textStatus, xhr){
		var dataArray = $().LNAGateway().readLD.persons(data);
		var links = $().LNAGateway().parseLink(xhr.getResponseHeader('link'));
		console.log(links)
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
	}
}

//Create dialogs from modal form elements
if($('.formModal').size()>0){
	$('.formModal').dialog({
		autoOpen: false,
		width: '80%',
	    maxWidth: 600,
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

//Find corresponding buttons and attach the open event
$('button[data-toggle="modal"]').click(function (e) { 
	e.preventDefault();
	$($(this).data('target')).dialog("open");
	return false;
});

//Find control panel buttons and attach the toggle behavior
$('button[data-toggle="controlPanel"]').click(function (e){
	e.preventDefault();
	$('#controlPanel').toggleClass('cpVisible');
	return false;
});

//Find login form button and attach the toggle behavior
// $('button[data-toggle="loginForm"]').click(function (e){
// 	e.preventDefault();
// 	$('#loginForm').toggleClass('loginVisible');
// 	return false;
// });