$(function(){
  $('.details-box .details-overlay, .details-box .details-close-button').on('click', function(){
    closeDetailsBox();
  });
});

function showDetailsBox(box) {
  // the same effect and speed as fancybox has in default
  box.fadeIn(300);
}

function closeDetailsBox() {
  $('.details-box').fadeOut(300);
}
