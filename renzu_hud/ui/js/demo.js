var carui = 'minimal'
var statusui = 'normal'
var status_type = 'icons'
var class_icon = 'octagon'
var statleft = false
var isambulance = false
var loopfuck = false
function pedface() {
    ////////console.log("REQUESTING")
    $.post(`https://${GetParentResourceName()}/requestface`, {}, function(data) {
        ////////console.log("POSTED")
        let face = data;
        if (face) {
            ////////console.log("URL")
            let url = 'https://nui-img/' + face + '/' + face + '?t=' + String(Math.round(new Date().getTime() / 1000));
            if (face == 'none') {
                url = 'https://nui-img/pedmugshot_01/pedmugshot_01?t123';   // assuming theres a cache
            }
            //////console.log(url)
            $("#pedface").attr("src", ""+url+"")

        }  
    });
}

function getvehdata() {
    ////////console.log("REQUESTING")
    $.post(`https://${GetParentResourceName()}/getvehicledata`, {}, function(data) {
        SetVehData(data)
    });
}

var keyPressed = false
$(document).on('keydown', function(e) {
    var key;
    keyPressed = true;
    key = String.fromCharCode(e.keyCode);
    //this is where you map your key
    if (key === 'W') {
        //console.log(key);
        //or some other code
    }
  $(this).on('keyup', function() {
    if (keyPressed === true) {
      keyPressed = false;
      //console.log('Key no longer held down');
      //or some other code
    }
  });
});

$(document).on('click','#start',function(){
    ////////console.log("START")
    $.post(`https://${GetParentResourceName()}/pushtostart`, {}, function(data) {}); 
});

var pressedkey = 0
const time = new Date().toLocaleTimeString();

function setArmor(s) {
    ////////console.log("time",time)
    if (statusui == 'simple') {
        if (status_type == 'icons') {
            document.getElementById("armorsimple").style.clip = 'rect('+toclip(s)+', 100px, 100px, 0)'
        } else {
            setNoobCircle('armorsimple', s)
        }
    } else {
        document.getElementById("armor").style.width = ''+s+'%'
    }
}

function setHp(s) {
    if (statusui == 'simple') {
        if (status_type == 'icons') {
            document.getElementById("healthsimple").style.clip = 'rect('+toclip(s)+', 100px, 100px, 0)'
        } else {
            setNoobCircle('healthsimple', s)
        }
    } else {
        document.getElementById("health").style.width = ''+s+'%'
    }
}

function setMic(type) {
    if (status_type == 'icons') {
        did = 'microphone'
    } else if (statusui == 'simple') {
        did = 'voipsimplebg'
        if (type == 1) {
            val = 20
            //$("#microphone").css("color", 'rgb(227, 250, 22)');
            $("#microphone").attr('style', "stroke:rgb(227, 250, 22)")
        } else if (type == 2) {
            val = 50
            $("#microphone").attr('style', "stroke:rgb(23, 255, 15)")
            //$("#microphone").css("color", 'rgb(255, 35, 6)');
        } else if (type == 3) {
            val = 100
            $("#microphone").attr('style', "rgb(255, 35, 6)")
            //$("#microphone").css("color", 'rgb(23, 255, 15)');
        }
        setNoobCircle('microphone', val)
    } else {
        did = 'microphone'
    }
    switch (type) {
        case 1:
        new Notify ({status: 'success',title: 'Voice System',text: 'VOIP : Whisper Mode',autoclose: true})
        $("#"+did+"").css("color", 'rgb(227, 250, 22)');
        break;
        case 2:
        new Notify ({status: 'success',title: 'Voice System',text: 'VOIP : Normal Mode',autoclose: true})
        $("#"+did+"").css("color", 'rgb(23, 255, 15)');
        break;    
        case 3:
        new Notify ({status: 'success',title: 'Voice System',text: 'VOIP : Shout Mode',autoclose: true})
        $("#"+did+"").css("color", 'rgb(255, 35, 6)');
        break;
        default:
        new Notify ({status: 'success',title: 'Voice System',text: 'VOIP : Normal Mode',autoclose: true})
        $("#"+did+"").css("color", 'rgb(23, 255, 15)');
        break;
    }
}

function setFuelLevel(value) {
    var max = 100;
    var total = value / max
    var gas = total * 100
    //////////console.log("GASUI")
    if (carui == 'modern') {
        ////////console.log(carui);
    document.getElementById("gasbar").style.width = ''+gas+'%'
    } else if (carui == 'minimal') {
        var e = document.getElementById("gasbar");
        let length = e.getTotalLength();
        ////////console.log(gas)
        let to = length * ((93 - gas) / 100);
        e.style.strokeDashoffset = to;
    } else if (carui == 'simple') {
        var opacity = 1.0 - (gas * 0.01)
        document.getElementById("gasbar").style.clip = 'rect('+toclip(gas)+', 100px, 100px, 0)'
        document.getElementById("gasbg").style.opacity = ''+opacity+''
    }
}

function setCarhp(value) {
    var hp = value * 0.1
    if (carui == 'minimal') {
        var e = document.getElementById("carhealthbar");
        let length = e.getTotalLength();
        ////////console.log(hp)
        let to = length * ((100 - hp) / 100);
        e.style.strokeDashoffset = to;
    } else if(carui == 'modern') {
        document.getElementById("carhealthbar").style.width = ''+hp+'%'
    } else if (carui == 'simple') {
        var opacity = 1.0 - (hp * 0.01)
        document.getElementById("carhealthbg").style.opacity = ''+opacity+''
        document.getElementById("carhealthbar").style.clip = 'rect('+toclip(hp)+', 100px, 100px, 0)'
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

        for (let i=0; i < borderDOM.length; i++) {
            borderDOM[i].style.color = 'rgba('+border.join(', ')+')';
            borderDOM[i].style.fontSize = item.border.size + 'vh';
        }
    }
}

function toclip(val) {
    return 20 - (val / 5)
}

var status_move = []
var move_count = []

function setStatus(t) {
    var table = t['data']
    var type = t['type']
    status_type = type
    for (const i in table) {
        move_count[i] = i
        if (table[i].rpuidiv !== 'null') {
            document.getElementById(table[i].rpuidiv).style.width = ''+table[i].value+'%'
            if (type == 'icons') {
                document.getElementById(table[i].i_id_1).style.clip = 'rect('+toclip(table[i].value)+', 100px, 100px, 0)'
            } else if (table[i].type == 1) {
                setNoobCircle(table[i].i_id_1, table[i].value)
            }
        }
        if (table[i].value >= 80 && table[i].status == 'sanity') {
            document.getElementById(table[i].id_3).style.setProperty("-webkit-filter", "drop-shadow(5px 5px 5px rgba(255, 5, 5, 1.0)");
            document.getElementById(table[i].id_3).style.color = "rgb(255, 5, 5)";
        } else if (table[i].value <= 40 && table[i].status !== 'sanity' && table[i].status !== 'voip' && table[i].type == 1) {
            document.getElementById(table[i].id_3).style.color = "rgb(255, 5, 5)";
            document.getElementById(table[i].id_3).style.setProperty("-webkit-filter", "drop-shadow(5px -1px 5px rgba(255, 5, 5, 1.0)");
        } else if (document.getElementById(table[i].id_3)) {
            document.getElementById(table[i].id_3).style.color = "rgba(151, 147, 147, 0.623)";
            document.getElementById(table[i].id_3).style.setProperty("-webkit-filter", "drop-shadow(15px -1px 22px rgba(255, 5, 5, 0.0)");
        }
        if (table[i].hideifmax) {
            if (table[i].value == 100 && table[i].status !== 'armor' && table[i].type == 1) {
                document.getElementById(table[i].id).style.display = 'none'
            } else if (table[i].type == 1) {
                document.getElementById(table[i].id).style.display = 'block'
                if (table[i].status == 'armor' && statusui !== 'simple' || table[i].status == 'armor' && statusui == 'simple' && table[i].value == 0) {
                    document.getElementById(table[i].id).style.display = 'none'
                } else if (table[i].status == 'armor' && statusui == 'simple' && table[i].value > 0) {
                    document.getElementById(table[i].id).style.display = 'block'
                }
            }
        }
    }
}

function setShowstatus(t) {
    var bool = t['bool']
    var enable = t['enable']
    if (bool) {
        $("#status").fadeIn();
        setTimeout(function(){
            $("#statusbar").fadeIn();
            if (!enable) {
                document.getElementById('status_prog').style.display = 'none'
                document.getElementById('statusbar').style.display = 'none'
                document.getElementById('status').style.overflow = 'hidden'
                document.getElementById('stats').style.display = 'none'
            }
        }, 333);
    } else {
        $("#statusbar").fadeOut();
        setTimeout(function(){
            $("#status").fadeOut();
        }, 333);
    }
}

function setShowstatusv2(bool) {
    ////////console.log(bool)
    if (bool) {
        $("#status2").fadeIn();
    } else {
        $("#status2").fadeOut();
    }
}

var oldrpm = 0, cntSi = 0;
var newrpm = 0
var oldp = 0
function doStuffwTimeout(rpm){
    var val = rpm / 200
    setTimeout(function(){
        if(oldrpm<200){
        oldrpm++
        p = (val * oldrpm)
        console.log('setTimeout() executed, cntSt=' + p);
        setRpm(p)
        doStuffwTimeout(rpm);
        } else {
            oldrpm = 0
            oldp = p
        }
    },1);
}

var r = 0
var run = false
function animateValue(start, end, duration) {
    if (run) { return }
    if (start >= 1) return;
    var range = end - start;
    var current = r;
    var increment = end / 200
    var c = 0
    var stepTime = Math.abs(Math.floor(duration / range));
    //var obj = document.getElementById(id);
    var timer = setInterval(function() {
        run = true
        c++
        current += increment;
        //console.log(current,increment,c)
        //obj.innerHTML = current;
        setRpm(current)
        if (c >= 200 || current >= 1) { 
            run = false
            r = current
            clearInterval(timer);
        }
    }, 1);
}

function setRpm(percent) {
    var rpm = (percent * 100);
    rpm2 = rpm.toFixed(0) * 100
    document.getElementById("rpmmeter").innerHTML = ""+rpm2+"";
    $(".rpm").addClass('notransition');
    $(".rpm").removeClass("notransition");
    var e = document.getElementById("rpmpath");
    let length = e.getTotalLength();
    let to = length * ((100 - rpm) / 100);
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

function SetVehData(table) {
    var speed = table['speed']
    var rpm = table['rpm']
    if (speed > 0 && rpm > 0) {
        setSpeed(speed)
        setRpm(rpm)
    }
}

function setSpeed(s) {
    var type = carui
    var takbo = (s * 3.6)
    var max = 350
    var bilis = takbo / max
    var right = '47%'
    speed = bilis * 100;
    takbo = takbo.toFixed(0)
    $(".carhud").addClass('notransition');
    $(".carhud").removeClass("notransition");
    if (type == 'minimal') {
        // document.getElementById("speed_minimal").style.display = "block";
        // document.getElementById("speed").style.display = "none";
        document.getElementById("speedmeter").style.right = "20%";
        document.getElementById("speedmeter").style.fontSize  = "1.5vw";
        document.getElementById("speedmeter").style.bottom = "50%";
        if (takbo >= 100) {
            right = '45%'
        } else if (takbo >= 10) {
            right = '45.5%'
        } else {
            right = '47%'
        }
    } else if (type == 'modern') {
        document.getElementById("speedmeter").style.right = "268px";
        document.getElementById("speedmeter").style.bottom = "85px";
        if (takbo >= 100) {
            right = '247px'
        } else if (takbo >= 10) {
            right = '258px'
        } else {
            right = '268px'
        }
    } else if (type == 'simple') {
        document.getElementById("speedmeter").style.right = "20%";
        document.getElementById("speedmeter").style.fontSize  = "1.5vw";
        document.getElementById("speedmeter").style.bottom = "50%";
        if (takbo >= 100) {
            right = '45%'
        } else if (takbo >= 10) {
            right = '45.5%'
        } else {
            right = '47%'
        }  
    }
    //console.log(right)
    document.getElementById("speedmeter").style.right = right;
    //document.getElementById("speedmeter").innerHTML = ""+takbo+"";
    //$("#speedmeter").text(""+takbo+"");
    // document.getElementById("speedmeter").classList.add('move')
    //     setTimeout(function () {
    //     document.getElementById("speedmeter").classList.remove('move')
    //   }, 250)
    document.getElementById("speedmeter").style.setProperty('--num', takbo);
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
    ////console.log(rpm2)
    //document.getElementById("rpmmeter").innerHTML = ""+rpm2+"";
    var e = document.getElementById("coolantpath");
    let length = e.getTotalLength();
    let value = water;
    let to = length * ((100 - value) / 100);
    val = to / 1000
    e.style.strokeDashoffset = to;
}

var manual = false
function setShow(table) {
  if (table['bool']) {
        $("#"+carui+"").animate({
            opacity: "1"
        },400);
        setHeadlights(0)
        document.getElementById(""+carui+"").style.display = 'block'
  } else {
    $("#"+carui+"").animate({
      opacity: "0"
    },400);
    document.getElementById(""+carui+"").style.display = 'none'
    //clearInterval(loopfuck);
  }
}

function setHeadlights(v) {
    if (v == 1) {
        document.getElementById("offlight").style.display = 'none'
        document.getElementById("onlight").style.display = 'block'
        document.getElementById("highlight").style.display = 'none'
        if (carui == 'modern') { return }
        document.getElementById(""+carui+"_light").style.setProperty("-webkit-filter", "drop-shadow(1px 1px 3px rgba(3, 137, 246, 1.0)");
    } else if (v == 2) {
        document.getElementById("offlight").style.display = 'none'
        document.getElementById("onlight").style.display = 'none'
        document.getElementById("highlight").style.display = 'block'
        if (carui == 'modern') { return }
        document.getElementById(""+carui+"_light").style.setProperty("-webkit-filter", "drop-shadow(1px 1px 3px rgba(3, 137, 246, 1.0)");
    } else {
        document.getElementById("offlight").style.display = 'block'
        document.getElementById("onlight").style.display = 'none'
        document.getElementById("highlight").style.display = 'none'
        if (carui == 'modern') { return }
        document.getElementById(""+carui+"_light").style.setProperty("-webkit-filter", "drop-shadow(1px -1px 0.4px rgba(255, 255, 255, 0.822))");
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
    ////////console.log(value)
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
        //e.style.stroke = 'yellow'
        document.getElementById("mileage").style.color = 'yellow'
    } else if(mileage >=10000){
        //e.style.stroke = '#C85A17'
        document.getElementById("mileage").style.color = '#C85A17'
    } else {
        //e.style.stroke = 'lime'
        document.getElementById("mileage").style.color = 'rgba(182, 182, 182, 0.582)'
    }
    document.getElementById("mileage").innerHTML = ''+mileage+''
}

function setWaydistance(value) {
    var dis = value.toFixed(0)
    if (dis >= 1000) {
        document.getElementById("distance").style.margin = '0 -1px 0 0'
    } else if (dis >= 100) {
        document.getElementById("distance").style.margin = '0 4px 0 0'
    } else if (dis >= 10) {
        document.getElementById("distance").style.margin = '0 8px 0 0'
    }
    if (dis <= 0) {
        document.getElementById("distext").innerHTML = ''
        document.getElementById("distance").style.margin = '0 -1px 0 0'
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
    document.getElementById("idnumlabel").innerHTML = 'Citizen ID#: '+table.id+''
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
    var table = detail.content
    var r = document.querySelector(':root');
    if (detail.type == "updatemapa") {
        //////console.log("updating map ui")
        $(".centermap").css("transform", "rotate(" + table.myheading + "deg)");
        $("#carblip").css("transform", "translateX(-50%) translateY(50%) rotate(" + table.camheading + "deg)");
        //console.log(table.y,table.x)
        r.style.setProperty('--Y', table.y);
        r.style.setProperty('--X', table.x);
        //$(":root").css("--Y", table.y);
        //$(":root").css("--X", table.x);
    } else {
        if (detail.type == "sarado") {
            $(".carhudmap").fadeOut();
            setTimeout(function(){
                $("#gps").fadeOut();
            }, 333);
        }
        if (detail.type =="bukas") {
            $("#gps").fadeIn();
            setTimeout(function(){
                $(".carhudmap").fadeIn();
            }, 333);
        }
    }
}

function setTemp(temp) {
    ////console.log(carui,"temp")
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

function setMode(value,c) {
    if (carui == undefined) {
        carui = c
    }
    if (carui == 'minimal') {
        //document.getElementById("simple").innerHTML = '';
        document.getElementById("mode").innerHTML = value;
        document.getElementById("modediv").style.right = '61%';
        document.getElementById("modediv").style.bottom = '49%';
        document.getElementById("modediv").style.fontSize = '0.5vw';
    } else if (carui == 'modern') {
        document.getElementById("mode").innerHTML = value;
    } else if (carui == 'simple') {
        //document.getElementById("minimal").innerHTML = '';
        document.getElementById("mode").innerHTML = value;
        document.getElementById("modediv").style.right = '61%';
        document.getElementById("modediv").style.bottom = '49%';
        document.getElementById("modediv").style.fontSize = '0.5vw';
    }
    document.getElementById(""+carui+"").style.display = ''+carui+'';
    document.getElementById(""+carui+"").style.opacity = '1.0';
}

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

var bodystatus = {}
function setUpdateBodyStatus(table) {
    bodystatus = table
    var totalpain = 0
    for (const key in table) {
        var val = table[key] * 0.1;
        ////////console.log(val)
        if (val == undefined) {
            val = 0.0
        }
        if(key) {
            document.getElementById(''+key+'_heal').style.zIndex = '0';
            document.getElementById(''+key+'_heal').style.opacity = '0.0';
            if (val < 0.29 && val >= 0.1) {
                val = 0.29
            }
            totalpain = totalpain + val
            document.getElementById(key).style.opacity = val;
            //console.log(key,val)
            if (val > 0.9) {
                document.getElementById(''+key+'_status').innerHTML = 'Severe';
            } else if (val > 0.7) {
                document.getElementById(''+key+'_status').innerHTML = 'Damaged';
            } else if (val > 0.5) {
                document.getElementById(''+key+'_status').innerHTML = 'Injured';
            } else if (val > 0.3) {
                document.getElementById(''+key+'_status').innerHTML = 'inPain';
            } else if (val >= 0.29) {
                document.getElementById(''+key+'_status').innerHTML = 'Small Pain';
            } else if(val <= 0) {
                document.getElementById(''+key+'_status').innerHTML = 'Normal';
            }
            if (val >= 0.29 && isambulance) {
                document.getElementById(''+key+'_heal').style.opacity = '0.5';
                document.getElementById(''+key+'_heal').style.zIndex = '1222';
            } else {
                document.getElementById(''+key+'_heal').style.opacity = '0.0';
                document.getElementById(''+key+'_heal').style.zIndex = '0';
            }
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

function setBodyParts(table) {
    ////////console.log("bodyparts")
    $(document).ready(function(){
        for (const key in table) {
            if (key == 'arm') {
                for (const key2 in table[key]) {
                    var idname = ""+table[key][key2]+"_heal"
                    ////////console.log(idname)
                    $("#"+idname+"").hover(function(){
                        $(this).css("opacity", "1.0");
                        ////////console.log("hover")
                        }, function(){
                        $(this).css("opacity", "0.5");
                    });
                    $("#"+idname+"").click(function(){
                        post("healpart",{part:key})
                    });
                }
            } else if (key == 'leg') {
                for (const key2 in table[key]) {
                    var idname = ""+table[key][key2]+"_heal"
                    ////////console.log(idname)
                    $("#"+idname+"").hover(function(){
                        $(this).css("opacity", "1.0");
                        ////////console.log("hover")
                        }, function(){
                        $(this).css("opacity", "0.5");
                    });
                    $("#"+idname+"").click(function(){
                        post("healpart",{part:key})
                    });
                }
            } else {
                var idname = ""+table[key]+"_heal"
                ////////console.log(idname)
                $("#"+idname+"").hover(function(){
                    $(this).css("opacity", "1.0");
                    ////////console.log("hover")
                    }, function(){
                    $(this).css("opacity", "0.5");
                });
                $("#"+idname+"").click(function(){
                    post("healpart",{part:key})
                });
            }
        }
    });
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
			////////console.log(datab);
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
    ////////console.log("callback car control")
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
    //////////console.log(""+weapon+".png")
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
    ////////console.log(percent)
    var bullets = percent;
    //rpm2 = bullets.toFixed(0) * 100
    var e = document.getElementById("weaponpath");
    let length = e.getTotalLength();
    let value = bullets;
    let to = length * ((100 - value) / 100);
    val = to / 1000
    e.style.strokeDashoffset = to;
    document.getElementById("ammotext").innerHTML = ''+table['ammo']+'';
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

var carui_element = []
function setCarui(ver) {
    if (carui_element['simple'] == undefined) {
        carui_element['simple'] = document.getElementById("simple").innerHTML
        carui_element['modern'] = document.getElementById("modern").innerHTML
        carui_element['minimal'] = document.getElementById("minimal").innerHTML
    }
    document.getElementById("modern").innerHTML = '';
    document.getElementById("simple").innerHTML = '';
    document.getElementById("minimal").innerHTML = '';
    ////console.log(carui_element['modern'])
    //loopfuck = setInterval(function(){ getvehdata() }, 200);
    document.getElementById(ver).innerHTML = ''
    document.getElementById(ver).innerHTML = carui_element[ver]
    //console.log(carui_element[ver])
    carui = ver
    if (ver == 'minimal') {
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
        document.getElementById("geardiv").style.right = '13.7vw';
        document.getElementById("geardiv").style.bottom = '42%';
        document.getElementById("geardiv").style.fontSize = '0.4vw';
        document.getElementById("right").style.right = '27%';
        document.getElementById("right").style.bottom = '75%';
        document.getElementById("left").style.right = '69%';
        document.getElementById("left").style.bottom = '75%';
        document.getElementById("milediv").style.right = '39.0%';
        document.getElementById("milediv").style.bottom = '30.5%';
        document.getElementById("milediv").style.margin = '1% 1% 1% 1%';
        document.getElementById("milediv").style.background = '#000000';
        document.getElementById("milediv").style.opacity = '0.6';
        document.getElementById("milediv").style.fontSize = '0.5vw';
        document.getElementById("milediv").style.fontSize = '0.5vw';
        document.getElementById("milediv").style.webkitFilter = "drop-shadow(1px 1px 2px rgb(5, 155, 255))";
        document.getElementById("timediv").style.right = '44%';
        document.getElementById("timediv").style.textAlign = 'unset';
        document.getElementById("timediv").style.width = 'unset';
        document.getElementById("timediv").style.bottom = '72.6%';
        document.getElementById("timediv").style.fontSize = '0.4vw';
        document.getElementById("distancediv").style.right = '53%';
        document.getElementById("distancediv").style.bottom = '73%';
        document.getElementById("distancediv").style.width = 'unset';
        document.getElementById("distancediv").style.textAlign = 'unset';
        document.getElementById("distancediv").style.background = '#00000000';
        document.getElementById("distancediv").style.fontSize = '0.4vw';
        document.getElementById("diffdiv").style.right = '33%';
        document.getElementById("diffdiv").style.bottom = '73%';
        document.getElementById("diffdiv").style.background = '#00000000';
        document.getElementById("diffdiv").style.fontSize = '0.4vw';
        setCoolant(100)
    } else if (ver == 'modern') {
        document.getElementById("modern").style.display = 'block';
    } else if (ver == 'simple') {
        document.getElementById("simple").style.display = 'block';
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
        document.getElementById("geardiv").style.right = '45%';
        document.getElementById("geardiv").style.bottom = '42%';
        document.getElementById("geardiv").style.fontSize = '0.4vw';
        document.getElementById("right").style.right = '37%';
        document.getElementById("right").style.bottom = '30%';
        document.getElementById("left").style.right = '79%';
        document.getElementById("left").style.bottom = '30%';
        document.getElementById("milediv").style.right = '50.0%';
        document.getElementById("milediv").style.bottom = '28.5%';
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
    }
    setMode('NORMAL',carui)
    changeallclass(class_icon)
}
function setCompass(bool) {
    if (bool) {
        document.getElementById("location").style.display = 'block';
        document.getElementById("compass").style.display = 'block';
    } else {
        setTimeout(function(){
            document.getElementById("mic").style.top = '22px';
            document.getElementById("mic").style.right = '365px';
        }, 333);
    }
}

function setStatusUI(t) {
    var ver = t['ver']
    var type = t['type']
        status_type = type
    if (!t['enable'] && ver == 'simple') {
        document.getElementById("uibar").innerHTML = '';
        document.getElementById("logo").innerHTML = '';
        document.getElementById("voip_1").innerHTML = '';
        document.getElementById("statusnormal").style.display = 'none';
    }
    if (ver == 'simple' && t['enable']) {
        statusui = 'simple'
        document.getElementById("uisimplehp").style.display = 'block';
        document.getElementById("armorsimple").style.display = 'block';
        document.getElementById("uisimplearmor").style.display = 'block';
        if (type == 'icons') {
            document.getElementById("armorsimplebg").style.display = 'block';
        }
        //document.getElementById("voip_2").style.marginLeft = '40px';
        document.getElementById("uibar").innerHTML = '';
        $("#statusver").attr("src", "img/simplestatus.png")
        document.getElementById("statusnormal").style.display = 'none';
        document.getElementById("logo").innerHTML = '';
        document.getElementById("location").style.top = '60px';
        document.getElementById("location").style.right = '60px';
        document.getElementById("location").style.width = '280px';
        document.getElementById("voip_1").innerHTML = '';
        //document.getElementById("mic").style.right = '363px';
        //document.getElementById("mic-color").style.width = '15px';
        //document.getElementById("mic-color").style.height = '27px';
    } else if (t['enable']) {
        document.getElementById("voip_2").innerHTML = '';
    }
}

function setStatusUILocation(table) {
    ////////console.log("MOVE UI")
    if (table['top']) {
        //////console.log(table['top'])
        document.getElementById("statusv3").style.top = ''+table['top']+'';
    }
    if (table['right']) {
        //////console.log(table['right'])
        document.getElementById("statusv3").style.right = ''+table['right']+'';
    }
    if (table['bottom']) {
        //////console.log(table['bottom'])
        document.getElementById("statusv3").style.bottom = ''+table['bottom']+'';
    }
    if (table['left']) {
        //////console.log(table['left'])
        document.getElementById("statusv3").style.left = ''+table['left']+'';
    }
}

function setMoveStatusUi(bool) {
    ////////console.log("MOVE UI")
    if (bool) {
        if (status_type == 'icons') {
            document.getElementById("statusv3").style.right = '22%';
        } else {
            document.getElementById("statusv3").style.right = '30%';
        }
    } else {
        if (status_type == 'icons') {
            document.getElementById("statusv3").style.right = '25px';
        } else {
            document.getElementById("statusv3").style.right = '85px';
        }
    }
}

function setNitro(nitro) {
    if (carui !== 'minimal') { return }
    var e = document.getElementById("nitropath");
    let length = e.getTotalLength();
    let value = nitro;
    let to = length * ((100 - value) / 100);
    val = to / 1000
    e.style.strokeDashoffset = to;
}

function setWheelHealth(table) {
        var index = table[['index']]
        var val = 1 - table[['tirehealth']] / 1000
        if (carui == 'minimal') {
            document.getElementById("wheel"+index+"").style.opacity = ''+val+'';
        }
}

function setShowKeyless(bool) {
    if (bool) {
        document.getElementById("keyless").style.display = 'block';
    } else {
        document.getElementById("keyless").style.display = 'none';
    }
}

var currentvehicle = undefined
var openall = false
var alarm = false
function carlockcallback(type) {
    ////////console.log("callback car keyless system")
    if (type == 'lock') {
        post("setvehiclelock",{vehicle:currentvehicle})
        ////////console.log("locking")
        document.getElementById("carlock").style.display = 'block';
        document.getElementById("carunlock").style.display = 'none';
    }
    if (type == 'unlock') {
        post("setvehicleunlock",{vehicle:currentvehicle})
        ////////console.log("unlocking")
        document.getElementById("carunlock").style.display = 'block';
        document.getElementById("carlock").style.display = 'none';
    }
    if (type == 'openall') {
        openall = !openall
        //////console.log(openall)
        post("setvehicleopendoors",{vehicle:currentvehicle, bool:openall})
        ////////console.log("openall")
        if (openall) {
            document.getElementById("allopen").style.display = 'block';
        } else {
            document.getElementById("allopen").style.display = 'none';
        }
    }
    if (type == 'alarm') {
        alarm = !alarm
        //////console.log(alarm)
        post("setvehiclealarm",{vehicle:currentvehicle, bool:alarm})
        ////////console.log("alarm")
        if (alarm) {
            document.getElementById("alarm").style.display = 'block';
        } else {
            document.getElementById("alarm").style.display = 'none';
        }
    }
}

function setKeyless(table) {
    var type = table['type']
    var bool = table['bool']
    var vehicle = table['vehicle']
    var plate = table['plate']
    var doorstatus = table['state']
    if (type == 'connect') {
        currentvehicle = vehicle
        document.getElementById("foundcar").style.display = 'block';
        if (doorstatus == 2) {
            document.getElementById("carlock").style.display = 'block';
            document.getElementById("carunlock").style.display = 'none';
        }
        if (doorstatus == 1) {
            document.getElementById("carunlock").style.display = 'block';
            document.getElementById("carlock").style.display = 'none';
        }
    }
}

pressfuck = 0
var pressedkey1 = 0
var pressedkey2 = false
var pressedkey3 = false
document.onkeyup = function (data) {
	if (data.keyCode == '76' || data.keyCode == '27') { // Escape key 76 = L (Change the 76 to whatever keycodes you want to hide the carlock ui LINK https://css-tricks.com/snippets/javascript/javascript-keycodes/)
        if (pressfuck == 1) {
            document.getElementById("foundcar").style.display = 'none';
            document.getElementById("carunlock").style.display = 'none';
            document.getElementById("carlock").style.display = 'none';
            post("hidecarlock",{})
            pressfuck = 0
        }
        pressfuck = 1
	}
    if (data.keyCode == '70') {
        $.post(`https://${GetParentResourceName()}/getoutvehicle`, {}, function(data) {});
        pressedkey1 = 0
    }
    if (data.keyCode == '144' || data.keyCode == '27') {
        if (pressedkey2) {
            pressedkey2 = false
            //////console.log('pressed')
            $.post(`https://${GetParentResourceName()}/closecarcontrol`, {}, function(data) {});
        }
        if (!pressedkey2) {
            pressedkey2 = true
        }
    }
    if (data.keyCode == '75' || data.keyCode == '76') {
        if (pressedkey3) {
            pressedkey3 = false
            $.post(`https://${GetParentResourceName()}/hideclothing`, {}, function(data) {});
        }
    }
};

function playsound(table) {
    var file = table['file']
    var volume = table['volume']
    var audioPlayer = null;
    if (audioPlayer != null) {
        audioPlayer.pause();
    }
    if (volume == undefined) {
        volume = 0.8
    }
    audioPlayer = new Audio("./sounds/" + file + ".ogg");
    audioPlayer.volume = volume;
    audioPlayer.play();
}

function SetNotify(table) {
    ////////console.log("notify")
    new Notify ({status: table['type'],title: table['title'],text: table['message'],autoclose: true})
}

    // more carcontrols
    const settings = {
    fill: '#1abc9c',
    background: '#d7dcdf' };
    const suspension = document.querySelectorAll('#suspension');
    Array.prototype.forEach.call(suspension, slider => {
        slider.querySelector('input').addEventListener('input', event => {
            slider.querySelector('span').innerHTML = event.target.value * 0.01;
            applyFill(event.target);
            post("setvehicleheight",{val:event.target.value * 0.01})
        });
        applyFill(slider.querySelector('input'));
    });

    const wheeloffsetfront = document.querySelectorAll('#wheeloffsetfront');
    Array.prototype.forEach.call(wheeloffsetfront, slider => {
        slider.querySelector('input').addEventListener('input', event => {
            slider.querySelector('span').innerHTML = event.target.value * 0.01;
            applyFill(event.target);
            //console.log(event.target.value)
            post("setvehiclewheeloffsetfront",{val:event.target.value})
        });
        applyFill(slider.querySelector('input'));
    });

    const wheeloffsetrear = document.querySelectorAll('#wheeloffsetrear');
    Array.prototype.forEach.call(wheeloffsetrear, slider => {
        slider.querySelector('input').addEventListener('input', event => {
            slider.querySelector('span').innerHTML = event.target.value * 0.01;
            applyFill(event.target);
            //console.log(event.target.value)
            post("setvehiclewheeloffsetrear",{val:event.target.value})
        });
        applyFill(slider.querySelector('input'));
    });

    const wheelrotationfront = document.querySelectorAll('#wheelrotationfront');
    Array.prototype.forEach.call(wheelrotationfront, slider => {
        slider.querySelector('input').addEventListener('input', event => {
            slider.querySelector('span').innerHTML = event.target.value * 0.01;
            applyFill(event.target);
            post("setvehiclewheelrotationfront",{val:event.target.value})
        });
        applyFill(slider.querySelector('input'));
    });

    const wheelrotationrear = document.querySelectorAll('#wheelrotationrear');
    Array.prototype.forEach.call(wheelrotationrear, slider => {
        slider.querySelector('input').addEventListener('input', event => {
            slider.querySelector('span').innerHTML = event.target.value * 0.01;
            applyFill(event.target);
            post("setvehiclewheelrotationrear",{val:event.target.value})
        });
        applyFill(slider.querySelector('input'));
    });

    function applyFill(slider) {
        const percentage = 100 * (slider.value - slider.min) / (slider.max - slider.min);
        const bg = `linear-gradient(90deg, ${settings.fill} ${percentage}%, ${settings.background} ${percentage + 0.1}%)`;
        slider.style.background = bg;
    }

    function unsetradio() {
        //$('input[type=radio][name=wheelsetting]').val('off')
        //console.log("unset")
        $("input[type=radio][name=wheelsetting][value='off']").prop("checked", true);
        //post("wheelsetting",{bool:true})
    }

    $('input[type=radio][name=wheelsetting]').change(function() {
        if (this.value == 'on') {
            //console.log("ON")
            post("wheelsetting",{bool:false})
        } else {
            //console.log("OFF")
            post("wheelsetting",{bool:true})
        }
    });
    
    $('input[type=radio][name=neon]').change(function() {
        if (this.value == 'on') {
            ////////console.log("ON")
            post("setvehicleneon",{bool:true})
        } else {
            ////////console.log("OFF")
            post("setvehicleneon",{bool:false})
        }
    });

    $('input[type=radio][name=neoneffect1]').change(function() {
        if (this.value == 'on') {
            ////////console.log("ON")
            post("setneoneffect1",{bool:true})
        } else {
            ////////console.log("OFF")
            post("setneoneffect1",{bool:false})
        }
    });

    $('input[type=radio][name=neoneffect2]').change(function() {
        if (this.value == 'on') {
            ////////console.log("ON")
            post("setneoneffect2",{bool:true})
        } else {
            ////////console.log("OFF")
            post("setneoneffect2",{bool:false})
        }
    });

    function setMapVersion(table) {
        var type = table['type']
        var custom = table['custom']
        //console.log(table['custom'],table['custom'],table['custom'])
        if (custom) {
            //console.log("its custom")
            $("#mapimg").attr("src", ""+table['link']+"")
        } else {
            //console.log("hosted img",type)
            $("#mapimg").attr("src", "img/"+type+".webp")
        }
    }

    function setRadioChannel(channel) {
        //////console.log(channel)
        if (channel !== false && channel !== undefined) {
            document.getElementById("radio").style.display = 'block';
            document.getElementById("mic-radio").innerHTML = ''+channel+'';
            if (statusui == 'simple') {
                document.getElementById("radio").style.top = '25px';
                document.getElementById("radio").style.right = '20px';
                if (statleft == 'top-right') {
                    document.getElementById("statusv3").style.right = '320px';
                }
                $("#radio").fadeIn();
            }
        } else {
            if (statleft == 'top-right') {
                document.getElementById("statusv3").style.right = '90px';
            }
            //document.getElementById("radio").style.display = 'none';
            $("#radio").fadeOut();
        }
    }

    var state = {}

    function setShowClothing(table) {
        if (table['bool']) {
            state = table['equipped']
            document.getElementById("clothe").style.display = 'block';
        } else {
            document.getElementById("clothe").style.display = 'none';
        }
    }

    function setClotheState(table) {
        ////////console.log("clothe",table['bool'])
        if (!table['bool']) {
            //$("#variants_"+table['variant']+"").css("--fa-secondary-color", 'red');
            $("#variants_"+table['variant']+"").addClass("clotheoff");
            //////////console.log("red color","variants_"+table['variant']+"")
        } else {
            $("#variants_"+table['variant']+"").removeClass("clotheoff")
            //$("#variants_"+table['variant']+"").css("--fa-secondary-color", 'unset');   
        }
    }

    function ResetClotheState(table) {
        for (const key in table) {
            $("#variants_"+key+"").css("--fa-secondary-color", 'unset'); 
        }
    }

    function CallbackCLothing(variant,variant2) {
        $.post('https://hud/ChangeClothes', JSON.stringify({
            variant : variant, variant2: variant2, state: state[variant]
        }))
    }

    function ResetClothes() {
        $.post('https://hud/resetclothing', JSON.stringify({}))
    }

    function hasClass(element, className) {
        return (' ' + element.className + ' ').indexOf(' ' + className+ ' ') > -1;
    }

    function changeallclass(setting) {
        class_icon = setting
        var all = document.getElementsByClassName('fa-octagon');
        for (var i = 0; i < all.length; i++) {
            all[i].classList.toggle("fa-"+setting+"");
        }
        if (setting !== 'circle' && settings !== 'octagon') {
            var icon = document.getElementsByClassName('default');
            for (var i = 0; i < icon.length; i++) {
                //////console.log(i)
                icon[i].classList.toggle("square");
            }
        }
    }

    function reverseArrayInPlace(array) {
    for (let i = 0, j = array.length - 1; i < j; i++, j--) 
        [array[i], array[j]] = [array[j], array[i]];
    }

    function setNoobCircle(id,percent) {
        var rpm = (percent);
        var e = document.getElementById(id);
        let length = e.getTotalLength();
        let to = length * ((100 - percent) / 100);
        e.style.strokeDashoffset = to;
    }
    
    function SetStatusOrder(t) {
        var s = t['table']
        statleft = t['float']
        var offsetplus = -35
        var statuses = s
        for (const i in statuses) {
            if (statuses[i].enable) {
                var offset = statuses[0].offset
                offsetplus = offsetplus + 35
                offset = (+offset - +offsetplus)
                var class1 = statuses[i].i_id_1_class
                var class2 = statuses[i].i_id_2_class
                var color1 = statuses[i].i_id_1_color
                var color2 = statuses[i].i_id_2_color
                var divid = statuses[i].id
                var i_id_1 = statuses[i].i_id_1
                var i_id_2 = statuses[i].i_id_2
                if (statleft == 'top-left' || statleft == 'bottom-left') {
                    float = 'left'
                } else {
                    float = 'right'
                }
                if (statuses[i].type == 1) {
                    if (status_type == 'icons') {
                        $("#statusv3").prepend('<span id="'+divid+'" class="fa-stack fa-2x" style="display:'+statuses[i].display+';font-size:17px;position:relative;color:rgba(144, 144, 144, 0.876);float:right; margin-top:-25px;margin-left:-7px;"> <i class="fas fa-octagon fa-stack-2x" style="font-size:17px;color:rgba(11, 39, 63, 0.707)"></i> <i id="'+statuses[i].id_3+'" class="fal fa-octagon fa-stack-2x" style="font-size:16px;color:rgba(151, 147, 147, 0.623)"></i> <i id="'+i_id_1+'" class="'+class1+'" style="font-size:19px;color:'+color1+';z-index:1131;opacity:1.0;"></i> <i id="'+i_id_2+'" class="'+class2+'" style="font-size:19px;color:'+color2+';z-index:1130;opacity:1.0;"></i> </span>');
                    } else {
                        $("#statusv3").prepend('<div id="'+divid+'" style="float:'+float+';height:2.9vw;width:2.9vw;position:relative;display:'+statuses[i].display+'"> <span class="fa-stack fa-2x" style="position:absolute;font-size:0.9vw;color:rgba(144, 144, 144, 0.876);bottom:1.0vw;left:3.5vw;"> <i class="fas fa-octagon fa-stack-2x" style="font-size:1.25vw;color:rgba(11, 39, 63, 0.707);margin-left:0.2vw;"></i> <i id="'+statuses[i].id_3+'" class="fal fa-octagon fa-stack-2x" style="font-size:1.4vw;color:rgba(170, 170, 170, 0.623)"></i> <i id="'+statuses[i].i_id_2+'" class="'+statuses[i].i_id_1_class+'" style="font-size:1.25vw;color:rgb(240, 240, 240);z-index:1131;opacity:1.0;left:1vw;"></i> <svg class="default" preserveAspectRatio="xMidYMin" style="position:absolute;left:-0.14vw;bottom:-0.53vw;display: block;margin:auto;z-index:1205;opacity:0.65;transform: rotate(0deg);height:2.9vw;" xmlns="http://www.w3.org/2000/svg" width="5.5vw" viewBox="0 0 200 200" data-value="1"> <path class="bg" stroke="#00000078" d="M41 179.5a77 77 0 1 1 0.93 0"  fill="none"/> <path style="" id="'+statuses[i].i_id_1+'" class="meter statushud" stroke="'+statuses[i].i_id_1_color+'" d="M41 179.5a77 77 0 1 1 0.93 0" fill="none" stroke-dasharray="480" stroke-dashoffset="480"/> </svg> </span>');
                    }
                } else {
                    $("#status_progress").append('<li style="height: 40px;position:relative;">\
                    <div class="prog-bar">\
                      <span class="bar">\
                        <span style="background: '+statuses[i].i_id_1_color+';" class="prog_progress" id="'+statuses[i].rpuidiv+'"></span>\
                      </span>\
                    </div>\
                    <i style="position:absolute;right:23px;top:27px;z-index: 1350;color:white;font-size:20px;" class="tikol '+statuses[i].i_id_3_class+'"></i>\
                    <img style="position:relative;z-index:1205 !important;height:40px;" src="img/status_bar.png" />\
                </li>');
                $("tikol").removeClass("fa-stack-1x");
                }
            }
        }
    }

    function setShowTurboBoost(bool) {
        ////////console.log("show turbo")
        if (bool) {
            //////console.log(bool)
            $('.turbo_hud').fadeIn('fast');
        } else {
            $('.turbo_hud').fadeOut('fast');
        }
    }

    function setTurboBoost(table) {
        let data = table
        //$('.turbo_hud').fadeIn('fast');
        //////console.log(data['speed'])
        if (data['speed']) {
            if (data['speed'] < 0) {
                data['speed'] = 0
            }
            if (String(parseInt(data['speed'])).length == 0x2) {
                $('.turbo_hud .boost_div .boost_text').css('left', '1px');
            } else if (String(parseInt(data['speed'])).length == 0x3) {
                $('.turbo_hud .boost_div .boost_text').css('left', '-0.1px');
            } else {
                $('.turbo_hud .boost_div .boost_text').css('left', '0px');
            }
            if (data['speed'] < 0) {
                data['speed'] = 0
            }
            $('div.boost_text > p').html((data['speed']).toFixed(1));
        } else if (!data['speed']) {
            $('div.boost_text > p').html(0x0);
        }
        if (data['max']) {
            if (data['speed'] < 0) {
                data['speed'] = 0
            }
            var kupal = (0x48 * (data['speed'] / data['max']) * ' 180').toFixed(1);
            $('div.boost_div > svg > circle.progress3').attr('stroke-dasharray', ''+(data['speed'] / 2.8) * 100 +' 180');
        }
    }

    function setShowCarStatus(table) {
        for (const i in table) {
            //////console.log(i,table[i])
            if (i == 'brake') {
                $('#brakelevel').html("LVL "+(+table[i]+1))
            }
            if (i == 'tranny') {
                $('#trannylevel').html("LVL "+(+table[i]+1))
            }
            if (i == 'turbo') {
                if (table[i] == 'NOTURBO') {
                    table[i] = 'NONE'
                }
                $('#turbolevel').html("LVL "+(+table[i]+1))
            }
            if (i == 'engine') {
                $('#enginelevel').html("LVL "+(+table[i]+1))
            }
            if (i == 'suspension') {
                $('#suspensionlevel').html("LVL "+(+table[i]+1))
            }
            if (i == 'tire') {
                $('#tirelevel').html("LVL "+(+table[i]+1))
            }
            if (i == 'coolant') {
                $('#coolanttext').html((+table[i]).toFixed(0)+"%")
            }
            if (i == 'oil') {
                $('#oiltext').html((+table[i]).toFixed(0)+"%")
            }
            if (i == 'tires_health') {
                $('#tiretext').html((+table[i]).toFixed(0)+"%")
            }
            if (i == 'mileage') {
                $('#mileagetext').html((+table[i]).toFixed(0)+" Km")
            }
            if (i == 'trannytype') {
                $('#trannytype').html(table[i])
            }
            if (i == 'enginename') {
                $('#enginename').html(table[i])
            }
        }
        if (table['bool']) {
            $('#carstatusui').fadeIn('fast');
        } else {
            $('#carstatusui').fadeOut('fast');
        }
    }
    
    function setShooting(sleep) {
        setInterval(function(){ post("setShooting",{}) }, sleep);
    }

    function NuiLoop() {
        setInterval(function(){ post("NuiLoop",{}) }, 2000);
    }

    function Drag(bool) {
        if (bool) {
            $('#statusv3').draggable({
                // ...
                drag: function(event, ui) {
                  //////console.log($(event.target).width() + " x " + $(event.target).height());
                  //////console.log(ui.position.top + " x " + ui.position.left);
                },
                stop: function(event, ui) {
                  //////console.log($(event.target).width() + " x " + $(event.target).height());
                  //////console.log(ui.position.top + " x " + ui.position.left);
                },
                scroll: false
              }).draggable('enable');
        } else {
            $('#statusv3').draggable().draggable('disable');
        }
    }

    function DragCar(bool) {
        if (bool) {
            $('#simple').draggable({
            // ...
            drag: function(event, ui) {
                //////console.log($(event.target).width() + " x " + $(event.target).height());
                //////console.log(ui.position.top + " x " + ui.position.left);
            },
            stop: function(event, ui) {
                //////console.log($(event.target).width() + " x " + $(event.target).height());
                //////console.log(ui.position.top + " x " + ui.position.left);
            },
            scroll: false
            }).draggable('enable');
            $('#minimal').draggable({
            // ...
            drag: function(event, ui) {
                //////console.log($(event.target).width() + " x " + $(event.target).height());
                //////console.log(ui.position.top + " x " + ui.position.left);
            },
            stop: function(event, ui) {
                //////console.log($(event.target).width() + " x " + $(event.target).height());
                //////console.log(ui.position.top + " x " + ui.position.left);
            },
            scroll: false
            }).draggable('enable');
            $('#modern').draggable({
            // ...
            drag: function(event, ui) {
                //////console.log($(event.target).width() + " x " + $(event.target).height());
                //////console.log(ui.position.top + " x " + ui.position.left);
            },
            stop: function(event, ui) {
                //////console.log($(event.target).width() + " x " + $(event.target).height());
                //////console.log(ui.position.top + " x " + ui.position.left);
            },
            scroll: false
            }).draggable('enable');
        } else {
            $('#modern').draggable().draggable('disable');
            $('#simple').draggable().draggable('disable');
            $('#minimal').draggable().draggable('disable');
        }
    }

    function setStatusType(type) {
        document.getElementById("uibody").style.display = 'block'
        status_type = type
    }

    function isAmbulance(bool) {
        isambulance = bool
    }

    function hideui(bool) {
        if (bool) {
            display = 'block'
        } else {
            display = 'none'
        }
        document.getElementById("uibody").style.display = ''+display+''
    }

    function uiconfig(table) {
        var r = document.querySelector(':root');
        var acce = table.acceleration
        if (acce == 'hardware') {
            acce = 'hardware_acce'
            $(".carhud").removeClass("gpu_acce");
            $(".carhud").addClass(acce);
            $(".statushud").addClass(acce);
        } else if (acce == 'gpu') {
            acce = 'gpu_acce'
            $(".carhud").removeClass("hardware_acce");
            $(".carhud").addClass(acce);
            $(".statushud").addClass(acce);
        } else {
            $(".carhud").removeClass("hardware_acce");
            $(".carhud").removeClass("gpu_acce");
            $(".statushud").removeClass('gpu_acce');
            $(".statushud").removeClass('hardware_acce');
        }
        r.style.setProperty('--ms', table.animation_ms);
        r.style.setProperty('--trans', table.transition);
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
    playsound,
    SetNotify,
    setStatusUI,
    setCompass,
    setRadioChannel,
    setShowClothing,
    setClotheState,
    ResetClotheState,
    setStatusUILocation,
    setMoveStatusUi,
    changeallclass,
    SetStatusOrder,
    setShooting,
    NuiLoop,
    Drag,
    setStatusType,
    setBodyParts,
    isAmbulance,
    hideui,
    uiconfig,
    unsetradio,
    pedface,
    //CAR
    setShow,
    setRpm,
    SetVehData,
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
    setShowKeyless,
    setKeyless,
    setMapVersion,
    setTurboBoost,
    setShowTurboBoost,
    setShowCarStatus,
    DragCar,

};

window.addEventListener("message", event => {
    const item = event.data || event.detail;
    ////////console.log(item.type);
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

setTimeout(function(){
    $(".fadeout").fadeOut();
    $(".loading").fadeOut();
    setMic(2)
}, 5000);
setShowCarStatus(false)