
$("document").ready(function() {

	//alert("alerts suck");
	/* GET VIDEO */
	var video = $('#output_video')[0];

	var webcamError = function(e) {
		alert('Webcam error!', e);
	};

	if (navigator.getUserMedia) {
		navigator.getUserMedia({audio: true, video: true}, function(stream) {
			video.src = stream;
			video.autoplay = true;
			initialize();
		}, webcamError);
	} else if (navigator.webkitGetUserMedia) {
		navigator.webkitGetUserMedia({audio:true, video:true}, function(stream) {
			video.src = window.webkitURL.createObjectURL(stream);
			video.autoplay = true;
			initialize();
		}, webcamError);
	} else {
		//video.src = 'somevideo.webm'; // fallback.
	}

	/* UTLITES */

	window.requestAnimFrame = (function(){
		return  window.requestAnimationFrame       ||
			window.webkitRequestAnimationFrame ||
			window.mozRequestAnimationFrame    ||
			window.oRequestAnimationFrame      ||
			window.msRequestAnimationFrame     ||
			function( callback ){
				window.setTimeout(callback, 1000 / 60);
			};
	})();

	/* DRAWING TO CANVAS */
	var timeOut, lastImageData;
	var canvasSource = $('#canvas_video')[0];
	var canvasBlended = $('#canvas_video_blend')[0];
	var contextSource = canvasSource.getContext('2d');
	var contextBlended = canvasBlended.getContext('2d');
	var soundContext, bufferLoader;

	contextSource.translate(canvasSource.width, 0);
	contextSource.scale(-1, 1);

	function initialize() {
		update();
	}

	function update() {
		drawVideo();
		//blend();
		//checkAreas();
		requestAnimFrame(update);
		//window.webkitRequestAnimationFrame(update);
		//timeOut = setTimeout(update, 1000/60);
	}

	function drawVideo() {
		//contextSource.drawImage(video, 0, 0, video.width, video.height);
		contextSource.drawImage(video, 0, 0, video.width, video.height);
		//console.log('workign');
	}

	


});
