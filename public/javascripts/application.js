(function($){

  $(function() {
    $('ul.gallery a').lightbox();
  });

  $.fn.lightbox = function(options) {
    var show = function() {
      redraw();

      container.show().animate({ opacity: 1 }, 200);

      return false;
    };

    var create = function() {
      if (container) return;

      backdrop  = $('<div id="lightbox_backdrop"></div>').hide().css('opacity', 0);
      container = $('<div id="lightbox"></div>').hide().css('opacity', 0);

      backdrop.click(function() { hide(); });

      $('body').append(backdrop).append(container);
    };

    var redraw = function() {
      backdrop.css('height', doc.height()).css('width', doc.width());
    };

    var load = function(src) {
      var link = $(this);
      var src = link.attr('href');

      create();
      redraw();

      backdrop.show().animate({ opacity: 0.9 }, 200);

      var oldImg = container.find('img');
      var newImg = $('<img src="'+src+'"></img>');
      newImg.load(function() {
        if (oldImg.length) {
          oldImg.before(newImg).remove();
        } else {
          container.prepend(newImg);
        }
      
        show();
      });

      return false;
    };

    var hide = function() {
      backdrop.animate({ opacity: 0 }, 100, null, function() { backdrop.hide(); });
      container.animate({ opacity: 0 }, 100, null, function() { container.hide(); });
    };

    var container, backdrop;
    var doc = $(document);
    var links = this;
    links.click(load);
  };

}(jQuery));