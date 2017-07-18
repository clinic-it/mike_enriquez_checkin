$(document).on('page:load turbolinks:load', function() {

  $(':checkbox').on('click', function(){
    var className = '.' + $(this).attr('class'),
        count = 0;

    $(className).each(function() {
      if ( $(this).prop('checked') ) {
        count++;
      }
    })

    $(className.replace('check-box', 'count').replace('.', '#')).text(count + ' selected');
  });

});
