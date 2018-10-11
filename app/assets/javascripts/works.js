$(document).on('turbolinks:load', function() {
  if ( $('#works-div').length > 0 ) {
    var freshbooksProjects,
        freshbooksTasks,
        pivotalProjects,
        eventElement,
        table = $('#pivotal-project-stories').DataTable();

    $.getJSON('/works/freshbooks_projects_data', function(data) {
      freshbooksProjects = data;
      populateProject();

      $.getJSON('/works/freshbooks_time_entries_data', function(timeEntriesData) {
        $.each(freshbooksProjects.projects.project, function(index, object) {
          $.each(timeEntriesData, function(index2, object2) {
            if ( object.project_id === object2.title ) {
              if ( typeof object2.project_id === 'undefined' ) {
                object2.project_id = object2.title;
              }

              object2.title = object.name;
            }
          });
        });

        $('#calendar').fullCalendar({
          events: timeEntriesData,
          eventLimit: true,
          eventBorderColor: 'transparent',
          eventBackgroundColor: '#3498db',
          eventTextColor: '#ffffff',
          eventRender: function(event, element) {
            element.find('.fc-time').hide();
          },
          eventAfterAllRender: function(view) {
            $('#calendar-loader').hide();
          },
          eventClick: function(calEvent, jsEvent, view) {
            if ($('#event-popup').is(':visible')) $('#event-popup').toggle();

            $.each(freshbooksTasks.tasks.task, function(index, object) {
              if ( object.task_id === calEvent.task_id ) {
                calEvent.task_name = object.name;
              }
            });

            $('.js-edit-freshbooks-entry').data('project', calEvent.project_id);
            $('.js-edit-freshbooks-entry').data('task', calEvent.task_id);
            $('.js-edit-freshbooks-entry').data('hours', calEvent.hours);
            $('.js-edit-freshbooks-entry').data('notes', calEvent.notes);
            $('.js-edit-freshbooks-entry').data('date', calEvent.date);
            $('.js-edit-freshbooks-entry').data('entry-id', calEvent.id);
            $('.js-freshbooks-delete-logged-hours').data('entry-id', calEvent.id);

            $('#event-popup .event-project').html(calEvent.title);
            $('#event-popup .event-task').html(calEvent.task_name);
            $('#event-popup .event-hours').html(calEvent.hours);
            $('#event-popup .event-notes').html(calEvent.notes.replace(/\n/g, '<br>'));

            eventElement = $(this);

            $('#event-popup').css({
              'left': eventElement.offset().left,
              'top': eventElement.offset().top + eventElement.height() + 15
            }).toggle();
          }
        });
      });
    });

    $.getJSON('/works/freshbooks_tasks_data', function(data) {
      freshbooksTasks = data;
    });

    $.getJSON('/works/pivotal_projects_data', function(data) {
      pivotalProjects = data;

      $.each(data, function(index, object) {
        $('#pivotal-projects').append(`<option value='${object.id}'>${object.name}</option>`);
      });

      sortOptionElements($('#pivotal-projects'));
      populateTable($('#pivotal-projects').val());
    });

    $('#freshbooks-date').datepicker({
      dateFormat: 'yy-mm-dd'
    });

    $('#freshbooks-modal').scroll(function() {
      if ( $('#event-popup').is(':visible') ) {
        $('#event-popup').css({
          'left': eventElement.offset().left,
          'top': eventElement.offset().top + eventElement.height() + 15
        });
      }
    });

    $('.js-edit-freshbooks-entry').click(function() {
      $('#freshbooks-projects').val($(this).data('project'));
      $('#freshbooks-projects').trigger('change');
      $('#freshbooks-tasks').val($(this).data('task'));
      $('#freshbooks-hours').val($(this).data('hours'));
      $('#freshbooks-notes_').val($(this).data('notes'));
      $('#freshbooks-date').val($(this).data('date'));
      $('#freshbooks-time-entry-id').val($(this).data('entry-id'));

      $('.js-freshbooks-log-hours').text('Save Changes');
    });

    $('.js-event-popup-close').click(function() {
      $('#event-popup').hide();
    });

    $(document).mouseup(function(event) {
      var container = $('#event-popup');

      if ( !container.is(event.target) && container.has(event.target).length === 0 ) {
        container.hide();
      }
    });

    $('#pivotal-projects').change(function() {
      populateTable($(this).val());
    });

    $('#freshbooks-projects').change(function() {
      populateTask();
    });

    $('.js-freshbooks-log-hours').click(function() {
      if ( $('#freshbooks-projects').val() !== '' &&
            $('#freshbooks-tasks').val() !== '' &&
            $('#freshbooks-date').val() !== '' ) {

        var clickedElem = $(this),
            prevContent = clickedElem.html();

        clickedElem.html('<i class="fa fa-refresh fa-spin"></i>');
        clickedElem.prop('disabled', true);

        $.ajax({
          type: 'post',
          url: '/works/freshbooks_log_hours',
          data: {
            project_id: $('#freshbooks-projects').val(),
            task_id: $('#freshbooks-tasks').val(),
            hours: $('#freshbooks-hours').val(),
            notes: $('#freshbooks-notes_').val(),
            date: $('#freshbooks-date').val(),
            entry_id: $('#freshbooks-time-entry-id').val()
          },
          success: function(response) {
            $('#calendar').fullCalendar('removeEvents', response);

            var newCalendarData = {
              id: response,
              title: $('#freshbooks-projects option:selected').text(),
              start: moment($('#freshbooks-date').val()).format(),
              end: moment($('#freshbooks-date').val()).format(),
              task_id: $('#freshbooks-tasks').val(),
              hours: $('#freshbooks-hours').val(),
              notes: $('#freshbooks-notes_').val(),
              date: $('#freshbooks-date').val(),
              project_id: $('#freshbooks-projects').val()
            }

            $('#calendar').fullCalendar('renderEvent', newCalendarData);


            $('#freshbooks-time-entry-id').val() === '' ?
              $.notify('Hours has been logged successfully.', 'success') :
              $.notify('Entry has been updated successfully.', 'success');


            clickedElem.html(prevContent);
            clickedElem.prop('disabled', false);
            $('#freshbooks-hours').val('');
            $('#freshbooks-notes_').val('');
            $('#freshbooks-time-entry-id').val('');
          }
        });
      }
      else {
        $.notify('Please fill out fields with (*).', 'error');
      }
    });

    $('.js-freshbooks-delete-logged-hours').click(function() {
      if ( confirm('Are you sure to delete this time entry?') ) {
        var clickedElem = $(this);

        clickedElem.html('<i class="fa fa-refresh fa-spin"></i>');
        $.ajax({
          type: 'post',
          url: '/works/freshbooks_delete_logged_hours',
          data: {
            entry_id: $(this).data('entry-id')
          },
          success: function(response) {
            $('#event-popup').hide();
            clickedElem.html('Delete');
            $('#calendar').fullCalendar('removeEvents', response);
            $.notify('Time entry has been deleted successfully.', 'success');
          }
        });
      }
    });

    $('#freshbooks-modal').on({
      'hide.uk.modal': function() {
        $('.js-freshbooks-log-hours').text('Log Hours');
        $('#freshbooks-hours').val('');
        $('#freshbooks-notes_').val('');
        $('#freshbooks-time-entry-id').val('');
      }
    });

    $(document).on('click', '.js-log-story', function() {
      var projectName = $(this).data('project');

      $('#freshbooks-hours').val($(this).data('hours'));
      $('#freshbooks-notes_').val($(this).data('notes'));

      $('#freshbooks-projects option').each(function(index, element) {
        $(this).removeAttr('selected');

        if ( compareString(projectName, $(this).text()) ) {
          $('#freshbooks-projects').val($(this).attr('value'))
        }
      });

      $('#freshbooks-projects').trigger('change');
      $('#freshbooks-tasks').val($(this).data('task'));

      UIkit.modal('#freshbooks-modal').show();
    });

    $(document).on('click', '.js-state-button', function() {
      var clickedElem = $(this),
          prevContent = clickedElem.html();

      clickedElem.html('<i class="fa fa-refresh fa-spin"></i>');
      clickedElem.prop('disabled', true);

      $.ajax({
        type: 'put',
        url: '/works/pivotal_update_state',
        data: {
          project_id: $('#pivotal-projects').val(),
          story_id: $(this).data('id'),
          new_state: $(this).data('value')
        },
        success: function() {
          clickedElem.html(prevContent);
          clickedElem.prop('disabled', false);
          toggleButton(clickedElem);
        }
      });
    });

    function populateTable(projectID) {
      var projectName = findPivotalProjectName(projectID);

      $('.pivotal-project-stories-container').hide();
      $('#pivotal-table-loader').show();

      $.getJSON(`/works/pivotal_project_stories_data?project_id=${projectID}`, function(data) {
        table.clear().destroy();

        $.each(data, function(index, object) {
          $('#pivotal-project-stories tbody').append(`
            <tr>
              <td>${validateEstimate(object.estimate)}</td>
              <td><a href='${object.url}' target='_blank'>${object.name}</a> <span class='badge badge-${generateTypeBadge(object.story_type)}'>${object.story_type}</span></td>
              <td><span class='uk-hidden'>${sortByState(object.current_state)}</span>${generateButton(object.id)}</td>
              <td><button class='js-log-story btn btn-primary btn-sm' data-project='${projectName}' data-task='${object.freshbooks_task_id}' data-notes='${object.name}' data-hours='${validateEstimate(object.estimate)}'>Log this story</button></td>
            </tr>
          `);

          $(`button[data-id='${object.id}'].state-button`).hide();
          $(`button[data-id='${object.id}'].${object.current_state}`).toggle();
        });

        $('#pivotal-table-loader').hide();
        $('.pivotal-project-stories-container').show();

        table = $('#pivotal-project-stories').DataTable({
          'autoWidth': false,
          'order': [[2, 'asc']],
          'columnDefs': [
            {
              'targets': 3,
              'orderable': false
            },
            {
              'targets': 2,
              'width': '17%',
            },
            {
              'targets': [0, 2, 3],
              'className': 'uk-text-center'
            }
          ]
        });
      });
    }

    function findPivotalProjectName(projectID) {
      var projectName = '';

      $.each(pivotalProjects, function(index, object) {
        if ( object.id == projectID ) {
          projectName = object.name;
        }
      });

      return projectName;
    }

    function compareString(string1, string2) {
      return new RegExp("\\b(" + string1.match(/\w+/g).join('|') + ")\\b", "gi").test(string2);
    }

    function generateButton(storyID) {
      return `
        <button data-value='started' data-id='${storyID}' class='js-state-button state-button start-button unstarted'>Start</button>
        <button data-value='finished' data-id='${storyID}' class='js-state-button state-button finish-button started'>Finish</button>
        <button data-value='delivered' data-id='${storyID}' class='js-state-button state-button deliver-button finished'>Deliver</button>
        <button data-value='accepted' data-id='${storyID}' class='js-state-button state-button accept-button delivered'>Accept</button>
        <button data-value='rejected' data-id='${storyID}' class='js-state-button state-button reject-button delivered'>Reject</button>
        <button data-value='started' data-id='${storyID}' class='js-state-button state-button restart-button rejected'><span class='restart-circle'>&#9679;</span> Restart</button>
      `;
    }

    function toggleButton(element) {
      $(`button[data-id="${element.data('id')}"].state-button`).hide();

      switch(element.data('value')) {
        case 'started':
          $(`button[data-id="${element.data('id')}"].started`).toggle();
          break;
        case 'finished':
          $(`button[data-id="${element.data('id')}"].finished`).toggle();
          break;
        case 'delivered':
          $(`button[data-id="${element.data('id')}"].delivered`).toggle();
          break;
        case 'rejected':
          $(`button[data-id="${element.data('id')}"].rejected`).toggle();
          break;
      }
    }

    function generateTypeBadge(type) {
      switch(type) {
        case 'feature':
          return 'success';
          break;
        case 'bug':
          return 'danger';
          break;
        case 'chore':
          return 'info';
          break;
        default:
          return 'primary';
      }
    }

    function sortByState(state) {
      switch(state) {
        case 'accepted':
          return 8;
          break;
        case 'delivered':
          return 1;
          break;
        case 'finished':
          return 2;
          break;
        case 'started':
          return 3;
          break;
        case 'rejected':
          return 4;
          break;
        case 'planned':
          return 5;
          break;
        case 'unstarted':
          return 6;
          break;
        case 'unscheduled':
          return 7;
          break;
        default:
          return -1;
      }
    }

    function validateEstimate(estimate) {
      return typeof estimate === 'undefined' ? 0 : estimate;
    }

    function populateProject() {
      $('#freshbooks-projects').html('<optgroup label="Internal"></optgroup><optgroup label="Other"></optgroup>');

      $.each(freshbooksProjects.projects.project, function(index, object) {
        object.client_id === null ?
          $('#freshbooks-projects').find('optgroup[label="Internal"]').append(`<option value='${object.project_id}'>${object.name}</option>`) :
          $('#freshbooks-projects').find('optgroup[label="Other"]').append(`<option value='${object.project_id}'>${object.name}</option>`);
      });

      sortOptionElements($('#freshbooks-projects').find('optgroup[label="Internal"]'));
      sortOptionElements($('#freshbooks-projects').find('optgroup[label="Other"]'));
    }

    function populateTask() {
      $('#freshbooks-tasks').html('');

      $.each(freshbooksProjects.projects.project, function(index, object) {
        if ( $('#freshbooks-projects').val() === object.project_id ) {
          $.each(object.tasks.task, function(index, object) {
            $.each(freshbooksTasks.tasks.task, function(index2, object2) {
              if ( object.task_id === object2.task_id) {
                $('#freshbooks-tasks').append(`<option value='${object2.task_id}'>${object2.name}</option>`);
              }
            });
          });
        }
      });

      sortOptionElements($('#freshbooks-tasks'));
    }

    function sortOptionElements(selectElement) {
      var selected = selectElement.val(),
          options = selectElement.find('option');

      options.sort(function(a, b) { return $(a).text() > $(b).text() ? 1 : -1; });
      selectElement.html('').append(options);
      selectElement.val(selected);
    }
  }
});
