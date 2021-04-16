'use strict';
let gps = true;

$(document).ready(function() {
  window.addEventListener("message", function(detalye) {
    var detail = detalye.data;
    $(".container").css("display", detail.show ? "none" : "block");
    if (detail.type == "updatemapa") {
      updatemapa(detail.myheading, detail.camheading, detail.x, detail.y);
    } else {
      if (detail.type == "bukas") {
        bukas();
      }
      if (detail.type == "sarado") {
        gps = false
        bukas();
      }
    }
  });
});

function updatemapa(pos, prop, dy, dx) {
  $(".centermap").css("transform", "rotate(" + pos + "deg)");
  $("#carblip").css("transform", "translateX(-50%) translateY(50%) rotate(" + prop + "deg)");
  document.documentElement.style.setProperty("--CoordsX", dy);
  document.documentElement.style.setProperty("--CoordsY", dx);
  var r = "";
  var i = "";
  if (1 == Math.sign(dy)) {
    r = "+";
  }
  if (1 == Math.sign(dx)) {
    i = "+";
  }
  if (Math.abs(dy) < Math.abs(dx)) {
    dy = dy.toFixedFunc(Math.floor(Math.abs(dx)).toString().length - Math.floor(Math.abs(dy)).toString().length + 1);
    dx = dx.toFixedFunc(1);
  } else {
    if (Math.abs(dy) > Math.abs(dx)) {
      dx = dx.toFixedFunc(Math.floor(Math.abs(dy)).toString().length - Math.floor(Math.abs(dx)).toString().length + 1);
      dy = dy.toFixedFunc(1);
    } else {
      parseFloat(dy).toPrecision(1);
      parseFloat(dx).toPrecision(1);
    }
  }
}

Number.prototype.toFixedFunc = function(length) {
  var result = this.toFixed(length);
  return -1 === result.indexOf("e+") ? result : (result = result.replace(".", "").split("e+").reduce(function(object, value) {
    return object + Array(value - object.length + 2).join(0);
  }), length > 0 && (result = result + ("." + Array(length + 1).join(0))), result);
};

let link = '"https://raw.githubusercontent.com/renzuzu/carmap/main/carmap/';
var here = document.getElementById("here");
var type = "satellite";
var z = 7;
var htmlString = "";
var i = 1;
for (; i < Math.pow(2, z - 2) + 1; i++) {
  var j = 1;
  for (; j < Math.pow(2, z - 2) + 1; j++) {
    htmlString = htmlString + "<img src=" + link + type + "/" + z + "_" + j + "_" + i + '.png" alt="" class="map" id="map" />';
  }
}
here.insertAdjacentHTML("afterend", htmlString), setTimeout(fo, 2500), $(".boxOpt").fadeOut();
var mapCharged = true;
let status = true;
let statusA = true;
function sarado() {
  $(".boxOpt").fadeOut();
}

function bukas() {
  if (1 == gps) {
    $(".carhudmap").fadeOut();
    tulog(300);
    $("#gps").fadeOut();
    gps = false;
  } else {
    if (0 == gps) {
      $("#gps").fadeIn();
      tulog(300);
      $(".carhudmap").fadeIn();
      gps = true;
    }
  }
}
var map = "satellite";
var box = document.getElementById("maploc");

function fo() {
  mapCharged = true;
}

function tulog(interval) {
  var lastCssUpdate = (new Date).getTime();
  var a = 0;
  for (; a < 1e7 && !((new Date).getTime() - lastCssUpdate > interval); a++) {
  }
}
setInterval(() => {
  if (mapCharged) {
    $(".fadeout").fadeOut();
    $(".loading").fadeOut();
  }
}, 150);
