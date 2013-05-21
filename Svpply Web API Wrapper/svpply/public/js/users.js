var $container;

function queryObj() {
    var result = {}, keyValuePairs = location.search.slice(1).split('&');

    keyValuePairs.forEach(function(keyValuePair) {
        keyValuePair = keyValuePair.split('=');
        result[keyValuePair[0]] = keyValuePair[1] || '';
    });

    return result;
}

function handleresponse(data){
	console.log( data );
	var users = data.response.users;
	users.sort(sortdesc_byfollowers);
    console.log(users);

    $container.empty().css( {
		'width' : '480px',
		'margin-left':'auto',
		'margin-right':'auto',
		'margin-bottom':'4em',
		'margin-top':'1em'
		
	});

	$container.append($('<div>top wanters</div><div><small>by number of followers</small></div>'));
    var count = 0;

    $.each(users, function(){
	  	  count++;
	  	  var id = this.id_str
	  	    , img = this.avatar
	  		, title = this.display_name.substring(0, 40)
	  		, location = this.location
	  		, followers = this.users_followers_count
	  		;
		   var itemheight = 48;
	 	   var $div = $('<div id="listitem"/>').css({
	 		   'width' : '100%',
	 		   'height': itemheight + 'px',
	 		   'margin-bottom': '2px',
	 		   'background':'#eee'
	 	   });
	   
	 	   var $img = $('<img src="' + img + '"/>');
	 	   $img.css({
	 		   'position': 'absolute',
	 		   'width' : '48px',
	 		   'height' : '48px',
	 		   'opacity':'0.8'
	 	   });
		   
		   var $name = $('<div/>').text(title).css({
	 		   'position': 'absolute',
	 		   'width' : '240px',
	 		   'height' : '48px',
			   'left' : '50px',
			   'padding' : '0.3em'
		   });
		   
		   var $num = $('<div/>').text(followers).css({
	 		   'position': 'absolute',
	 		   'height' : '48px',
			   'right' : '0px',
			   'padding' : '0.3em'
		   });
		   
		   $div.append( $img ).append($name).append($num);
		   $container.append( $div );
			
	    });

}

function sortdesc_byfollowers(a, b){
  if (a.users_followers_count<b.users_followers_count) return 1;
  if (a.users_followers_count>b.users_followers_count) return -1;
  return 0;
}

$(function() {
	var dictionary = queryObj();
	var id = dictionary['id'];
	$container = $('<div id="container"><div class="status">loading...</div></div>');
	var $header = $('<div/>');
	$('body').append($header).append($container);
	$.getJSON('users/?id='+id, handleresponse);

	$.getJSON('product/?id='+id, function(data){
		
		var p = data.response.product;
		var title = p.page_title;
		var image = p.image;
	
		$header.html(
			title + '<br><br>'
		).css( {
			'width':'480px',
			'margin-left':'auto',
			'margin-right':'auto',
			'margin-top':'4em'
		});
		
		var $img = $('<img src="' + image + '">').css('width', '480px');
		$header.append($img);
	});
	
});
	
	
