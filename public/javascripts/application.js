$(document).ready(function(){
  $('#hint').on('click', function(event){
    event.preventDefault();

    $.get('/game/hint', function(data){
      $('.modal-header h2').text(data);
    });

    $('#hint-modal').modal('show');
  });
});