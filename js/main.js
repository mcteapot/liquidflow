
$("document").ready(function() {

	/* GLOBAL VARS */
	var video = $('#output_video')[0];
	var moveX = 0; // DEBUG
	var handPoints;
	var smoother = new Smoother(0.85, [0, 0, 0, 0, 0]);
	/* GET VIDEO */
	var webcamError = function(e) {
		alert('Webcam error!', e);
	};

	if (navigator.getUserMedia) {
		navigator.getUserMedia({audio: false, video: true}, function(stream) {
			video.src = stream;
			video.autoplay = true;
			initialize();
		}, webcamError);
	} else if (navigator.webkitGetUserMedia) {
		navigator.webkitGetUserMedia({audio: false, video: true}, function(stream) {
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

	function fastAbs(value) {
		// equivalent to Math.abs();
		return (value ^ (value >> 31)) - (value >> 31);
	}

	function threshold(value) {
		return (value > 0x15) ? 0xFF : 0;
	}


	function differenceAccuracy(target, data1, data2) {
		if (data1.length != data2.length) return null;
		var i = 0;
		while (i < (data1.length * 0.25)) {
			var average1 = (data1[4*i] + data1[4*i+1] + data1[4*i+2]) / 3;
			var average2 = (data2[4*i] + data2[4*i+1] + data2[4*i+2]) / 3;
			var diff = threshold(fastAbs(average1 - average2));
			target[4*i] = diff;
			target[4*i+1] = diff;
			target[4*i+2] = diff;
			target[4*i+3] = 0xFF;
			++i;
		}
	}

	/* DRAWING TO CANVAS */
	var timeOut, lastImageData;
	var canvasSource = $('#canvas_video')[0];
	var canvasBlended = $('#canvas_video_blend')[0];
	var contextSource = canvasSource.getContext('2d');
	var contextBlended = canvasBlended.getContext('2d');
	var soundContext, bufferLoader;

	//contextSource.translate(canvasSource.width, 0);
	//contextSource.scale(-1, 1);

	function initialize() {
		update();
	}
	
	function update() {
		drawVideo();
		blend();
		/*
		if(moveX > video.width) {
			moveX = 0;
		} else {
			moveX = moveX + 3;
		}
		drawRect(canvasBlended, moveX, 50, 30, 30);
		*/
		handPoints = null;
		handPoints = findHand();
		if(handPoints) {
			var posX = (handPoints[0] + handPoints[2] );
			var posY = (handPoints[1] + handPoints[3] );
			console.log('x ' + (handPoints[0] + handPoints[2] * 1.0/8 + $(video).offset().left));
			console.log('y ' + (handPoints[1] + handPoints[3] * 1.0/8 + $(video).offset().top));
			drawRect(canvasBlended, posX, posY, 30, 30, '#FFA500');
		}
		//checkAreas();
		requestAnimFrame(update);
	}

	function drawVideo() {
		contextSource.drawImage(video, 0, 0, video.width, video.height);
	}

	function blend() {
		var width = canvasSource.width;
		var height = canvasSource.height;
		// get webcam image data
		var sourceData = contextSource.getImageData(0, 0, width, height);
		// create an image if the previous image doesn’t exist
		if (!lastImageData) lastImageData = contextSource.getImageData(0, 0, width, height);
		// create a ImageData instance to receive the blended result
		var blendedData = contextSource.createImageData(width, height);
		// blend the 2 images
		differenceAccuracy(blendedData.data, sourceData.data, lastImageData.data);
		// draw the result in a canvas
		contextBlended.putImageData(blendedData, 0, 0);
		// store the current webcam image
		lastImageData = sourceData;
	}

	function drawRect(canvasId, x, y, width, height, color) {
		var ctx=canvasId.getContext("2d");
		//center origin point
		x = x - (width * 0.5);
		y = y - (height * 0.5);
		ctx.fillStyle = color;
		ctx.fillRect(x, y, width, height);
	}

	function findHand() {
		var finalCoords;
		if (video.readyState === video.HAVE_ENOUGH_DATA) {
			$(video).objectdetect("all", {scaleMin: 3, scaleFactor: 1.1, classifier: objectdetect.frontalface}, function(coords) {
				if (coords[0]) {
					coords = smoother.smooth(coords[0]);
					//console.log(coords);
					finalCoords = coords;
					//drawRect(contextSource, 100, 50, 30, 30, '#FFA500');
					//drawRect(contextSource, coords[0], coords[1], 5, 5, '#FFA500');
					//drawRect(contextSource, coords[2], coords[3], 5, 5, '#F00060');

				} else {
					console.log('nothing to see');
				}
			});
		}
		//console.log(finalCoords);

		return finalCoords;
	}

	


});
