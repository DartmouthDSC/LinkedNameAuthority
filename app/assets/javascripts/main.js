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