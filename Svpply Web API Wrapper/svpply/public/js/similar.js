function queryObj() {
    var result = {}, keyValuePairs = location.search.slice(1).split('&');

    keyValuePairs.forEach(function(keyValuePair) {
        keyValuePair = keyValuePair.split('=');
        result[keyValuePair[0]] = keyValuePair[1] || '';
    });

    return result;
}

function handleresponse(data){

  console.log(data);

}


$(function() {
	var dictionary = queryObj();
	var id = dictionary['id'];

	$.getJSON('similars/?id='+id, handleresponse);
	
	//$.getJSON('https://api.svpply.com/v1/products/'+id+'/similars.json', handleresponse);
	
});
	
	
