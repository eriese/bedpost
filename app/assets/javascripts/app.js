$(".disease").click(function(e) {
  $(this).find(".risk").toggle();
  $(this).toggleClass("highlight")
});
$(".category").click(function(e) {
  $(this).siblings().toggle();
  var newText;
  if ($(this).text().indexOf("+") < 0 ) {
    newText = $(this).html().replace("–", "+");
  }
  else {
    newText = $(this).html().replace("+", "–");
  }
  $(this).html(newText);
});
$(".response").click(function(e) {
  $(this).find(".continue").toggle();
  $(this).find("input[id='uid']").focus();
  $(".response").not($(this)).toggle();
});
$(".help").on({
  mouseover: function(e) {
    var infoPos = $(this).find("img").position();
  $(this).find(".info").css({top: infoPos.top, left: infoPos.left - 200})
  .show();
  },
  mouseout: function(e) {
    $(this).find(".info").hide()
  }}
)
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
    // var marginWidth = $(window).width() / 55;
    $(".nav li").css("font-size", fontSize);
    // $(".nav li").css("margin-right", marginWidth);
    var optionHeight = 0;
    $(".option").each(function(index) {
      if ($(this).height() > optionHeight) {
        optionHeight = $(this).height();
      };
    });
    $(".option").height(optionHeight);
    $(".option p").each(function(index) {
      var hgt = $(this).height();
      var margin = ($(".option").height() - ( hgt + $(".icon").height())) / 2;
      $(this).css("padding-top", margin);
    });
}
$(window).load(setSize);
$(window).resize(setSize);
