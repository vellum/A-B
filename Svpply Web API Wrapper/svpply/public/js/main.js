var $container;
var $header;
var isgrid = true;
var storeddata;

function queryObj() {
    var result = {}, keyValuePairs = location.search.slice(1).split('&');

    keyValuePairs.forEach(function(keyValuePair) {
        keyValuePair = keyValuePair.split('=');
        result[keyValuePair[0]] = keyValuePair[1] || '';
    });

    return result;
}

function sortdesc_bysaves(a, b){
  if (a.saves<b.saves) return 1;
  if (a.saves>b.saves) return -1;
  return 0;
}

function handleresponse(data){

  console.log(data);

  var response = data.response
    , products = response.products
	;

  products.sort(sortdesc_bysaves);
  storeddata = products;

  if (isgrid)
  	rendergrid();
  else
	renderlist();
}

function rendergrid(){
    $container.empty();
	$container.css('max-width', 'none');
	$container.css('width', '100%');

	var products = storeddata;
    var count = 0;
    $.each(products, function(){
  	  count++;
  	  var id = this.id_str
  	    , img = this.image
  		, title = this.page_title.substring(0, 40)
  		, notes = this.notes
  		, saves = this.saves
  		, cat = this.category
  		, url = this.page_url
  		, store = this.store
  		, w = this.width
  		, h = this.height
  		;
  		console.log( saves + '\t' + title );
  		var $product = $('<div class="product"/>').css({
  			width: '240px',
  			height: Math.round(240.0*h/w) + 'px'
  		});
		var $img = $('<img src="' + img + '"/>');
  		$product.append($img);
		
  		var $lbl = $('<div class="centeredlabel"></div>').css({
  			width: '200px',
  			height: Math.round(240.0*h/w - 15) + 'px'
  		});
  		$lbl.append('<div><div class="ranking"><span class="ranking">' + zeroFill(count,2) + '</span></div>' + title + '<br><small>' + saves + ' votes</small></div>');


  		$product.append($lbl);
		
		var $menu = $('<div class="centeredlabel"></div>').css({
  			width: '200px',
  			height: Math.round(240.0*h/w - 15) + 'px'
  		}).html(
			'<!--<a class="menu" href="similar.html?id=' + id + '">similar products</a><br><br>--><a class="menu" href="people.html?id=' + id + '">people who want this</a>'
		).css({
			'pointer-events':'none',
			'opacity':'0'
		}); 
		$product.append($menu);
		
		$product.hover(
			
			// on
			function(){
				$product.css('background', '#1db7cb');
				$lbl.css('opacity', 0);
				$img.css('opacity', 0.2);
				$menu.css({
					'pointer-events':'auto',
					'opacity':'1'
				});
			}, 
			
			// off
			function(){
				$product.css('background', 'black');
				$lbl.css('opacity', 1);
				$img.css('opacity', 0.8);
				$menu.css({
					'pointer-events':'none',
					'opacity':'0'
				});
			}
		);


  	    $container.append($product);
    });

  	var options = {
  			autoResize: true, 
  			container: $('#container'), 
  			offset: 2, 
  			itemWidth: 240 
  		};

  	var handler = $('.product');
  	handler.wookmark(options);
}
function zeroFill( number, width )
{
  width -= number.toString().length;
  if ( width > 0 )
  {
    return new Array( width + (/\./.test( number ) ? 2 : 1) ).join( '0' ) + number;
  }
  return number + ""; // always return a string
}
function renderlist(){

    $container.empty().css( {
		'width' : '80%',
		'max-width' : '720px',
		'margin-left':'auto',
		'margin-right':'auto',
		'margin-bottom':'4em'
		
	});

	var products = storeddata;
    var count = 0;
	var maxsaves = 10000;
	
    $.each(products, function(){
		
  	  count++;
  	  var id = this.id_str
  	    , img = this.image
  		, title = this.page_title.substring(0, 37)
  		, notes = this.notes
  		, saves = this.saves
  		, cat = this.category
  		, url = this.page_url
  		, store = this.store
  		, w = this.width
  		, h = this.height
  		;
		//var dim =
		if ( count == 1 ) maxsaves = saves;
		var pct = Math.round( saves / maxsaves * 100);
		console.log( saves + ', ' + maxsaves );
	   var itemheight = 80;
	   var $div = $('<div id="listitem"/>').css({
		   'width' : '100%',
		   'height': itemheight + 'px',
		   'margin-bottom': '2px',
		   'background':'#eee'
	   });
	   
	   var $imgholder = $('<div class="product"/>').css({
		   'width' : pct + '%',
		   'height': itemheight + 'px',
		   'background' : '#000',
		   'padding':0,
		   'margin':0,
		   'position': 'absolute',
		   'z-index':1,
		   'opacity' : 1,
		   'overflow':'hidden'
	   });
	   
	   var $img = $('<img src="' + img + '"/>');
	   $img.css({
		   'width' : '100%',
		   'opacity':'0.8'
	   });


	   
	   var $lblcontainer = $('<div />').css({
		   'position' : 'absolute',
		   'z-index' : 999,
		   'height':'2.125em',
		   'width':pct+'%',
		   'overflow':'hidden'
	   });
	   
	   var text = zeroFill(count,2) + ' ' + title.substring(0,40);
	   var $lbl = $('<div />').text(text).css({
		   'color' : '#fff',
		   'padding':'1em',
		   'width':'1000px'
	   });
	   
	   $lblcontainer.append( $lbl );

	   var $lblcontainerd = $('<div />').css({
		   'position' : 'absolute',
		   'z-index' : 0,
		   'height':'2.125em',
		   'width':'100%',
		   'overflow':'hidden'
	   });
	   
	   var $lbld = $('<div />').text(text).css({
		   'color' : '#555',
		   'padding':'1em',
		   'width':'1000px'
	   });
	   $lblcontainerd.append( $lbld );
	   $div.append($lblcontainerd);
	   var $lbl2 = $('<div/>').html('<nobr>' + saves + '</nobr>').css({
		   'position' : 'absolute',
		   'right' : 0,
		   'z-index' : 1000,
		   'text-align':'right',
		   'padding':'1em'
	   });

	   $div.append( $imgholder.append($img) ).append( $lblcontainer ).append($lbl2);
	   $container.append( $div );
	   
	   
    });
}

function togglegrid(){
	isgrid = !isgrid;
	if ( isgrid ){
		$('#currentitem').text('grid');
		$('#menuitem').text('or list');
		//rewrite querystring
		if ( storeddata ) rendergrid();
	} else {
		$('#currentitem').text('list');
		$('#menuitem').text('or grid');
		//rewrite querystring
		
		if ( storeddata ) renderlist();
	}
	$('.fallback').css('display','none');

}

$(function() {
	var dictionary = queryObj();
	var key = dictionary['q'];
	var searchie = ( key ) ? key : '';
	var showlist = dictionary['l'] == 1;


	$container = $('<div id="container"><div class="status">loading...</div></div>');
	$('body').append($container);

	if ( showlist ) {
		isgrid = true;
		togglegrid();
	} else {
		isgrid = false;
		togglegrid();
	}
	

	$('#q').attr('value', searchie);
	if (!key) 
		$.getJSON('search/', handleresponse);
	else
		$.getJSON('search/?q='+encodeURIComponent(key), handleresponse);


	$('#menuitem').click(function(){
		togglegrid();
	});
	$('nav li ul').hide().removeClass('fallback');
	$('nav li').hover(function () {
		$('ul', this).stop().slideToggle(0);
	});
	
});
	
	
