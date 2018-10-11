$(document).on('turbolinks:load', function() {
  $('#users-table').DataTable({
    'columnDefs': [
      {
        'targets': 1,
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
