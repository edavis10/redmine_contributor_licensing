jQuery(function($) {
  wrapWithContributorColor = function(contributorState) {
    return '<span class="'+contributorState+'" title="'+contributorState+'"></span>';
  };

  $.each(contributors, function(index, contributor) {
    $('#content td:contains("'+contributor.name+'")').wrapInner(function() {
      return wrapWithContributorColor(contributor.state);
    });

    $('#content .author a:contains("'+contributor.name+'")').wrapInner(function() {
      return wrapWithContributorColor(contributor.state);
    });
  });
});
