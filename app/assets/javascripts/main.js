$(document).on('turbolinks:load', function() {
  $('a[href="' + this.location.pathname + '"]').parent().addClass('active');
  $('[data-toggle="tooltip"]').tooltip();
});
