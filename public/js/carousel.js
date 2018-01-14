$().ready(function() {
  rotate_carousel()
})

function rotate_carousel() {
  $carousel = $('.carousel')

  $carousel.find('.next-slide')
    .detach()
    .removeClass('next-slide')
    .appendTo($carousel)
    .show()
    .css({opacity: 1})

  $carousel.find('a.slide:first')
    .addClass('next-slide')
    .css({opacity: 0})

  setTimeout(rotate_carousel, 3000);
}
