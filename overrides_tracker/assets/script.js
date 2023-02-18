
$(document).ready(function() {
  var clipboard = new ClipboardJS('.clipboard-btn');

  function setTooltip(btn, message) {
    $(btn).attr('title', message)

    var tooltip = new bootstrap.Tooltip($(btn), {
    });
    tooltip.show();
  }

  function hideTooltip(btn) {
    setTimeout(function() {
      $(btn).tooltip('hide');
    }, 1000);
  }

  clipboard.on('success', function(e) {
    setTooltip(e.trigger, 'Copied!');
      hideTooltip(e.trigger);
  });

  clipboard.on('error', function(e) {
    setTooltip(e.trigger, 'Failed!');
      hideTooltip(e.trigger);
  });

  $('.nav-link').click(function() {
    $('.nav-link').removeClass('active');
    $(this).addClass('active');
  }
  );



  $("pre code").html(function(index, html) {
    return html.trim().replace(/^(.*)$/mg, "<span class=\"line\">$1</span>");
  });

  window.onload = function () {
    $('.marked_block').each(function( index ) {
      lines_to_mark = $( this ).data('mark-lines');
      for (var i in lines_to_mark) {
        line_index = lines_to_mark[i]+1;
        if($( this ).children().length > line_index){
          $( this ).children('span:nth-child('+line_index+')').addClass('mark');
        }
      }
    });
  }
  
  $(window).resize(function(){
    if($('.scrollbox').length > 0 ){
     $('.scrollbox').height($(window).height()-$('.scrollbox').position().top);
    }
    $('.content-wrapper').css('min-height', $(window).height()+'px');
  });
  if($('.scrollbox').length > 0 ){
    $('.scrollbox').height($(window).height()-$('.scrollbox').position().top);
  }
  

});