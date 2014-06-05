$(".disease").click(function(e) {
  $(this).find(".risk").toggle();
});
$(".category").click(function(e) {
  $(this).siblings().toggle();
});
console.log("here")
