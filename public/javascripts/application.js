(function($){

  $(function() {
    $('ul.gallery a').lightbox();
  });

  $.fn.lightbox = function(options) {
    var options = $.extend({
      padding: 5
    }, options);

    var show = function() {
      container.show().animate({ opacity: 1 }, 200);

      win.bind('scroll.lightbox', redraw);
      win.bind('keyup.lightbox', function(e) {
        if (working) return;

        if (e.keyCode == 37) loadPrevious();
        if (e.keyCode == 39) loadNext();
        if (e.keyCode == 27) hide();

        return false;
      });
    };

    var create = function() {
      if (container) return;

      backdrop  = $('<div id="lightbox_backdrop"></div>').hide().css('opacity', 0);
      container = $('<div id="lightbox"></div>').hide().css('opacity', 0);

      backdrop.click(function() { hide(); });

      $('body').append(backdrop).append(container);
    };

    var redraw = function(imgWidth, imgHeight) {
      if (!backdrop.is(':visible')) backdrop.css('height', doc.height()).css('width', doc.width());

      var img = container.find('img:visible');
      if (img.length) {
        imgWidth = img.width();
        imgHeight = img.height();
      }

      if (imgWidth && imgHeight) {
        container.css({
          left: (doc.width()-imgWidth+(options.padding*2))/2,
          top: ((win.height()-imgHeight-(options.padding*2))/2)+win.scrollTop()
        });
      }
    };

    var load = function(src, index) {
      currentIndex = index;
      working = true;

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

        var fakeImg = newImg.clone().css('opacity', 0).attr('id', 'lightbox_fake').appendTo('body');
        fakeImg.load(function() {
          redraw(fakeImg.width(), fakeImg.height())
          show();
          fakeImg.remove();
          working = false;
        });
      });

      return false;
    };

    var loadPrevious = function() {
      if (currentIndex > 0) {
        var link = links.slice(currentIndex-1, currentIndex);
        var src = link.attr('href');
        load(src, currentIndex-1);
      }
    };

    var loadNext = function() {
      if (currentIndex < links.length) {
        var link = links.slice(currentIndex+1, currentIndex+2);
        var src = link.attr('href');
        load(src, currentIndex+1);
      }
    };

    var hide = function() {
      backdrop.animate({ opacity: 0 }, 100, null, function() { backdrop.hide(); });
      container.animate({ opacity: 0 }, 100, null, function() { container.hide(); });
      win.unbind('scroll.lightbox').unbind('keyup.lightbox');
    };

    var container, backdrop;
    var doc = $(document);
    var win = $(window);
    var links = this;
    var currentIndex = 0;
    var working = false;

    links.each(function(index) {
      var link = $(this);
      var src = link.attr('href');
      link.click(function() {
        load(src, index);
        return false;
      });
    });
  };

}(jQuery));