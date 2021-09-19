
var player;
var app = Elm.Main.init({
  node: document.getElementById('elm')
});

var tag = document.createElement('script');
tag.src = "https://www.youtube.com/iframe_api";
var firstScriptTag = document.getElementsByTagName('script')[0];
firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

var isYoutubeApiReady = false;
function onYouTubeIframeAPIReady() {
  isYoutubeApiReady = true;
}

function tryToLoadPlayer(t) {
    if (isYoutubeApiReady && document.getElementById('player')) {
        player = new YT.Player('player', {
          videoId: 'M7lc1UVf-VE',
          playerVars: {
            controls: 0,
            autoplay: 1,
            disablekb: 1,
            enablejsapi: 1,
            iv_load_policy: 3,
            modestbranding: 1,
            showinfo: 0,
            rel: 0
          },
          events: {
            'onReady': onPlayerReady,
            'onStateChange': onPlayerStateChange
          }
        });
    } else {
        requestAnimationFrame(tryToLoadPlayer);
    }
}
requestAnimationFrame(tryToLoadPlayer);

function onPlayerReady(event) {
    event.target.playVideo();
}

function onPlayerStateChange(event) {
    app.ports.fromPlayer.send({msg : "onPlayerStateChange", data : event.data});
}

app.ports.sendToPlayer.subscribe(function (o) {
    if(player){
      if (o.msg == "playVideo") {
        player.playVideo();
      } else if (o.msg == "pauseVideo") {
        player.pauseVideo();
      }
    }
});
