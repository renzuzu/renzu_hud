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
    console.log("GETOUT VEH")
    if (key.which == '70') {
        $.post(`https://${GetParentResourceName()}/getoutvehicle`, {}, function(data) {});
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
    document.getElementById("gasbar").style.width = ''+gas+'%'
}

function setCarhp(value) {
    var hp = value * 0.1
    document.getElementById("carhealthbar").style.width = ''+hp+'%'
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
    console.log(bool)
    if (bool) {
        $("#status2").fadeIn();
    } else {
        $("#status2").fadeOut();
    }
}

function setRpm(percent) {
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
    var takbo = (s * 3.6)
    var max = 350
    var bilis = takbo / max
    speed = bilis * 100;
    takbo = takbo.toFixed(0)
    if (takbo >= 100) {
        document.getElementById("speedmeter").style.right = "252px";
    } else if (takbo >= 10) {
        document.getElementById("speedmeter").style.right = "258px";
    } else {
        document.getElementById("speedmeter").style.right = "268px";
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
function setShow(value) {
    //console.log(value)
  if (value) {
        $("#car").animate({
            opacity: "1"
        },400);
        setBelt(false)
        setHeadlights(0)
  } else {
    $("#car").animate({
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
        document.getElementById("seatbelt").style.display = 'none'
        document.getElementById("onseatbelt").style.display = 'block'
    } else {
        document.getElementById("seatbelt").style.display = 'block'
        document.getElementById("onseatbelt").style.display = 'none'
    }
}

function setMileage(value) {
    mileage = value.toFixed(0);
    if (mileage >= 100) {
        document.getElementById("mileage").style.margin = '0 10px 0 0'
    } else if (mileage >= 10) {
        document.getElementById("mileage").style.margin = '0 15px 0 0'
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
    document.getElementById("cartempbar").style.width = ''+temp+'%'
}

function setMode(value) {
    document.getElementById("mode").innerHTML = value;
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

//FUNCTIONS
var renzu_hud = {
    setArmor,
    setHp,
    setMic,
    setStatus,
    setShowstatus,
    setShowstatusv2,

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