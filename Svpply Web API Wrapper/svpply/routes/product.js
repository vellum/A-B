
/*
 * GET Search API
 */

var svpply = require('svpply')
  , api = new svpply.API();

exports.list = function(req, res){
	res.contentType('application/json');
	var querykey = req.query["id"];
	console.log('users who want product: ' + querykey);
	
	// Search products for a specified query. 
	api.products.show(querykey,  
		function(results, error) {

			if (error) { console.log('Error: ' + error + "\n"); }

			//console.log('Results: %j\n', results);
			res.end(JSON.stringify(results, null, 2));

	});

};
