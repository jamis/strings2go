/* Modified from "Building iPhone Apps with HTML, CSS, and Javascript" by Jonathan Stark */

var hist = [];
var startUrl = "data/contents.html";

$(document).ready(function(){ 
  if(navigator.userAgent.toLowerCase().indexOf('iphone') != -1) {
    loadPage(startUrl);
  } else {
    loadPage("badbrowser.html")
  }
});

function loadPage(url) {
  scrollTo(0,0);
  $('#container').load(url + ' #content', function(){
    var title = $('h2').html() || 'Strings to Go';
    $('h1').html(title);
    $('h2').remove();
    $('.leftButton').remove();

    hist.unshift({'url':url, 'title':title});
    if(hist.length > 1) {
      $('#header').append('<div class="leftButton">' + hist[1].title + "</div>");
      $('#header .leftButton').click(function(e){
        $(e.target).addClass('clicked');
        var thisPage = hist.shift();
        var previousPage = hist.shift();
        loadPage(previousPage.url);
      });
    }
    $('#container a').click(function(e){
      e.preventDefault();
      loadPage(e.target.href);
    });
  });
}
