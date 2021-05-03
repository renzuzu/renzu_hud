var carui = 'minimal'
function pedface() {
    console.log("REQUESTING")
    $.post(`https://${GetParentResourceName()}/requestface`, {}, function(data) {
        console.log("POSTED")
        let face = data;
        if (face) {
            console.log("URL")
            let url = 'https://nui-img/' + face + '/' + face + '?t=' + String(Math.round(new Date().getTime() / 1000));
            if (face == 'none') {
                url = 'https://cdn.discordapp.com/attachments/696445330480300032/790173823202099240/newnewnewlogo.png';   
            }
            console.log(url)
            $("#pedface").attr("src", ""+url+"")

        }  
    });
}

$(document).on('click','#start',function(){
    console.log("START")
    $.post(`https://${GetParentResourceName()}/pushtostart`, {}, function(data) {}); 
});

$("body").on("keyup", function (key) {
    if (key.which == '70') {
        $.post(`https://${GetParentResourceName()}/getoutvehicle`, {}, function(data) {});
    }
    if (key.which == '27' || key.which == '8') {
        $.post(`https://${GetParentResourceName()}/closecarcontrol`, {}, function(data) {});
    }
});

function setArmor(s) {
    document.getElementById("armor").style.width = ''+s+'%'
}

function setHp(s) {
    document.getElementById("health").style.width = ''+s+'%'
}

function setMic(type) {
    $("#mic-color").removeClass("amarelo");
    $("#mic-color").removeClass("verde");
    $("#mic-color").removeClass("azul");
    $("#mic-color").removeClass("vermelho");

    switch (type) {
        case 1:
        $("#mic-text").html("Whisper");
        $("#mic-color").addClass("amarelo");
        break;
        case 2:
        $("#mic-text").html("Normal");
        $("#mic-color").addClass("verde");
        break;    
        case 3:
        $("#mic-text").html("Shout");
        $("#mic-color").addClass("vermelho");
        break;
        default:
        $("#mic-text").html("Normal");
        $("#mic-color").addClass("verde");
        break;
    }
}

function setFuelLevel(value) {
    var max = 100;
    var total = value / max
    var gas = total * 100
    //console.log("GASUI")
    if (carui == 'modern') {
        //console.log(carui);
    document.getElementById("gasbar").style.width = ''+gas+'%'
    } else {
        var e = document.getElementById("gasbar");
        let length = e.getTotalLength();
        //console.log(gas)
        let to = length * ((93 - gas) / 100);
        e.style.strokeDashoffset = to;
    }
}

function setCarhp(value) {
    var hp = value * 0.1
    if (carui == 'minimal') {
        var e = document.getElementById("carhealthbar");
        let length = e.getTotalLength();
        console.log(hp)
        let to = length * ((100 - hp) / 100);
        e.style.strokeDashoffset = to;
    } else {
        document.getElementById("carhealthbar").style.width = ''+hp+'%'
    }
}

function onMessageRecieved(event) {
    let item = event;
    
    if (item && item.type === 'streetLabel:MSG') {
        if (!item.active) {
            $("#container").hide();
        } else {
            $("#container").show();

            let direction	= item.direction;
            let zone = item.zone;
            let street = item.street;

            $('#direction').text(direction);
            $('#zone').text(zone);
            $('#street').text(street);
        }
    }
    
    if (item && item.type === 'streetLabel:DATA') {
        let container = document.getElementById('container');

        /* color customization */
        let border = [item.border.r, item.border.g, item.border.b, item.border.a];
        let borderDOM = document.querySelectorAll('#border');

        let direction = [item.direction.r, item.direction.g, item.direction.b, item.direction.a];
        let zone = [item.zone.r, item.zone.g, item.zone.b, item.zone.a];
        let street = [item.street.r, item.street.g, item.street.b, item.street.a];
      
        // // jQuery #direction to proper color & font-size configuration
        // $('#direction').css('color', 'rgba('+direction.join(', ')+')');
        // $('#direction').css('font-size', item.direction.size + 'vh');

        // // jQuery #street to proper color & font-size configuration
        // $('#street').css('color', 'rgba('+street.join(', ')+')');
        // $('#street').css('font-size', item.street.size + 'vh');

        // // jQuery #zone to proper color & font-size configuration
        // $('#zone').css('color', 'rgba('+zone.join(', ')+')');
        // $('#zone').css('font-size', item.zone.size + 'vh');

        for (let i=0; i < borderDOM.length; i++) {
            borderDOM[i].style.color = 'rgba('+border.join(', ')+')';
            borderDOM[i].style.fontSize = item.border.size + 'vh';
        }
    }
}

function toclip(val) {
    return 20 - (val / 5)
}

function setStatus(table) {
    document.getElementById("hunger").style.width = ''+table.hunger+'%'
    document.getElementById("thirst").style.width = ''+table.thirst+'%'
    document.getElementById("stressbar").style.width = ''+table.stress+'%'
    document.getElementById("staminabar").style.width = ''+table.stamina+'%'
    document.getElementById("oxygenbar").style.width = ''+table.oxygen+'%'
    document.getElementById("energybar").style.width = ''+table.energy+'%'
    document.getElementById("food2").style.clip = 'rect('+toclip(table.hunger)+', 100px, 100px, 0)'
    document.getElementById("water2").style.clip = 'rect('+toclip(table.thirst)+', 100px, 100px, 0)'
    document.getElementById("stress2").style.clip = 'rect('+toclip(table.stress)+', 100px, 100px, 0)'
    document.getElementById("stamina2").style.clip = 'rect('+toclip(table.stamina)+', 100px, 100px, 0)'
    document.getElementById("oxygen2").style.clip = 'rect('+toclip(table.oxygen)+', 100px, 100px, 0)'
    document.getElementById("energy2").style.clip = 'rect('+toclip(table.energy)+', 100px, 100px, 0)'
}

function setShowstatus(bool) {
    if (bool) {
        $("#status").fadeIn();
        setTimeout(function(){
            $("#statusbar").fadeIn();
        }, 333);
    } else {
        $("#statusbar").fadeOut();
        setTimeout(function(){
            $("#status").fadeOut();
        }, 333);
    }
}

function setShowstatusv2(bool) {
    //console.log(bool)
    if (bool) {
        $("#status2").fadeIn();
    } else {
        $("#status2").fadeOut();
    }
}

function setRpm(percent) {
    var type = carui
    var rpm = (percent * 100);
    rpm2 = rpm.toFixed(0) * 100
    document.getElementById("rpmmeter").innerHTML = ""+rpm2+"";
    var e = document.getElementById("rpmpath");
    let length = e.getTotalLength();
    let value = rpm;
    let to = length * ((100 - value) / 100);
    val = to / 1000
    e.style.strokeDashoffset = to;
    if (percent > 0.9) {
        e.style.stroke = 'red';
    } else if (percent > 0.7) {
        e.style.stroke = 'orange';
    } else if (percent > 0.4) {
        e.style.stroke = 'yellow';
    } else {
        e.style.stroke = 'white';
    }
}

function setSpeed(s) {
    var type = carui
    var takbo = (s * 3.6)
    var max = 350
    var bilis = takbo / max
    speed = bilis * 100;
    takbo = takbo.toFixed(0)
    if (type == 'minimal') {
        // document.getElementById("speed_minimal").style.display = "block";
        // document.getElementById("speed").style.display = "none";
        document.getElementById("speedmeter").style.right = "20%";
        document.getElementById("speedmeter").style.fontSize  = "1.5vw";
        document.getElementById("speedmeter").style.bottom = "50%";
        if (takbo >= 100) {
            document.getElementById("speedmeter").style.right = "45%";
        } else if (takbo >= 10) {
            document.getElementById("speedmeter").style.right = "45.5%";
        } else {
            document.getElementById("speedmeter").style.right = "47%";
        }
    } else {
        document.getElementById("speedmeter").style.right = "268px";
        document.getElementById("speedmeter").style.bottom = "85px";
        if (takbo >= 100) {
            document.getElementById("speedmeter").style.right = "252px";
        } else if (takbo >= 10) {
            document.getElementById("speedmeter").style.right = "258px";
        } else {
            document.getElementById("speedmeter").style.right = "268px";
        }
    }
    document.getElementById("speedmeter").innerHTML = ""+takbo+"";
    var e = document.getElementById("speedpath");
    let length = e.getTotalLength();
    let value = speed;
    let to = length * ((100 - value) / 100);
    val = to / 1000
    e.style.strokeDashoffset = to;
}

function setCoolant(percent) {
    var water = (percent);
    rpm2 = water.toFixed(0)
    //document.getElementById("rpmmeter").innerHTML = ""+rpm2+"";
    var e = document.getElementById("coolantpath");
    let length = e.getTotalLength();
    let value = water;
    let to = length * ((100 - value) / 100);
    val = to / 1000
    e.style.strokeDashoffset = to;
    // if (percent > 0.9) {
    //     e.style.stroke = 'red';
    // } else if (percent > 0.7) {
    //     e.style.stroke = 'orange';
    // } else if (percent > 0.4) {
    //     e.style.stroke = 'yellow';
    // } else {
    //     e.style.stroke = 'white';
    // }
}

var manual = false
function setShow(table) {
  if (table['bool']) {
        $("#"+table['type']+"").animate({
            opacity: "1"
        },400);
        setHeadlights(0)
  } else {
    $("#"+table['type']+"").animate({
      opacity: "0"
    },400);
  }
}

function setHeadlights(v) {
    if (v == 1) {
        document.getElementById("offlight").style.display = 'none'
        document.getElementById("onlight").style.display = 'block'
        document.getElementById("highlight").style.display = 'none'
    } else if (v == 2) {
        document.getElementById("offlight").style.display = 'none'
        document.getElementById("onlight").style.display = 'none'
        document.getElementById("highlight").style.display = 'block'
    } else {
        document.getElementById("offlight").style.display = 'block'
        document.getElementById("onlight").style.display = 'none'
        document.getElementById("highlight").style.display = 'none'
    }
}

function setBelt(s) {
    if (s) {
        playsoundSeatbelt(s)
        document.getElementById("seatbelt").style.display = 'none'
        document.getElementById("onseatbelt").style.display = 'block'
    } else {
        playsoundSeatbelt(s)
        document.getElementById("seatbelt").style.display = 'block'
        document.getElementById("onseatbelt").style.display = 'none'
    }
}

function playsoundSeatbelt(bool) {
    var audioPlayer = null;
    if (audioPlayer != null) {
        audioPlayer.pause();
    }
    audioPlayer = new Audio("./sounds/" + bool + ".ogg");
    audioPlayer.volume = 0.8;
    audioPlayer.play();
}

function setMileage(value) {
    console.log(value)
    mileage = value.toFixed(0);
    if (mileage >= 1000) {
        document.getElementById("mileage").style.margin = '0 2px 0 0'
    } else if (mileage >= 100) {
        document.getElementById("mileage").style.margin = '0 10px 0 0'
    } else if (mileage >= 10) {
        document.getElementById("mileage").style.margin = '0 15px 0 0'
    }

    //color
    var e = document.getElementById("oilpath");
    if (mileage >= 5000 && mileage < 10000) {
        e.style.stroke = 'yellow'
    } else if(mileage >=10000){
        e.style.stroke = '#C85A17'
    } else {
        e.style.stroke = 'lime'
    }
    document.getElementById("mileage").innerHTML = ''+mileage+''
}

function setWaydistance(value) {
    var dis = value.toFixed(0)
    if (dis >= 1000) {
        document.getElementById("distance").style.margin = '0 -1px 0 0'
    } else if (dis >= 100) {
        document.getElementById("distance").style.margin = '0 10px 0 0'
    } else if (dis >= 10) {
        document.getElementById("distance").style.margin = '0 15px 0 0'
    }
    if (dis <= 0) {
        document.getElementById("distext").innerHTML = ''
        document.getElementById("distance").style.margin = '0 -4px 0 0'
        dis = 'ARRIVE'
    } else {
        document.getElementById("distext").innerHTML = 'DIS'
    }
    document.getElementById("distance").innerHTML = ''+dis+''
}

function setTime(format) {
    var cur = 'Am'
    if (format.hour > 12) {
        cur = 'Pm'
        document.getElementById("timetext").innerHTML = ' Pm' 
    } else {
        cur = 'Am'
        document.getElementById("timetext").innerHTML = ' Am' 
    }
    var formatdate = ''+format.hour+':'+format.min+''
    if (cur == 'Pm' && format.hour > 12) {
        format.hour = format.hour - 12
        formatdate = ''+format.hour+':'+format.min+''
    }
    document.getElementById("time").innerHTML = ''+formatdate+'' 
}

function setGear(gear) {
    if (gear == 0) {
        gear = 'P'
    }
    if (gear == 1) {
        gear = '1st'
    }
    if (gear == 2) {
        gear = '2nd'
    }
    if (gear == 3) {
        gear = '3rd'
    }
    if (gear == 4) {
        gear = '4th'
    }
    if (gear == 5) {
        gear = '5th'
    }
    if (gear == 6) {
        gear = '6th'
    }
    document.getElementById("gear").innerHTML = ''+gear+''
}

function numberWithCommas(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function setInfo(table) {
    document.getElementById("joblabel").innerHTML = ''+table.job+': '+table.joblabel+''
    document.getElementById("moneylabel").innerHTML = ''+numberWithCommas(table.money)+''
    document.getElementById("black_moneylabel").innerHTML = ''+numberWithCommas(table.black)+''
    document.getElementById("banklabel").innerHTML = ''+numberWithCommas(table.bank)+''
}

function setSignal(value) {
    if (value == 'hazard') {
        document.getElementById('left').style.opacity = '0.2'
        document.getElementById('left').style.color = 'white'
        document.getElementById('right').style.opacity = '0.2'
        document.getElementById('right').style.color = 'white'
        setTimeout(function(){
            $("#left").fadeIn();
            $("#right").fadeIn();
            document.getElementById('left').style.opacity = '1'
            document.getElementById('left').style.color = 'lime'
            document.getElementById('right').style.opacity = '1'
            document.getElementById('right').style.color = 'lime'
        }, 533);
    } else {
        document.getElementById(value).style.opacity = '0.2'
        document.getElementById(value).style.color = 'white'
        setTimeout(function(){
            $("#"+value+"").fadeIn();
            document.getElementById(value).style.opacity = '1'
            document.getElementById(value).style.color = 'lime'
        }, 433);
    }
    setTimeout(function(){
        document.getElementById('left').style.opacity = '0.2'
        document.getElementById('left').style.color = 'white'
        document.getElementById('right').style.opacity = '0.2'
        document.getElementById('right').style.color = 'white'
    }, 733);
}

function setManual(bool) {
    manual = bool
    if (bool) {
        $("#shift").animate({
            opacity: "1"
        },400);
    } else {
        $("#shift").animate({
            opacity: "0"
        },400);
    }
}

function setShift(gear) {
    $("#shifter").css(
        "background-image",
        'url("shifter/' + gear + '.png")'
      );
}

function setStart(bool) {
      $("#carui").attr("src", "img/carui_"+bool+".png")
}

function setDoor(s) {
    if (s == 2) {
        document.getElementById('dooropen').style.display = 'block'
        document.getElementById('doorclose').style.display = 'none'
    } else {
        document.getElementById('dooropen').style.display = 'none'
        document.getElementById('doorclose').style.display = 'block'
    }
}

function setHood(s) {
    if (s == 2) {
        document.getElementById('hoodopen').style.display = 'block'
        document.getElementById('hoodclose').style.display = 'none'
    } else {
        document.getElementById('hoodopen').style.display = 'none'
        document.getElementById('hoodclose').style.display = 'block'
    }
}

function setTrunk(s) {
    if (s == 2) {
        document.getElementById('trunkopen').style.display = 'block'
        document.getElementById('trunkclose').style.display = 'none'
    } else {
        document.getElementById('trunkopen').style.display = 'none'
        document.getElementById('trunkclose').style.display = 'block'
    }
}

function setBrake(s) {
    if (s) {
        document.getElementById('handbrakeopen').style.display = 'block'
        document.getElementById('handbrakeclose').style.display = 'none'
    } else {
        document.getElementById('handbrakeopen').style.display = 'none'
        document.getElementById('handbrakeclose').style.display = 'block'
    }
}

function CarMap(detalye) {
    var detail = detalye;
    if (detail.type == "updatemapa") {
        $(".centermap").css("transform", "rotate(" + detail.myheading + "deg)");
        $("#carblip").css("transform", "translateX(-50%) translateY(50%) rotate(" + detail.camheading + "deg)");
        $(":root").css("--Y", detail.y);
        $(":root").css("--X", detail.x);
    } else {
        if (detail.type == "sarado") {
            $(".carhudmap").fadeOut();
            var lastCssUpdate = (new Date).getTime();
            var a = 0;
            for (; a < 1e7 && !((new Date).getTime() - lastCssUpdate > 350); a++) {}
            $("#gps").fadeOut();
        }
        if (detail.type =="bukas") {
            $("#gps").fadeIn();
            var lastCssUpdate = (new Date).getTime();
            var a = 0;
            for (; a < 1e7 && !((new Date).getTime() - lastCssUpdate > 350); a++) {}
            $(".carhudmap").fadeIn();
        }
    }
}

function setTemp(temp) {
    var temp = temp - 50
    if (carui == 'modern') {
        document.getElementById("cartempbar").style.width = ''+temp+'%'
    } else {
        var e = document.getElementById("cartempbar");
        let length = e.getTotalLength();
        let to = length * ((91 - temp) / 100);
        e.style.strokeDashoffset = to;
        if (temp > 80) {
            e.style.stroke = 'red';
        } else if (temp > 70) {
            e.style.stroke = 'orange';
        } else if (temp > 50) {
            e.style.stroke = 'blue';
        } else {
            e.style.stroke = 'skyblue';
        }
    }
}

function setMode(value) {
    if (carui == 'minimal') {
        document.getElementById("mode").innerHTML = value;
        document.getElementById("modediv").style.right = '64%';
        document.getElementById("modediv").style.bottom = '49%';
        document.getElementById("modediv").style.fontSize = '0.5vw';
    } else {
        document.getElementById("mode").innerHTML = value;
    }
}
setMode('NORMAL')

function setDifferential(value) {
    if (value == 0.0) {
        value = 'RWD'
    } else if (value == 1.0) {
        value = 'FWD'
    } else {
        value = 'AWD'
    }
    document.getElementById("diff").innerHTML = value;
}

function setCruiseControl(bool) {
    if (bool) {
        document.getElementById('cruisetext').style.color = 'lime'
    } else {
        document.getElementById('cruisetext').style.color = '#1817179f'
    }
}

function setShowBodyUi(bool) {
    if (bool) {
        document.getElementById('bodyui').style.display = 'block'
        $("#bodystatus").fadeIn();
    } else {
        document.getElementById('bodyui').style.display = 'none'
        $("#bodystatus").fadeOut();
    }
}

function pulse(stroke) {
    var pulsespeed = '2s'
    if (stroke == 'red') {
        pulsespeed = '1s'
    } else if (stroke == 'orange') {
        pulsespeed = '1s'
    } else if (stroke == 'yelow') {
        pulsespeed = '2s'
    } else if (stroke == 'green') {
        pulsespeed = '2s'
    } else if (stroke == 'lime') {
        pulsespeed = '2s'
    }
    var pulseurl = 'data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 200px 100px" enable-background="new 0 0 200px 100px" xml:space="preserve"><polyline fill="none" stroke-width="3px" stroke="'+stroke+'" points="2.4,58.7 70.8,58.7 76.1,46.2 81.1,58.7 89.9,58.7 93.8,66.5 102.8,22.7 110.6,78.7 115.3,58.7 126.4,58.7 134.4,54.7 142.4,58.7 197.8,58.7 "/></svg>'
    var addRule = (function(style){
        var sheet = document.head.appendChild(style).sheet;
        return function(selector, css){
            var propText = Object.keys(css).map(function(p){
                return p+":"+css[p]
            }).join(";");
            sheet.insertRule(selector + "{" + propText + "}", sheet.cssRules.length);
        }
    })(document.createElement("style"));

    addRule(".pulse:after", {
        content: "''",
        display: "block",
        background: "url('"+pulseurl+"') 0 0 no-repeat;",
        width: "100%",
        height: "100%",
        position: "absolute",
        "-webkit-animation": "2s pulse linear infinite",
        "-moz-animation": "2s pulse linear infinite",
        "-o-animation": "2s pulse linear infinite",
        animation: ""+pulsespeed+" pulse linear infinite",
        clip: "rect(0, 0, 100px, 0)"
    });
}


function setUpdateBodyStatus(table) {
    var totalpain = 0
    for (const key in table) {
        var val = table[key] * 0.1;
        //console.log(val)
        if (val == undefined) {
            val = 0.0
        }
        if(key) {
            if (val < 0.4 && val >= 0.1) {
                val = 0.4
            }
            totalpain = totalpain + val
            document.getElementById(key).style.opacity = val;
            if (totalpain > 4) {
                pulse('red')
            } else if(totalpain > 3) {
                pulse('orange')
            } else if (totalpain > 2) {
                pulse('yellow')
            } else if (totalpain > 1) {
                pulse('green')
            } else {
                pulse('lime')
            }
        }
    }
}

function setShowCarcontrol(bool) {
    if (bool) {
        document.getElementById('carcontrolui').style.display = 'block'
        $("#carcontrol").fadeIn();
    } else {
        document.getElementById('carcontrolui').style.display = 'none'
        $("#carcontrol").fadeOut();
    }
}

function post(name,data){
	var name = name;
	var data = data;
	$.post("https://hud/"+name,JSON.stringify(data),function(datab){
		if (datab != "ok"){
			console.log(datab);
		}
	});
}
function indexname(index) {
    if (index == 0) {
        return 'frontleftdoor'
    }
    if (index == 1) {
        return 'frontrightdoor'
    }
    if (index == 2) {
        return 'rearleftdoor'
    }
    if (index == 3) {
        return 'rearrightdoor'
    }
    if (index == 4) {
        return 'hood'
    }
    if (index == 5) {
        return 'trunk'
    }
    if (index == 6) {
        return 'back'
    }
}

function windowname(index) {
    if (index <= 1) {
        return 'frontwindow'
    }
    if (index > 1) {
        return 'rearwindow'
    }
}

function showhidecontrolui(bool,id) {
    if (bool) {
        document.getElementById(''+id+'').style.opacity = '1.0'
        $("#"+id+"").fadeIn();
    } else {
        document.getElementById(''+id+'').style.display = '0.0'
        $("#"+id+"").fadeOut();
    }
}

var bool = false
var hood = false
var trunk = false
var frontleftdoor = false
var frontrightdoor = false
var rearleftdoor = false
var rearrightdoor = false
var rearwindow = false
var frontwindow = false

function setBool(index,type) {
    if (type == 'door') {
        if (index == 0) {
            frontleftdoor = true
        }
        if (index == 1) {
            frontrightdoor = true
        }
        if (index == 2) {
            rearleftdoor = true
        }
        if (index == 3) {
            rearrightdoor = true
        }
        if (index == 4) {
            hood = true
        }
        if (index == 5) {
            trunk = true
        }
    }
    if (type == 'window') {
        if (index <= 1) {
            frontwindow = true
        }
        if (index > 1) {
            rearwindow = true
        }
    }
}

function setDoorState(table) {
    for (const key in table) {
        if (key <= 5 && table[key] == true) {
            var bool = table[key];
            setBool(key,'door')
            showhidecontrolui(bool,indexname(key))
        }
    }
}

function setWindowState(table) {
    for (const key in table) {
        if (key <= 3 && table[key] == true) {
            var bool = table[key];
            setBool(key,'window')
            showhidecontrolui(bool,windowname(key))
        }
    }
}

function Carcontrolcallbackui(type,index) {
    console.log("callback car control")
    if (type == 'window') {
        bool = !bool
        if (index == 2) {
            post("setVehicleWindow2",{})
            showhidecontrolui(bool,'rearwindow')
        } else {
            post("setVehicleWindow1",{})
            showhidecontrolui(bool,'frontwindow')
        }
    }
    if (type == 'seat') {
        //showhidecontrolui(bool,indexname(index))
        if (index == 2) {
            post("setVehicleSeat2",{})
        } else {
            post("setVehicleSeat1",{})
        }
    }
    if (type == 'engine') {
        if (bool) {
            bool = false
        } else {
            bool = true
        }
        //showhidecontrolui(bool,indexname(index))
        post("setVehicleEnginestate",{bool:bool,index:index})
    }
    if (type == 'door') {
        if (index == 4 && hood == false) {
            hood = true
            bool = true
        } else if (index == 4 && hood) {
            hood = false
            bool = false
        }
        if (index == 5 && trunk == false) {
            trunk = true
            bool = true
        } else if (index == 5 && trunk) {
            trunk = false
            bool = false
        }
        if (index == 0 && frontleftdoor == false) {
            frontleftdoor = true
            bool = true
        } else if (index == 0 && frontleftdoor) {
            frontleftdoor = false
            bool = false
        }
        if (index == 1 && frontrightdoor == false) {
            frontrightdoor = true
            bool = true
        } else if (index == 1 && frontrightdoor) {
            frontrightdoor = false
            bool = false
        }
        if (index == 2 && rearleftdoor == false) {
            rearleftdoor = true
            bool = true
        } else if (index == 2 && rearleftdoor) {
            rearleftdoor = false
            bool = false
        }
        if (index == 3 && rearrightdoor == false) {
            rearrightdoor = true
            bool = true
        } else if (index == 3 && rearrightdoor) {
            rearrightdoor = false
            bool = false
        }
        showhidecontrolui(bool,indexname(index))
        post("setVehicleDoor",{bool:bool,index:index})
    }
}

function setWeapon(weapon) {
    console.log(""+weapon+".png")
    var url = "img/weapons/"+weapon+".png"
    $("#weaponimg").attr("src", url)
    setTimeout(function(){
        var x = document.getElementById("weaponimg").naturalWidth
        if (x > 200 && x < 300) {
            document.getElementById("weaponimg").style.height = '37px';
        } else if (x > 300 && x < 400) {
            document.getElementById("weaponimg").style.height = '33px';
        } else if (x > 400) {
            document.getElementById("weaponimg").style.height = '27px';
        } else {
            document.getElementById("weaponimg").style.height = '40px';
        }
    }, 333);
}

function setAmmo(table) {
    var max = table['max'];
    var ammo = table['clip'];
    var percent = ammo / max * 100;
    console.log(percent)
    var bullets = percent;
    //rpm2 = bullets.toFixed(0) * 100
    var e = document.getElementById("weaponpath");
    let length = e.getTotalLength();
    let value = bullets;
    let to = length * ((100 - value) / 100);
    val = to / 1000
    e.style.strokeDashoffset = to;
    document.getElementById("ammotext").innerHTML = ''+table['ammo']+'';
    // if (percent > 0.9) {
    //     e.style.stroke = 'red';
    // } else if (percent > 0.7) {
    //     e.style.stroke = 'orange';
    // } else if (percent > 0.4) {
    //     e.style.stroke = 'yellow';
    // } else {
    //     e.style.stroke = 'white';
    // }
}

function setWeaponUi(bool) {
    if (bool) {
        //document.getElementById("weaponui").style.display = 'block';
        $("#weaponui").fadeIn();
    } else {
        //document.getElementById("weaponui").style.display = 'none';
        $("#weaponui").fadeOut();
    }
}

function setCrosshair(val) {
    if (val <= 5) {
        document.getElementById("crosshair").style.display = 'block';
        var url = "img/crosshair_"+val+".png"
        $("#crosshair").attr("src", url)
    }
}

setWeaponUi(false)

function setCarui(ver) {
    carui = ver
    if (ver == 'minimal') {
        document.getElementById("modern").innerHTML = '';
        document.getElementById("minimal").style.display = 'block';
        document.getElementById("rpmtext").style.right = '68%';
        document.getElementById("rpmtext").style.bottom = '55%';
        document.getElementById("rpmtext").style.fontSize = '0.3vw';
        document.getElementById("mode").style.fontSize = '0.55vw';
        document.getElementById("tempicon").style.right = '23.5%';
        document.getElementById("tempicon").style.bottom = '57%';
        document.getElementById("gasicon").style.right = '21%';
        document.getElementById("gasicon").style.bottom = '47%';
        document.getElementById("gasicon").style.opacity = '0.6';
        document.getElementById("tempicon").style.opacity = '0.6';
        document.getElementById("geardiv").style.right = '42%';
        document.getElementById("geardiv").style.bottom = '42%';
        document.getElementById("geardiv").style.fontSize = '0.4vw';
        document.getElementById("right").style.right = '27%';
        document.getElementById("right").style.bottom = '75%';
        document.getElementById("left").style.right = '69%';
        document.getElementById("left").style.bottom = '75%';
        document.getElementById("milediv").style.right = '41%';
        document.getElementById("milediv").style.bottom = '32%';
        document.getElementById("milediv").style.margin = '1% 1% 1% 1%';
        document.getElementById("milediv").style.background = '#000000';
        document.getElementById("milediv").style.opacity = '0.6';
        document.getElementById("milediv").style.fontSize = '0.5vw';
        document.getElementById("milediv").style.fontSize = '0.5vw';
        document.getElementById("milediv").style.webkitFilter = "drop-shadow(1px 1px 2px rgb(5, 155, 255))";
        document.getElementById("timediv").style.right = '42%';
        document.getElementById("timediv").style.bottom = '72.6%';
        document.getElementById("timediv").style.fontSize = '0.4vw';
        document.getElementById("distancediv").style.right = '53%';
        document.getElementById("distancediv").style.bottom = '73%';
        document.getElementById("distancediv").style.background = '#00000000';
        document.getElementById("distancediv").style.fontSize = '0.4vw';
        document.getElementById("diffdiv").style.right = '33%';
        document.getElementById("diffdiv").style.bottom = '73%';
        document.getElementById("diffdiv").style.background = '#00000000';
        document.getElementById("diffdiv").style.fontSize = '0.4vw';
        setCoolant(100)
    } else {
        document.getElementById("modern").style.display = 'block';
        document.getElementById("minimal").innerHTML = '';
    }
}

function setNitro(nitro) {
    var e = document.getElementById("nitropath");
    let length = e.getTotalLength();
    let value = nitro;
    console.log(nitro)
    let to = length * ((100 - value) / 100);
    val = to / 1000
    e.style.strokeDashoffset = to;
}

function setWheelHealth(table) {
        var index = table[['index']]
        var val = 1 - table[['tirehealth']] / 1000
        console.log(index)
        console.log(val)
        document.getElementById("wheel"+index+"").style.opacity = ''+val+'';  
}

//FUNCTIONS
var renzu_hud = {
    setArmor,
    setHp,
    setMic,
    setStatus,
    setShowstatus,
    setShowstatusv2,
    setShowBodyUi,
    setUpdateBodyStatus,
    setAmmo,
    setWeapon,
    setWeaponUi,
    setCrosshair,
    //CAR
    setShow,
    setRpm,
    setSpeed,
    setCarhp,
    setFuelLevel,
    setHeadlights,
    setBelt,
    setMileage,
    setWaydistance,
    setTime,
    setGear,
    setSignal,
    setInfo,
    setManual,
    setShift,
    setStart,
    setDoor,
    setHood,
    setTrunk,
    setBrake,
    setTemp,
    setMode,
    setDifferential,
    setCoolant,
    setCruiseControl,
    setShowCarcontrol,
    setDoorState,
    setWindowState,
    setCarui,
    setNitro,
    setWheelHealth,

};
setMic(2);

let gps = true;
var mapdiv = document.getElementById("mapdiv");
var zoom = 7;
var content = "";
var index = 1;
var complete = true;
let status = true;
let statusA = true;

function startmap() {
  for (; index < mp(zoom) + 1; index++) {
    var jump = 1;
    generatedimg(jump,zoom,content,index)
  }
}

function mp(val) {
  return Math.pow(2, val - 2)
}

function generatedimg(var1,var2,var3,var4) {
  for (; var1 < mp(var2) + 1; var1++) {
    content = content + "<img src='https://raw.githubusercontent.com/renzuzu/carmap/main/carmap/satellite/" + var2 + "_" + var1 + "_" + var4 + ".png' class='map' id='map' />";
  }
}

window.addEventListener("message", event => {
    const item = event.data || event.detail;
    //console.log(item.type);
    if (renzu_hud[item.type]) {
        renzu_hud[item.type](item.content);
    }
    if (item.hud) {
        renzu_hud[item.hud](item.content);
    }
    if (item.compass) {
        onMessageRecieved(event.data);
    }
    if (item.map) {
        CarMap(item);
    }
});

function downloadcomplete() {
  complete = true;
}

function append(div) {
  $('#'+div+'').append(content)
}

setInterval(() => {
  if (complete) {$(".fadeout").fadeOut();$(".loading").fadeOut();}
}, 550);

startmap()
append('mapdiv')
setTimeout(downloadcomplete, 4000)
pedface()
setMode('NORMAL',carui)