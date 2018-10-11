$(document).ready(function() {
  var target = [1];

  if ( $('#users-table thead th').length === 6 ) target.push(5);

  $('#users-table').DataTable({
    'columnDefs': [
      {
        'targets': target,
        'orderable': false
      }
    ]
  });

  $('.js-image-preview').change(function() {
    if ( this.files && this.files[0] ) {
      var reader = new FileReader();

      reader.onload = function(e) {
        $('.js-image-holder').attr('src', e.target.result);
      }

      reader.readAsDataURL(this.files[0]);
    }
  });
});
