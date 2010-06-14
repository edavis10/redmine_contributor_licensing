jQuery(function($) {
  $.each(contributors, function(index, contributor) {
    $('#content td:contains("'+contributor.name+'")').
      wrapInner(function() {
        return '<span class="'+contributor.state+'" title="'+contributor.state+'"></span>'
      });
  });
});
