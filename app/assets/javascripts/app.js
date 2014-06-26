$(".disease").click(function(e) {
  $(this).find(".risk").toggle();
  $(this).toggleClass("highlight")
});
$(".category").click(function(e) {
  $(this).siblings().toggle();
});
$(".response").click(function(e) {
  $(this).find(".continue").toggle();
  $(this).find("input[id='uid']").focus();
  $(".response").not($(this)).toggle();
});
var setSize = function() {
    var fontSize;
    if($(window).width() / 40 > 16) {
      fontSize = $(window).width() / 40;
    }
    else {
      fontSize = 16;
    }
    if (fontSize > 25) {
      fontSize = 25;
    }
    var marginWidth = $(window).width() / 55;
    $(".nav li").css("font-size", fontSize);
    $(".nav li").css("margin-right", marginWidth);
}
$(document).ready(setSize);
$(window).resize(setSize);
