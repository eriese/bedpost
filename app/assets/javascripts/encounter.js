$(window).load(function() {
  $("#time-form").submit(function(e){
    e.preventDefault();
    $.ajax({
      url: "/" + $("#time_type").val() + "_test?encounter_id=" + $("#encounter_id").val(),
      type: "GET",
      success: function(data) {
        $(".results").text(data[$("#d_name").val()]);
      }
    })
  })
})
