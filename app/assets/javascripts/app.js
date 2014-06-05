$(".disease").click(function(e) {
  $(this).find(".risk").toggle();
  $(this).toggleClass("highlight")
});
$(".category").click(function(e) {
  $(this).siblings().toggle();
});
console.log("here")
