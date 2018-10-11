$(document).on('turbolinks:load', function() {
  $('#users-table').DataTable({
    'columnDefs': [
      {
        'targets': 1,
        'orderable': false
      }
    ]
  });
});
