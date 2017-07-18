$(document).on('page:load turbolinks:load', function() {

  $('.js-project-tablesorter').tablesorter();

  $(':checkbox').on('click', function(){
    var className = '.' + $(this).attr('class'),
        parentClass = '.' + $(this).attr('class').split('-');
        count = 0,
        dayCount = 0;

    $(className).each(function() {
      if ( $(this).prop('checked') ) {
        count++;
      }
    })

    $(parentClass).find(':checkbox').each(function() {
      if ( $(this).prop('checked') ) {
        dayCount++;
      }
    });

    $(parentClass.replace('.', '#')).text(dayCount + ' selected');
    $(className.replace('check-box', 'count').replace('.', '#')).text(count + ' selected');
  });

  $('.project-select').on('change', function() {
    var project = $($(this).val());

    console.log(project);
    project.siblings().hide();
    project.show();
  });

});
