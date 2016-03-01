//Create dialogs from modal form elements
$('.formModal').dialog({
	autoOpen: false,
	width: '80%',
    maxWidth: 600,
    modal: true
})

//Find corresponding buttons and attach the open event
$('button[data-toggle="modal"]').click(function (e) { 
	$($(this).data('target')).dialog("open");
});