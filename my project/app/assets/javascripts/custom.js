
$(document).ready(function(){
    
    $('#sbm_search_bar #search_by_merchants').click(function(){        
        var keywordVal = $(this).val();
        if (keywordVal == "Macy's, JCPenney, Target...") {
            $(this).val('');
        }
    });
    
    $('#sbm_search_bar #search_by_merchants').blur(function(){
        var keywordVal = $(this).val();
        if (keywordVal == "") {
            $(this).val("Macy's, JCPenney, Target...");
        }
    });
    
    /// responsive menu
    wWidth = $(window).width();
    if (wWidth < 801) {
       $(".container .row").find(".vertical_listings").removeClass("vertical_listings");
    }
    $( window ).on( "orientationchange", function( event ) {
       resizeMenu();
    });
    $(window).on("resize", resizeMenu);
    
    function resizeMenu(){
         wWidth = $(window).width();
        if (wWidth > 800) {
            $(".mps_less_listings").addClass("vertical_listings");
             $(".popularCat").addClass("vertical_listings");
        }else{
            $(".container .row").find(".vertical_listings").removeClass("vertical_listings");
        }
    }
});