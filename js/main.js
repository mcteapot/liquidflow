
$("document").ready(function() {

	//alert("alerts suck");

	var n = navigator,
	is_webkit = false;

	if (n.getUserMedia) {
    	// opera users (hopefully everyone else at some point)
    	n.getUserMedia({video: true, audio: true}, onSuccess, onError);
		console.log("opera user");
	}
	else if (n.webkitGetUserMedia) {
    // webkit users
    	is_webkit = true;
    	n.webkitGetUserMedia({audio:true, video:true}, onSuccess, onError);
		console.log("chrome user");
	}
	else {
    	// moms, dads, grandmas, and grandpas
	}
 
	function onSuccess(stream) {
	    var output = document.getElementById('output'), // a video element
	    source;
	 
	    output.autoplay = true; // you can set this in your markup instead
	 
	    if (!is_webkit) {
	        source = stream;
	    }
	    else {
	        source = window.webkitURL.createObjectURL(stream);
	    }
	 
	    output.src = source;
	}

	function onError() {
	    // womp, womp =(
	}


});




