// -- Copyright (c) Renzuzu
// -- All rights reserved.
// -- Even if 'All rights reserved' is very clear :
// -- You shall not use any piece of this software in a commercial product / service
// -- You shall not resell this software
// -- You shall not provide any facility to install this particular software in a commercial product / service
// -- If you redistribute this software, you must link to ORIGINAL repository at https://github.com/renzuzu/renzu_hud
// -- This copyright should appear in every part of the project code
var carui = 'minimal'
var statusui = 'normal'
var status_type = 'progressbar'
var class_icon = 'circle'
var statleft = false
var isambulance = false
var loopfuck = false
var rpmanimation = false
var speedanimation = false
let setting = {}
let usersetting = {}
var featstate = {}
var invehicle = false
var statusbars = {}
var locache = undefined
var statcache = {}
var lasticon = undefined
featstate['turbohud'] = false
featstate['weaponhud'] = false
featstate['manualhud'] = false
var pedfacetimer = 0
var pedfacecache = "https://nui-img/pedmugshot_01/pedmugshot_01?t123"
let globalconfig = {}
usersetting['carhud'] = {}
setting['carhud'] = {}

function pedface(force) {
    console.log("REQUESTING", force)
    if (pedfacetimer == 0 || Date.now() > pedfacetimer) {
        pedfacetimer = Date.now() + 5000
        $.post(`https://${GetParentResourceName()}/requestface`, JSON.stringify({ force: force }), function(data) {
            console.log("POSTED", data)
            let face = data;
            if (face) {
                console.log("URL", face)
                let url = 'https://nui-img/' + face + '/' + face + '?t=' + String(Math.round(new Date().getTime() / 1000));
                if (face !== 'none') {
                    pedfacecache = url
                }
                if (face == 'none') {
                    url = pedfacecache; // assuming theres a cache
                }
                console.log(url)
                $("#pedface").attr("src", "" + url + "")

            }
        });
    } else {
        $("#pedface").attr("src", pedfacecache)
    }
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

$(document).on('click', '#start', function() {
    ////////console.log("START")
    $.post(`https://${GetParentResourceName()}/pushtostart`, {}, function(data) {});
});

var pressedkey = 0
const time = new Date().toLocaleTimeString();

function setArmor(s) {
    if (statusui == 'simple' && !statusbars['health']) {
        if (status_type == 'icons' && document.getElementById("armorval")) {
            document.getElementById("armorval").style.clip = 'rect(' + toclip(s) + ', 100px, 100px, 0)'
        } else if (status_type !== 'icons') {
            SetProgressCircle('armorval', s * 0.99)
        }
    } else if (document.getElementById("armorbar")) {
        document.getElementById("armorbar").style.width = '' + s * 0.99 + '%'
    }
}

function setHp(s) {
    if (statusui == 'simple' && !statusbars['health']) {
        if (status_type == 'icons' && document.getElementById("healthval")) {
            document.getElementById("healthval").style.clip = 'rect(' + toclip(s) + ', 100px, 100px, 0)'
        } else if (status_type !== 'icons') {
            SetProgressCircle('healthval', s * 0.99)
        }
    } else if (document.getElementById("healthbar")) {
        document.getElementById("healthbar").style.width = '' + s * 0.99 + '%'
        var perc = s * 0.99 + '%'
            //$('#healthbar').velocity({ width: "50px" })
    }
}

function setMic(type) {
    if (status_type == 'icons') {
        did = 'voipdiv'
    } else if (statusui == 'simple') {
        did = 'voipdiv'
        if (type == 1) {
            val = 20
                //$("#microphone").css("color", 'rgb(227, 250, 22)');
            $("#voipval").attr('style', "stroke:rgb(227, 250, 22)")
        } else if (type == 2) {
            val = 50
            $("#voipval").attr('style', "stroke:rgb(23, 255, 15)")
                //$("#microphone").css("color", 'rgb(255, 35, 6)');
        } else if (type == 3) {
            val = 100
            $("#voipval").attr('style', "rgb(255, 35, 6)")
                //$("#microphone").css("color", 'rgb(23, 255, 15)');
        }
        SetProgressCircle('voipval', val)
    } else {
        did = 'voip_1'
    }
    switch (type) {
        case 1:
            new Notify({ status: 'success', title: 'Voice System', text: 'VOIP : Whisper Mode', autoclose: true })
            $("#" + did + "").css("color", 'rgb(227, 250, 22)');
            break;
        case 2:
            new Notify({ status: 'success', title: 'Voice System', text: 'VOIP : Normal Mode', autoclose: true })
            $("#" + did + "").css("color", 'rgb(23, 255, 15)');
            break;
        case 3:
            new Notify({ status: 'success', title: 'Voice System', text: 'VOIP : Shout Mode', autoclose: true })
            $("#" + did + "").css("color", 'rgb(255, 35, 6)');
            break;
        default:
            new Notify({ status: 'success', title: 'Voice System', text: 'VOIP : Normal Mode', autoclose: true })
            $("#" + did + "").css("color", 'rgb(23, 255, 15)');
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
        document.getElementById("gasbar").style.width = '' + gas + '%'
    } else if (carui == 'minimal') {
        var e = document.getElementById("gasbar");
        if (e) {
            let length = e.getTotalLength();
            ////////console.log(gas)
            let to = length * ((93 - gas) / 100);
            //e.style.strokeDashoffset = to;
            $('#gasbar').velocity({ 'stroke-dashoffset': to }, { duration: 230, delay: 60 })
        }
    } else if (carui == 'simple' && document.getElementById("gasbar")) {
        var opacity = 1.0 - (gas * 0.01)
        document.getElementById("gasbar").style.clip = 'rect(' + toclip(gas) + ', 100px, 100px, 0)'
        document.getElementById("gasbg").style.opacity = '' + opacity + ''
    }
}

function setCarhp(value) {
    var hp = value * 0.1
    if (carui == 'minimal') {
        var e = document.getElementById("carhealthbar");
        if (e) {
            let length = e.getTotalLength();
            ////////console.log(hp)
            let to = length * ((100 - hp) / 100);
            //e.style.strokeDashoffset = to;
            $('#carhealthbar').velocity({ 'stroke-dashoffset': to }, { duration: 450, delay: 60 })
        }
    } else if (carui == 'modern') {
        document.getElementById("carhealthbar").style.width = '' + hp + '%'
    } else if (carui == 'simple') {
        var opacity = 1.0 - (hp * 0.01)
        document.getElementById("carhealthbg").style.opacity = '' + opacity + ''
        document.getElementById("carhealthbar").style.clip = 'rect(' + toclip(hp) + ', 100px, 100px, 0)'
    }
}

function onMessageRecieved(event) {
    let item = event;

    if (item && item.type === 'streetLabel:MSG') {
        if (!item.active) {
            $("#container").hide();
        } else {
            $("#container").show();

            let direction = item.direction;
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

        for (let i = 0; i < borderDOM.length; i++) {
            borderDOM[i].style.color = 'rgba(' + border.join(', ') + ')';
            borderDOM[i].style.fontSize = item.border.size + 'vh';
        }
    }
}

function toclip(val) {
    return 20 - (val / 5)
}

var status_move = []
var move_count = []

var statuscache = {}

function setStatus(t) {
    var table = t['data']
    var type = t['type']
    if (setting['statusver']) {
        status_type = setting['statusver']
    } else {
        status_type = type
    }
    for (const i in table) {
        move_count[i] = i
        if (table[i].rpuidiv == undefined) { table[i].rpuidiv = table[i].status + 'bar' }
        if (document.getElementById(table[i].rpuidiv) && table[i].rpuidiv !== 'armorbar' && table[i].rpuidiv !== 'healthbar') {
            document.getElementById(table[i].rpuidiv).style.width = '' + table[i].value + '%'
        }
        if (status_type == 'icons' && document.getElementById(table[i].status + 'val') && table[i].rpuidiv !== 'armorbar' && table[i].rpuidiv !== 'healthbar') {
            document.getElementById(table[i].status + 'val').style.clip = 'rect(' + toclip(table[i].value) + ', 100px, 100px, 0)'
        } else if (status_type !== 'icons' && table[i].type == 1 && statuscache[table[i].status] !== table[i].value * 1.01 && table[i].status !== 'health' && table[i].status !== 'armor' || status_type !== 'icons' && table[i].type == 1 && statuscache[table[i].status] == undefined && table[i].status !== 'health' && table[i].status !== 'armor') {
            statuscache[table[i].status] = table[i].value
            SetProgressCircle(table[i].status + 'val', table[i].value * 0.9999)
                //console.log(table[i].status,table[i].value)
        }
        if (table[i].value >= 80 && table[i].status == 'stress') {
            document.getElementById(table[i].status + 'blink').style.setProperty("-webkit-filter", "drop-shadow(5px 5px 5px rgba(255, 5, 5, 1.0)");
            document.getElementById(table[i].status + 'blink').style.color = "rgb(255, 5, 5)";
        } else if (table[i].value <= 40 && table[i].status !== 'stress' && table[i].status !== 'voip' && table[i].status !== 'armor' && table[i].type == 1) {
            if (document.getElementById(table[i].status + 'blink')) {
                document.getElementById(table[i].status + 'blink').style.color = "rgb(255, 5, 5)";
                document.getElementById(table[i].status + 'blink').style.setProperty("-webkit-filter", "drop-shadow(5px -1px 5px rgba(255, 5, 5, 1.0)");
            }
        } else if (document.getElementById(table[i].status + 'blink')) {
            document.getElementById(table[i].status + 'blink').style.color = "rgb(177 177 177 / 13%)";
            document.getElementById(table[i].status + 'blink').style.setProperty("-webkit-filter", "drop-shadow(15px -1px 22px rgba(255, 5, 5, 0.0)");
        }
        if (setting['status'] && setting['status'][table[i].status] !== undefined && setting['status'][table[i].status].hideifmax && setting['status'][table[i].status].type == 1 && document.getElementById(table[i].status + 'div')) {
            if (table[i].min_val_hide == undefined) { table[i].min_val_hide = 100 }
            if (table[i].value >= setting['status'][table[i].status].min_val_hide && table[i].status !== 'armor' && table[i].status !== 'stress' && table[i].type == 1 || table[i].value <= setting['status'][table[i].status].min_val_hide && table[i].status !== 'armor' && table[i].status == 'stress' && table[i].type == 1) {
                document.getElementById(table[i].status + 'div').style.display = 'none'
            } else if (table[i].type == 1 && document.getElementById(table[i].status + 'div')) {
                document.getElementById(table[i].status + 'div').style.display = 'block'
                    //console.log(table[i].status,table[i].value)
                if (table[i].status == 'armor' && statusui !== 'simple' || table[i].status == 'armor' && statusui == 'simple' && table[i].value == 0) {
                    document.getElementById(table[i].status + 'div').style.display = 'none'
                } else if (table[i].status == 'armor' && statusui == 'simple' && table[i].value > 0) {
                    document.getElementById(table[i].status + 'div').style.display = 'block'
                }
            }
        } else if (document.getElementById(table[i].status + 'div')) {
            document.getElementById(table[i].status + 'div').style.display = 'block'
        }
    }
}

var status_string = `<div id="status_prog">
<i id="food" class="fad fa-cheeseburger"></i>
<i id="water" class="fad fa-glass"></i>
<i id="stress" class="fad fa-head-side-brain"></i>
<i id="stamina" class="fad fa-running"></i>
<i id="oxygen" class="fad fa-lungs"></i>
<i id="energy" class="fad fa-bed"></i>
<img style="z-index:999;position:absolute;right:25px;top:420px;opacity:0.9;width:260px;height:370px;" src="img/rpui.png" />
<img style="z-index:1001;position:absolute;right:60px;top:465px;opacity:1;height:270px;" src="img/ui.png" />
</div>
<div id="rpui">
<i id="idnum" class="fad fa-id-card"></i>
<div id="idnumlabel">1</div>
<i id="job" class="far fa-user-hard-hat"></i>
<div id="joblabel">Meralco: Employee</div>
<i id="money" class="fad fa-wallet"></i>
<div id="moneylabel">1,000,000</div>
<i id="black_money" class="fad fa-box-usd"></i>
<div id="black_moneylabel">1,000,000</div>
<i id="bank" class="fad fa-money-check"></i>
<div id="banklabel">100,000,000</div>
<img style="z-index:999;position:absolute;right:25px;top:110px;opacity:0.8;width:260px;height:353px;" src="img/rpui.png" />
<div id="info">My Info:</div>
<div id="stats">My Status:</div>
</div>`

function setShowstatus(t) {
    var bool = t['bool']
    var enable = t['enable']
    if (bool) {
        $('#status').append(status_string)
        $("#status").fadeIn();
        setTimeout(function() {
            $("#statusbar").fadeIn();
            if (!enable) {
                document.getElementById('status_prog').style.display = 'none'
                document.getElementById('statusbar').style.display = 'none'
                document.getElementById('status').style.overflow = 'hidden'
                document.getElementById('stats').style.display = 'none'
            }
        }, 333);
    } else {
        $('#status').html('')
        $("#statusbar").fadeOut();
        setTimeout(function() {
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

var oldrpm = 0,
    cntSi = 0;
var newrpm = 0
var oldp = 0

var r = 0
var run = false
var v1 = 5
var v2 = 15

function setRpm(percent) {
    if (rpmanimation) { return }
    var rpm = (percent * 100);
    rpm2 = rpm.toFixed(0) * 100
    if (carui == 'modern') {
        document.getElementById("rpmmeter").innerHTML = "" + rpm2 + "";
    }
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

var metrics = 'kmh'
var settingcarui = 'none'

function setSpeed(s) {
    if (speedanimation) { return }
    var type = carui
    var takbo = s
    if (metrics == 'kmh') {
        takbo = (s * 3.6)
    } else {
        takbo = (s * 2.236936)
    }
    var max = 350
    var bilis = takbo / max
    var right = '47%'
    speed = bilis * 100;
    takbo = takbo.toFixed(0)
    if (type == 'minimal' && settingcarui !== 'minimal') {
        // document.getElementById("speed_minimal").style.display = "block";
        // document.getElementById("speed").style.display = "none";
        document.getElementById("speedmeter").style.right = "20%";
        document.getElementById("speedmeter").style.fontSize = "1.5vw";
        document.getElementById("speedmeter").style.bottom = "50%";
        if (takbo >= 100) {
            right = '45%'
        } else if (takbo >= 10) {
            right = '45.5%'
        } else {
            right = '47%'
        }
    } else if (type == 'modern' && settingcarui !== 'modern') {
        document.getElementById("speedmeter").style.right = "268px";
        document.getElementById("speedmeter").style.bottom = "85px";
        if (takbo >= 100) {
            right = '247px'
        } else if (takbo >= 10) {
            right = '258px'
        } else {
            right = '268px'
        }
    } else if (type == 'simple' && settingcarui !== 'simple') {
        document.getElementById("speedmeter").style.right = "20%";
        document.getElementById("speedmeter").style.fontSize = "1.5vw";
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
    var e = document.getElementById("coolantpath");
    if (e) {
        let length = e.getTotalLength();
        let value = water;
        let to = length * ((100 - value) / 100);
        val = to / 1000
            //e.style.strokeDashoffset = to;
        $('#coolantpath').velocity({ 'stroke-dashoffset': to }, { duration: 450, delay: 60 })
    }
}

var manual = false

function setShow(table) {
    if (table['bool']) {
        invehicle = true
        $("#" + carui + "").animate({
            opacity: "0.65"
        }, 400);
        setHeadlights(0)
        if (carui == 'modern') {
            post("openmap", {})
        }
        document.getElementById("" + carui + "").style.display = 'block'
    } else {
        invehicle = false
        $("#" + carui + "").animate({
            opacity: "0"
        }, 400);
        document.getElementById("" + carui + "").style.display = 'none'
            //clearInterval(loopfuck);
    }
    RestoreCarPosition()
}

function setHeadlights(v) {
    if (v == 1) {
        document.getElementById("offlight").style.display = 'none'
        document.getElementById("onlight").style.display = 'block'
        document.getElementById("highlight").style.display = 'none'
        if (carui == 'modern') { return }
        document.getElementById("" + carui + "_light").style.setProperty("-webkit-filter", "drop-shadow(1px 1px 3px rgba(3, 137, 246, 1.0)");
    } else if (v == 2) {
        document.getElementById("offlight").style.display = 'none'
        document.getElementById("onlight").style.display = 'none'
        document.getElementById("highlight").style.display = 'block'
        if (carui == 'modern') { return }
        document.getElementById("" + carui + "_light").style.setProperty("-webkit-filter", "drop-shadow(1px 1px 3px rgba(3, 137, 246, 1.0)");
    } else {
        document.getElementById("offlight").style.display = 'block'
        document.getElementById("onlight").style.display = 'none'
        document.getElementById("highlight").style.display = 'none'
        if (carui == 'modern') { return }
        document.getElementById("" + carui + "_light").style.setProperty("-webkit-filter", "drop-shadow(1px -1px 0.4px rgba(255, 255, 255, 0.822))");
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
    mileage = value.toFixed(0);
    if (mileage >= 1000) {
        document.getElementById("mileage").style.margin = '0 2px 0 0'
    } else if (mileage >= 100) {
        document.getElementById("mileage").style.margin = '0 10px 0 0'
    } else if (mileage >= 10) {
        document.getElementById("mileage").style.margin = '0 15px 0 0'
    }

    var e = document.getElementById("oilpath");
    if (mileage >= 5000 && mileage < 10000) {
        document.getElementById("mileage").style.color = 'yellow'
    } else if (mileage >= 10000) {
        document.getElementById("mileage").style.color = '#C85A17'
    } else {
        document.getElementById("mileage").style.color = 'rgba(182, 182, 182, 0.582)'
    }
    document.getElementById("mileage").innerHTML = '' + mileage + ''
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
    document.getElementById("distance").innerHTML = '' + dis + ''
}

function setTime(format) {
    var cur = 'Am'
    if (!document.getElementById("timetext")) { return }
    if (format.hour > 12) {
        cur = 'Pm'
        document.getElementById("timetext").innerHTML = ' Pm'
    } else {
        cur = 'Am'
        document.getElementById("timetext").innerHTML = ' Am'
    }
    var formatdate = '' + format.hour + ':' + format.min + ''
    if (cur == 'Pm' && format.hour > 12) {
        format.hour = format.hour - 12
        formatdate = '' + format.hour + ':' + format.min + ''
    }
    document.getElementById("time").innerHTML = '' + formatdate + ''
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
    if (document.getElementById("gear")) {
        document.getElementById("gear").innerHTML = '' + gear + ''
    }
}

function numberWithCommas(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function setInfo(table) {
    if (document.getElementById("idnumlabel") == undefined) { return }
    document.getElementById("idnumlabel").innerHTML = 'Citizen ID#: ' + table.id + ''
    document.getElementById("joblabel").innerHTML = '' + table.job + ': ' + table.joblabel + ''
    document.getElementById("moneylabel").innerHTML = '' + numberWithCommas(table.money) + ''
    document.getElementById("black_moneylabel").innerHTML = '' + numberWithCommas(table.black) + ''
    document.getElementById("banklabel").innerHTML = '' + numberWithCommas(table.bank) + ''
}

function setSignal(value) {
    if (value == 'hazard') {
        document.getElementById('left').style.opacity = '0.2'
        document.getElementById('left').style.color = 'white'
        document.getElementById('right').style.opacity = '0.2'
        document.getElementById('right').style.color = 'white'
        setTimeout(function() {
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
        setTimeout(function() {
            $("#" + value + "").fadeIn();
            document.getElementById(value).style.opacity = '1'
            document.getElementById(value).style.color = 'lime'
        }, 433);
    }
    setTimeout(function() {
        document.getElementById('left').style.opacity = '0.2'
        document.getElementById('left').style.color = 'white'
        document.getElementById('right').style.opacity = '0.2'
        document.getElementById('right').style.color = 'white'
    }, 733);
}

function setManual(bool, s) {
    manual = bool
    if (!s) {
        featstate['manualhud'] = bool
    }
    if (bool && setting['carhud']['manualhud'] && featstate['manualhud']) {
        $("#shift").animate({
            opacity: "1"
        }, 400);
    } else {
        if (!s) {
            featstate['manualhud'] = false
        }
        $("#shift").animate({
            opacity: "0"
        }, 400);
    }
}

function setShift(gear) {
    $("#shifter").css(
        "background-image",
        'url("shifter/' + gear + '.webp")'
    );
}

function setStart(bool) {
    $("#carui").attr("src", "img/carui_" + bool + ".png")
}

function setDoor(s) {

}

function setHood(s) {

}

function setTrunk(s) {

}

function setBrake(s) {
    if (s && document.getElementById('handbrakeopen')) {
        document.getElementById('handbrakeopen').style.display = 'block'
        document.getElementById('handbrakeclose').style.display = 'none'
    } else if (document.getElementById('handbrakeopen')) {
        document.getElementById('handbrakeopen').style.display = 'none'
        document.getElementById('handbrakeclose').style.display = 'block'
    }
}

function CarMap(detalye) {
    var detail = detalye;
    var table = detail.content
    var r = document.querySelector(':root');
    if (detail.type == "updatemapa") {
        $(".centermap").css("transform", "rotate(" + table.myheading + "deg)");
        $("#carblip").css("transform", "translateX(-50%) translateY(50%) rotate(" + table.camheading + "deg)");
        r.style.setProperty('--Y', table.y);
        r.style.setProperty('--X', table.x);
    } else {
        if (detail.type == "sarado") {
            $(".carhudmap").fadeOut();
            setTimeout(function() {
                $("#gps").fadeOut();
                $("#gps").css("display", "none");
                $(".centermap").css("display", "none");
                $(".carhudmap").css("display", "none");
            }, 333);
        }
        if (detail.type == "bukas") {
            $("#gps").fadeIn();
            setTimeout(function() {
                $(".carhudmap").fadeIn();
                $(".centermap").css("display", "block");
                $("#gps").css("display", "block");
                $(".carhudmap").css("display", "block");
            }, 333);
        }
    }
}

function setTemp(temp) {
    ////console.log(carui,"temp")
    var temp = temp - 50
    if (carui == 'modern') {
        document.getElementById("cartempbar").style.width = '' + temp + '%'
    } else {
        var e = document.getElementById("cartempbar");
        if (e) {
            let length = e.getTotalLength();
            let to = length * ((71 - temp) / 100);
            //e.style.strokeDashoffset = to;
            if (temp > 80) {
                e.style.stroke = 'red';
            } else if (temp > 70) {
                e.style.stroke = 'orange';
            } else if (temp > 50) {
                e.style.stroke = 'blue';
            } else {
                e.style.stroke = 'skyblue';
            }
            $('#cartempbar').velocity({ 'stroke-dashoffset': to }, { duration: 250, delay: 60 })
        }
    }
}

function setMode(value, c) {
    document.getElementById("modediv").style.opacity = '0.0';
}

function setDifferential(value) {
    if (value == 0.0) {
        value = 'RWD'
    } else if (value == 1.0) {
        value = 'FWD'
    } else {
        value = 'AWD'
    }
    if (document.getElementById("diff")) {
        document.getElementById("diff").innerHTML = value;
    }
}

function setCruiseControl(bool) {
    if (bool) {
        document.getElementById('cruisetext').style.color = 'lime'
    } else {
        document.getElementById('cruisetext').style.color = '#1817179f'
    }
}
var cachebody = undefined

function setShowBodyUi(bool) {

}

function pulse(stroke) {

}

var bodystatus = {}

function setUpdateBodyStatus(table) {

}

function setBodyParts(table) {

}

function setShowCarcontrol(table) {

}

function post(name, data) {
    var name = name;
    var data = data;
    $.post("https://renzu_hud/" + name, JSON.stringify(data));
}

function healpart(data) {
    var name = name;
    var data = data;
    $.post("https://renzu_hud/healpart", JSON.stringify({ part: data }));
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

function showhidecontrolui(bool, id) {
    if (bool) {
        document.getElementById('' + id + '').style.opacity = '1.0'
        $("#" + id + "").fadeIn();
    } else {
        document.getElementById('' + id + '').style.display = '0.0'
        $("#" + id + "").fadeOut();
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

function setBool(index, type) {
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
            setBool(key, 'door')
            showhidecontrolui(bool, indexname(key))
        }
    }
}

function setWindowState(table) {
    for (const key in table) {
        if (key <= 3 && table[key] == true) {
            var bool = table[key];
            setBool(key, 'window')
            showhidecontrolui(bool, windowname(key))
        }
    }
}

function Carcontrolcallbackui(type, index) {

}

function setWeapon(weapon) {
    //////////console.log(""+weapon+".png")
    var url = "img/weapons/" + weapon + ".webp"
    $("#weaponimg").attr("src", url)
    setTimeout(function() {
        if (document.getElementById("weaponimg")) {
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
        }
    }, 333);
}

oldto = 55

function setAmmo(table) {
    var max = table['max'];
    var ammo = table['clip'];
    var percent = ammo / max * 100;
    ////////console.log(percent)
    var bullets = percent;
    //rpm2 = bullets.toFixed(0) * 100
    var e = document.getElementById("weaponpath");
    if (e) {
        let length = e.getTotalLength();
        let value = bullets;
        let to = length * ((100 - value) / 100);
        val = to / 1000
            //e.style.strokeDashoffset = to;
        if (to == oldto) { return }
        oldto = to
        $('#weaponpath').velocity({ 'stroke-dashoffset': to }, { duration: 50, delay: 10 })
        document.getElementById("ammotext").innerHTML = '' + table['ammo'] + '';
    }
}

var weaponstring = `<img style="z-index:900;position:absolute;right:10px;bottom:100px;opacity:0.7;height:200px;" src="img/weaponui.png" />
<img id="weaponimg" style="z-index:901;position:absolute;right:70px;bottom:180px;opacity:0.9;max-height:40px;max-width:100px;;align-content:center;align:center;display: block;margin-left: auto;margin-right: auto;" src="img/weapons/weapon_advancedrifle.png" />
<svg id="weapon" style="z-index:889;position:absolute;right:-39px;bottom:90px;opacity:0.65;height:212px;transform: rotate(-270deg) scaleX(-1);"
  xmlns="http://www.w3.org/2000/svg" height="250" width="250" viewBox="0 0 250 250" data-value="1">
  <path class="bg" stroke="#00000078" d="M41 149.5a77 77 0 1 1 180.93 0"  fill="none"/>
  <path id="weaponpath" class="meter carhud" stroke="skyblue" d="M41 149.5a77 77 0 1 1 180.93 0" fill="none" stroke-dasharray="280" stroke-dashoffset="280"/>
</svg>
<div id="ammotext">500</div>
<div class="crosshair-wrapper">
  <img style="display:none;" id="crosshair" src="img/crosshair_1.png" class="crosshair"/>
</div>`

function setWeaponUi(bool, s) {
    if (!s || s == undefined) {
        featstate['weaponhud'] = bool
    }
    if (bool && setting['weaponhud'] && featstate['weaponhud']) {
        //document.getElementById("weaponui").style.display = 'block';
        $('#weaponui').append(weaponstring)
        $("#weaponui").fadeIn();
    } else {
        if (!s && !bool) {
            featstate['weaponhud'] = false
        }
        $('#weaponui').html('')
            //document.getElementById("weaponui").style.display = 'none';
        $("#weaponui").fadeOut();
    }
}

function setCrosshair(val) {
    if (val <= 5 && document.getElementById("crosshair")) {
        document.getElementById("crosshair").style.display = 'block';
        var url = "img/crosshair_" + val + ".png"
        $("#crosshair").attr("src", url)
    }
}

setWeaponUi(false)

var carui_element = []
carui_element['modern'] = `<a id="start"></a>
<div class="carhudmap" style="display: none;">
  <div class="fadeout"></div>
  <img src="img/carblip.png" alt="you" id="carblip" />
  <div class="centermap">
    <div class="maploc">
      <img style="width:100%;" id="mapimg" src="img/loading.png">
      </div>
    </div>
  </div>
  <img id="carui" style="-webkit-filter: drop-shadow(1px -1px 0.4px rgba(255, 255, 255, 0.822));z-index:999;position:absolute;right:10px;bottom:10px;opacity:0.95;height:180px" src="img/carui_false.png?img/car.png" />
  <!-- <img id="carui" style="-webkit-filter: drop-shadow(1px -1px 0.4px rgba(255, 255, 255, 0.822));z-index:999;position:absolute;right:10px;bottom:10px;opacity:0.95;height:180px" src="img/carui_false.png?img/car.png" /> -->
  <!-- z-index:998;position:absolute;right:-27px;bottom:15px;opacity:0.65;height:125px;transform: rotate(-270deg) scaleX(-1); <svg id="rpm" style="z-index:999;position:absolute;right:-34px;bottom:12px;opacity:0.65;height:132px;transform: rotate(90deg);transform: scaleX(-1);"xmlns="http://www.w3.org/2000/svg" height="200" width="200" viewBox="0 0 200 200" data-value="1"> -->
  <svg id="rpm" style="z-index:998;position:absolute;right:-27px;bottom:15px;opacity:0.65;height:125px;transform: rotate(-270deg) scaleX(-1);"
    xmlns="http://www.w3.org/2000/svg" height="200" width="200" viewBox="0 0 200 200" data-value="1">
    <path class="bg" stroke="#00000078" d="M41 149.5a77 77 0 1 1 180.93 0"  fill="none"/>
    <defs>
      <filter id="dropshadow" width="170%" height="110%">
        <feOffset result="offOut" in="SourceGraphic" dx="4" dy="15"></feOffset>
        <feColorMatrix result="matrixOut" in="offOut" type="matrix"
values="1.000  0.000  0.000  0.000  0.000 
0.000  1.000  0.000  0.000  0.000 
0.000  0.000  6.000  0.000  0.000 
0.000  0.000  0.000  1.000  0.000" />
        <feGaussianBlur result="blurOut" in="matrixOut" stdDeviation="5"></feGaussianBlur>
        <feBlend in="SourceGraphic" in2="blurOut" mode="normal"></feBlend>
      </filter>
    </defs>
    <path id="rpmpath" class="meter rpm" stroke="#fefefe" d="M41 149.5a77 77 0 1 1 180.93 0" fill="none" style="filter:url(#dropshadow)" stroke-dasharray="280" stroke-dashoffset="280"/>
  </svg>
  <div id="rpmmeter">1000</div>
  <div id="rpmtext">x 1000rpm</div>
  <svg id="speed" style="z-index:998;position:absolute;right:201px;bottom:15px;opacity:0.65;height:125px;transform: rotate(-90deg)"
    xmlns="http://www.w3.org/2000/svg" height="200" width="200" viewBox="0 0 200 200" data-value="1">
    <path class="bg" stroke="#00000078" d="M41 149.5a77 77 0 1 1 180.93 0"  fill="none"/>
    <defs>
      <filter id="dropshadow" width="170%" height="110%">
        <feOffset result="offOut" in="SourceGraphic" dx="4" dy="15"></feOffset>
        <feColorMatrix result="matrixOut" in="offOut" type="matrix"
values="1.000  0.000  0.000  0.000  0.000 
0.000  1.000  0.000  0.000  0.000 
0.000  0.000  6.000  0.000  0.000 
0.000  0.000  0.000  1.000  0.000" />
        <feGaussianBlur result="blurOut" in="matrixOut" stdDeviation="5"></feGaussianBlur>
        <feBlend in="SourceGraphic" in2="blurOut" mode="normal"></feBlend>
      </filter>
    </defs>
    <path id="speedpath" class="meter carhud" stroke="#fefefe" d="M41 149.5a77 77 0 1 1 180.93 0" fill="none" style="filter:url(#dropshadow)" stroke-dasharray="290" stroke-dashoffset="290"/>
  </svg>
  <svg id="coolant" style="z-index:998;position:absolute;right:211px;bottom:10px;opacity:0.65;height:165px;transform: rotate(-90deg)"
    xmlns="http://www.w3.org/2000/svg" height="250" width="200" viewBox="0 0 250 200" data-value="1">
    <path class="bg" stroke="#00000078" d="M41 149.5a77 77 0 1 1 180.93 0"  fill="none"/>
    <defs>
      <filter id="dropshadow" width="170%" height="110%">
        <feOffset result="offOut" in="SourceGraphic" dx="4" dy="15"></feOffset>
        <feColorMatrix result="matrixOut" in="offOut" type="matrix"
values="1.000  0.000  0.000  0.000  0.000 
0.000  1.000  0.000  0.000  0.000 
0.000  0.000  6.000  0.000  0.000 
0.000  0.000  0.000  1.000  0.000" />
        <feGaussianBlur result="blurOut" in="matrixOut" stdDeviation="5"></feGaussianBlur>
        <feBlend in="SourceGraphic" in2="blurOut" mode="normal"></feBlend>
      </filter>
    </defs>
    <path style="stroke-width: 7px;stroke: rgb(0, 101, 253);" id="coolantpath" class="meter carhud" stroke="#fefefe" d="M41 149.5a77 77 0 1 1 180.93 0" fill="none" stroke-dasharray="290" stroke-dashoffset="0"/>
  </svg>
  <svg id="oil" style="z-index:998;position:absolute;right:-39px;bottom:10px;opacity:0.65;height:165px;transform:rotate(-270deg) scaleX(-1);"
    xmlns="http://www.w3.org/2000/svg" height="250" width="200" viewBox="0 0 250 200" data-value="1">
    <path class="bg" stroke="#00000078" d="M41 149.5a77 77 0 1 1 180.93 0"  fill="none"/>
    <defs>
      <filter id="dropshadow" width="170%" height="110%">
        <feOffset result="offOut" in="SourceGraphic" dx="4" dy="15"></feOffset>
        <feColorMatrix result="matrixOut" in="offOut" type="matrix"
values="1.000  0.000  0.000  0.000  0.000 
0.000  1.000  0.000  0.000  0.000 
0.000  0.000  6.000  0.000  0.000 
0.000  0.000  0.000  1.000  0.000" />
        <feGaussianBlur result="blurOut" in="matrixOut" stdDeviation="1"></feGaussianBlur>
        <feBlend in="SourceGraphic" in2="blurOut" mode="normal"></feBlend>
      </filter>
    </defs>
    <path style="stroke-width: 7px;stroke: rgb(128, 221, 22);" id="oilpath" class="meter carhud" stroke="#fefefe" d="M41 149.5a77 77 0 1 1 180.93 0" fill="none" stroke-dasharray="290" stroke-dashoffset="0"/>
  </svg>
  <div id="body" style="z-index:-1;position:absolute;border-radius:41%;right:21px;bottom:10px;height:175px;width:330px;background-color: #0000002a;"></div>
  <div id="diffdiv">
    <span id="diff">OFF</span>
  </div>
  <div id="modediv">
    <span id="mode">ECO</span>
  </div>
  <div id="speedmeter"></div>
  <div id="speedtext">kMH</div>
  <div id="cruisetext">Cruise</div>
  <div id="milediv">
    <span id="mileage">0</span> kM
  </div>
  <div id="distancediv">
    <span id="distance">0</span>
    <span id="distext">Dis</span>
  </div>
  <div id="timediv">
    <span id="time">00:00</span>
    <span id="timetext">Pm</span>
  </div>
  <div id="geardiv">
    <span id="gear">P</span>
    <span id="geartext"></span>
  </div>
  <i id="right" class="fas fa-arrow-alt-right"></i>
  <i id="left" class="fas fa-arrow-alt-left"></i>
  <div class="gas-bar">
    <span class="bar">
      <span class="gas_progress" id="gasbar"></span>
    </span>
  </div>
  <div class="carhealth-bar">
    <span class="bar">
      <span class="carhealth_progress" id="carhealthbar"></span>
    </span>
  </div>
  <div class="cartemp-bar">
    <span class="bar">
      <span class="cartemp_progress" id="cartempbar"></span>
    </span>
  </div>
  <div id="offlight">
    <img id="offlightclip" src="assets/icons.svg" />
  </div>
  <div id="onlight">
    <img id="onlightclip" src="assets/icons.svg" />
  </div>
  <div id="highlight">
    <img id="highlightclip" src="assets/icons.svg" />
  </div>
  <div id="seatbelt">
    <img id="seatbeltclip" src="assets/icons.svg" />
  </div>
  <div id="onseatbelt">
    <img id="onseatbeltclip" src="assets/icons.svg" />
  </div>
  <div id="carfunc">
    <img id="doorclose" src="img/doorclose.png" />
    <img id="dooropen" src="img/dooropen.png" />
    <img id="trunkopen" src="img/trunkopen.png" />
    <img id="trunkclose" src="img/trunkclose.png" />
    <img id="hoodopen" src="img/hoodopen.png" />
    <img id="hoodclose" src="img/hoodclose.png" />
    <img id="handbrakeopen" src="img/handbrakeopen.png" />
    <img id="handbrakeclose" src="img/handbrakeclose.png" />
    <i id="waterlevel" class="fad fa-oil-temp"></i>
    <span id="watermax">F</span>
    <span id="waterempty">E</span>
    <i id="oillevel" class="fas fa-oil-can"></i>
    <span id="oilmax">F</span>
    <span id="oilempty">E</span>
    <i id="tempicon" class="fad fa-thermometer-half"></i>
    <i id="gasicon" class="fad fa-gas-pump"></i>
    <i id="caricon" class="fad fa-car-mechanic"></i>
  </div>`

carui_element['minimal'] = `<img id="minimal_light" style="z-index:999;position:relative;opacity:0.85;width:100%;right:0;float:right;" src="img/carui_minimal.png?img/car.png" />
<svg id="rpm" style="z-index:1005;position:absolute;right:60%;bottom:36%;opacity:0.65;width:40%;height:28.88%;transform: rotate(-60deg);"
  xmlns="http://www.w3.org/2000/svg" height="210" width="210" viewBox="0 0 177 177" data-value="1">
  <defs>
    <filter id="dropshadow" width="170%" height="110%">
      <feOffset result="offOut" in="SourceGraphic" dx="4" dy="7"></feOffset>
      <feColorMatrix result="matrixOut" in="offOut" type="matrix"
values="1.000  0.000  0.000  0.000  0.000 
0.000  1.000  0.000  0.000  0.000 
0.000  0.000  6.000  0.000  0.000 
0.000  0.000  0.000  1.000  0.000" />
      <feGaussianBlur result="blurOut" in="matrixOut" stdDeviation="5"></feGaussianBlur>
      <feBlend in="SourceGraphic" in2="blurOut" mode="normal"></feBlend>
    </filter>
  </defs>
  <path class="bg" stroke="#00000078" d="M41 149.5a77 77 0 1 1 180.93 0" fill="none"/>
  <path id="rpmpath" class="meter rpm rpm_minimal" stroke="#fefefe" d="M41 149.5a77 77 0 1 1 180.93 0" fill="none" stroke-dasharray="280" stroke-dashoffset="280"/>
</svg>
<div id="rpmmeter" style="display:none;">1000</div>
<div id="speedtext">kMH</div>
<svg id="speed" style="z-index:1005;position:absolute;right:22%;bottom:26%;opacity:0.65;;width:54%;height:47%;transform: rotate(0deg)"
  xmlns="http://www.w3.org/2000/svg" height="200" width="200" viewBox="0 0 200 200" data-value="1">
  <path class="bg" stroke="#00000078" d="M41 149.5a77 77 0 1 1 111.93 0"  fill="none"/>
  <defs>
    <filter id="dropshadow" width="170%" height="110%">
      <feOffset result="offOut" in="SourceGraphic" dx="4" dy="15"></feOffset>
      <feColorMatrix result="matrixOut" in="offOut" type="matrix"
values="1.000  0.000  0.000  0.000  0.000 
0.000  1.000  0.000  0.000  0.000 
0.000  0.000  6.000  0.000  0.000 
0.000  0.000  0.000  1.000  0.000" />
      <feGaussianBlur result="blurOut" in="matrixOut" stdDeviation="5"></feGaussianBlur>
      <feBlend in="SourceGraphic" in2="blurOut" mode="normal"></feBlend>
    </filter>
  </defs>
  <path id="speedpath" class="meter carhud" stroke="#fefefe" d="M41 149.5a77 77 0 1 1 111.93 0" fill="none" stroke-dasharray="360" stroke-dashoffset="360"/>
</svg>
<div id="speedmeter"></div>
<svg id="gas" style="z-index:1005;position:absolute;right:6.5%;bottom:34.5%;opacity:0.65;height:22%;width:18%;transform: rotate(-100deg) scaleX(1) scaleY(-1);;"
  xmlns="http://www.w3.org/2000/svg" height="84" width="84" viewBox="0 0 140 140" data-value="1">
  <path class="bg" stroke="#00000078" d="M41 149.5a77 77 0 1 1 170.93 0"  fill="none"/>
  <defs>
    <filter id="dropshadow2" width="170%" height="110%">
      <feOffset result="offOut" in="SourceGraphic" dx="2" dy="2"></feOffset>
      <feColorMatrix result="matrixOut" in="offOut" type="matrix"
values="1.000  0.000  0.000  0.000  0.000 
0.000  1.000  0.000  0.000  0.000 
0.000  0.000  6.000  0.000  0.000 
0.000  0.000  0.000  1.000  0.000" />
      <feGaussianBlur result="blurOut" in="matrixOut" stdDeviation="8"></feGaussianBlur>
      <feBlend in="SourceGraphic" in2="blurOut" mode="normal"></feBlend>
    </filter>
  </defs>
  <path id="gasbar" class="meter carhud" stroke="gold" d="M41 149.5a77 77 0 1 1 170.93 0" fill="none" style="filter:url(#dropshadow2)" stroke-dasharray="180" stroke-dashoffset="250"/>
</svg>
<svg id="cartemp" style="z-index:1005;position:absolute;right:13.7%;bottom:56.5%;opacity:0.65;height:23%;width:20%;transform: rotate(-200deg) scaleX(1) scaleY(-1);;"
  xmlns="http://www.w3.org/2000/svg" height="84" width="84" viewBox="0 0 140 140" data-value="1">
  <path class="bg" stroke="#00000078" d="M41 149.5a77 77 0 1 1 170.93 0"  fill="none"/>
  <defs>
    <filter id="dropshadow2" width="170%" height="110%">
      <feOffset result="offOut" in="SourceGraphic" dx="2" dy="2"></feOffset>
      <feColorMatrix result="matrixOut" in="offOut" type="matrix"
values="1.000  0.000  0.000  0.000  0.000 
0.000  1.000  0.000  0.000  0.000 
0.000  0.000  6.000  0.000  0.000 
0.000  0.000  0.000  1.000  0.000" />
      <feGaussianBlur result="blurOut" in="matrixOut" stdDeviation="8"></feGaussianBlur>
      <feBlend in="SourceGraphic" in2="blurOut" mode="normal"></feBlend>
    </filter>
  </defs>
  <path id="cartempbar" class="meter carhud" stroke="red" d="M41 149.5a77 77 0 1 1 170.93 0" fill="none" style="filter:url(#dropshadow2)" stroke-dasharray="190" stroke-dashoffset="190"/>
</svg>
<svg id="vehiclehealth" style="z-index:1005;position:absolute;right:0.2%;bottom:39.9%;opacity:0.65;;width:20%;height:13%;transform: rotate(0deg)"
  xmlns="http://www.w3.org/2000/svg" height="200" width="200" viewBox="0 0 200 200" data-value="1">
  <path class="bg" stroke="#00000078" d="M41 149.5a77 77 0 1 1 111.93 0"  fill="none"/>
  <defs>
    <filter id="dropshadow" width="170%" height="110%">
      <feOffset result="offOut" in="SourceGraphic" dx="4" dy="15"></feOffset>
      <feColorMatrix result="matrixOut" in="offOut" type="matrix"
values="1.000  0.000  0.000  0.000  0.000 
0.000  1.000  0.000  0.000  0.000 
0.000  0.000  6.000  0.000  0.000 
0.000  0.000  0.000  1.000  0.000" />
      <feGaussianBlur result="blurOut" in="matrixOut" stdDeviation="5"></feGaussianBlur>
      <feBlend in="SourceGraphic" in2="blurOut" mode="normal"></feBlend>
    </filter>
  </defs>
  <path id="carhealthbar" class="meter carhud" stroke="#2B68E2" d="M41 149.5a77 77 0 1 1 111.93 0" fill="none" stroke-dasharray="360" stroke-dashoffset="360"/>
</svg>
<svg id="coolant" style="z-index:1005;position:absolute;right:-0.7%;bottom:50.5%;opacity:0.65;;width:20%;height:13%;transform: rotate(0deg)"
  xmlns="http://www.w3.org/2000/svg" height="200" width="200" viewBox="0 0 200 200" data-value="1">
  <path class="bg" stroke="#00000078" d="M41 149.5a77 77 0 1 1 111.93 0"  fill="none"/>
  <defs>
    <filter id="dropshadow" width="170%" height="110%">
      <feOffset result="offOut" in="SourceGraphic" dx="4" dy="15"></feOffset>
      <feColorMatrix result="matrixOut" in="offOut" type="matrix"
values="1.000  0.000  0.000  0.000  0.000 
0.000  1.000  0.000  0.000  0.000 
0.000  0.000  6.000  0.000  0.000 
0.000  0.000  0.000  1.000  0.000" />
      <feGaussianBlur result="blurOut" in="matrixOut" stdDeviation="5"></feGaussianBlur>
      <feBlend in="SourceGraphic" in2="blurOut" mode="normal"></feBlend>
    </filter>
  </defs>
  <path id="coolantpath" class="meter carhud" stroke="#2B68E2" d="M41 149.5a77 77 0 1 1 111.93 0" fill="none" stroke-dasharray="360" stroke-dashoffset="360"/>
</svg>
<svg id="nitro" style="z-index:1005;position:absolute;right:3.1%;bottom:29.6%;opacity:0.65;;width:20%;height:12%;transform: rotate(0deg)"
  xmlns="http://www.w3.org/2000/svg" height="200" width="200" viewBox="0 0 200 200" data-value="1">
  <path class="bg" stroke="#00000078" d="M41 149.5a77 77 0 1 1 111.93 0"  fill="none"/>
  <defs>
    <filter id="dropshadow" width="170%" height="110%">
      <feOffset result="offOut" in="SourceGraphic" dx="4" dy="15"></feOffset>
      <feColorMatrix result="matrixOut" in="offOut" type="matrix"
values="1.000  0.000  0.000  0.000  0.000 
0.000  1.000  0.000  0.000  0.000 
0.000  0.000  6.000  0.000  0.000 
0.000  0.000  0.000  1.000  0.000" />
      <feGaussianBlur result="blurOut" in="matrixOut" stdDeviation="5"></feGaussianBlur>
      <feBlend in="SourceGraphic" in2="blurOut" mode="normal"></feBlend>
    </filter>
  </defs>
  <path id="nitropath" class="meter carhud" stroke="red" d="M41 149.5a77 77 0 1 1 111.93 0" fill="none" stroke-dasharray="360" stroke-dashoffset="360"/>
</svg>
<div id="modediv">
  <span id="mode">ECO</span>
</div>
<div id="rpmtext">x 1000rpm</div>
<i id="tempicon" class="fad fa-oil-temp"></i>
<i id="gasicon" class="fad fa-gas-pump"></i>
<div id="geardiv">
  <span id="gear">P</span>
  <span id="geartext"></span>
</div>
<span class="fa-stack fa-2x" style='font-size:0.9vw;position:absolute;right:22%;bottom:20%;color:rgba(144, 144, 144, 0.876)'>
  <i class="fas fa-octagon fa-stack-2x" style='font-size:1.1vw;color:rgb(20 25 27 / 46%);margin-left:0.2vw;'></i>
  <i class="fal fa-octagon fa-stack-2x" style="font-size:1.3vw;color:rgb(177 177 177 / 13%)"></i>
  <img style="display:block; height:100%;width:80%;position:absolute;top:4%;left:32.5%;" id="handbrakeopen" src="img/handbrakeopen.png" />
  <img style="display:block; height:100%;width:80%;position:absolute;top:4%;left:32.5%;opacity:0.6;-webkit-filter: drop-shadow(1px -1px 2px rgba(6, 8, 8, 0.822));" id="handbrakeclose" src="img/handbrakeclose.png" />
</span>
<span class="fa-stack fa-2x" style='font-size:0.9vw;position:absolute;right:31%;bottom:20%;color:rgba(144, 144, 144, 0.876)'>
  <i class="fas fa-octagon fa-stack-2x" style='font-size:1.1vw;color:rgb(20 25 27 / 46%);margin-left:0.2vw;'></i>
  <i class="fal fa-octagon fa-stack-2x" style="font-size:1.3vw;color:rgb(177 177 177 / 13%)"></i>
  <img id="hoodopen" style="display:block; height:100%;width:80%;position:absolute;top:0%;left:33%;" src="img/hoodopen.png" />
  <img id="hoodclose" style="display:none; height:100%;width:80%;position:absolute;top:0%;left:33%;;opacity:0.6;-webkit-filter: drop-shadow(1px -1px 2px rgba(6, 8, 8, 0.822));" src="img/hoodclose.png" />
</span>
<span class="fa-stack fa-2x" style='font-size:0.9vw;position:absolute;right:40%;bottom:20%;color:rgba(144, 144, 144, 0.876)'>
  <i class="fas fa-octagon fa-stack-2x" style='font-size:1.1vw;color:rgb(20 25 27 / 46%);margin-left:0.2vw;'></i>
  <i class="fal fa-octagon fa-stack-2x" style="font-size:1.3vw;color:rgb(177 177 177 / 13%)"></i>
  <img id="trunkopen" style="display:block; height:100%;width:80%;position:absolute;top:0%;left:33%;" src="img/trunkopen.png" />
  <img id="trunkclose" style="display:block; height:100%;width:80%;position:absolute;top:0%;left:33%;;opacity:0.6;-webkit-filter: drop-shadow(1px -1px 2px rgba(6, 8, 8, 0.822));" src="img/trunkclose.png" />
</span>
<span class="fa-stack fa-2x" style='font-size:0.9vw;position:absolute;right:49%;bottom:20%;color:rgba(144, 144, 144, 0.876)'>
  <i class="fas fa-octagon fa-stack-2x" style='font-size:1.1vw;color:rgb(20 25 27 / 46%);margin-left:0.2vw;'></i>
  <i class="fal fa-octagon fa-stack-2x" style="font-size:1.3vw;color:rgb(177 177 177 / 13%)"></i>
  <img style="display:block; height:85%; width:75%;position:absolute;top:1%;left:33%;opacity:0.6;-webkit-filter: drop-shadow(1px -1px 2px rgba(6, 8, 8, 0.822));" id="doorclose" src="img/doorclose.png" />
  <img style="display:none; height:85%;width:75%;position:absolute;top:1%;left:33%;opacity:0.7" id="dooropen" src="img/dooropen.png" />
</span>
<span class="fa-stack fa-2x" style='font-size:0.9vw;position:absolute;right:58%;bottom:20%;color:rgba(144, 144, 144, 0.876)'>
  <i class="fas fa-octagon fa-stack-2x" style='font-size:1.1vw;color:rgb(20 25 27 / 46%);margin-left:0.2vw;'></i>
  <i class="fal fa-octagon fa-stack-2x" style="font-size:1.3vw;color:rgb(177 177 177 / 13%)"></i>
  <img style="display:block; height:85%;position:absolute;top:4%;left:38%;-webkit-filter: drop-shadow(1px -1px 2px rgba(6, 8, 8, 0.822));" id="seatbelt" src="img/seatbeltoff.png" />
  <img style="display:none;height:85%;position:absolute;top:4%;left:38%;-webkit-filter: drop-shadow(1px -1px 2px rgba(6, 8, 8, 0.822));" id="onseatbelt" src="img/seatbelton.png" />
</span>
<span class="fa-stack fa-2x" style='font-size:0.9vw;position:absolute;right:66.9%;bottom:20%;color:rgba(144, 144, 144, 0.876)'>
  <i class="fas fa-octagon fa-stack-2x" style='font-size:1.1vw;color:rgb(20 25 27 / 46%);margin-left:0.2vw;'></i>
  <i class="fal fa-octagon fa-stack-2x" style="font-size:1.3vw;color:rgb(177 177 177 / 13%)"></i>
  <img style="display:block; height:100%;position:absolute;top:3%;left:35%;opacity:0.5;-webkit-filter: drop-shadow(1px -1px 2px rgba(6, 8, 8, 0.822));" id="offlight" src="img/lightoff.png" />
  <img style="display:none;height:100%;position:absolute;top:3%;left:35%;-webkit-filter: drop-shadow(1px -1px 2px rgba(0, 0, 0, 0.822));" id="onlight" src="img/lighton.png" />
  <img style="display:none;height:100%;position:absolute;top:3%;left:35%;-webkit-filter: drop-shadow(1px -1px 2px rgba(4, 6, 7, 0.822));" id="highlight" src="img/lighthigh.png" />
</span>
<span class="fa-stack fa-2x" style='font-size:0.9vw;position:absolute;right:5.6%;bottom:53.5%;color:rgba(144, 144, 144, 0.876)'>
  <i class="fas fa-octagon fa-stack-2x" style='font-size:0.9vw;color:rgb(20 25 27 / 46%)'></i>
  <i class="fal fa-octagon fa-stack-2x" style="font-size:0.9vw;color:rgb(177 177 177 / 13%)"></i>
  <i class="fas fa-tint fa-stack-1x" style='font-size:1.1vw;color:rgb(2, 116, 192);z-index:1130;opacity:1.0;-webkit-filter: drop-shadow(1px -1px 2px rgba(6, 8, 8, 0.822));'></i>
</span>
<span class="fa-stack fa-2x" style='font-size:0.5vw;position:absolute;right:67%;bottom:40%;color:rgba(144, 144, 144, 0.294)'>
  <i class="fas fa-octagon fa-stack-2x" style='font-size:0.9vw;color:rgba(11, 39, 63, 0.20)'></i>
  <i class="fal fa-octagon fa-stack-2x" style="font-size:0.9vw;color:rgba(151, 147, 147, 0.01)"></i>
  <i class="fas fa-oil-can fa-stack-1x" style='font-size:1.14vw;color:rgba(144, 144, 144, 0.849);z-index:1130;opacity:1.0;padding-left:12px;-webkit-filter: drop-shadow(1px -1px 0.9px rgba(6, 8, 8, 0.822));'></i>
</span>
<span class="fa-stack fa-2x" style='font-size:0.5vw;position:absolute;right:9.9%;bottom:44.5%;color:rgba(144, 144, 144, 0.294)'>
  <i class="fas fa-octagon fa-stack-2x" style='font-size:0.9vw;color:rgb(20 25 27 / 46%)'></i>
  <i class="fal fa-octagon fa-stack-2x" style="font-size:0.9vw;color:rgb(177 177 177 / 13%)"></i>
  <i class="fad fa-car-mechanic fa-stack-1x"  style='font-size:0.9vw;color:rgba(182, 182, 182, 0.685);z-index:1130;opacity:1.0;margin-left:45%;-webkit-filter: drop-shadow(1px -1px 0.9px rgba(6, 8, 8, 0.822));'></i>
</span>
<i id="right" class="fas fa-arrow-alt-right"></i>
<i id="left" class="fas fa-arrow-alt-left"></i>
<div id="milediv">
  <span id="mileage">0</span> kM
</div>
<div id="timediv">
  <span id="time">00:00</span>
  <span id="timetext">Pm</span>
</div>
<div id="distancediv">
  <span id="distance">0</span>
  <span id="distext">Dis</span>
</div>
<div id="diffdiv">
  <span id="diff">OFF</span>
</div>
<img style="-webkit-filter: drop-shadow(1px -1px 0.4px rgba(255, 255, 255, 0.822));z-index:999;position:absolute;opacity:0.85;width:10%;height:20%;left:4.5vw;bottom:3vw;" src="img/tires.png?img/car.png" />
<img id="wheel0" style="-webkit-filter: drop-shadow(1px -1px 0.4px rgba(255, 0, 0, 0.822));z-index:999;position:absolute;opacity:0.85;width:10%;height:20%;left:4.5vw;bottom:3vw;opacity:0.0;" src="img/tirefrontleft.png?img/car.png" />
<img id="wheel1" style="-webkit-filter: drop-shadow(1px -1px 0.4px rgba(255, 0, 0, 0.822));z-index:999;position:absolute;opacity:0.85;width:10%;height:20%;left:4.5vw;bottom:3vw;opacity:0.0;" src="img/tirefrontright.png?img/car.png" />
<img id="wheel2" style="-webkit-filter: drop-shadow(1px -1px 0.4px rgba(246, 10, 10, 0.822));z-index:999;position:absolute;opacity:0.85;width:10%;height:20%;left:4.5vw;bottom:3vw;opacity:0.0;" src="img/tirerearleft.png?img/car.png" />
<img id="wheel3" style="-webkit-filter: drop-shadow(1px -1px 0.4px rgba(255, 0, 0, 0.822));z-index:999;position:absolute;opacity:0.85;width:10%;height:20%;left:4.5vw;bottom:3vw;opacity:0.0;" src="img/tirerearright.png?img/car.png" />`
carui_element['simple'] = `<img id="simple_light" style="z-index:999;position:relative;opacity:0.0;width:100%;right:0;float:right;" src="img/carui_simple.png?img/car.png" />
<svg id="rpm" style="z-index:1005;position:absolute;right:60%;bottom:36%;opacity:0.65;width:40%;height: 28.5%;transform: rotate(-60deg);"
  xmlns="http://www.w3.org/2000/svg" height="210" width="210" viewBox="0 0 177 177" data-value="1">
  <path class="bg" stroke="#00000078" d="M41 149.5a77 77 0 1 1 180.93 0"  fill="none" stroke-linejoin= "round" stroke-linecap= "round" />
  <defs>
    <filter id="dropshadow" width="170%" height="120%">
      <feOffset result="offOut" in="SourceGraphic" dx="4" dy="7"></feOffset>
      <feColorMatrix result="matrixOut" in="offOut" type="matrix"
values="1.000  0.000  0.000  0.000  0.000 
0.000  1.000  0.000  0.000  0.000 
0.000  0.000  6.000  0.000  0.000 
0.000  0.000  0.000  1.000  0.000" />
      <feGaussianBlur result="blurOut" in="matrixOut" stdDeviation="8"></feGaussianBlur>
      <feBlend in="SourceGraphic" in2="blurOut" mode="normal"></feBlend>
    </filter>
  </defs>
  <path id="rpmpath" class="meter rpm" stroke="#fefefe" d="M41 149.5a77 77 0 1 1 180.93 0" fill="none" style="    stroke-linecap: round;
  stroke-linejoin: round; filter:url(#dropshadow)" stroke-dasharray="280" stroke-dashoffset="280"/>
</svg>
<div id="rpmmeter" style="display:none;">1000</div>
<svg id="speed" style="z-index:1005;position:absolute;right:22%;bottom:26%;opacity:0.65;;width:54%;height:47%;transform: rotate(0deg)"
  xmlns="http://www.w3.org/2000/svg" height="200" width="200" viewBox="0 0 200 200" data-value="1">
  <path class="bg" stroke="#00000078" d="M41 149.5a77 77 0 1 1 111.93 0"  fill="none" stroke-linecap= "round" />
  <defs>
    <filter id="dropshadow" width="170%" height="120%">
      <feOffset result="offOut" in="SourceGraphic" dx="4" dy="15"></feOffset>
      <feColorMatrix result="matrixOut" in="offOut" type="matrix"
values="1.000  0.000  0.000  0.000  0.000 
0.000  1.000  0.000  0.000  0.000 
0.000  0.000  6.000  0.000  0.000 
0.000  0.000  0.000  1.000  0.000" />
      <feGaussianBlur result="blurOut" in="matrixOut" stdDeviation="5"></feGaussianBlur>
      <feBlend in="SourceGraphic" in2="blurOut" mode="normal"></feBlend>
    </filter>
  </defs>
  <path id="speedpath" class="meter carhud" stroke="#fefefe" d="M41 149.5a77 77 0 1 1 111.93 0" fill="none" stroke-dasharray="360" stroke-dashoffset="360" stroke-linecap = "round" />
</svg>
<div id="speedmeter"></div>
<div id="speedtext">kMH</div>
<svg id="cartemp" style="display:none;z-index:1005;position:absolute;right:13.7%;bottom:56.5%;opacity:0.65;height:23%;width:20%;transform: rotate(-200deg) scaleX(1) scaleY(-1);;"
  xmlns="http://www.w3.org/2000/svg" height="84" width="84" viewBox="0 0 140 140" data-value="1">
  <path class="bg" stroke="#00000078" d="M41 149.5a77 77 0 1 1 170.93 0"  fill="none"/>
  <defs>
    <filter id="dropshadow2" width="170%" height="120%">
      <feOffset result="offOut" in="SourceGraphic" dx="2" dy="2"></feOffset>
      <feColorMatrix result="matrixOut" in="offOut" type="matrix"
values="1.000  0.000  0.000  0.000  0.000 
0.000  1.000  0.000  0.000  0.000 
0.000  0.000  6.000  0.000  0.000 
0.000  0.000  0.000  1.000  0.000" />
      <feGaussianBlur result="blurOut" in="matrixOut" stdDeviation="8"></feGaussianBlur>
      <feBlend in="SourceGraphic" in2="blurOut" mode="normal"></feBlend>
    </filter>
  </defs>
  <path id="cartempbar" class="meter carhud" stroke="red" d="M41 149.5a77 77 0 1 1 170.93 0" fill="none" style="filter:url(#dropshadow2)" stroke-dasharray="190" stroke-dashoffset="190"/>
</svg>
<svg id="coolant" style="display:none;z-index:1005;position:absolute;right:-0.7%;bottom:50.5%;opacity:0.65;;width:20%;height:13%;transform: rotate(0deg)"
  xmlns="http://www.w3.org/2000/svg" height="200" width="200" viewBox="0 0 200 200" data-value="1">
  <path class="bg" stroke="#00000078" d="M41 149.5a77 77 0 1 1 111.93 0"  fill="none"/>
  <defs>
    <filter id="dropshadow" width="170%" height="110%">
      <feOffset result="offOut" in="SourceGraphic" dx="4" dy="15"></feOffset>
      <feColorMatrix result="matrixOut" in="offOut" type="matrix"
values="1.000  0.000  0.000  0.000  0.000 
0.000  1.000  0.000  0.000  0.000 
0.000  0.000  6.000  0.000  0.000 
0.000  0.000  0.000  1.000  0.000" />
      <feGaussianBlur result="blurOut" in="matrixOut" stdDeviation="5"></feGaussianBlur>
      <feBlend in="SourceGraphic" in2="blurOut" mode="normal"></feBlend>
    </filter>
  </defs>
  <path id="coolantpath" class="meter carhud" stroke="#2B68E2" d="M41 149.5a77 77 0 1 1 111.93 0" fill="none" stroke-dasharray="360" stroke-dashoffset="360"/>
</svg>
<svg id="nitro" style="display:none;z-index:1005;position:absolute;right:3.1%;bottom:29.6%;opacity:0.65;;width:20%;height:13%;transform: rotate(0deg)"
  xmlns="http://www.w3.org/2000/svg" height="200" width="200" viewBox="0 0 200 200" data-value="1">
  <path class="bg" stroke="#00000078" d="M41 149.5a77 77 0 1 1 111.93 0"  fill="none"/>
  <defs>
    <filter id="dropshadow" width="170%" height="110%">
      <feOffset result="offOut" in="SourceGraphic" dx="4" dy="15"></feOffset>
      <feColorMatrix result="matrixOut" in="offOut" type="matrix"
values="1.000  0.000  0.000  0.000  0.000 
0.000  1.000  0.000  0.000  0.000 
0.000  0.000  6.000  0.000  0.000 
0.000  0.000  0.000  1.000  0.000" />
      <feGaussianBlur result="blurOut" in="matrixOut" stdDeviation="5"></feGaussianBlur>
      <feBlend in="SourceGraphic" in2="blurOut" mode="normal"></feBlend>
    </filter>
  </defs>
  <path id="nitropath" class="meter carhud" stroke="red" d="M41 149.5a77 77 0 1 1 111.93 0" fill="none" stroke-dasharray="360" stroke-dashoffset="360"/>
</svg>
<div id="modediv">
  <span id="mode">ECO</span>
</div>
<div id="rpmtext">x 1000rpm</div>
<i style="display:none;" id="tempicon" class="fad fa-oil-temp"></i>
<i style="display:none;" id="gasicon" class="fad fa-gas-pump"></i>
<div id="geardiv">
  <span id="gear">P</span>
  <span id="geartext"></span>
</div>
<span class="fa-stack fa-2x" style='font-size:0.9vw;position:absolute;right:22%;bottom:20%;color:rgba(144, 144, 144, 0.876); display:none;'>
  <i class="fas fa-octagon fa-stack-2x" style='font-size:0.9vw;color:rgb(20 25 27 / 46%)'></i>
  <i class="fal fa-octagon fa-stack-2x" style="font-size:0.9vw;color:rgb(177 177 177 / 13%)"></i>
  <img style="display:block; height:80%;width:60%;position:absolute;top:11%;left:20%;" id="handbrakeopen" src="img/handbrakeopen.png" />
  <img style="display:block; height:80%;width:60%;position:absolute;top:11%;left:20%;opacity:0.6" id="handbrakeclose" src="img/handbrakeclose.png" />
</span>
<span class="fa-stack fa-2x" style='font-size:0.9vw;position:absolute;right:35%;bottom:17%;color:rgba(144, 144, 144, 0.876)'>
  <i class="fas fa-octagon fa-stack-2x" style='font-size:1.04vw;color:rgb(20 25 27 / 46%);margin-left:0.2vw;'></i>
  <i class="fal fa-octagon fa-stack-2x" style="font-size:1.2vw;color:rgb(177 177 177 / 13%);"></i>
  <i id="gasbar" class="fad fa-gas-pump fa-stack-1x" style='font-size:1.2vw;color:rgb(231, 231, 231);z-index:1131;opacity:1.0;margin-left:0.8vw;'></i>
  <i id="gasbg" class="fad fa-gas-pump fa-stack-1x" style='font-size:1.2vw;color:rgba(253, 0, 0, 0.856);z-index:1130;opacity:0.1;margin-left:0.8vw;'></i>
</span>
<span class="fa-stack fa-2x" style='font-size:0.9vw;position:absolute;right:45%;bottom:17%;color:rgba(144, 144, 144, 0.876)'>
  <i class="fas fa-octagon fa-stack-2x" style='font-size:1.04vw;color:rgb(20 25 27 / 46%);margin-left:0.2vw;'></i>
  <i class="fal fa-octagon fa-stack-2x" style="font-size:1.2vw;color:rgb(177 177 177 / 13%);"></i>
  <i id="carhealthbar" class="fad fa-car-mechanic fa-stack-1x" style='font-size:1.2vw;color:rgb(240, 240, 240);z-index:1131;opacity:1.0;margin-left:0.8vw;'></i>
  <i id="carhealthbg" class="fad fa-car-mechanic fa-stack-1x" style='font-size:1.2vw;color:rgba(235, 5, 5, 0.89);z-index:1130;opacity:0.1;margin-left:0.8vw;'></i>
</span>
<span class="fa-stack fa-2x" style='font-size:0.9vw;position:absolute;right:55%;bottom:17%;color:rgba(144, 144, 144, 0.876)'>
  <i class="fas fa-octagon fa-stack-2x" style='font-size:1.04vw;color:rgb(20 25 27 / 46%);margin-left:0.2vw;'></i>
  <i class="fal fa-octagon fa-stack-2x" style="font-size:1.2vw;color:rgb(177 177 177 / 13%);"></i>
  <img style="display:block; height:85%; width:75%;position:absolute;top:8%;left:29%;opacity:0.6" id="doorclose" src="img/doorclose.png" />
  <img style="display:none; height:85%;width:75%;position:absolute;top:8%;left:29%;opacity:0.7" id="dooropen" src="img/dooropen.png" />
</span>
<span class="fa-stack fa-2x" style='font-size:0.9vw;position:absolute;right:65%;bottom:17%;color:rgba(144, 144, 144, 0.876)'>
  <i class="fas fa-octagon fa-stack-2x" style='font-size:1.04vw;color:rgb(20 25 27 / 46%);margin-left:0.2vw;'></i>
  <i class="fal fa-octagon fa-stack-2x" style="font-size:1.2vw;color:rgb(177 177 177 / 13%);"></i>
  <img style="display:block; height:90%;position:absolute;top:11%;left:29%;" id="seatbelt" src="img/seatbeltoff.png" />
  <img style="display:none;height:90%;position:absolute;top:11%;left:29%;" id="onseatbelt" src="img/seatbelton.png" />
</span>
<span class="fa-stack fa-2x" style='font-size:0.9vw;position:absolute;right:75%;bottom:17%;color:rgba(144, 144, 144, 0.876)'>
  <i class="fas fa-octagon fa-stack-2x" style='font-size:1.04vw;color:rgb(20 25 27 / 46%);margin-left:0.2vw;'></i>
  <i class="fal fa-octagon fa-stack-2x" style="font-size:1.2vw;color:rgb(177 177 177 / 13%);"></i>
  <img style="display:block; height:90%;position:absolute;top:11%;left:29%;opacity:0.5;" id="offlight" src="img/lightoff.png" />
  <img style="display:none;height:90%;position:absolute;top:11%;left:29%;" id="onlight" src="img/lighton.png" />
  <img style="display:none;height:90%;position:absolute;top:11%;left:29%;" id="highlight" src="img/lighthigh.png" />
</span>
<span class="fa-stack fa-2x" style='font-size:0.5vw;position:absolute;right:67%;bottom:40%;color:rgba(144, 144, 144, 0.294)'>
  <i class="fas fa-octagon fa-stack-2x" style='font-size:0.7vw;color:rgba(11, 39, 63, 0.055)'></i>
  <i class="fal fa-octagon fa-stack-2x" style="font-size:0.9vw;color:rgba(151, 147, 147, 0.023)"></i>
  <i class="fas fa-oil-can fa-stack-1x" style='font-size:0.9vw;color:rgba(93, 93, 93, 0.782);z-index:1130;opacity:1.0;padding-left:7px;'></i>
</span>
<i id="right" class="fas fa-arrow-alt-right"></i>
<i id="left" class="fas fa-arrow-alt-left"></i>
<div id="milediv">
  <span id="mileage">0</span> kM
</div>
<div style="display:none;" id="timediv">
  <span id="time">00:00</span>
  <span id="timetext">Pm</span>
</div>
<div style="display:none;" id="distancediv">
  <span id="distance">0</span>
  <span id="distext">Dis</span>
</div>
<div style="display:none;" id="diffdiv">
  <span id="diff">OFF</span>
</div>`

function setCarui(ver) {
    document.getElementById("modern").innerHTML = '';
    document.getElementById("simple").innerHTML = '';
    document.getElementById("minimal").innerHTML = '';
    carui = ver
    if (usersetting['carhud'] && usersetting['carhud']['version'] !== 'auto' && usersetting['carhud']['version'] !== undefined) {
        carui = usersetting['carhud']['version']
        ver = usersetting['carhud']['version']
        console.log("User setting")
    }
    document.getElementById(ver).innerHTML = ''
    setTimeout(function() {
        document.getElementById(ver).innerHTML = carui_element[ver]
        if (ver == 'minimal') {
            document.getElementById("speedtext").style.fontWeight = '100';
            document.getElementById("speedtext").style.right = '47.5%';
            document.getElementById("speedtext").style.bottom = '45%';
            document.getElementById("speedtext").style.fontSize = '8px';
            if (invehicle) {
                document.getElementById("minimal").style.display = 'block';
            }
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
            document.getElementById("geardiv").style.bottom = '40%';
            document.getElementById("geardiv").style.fontSize = '0.4vw';
            document.getElementById("right").style.right = '27%';
            document.getElementById("right").style.bottom = '75%';
            document.getElementById("left").style.right = '69%';
            document.getElementById("left").style.bottom = '75%';
            document.getElementById("milediv").style.right = '12.5vw';
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
            if (invehicle) {
                document.getElementById("modern").style.display = 'block';
            }
        } else if (ver == 'simple') {
            document.getElementById("speedtext").style.fontWeight = '100';
            document.getElementById("speedtext").style.right = '47.5%';
            document.getElementById("speedtext").style.bottom = '45%';
            document.getElementById("speedtext").style.fontSize = '8px';
            if (invehicle) {
                document.getElementById("simple").style.display = 'block';
            }
            document.getElementById("rpmtext").style.right = '68%';
            document.getElementById("rpmtext").style.bottom = '52%';
            document.getElementById("rpmtext").style.fontSize = '0.35vw';
            document.getElementById("mode").style.fontSize = '0.55vw';
            document.getElementById("tempicon").style.right = '23.5%';
            document.getElementById("tempicon").style.bottom = '57%';
            document.getElementById("gasicon").style.right = '21%';
            document.getElementById("gasicon").style.bottom = '47%';
            document.getElementById("gasicon").style.opacity = '0.6';
            document.getElementById("tempicon").style.opacity = '0.6';
            document.getElementById("geardiv").style.right = '45%';
            document.getElementById("geardiv").style.bottom = '40%';
            document.getElementById("geardiv").style.fontSize = '0.4vw';
            document.getElementById("right").style.right = '37%';
            document.getElementById("right").style.bottom = '30%';
            document.getElementById("left").style.right = '79%';
            document.getElementById("left").style.bottom = '30%';
            document.getElementById("milediv").style.right = '50.0%';
            document.getElementById("milediv").style.bottom = '27.5%';
            document.getElementById("milediv").style.margin = '1% 1% 1% 1%';
            document.getElementById("milediv").style.background = 'rgb(0 0 0 / 86%)';
            document.getElementById("milediv").style.opacity = '0.6';
            document.getElementById("milediv").style.fontSize = '0.5vw';
            document.getElementById("milediv").style.fontSize = '0.5vw';
            document.getElementById("milediv").style.webkitFilter = "drop-shadow(1px 1px 1px rgb(5, 155, 255))";
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
        setMode('NORMAL', carui)
        if (setting['iconshape']) {
            class_icon = setting['iconshape']
        }
        //changeallclass(class_icon)
        const el = document.querySelector('.rpm');
        el.addEventListener('animationstart', function() {
            console.log('transition start')
            rpmanimation = true
        });

        el.addEventListener('animationend', function() {
            rpmanimation = false
                //console.log('transition end')
        });
        const el2 = document.querySelector('.carhud');
        el2.addEventListener('transitionrun', function() {
            //console.log('transition start')
            speedanimation = true
        });

        el2.addEventListener('transitionend', function() {
            speedanimation = false
                //console.log('transition end')
        });
    }, 333);
}

var compassstring = `<div id="container">
<section>
  <span id="border" style="font-size:15px !important; color:rgba(255, 233, 233, 0.65) !important;display:none;">|</span>
  <h4 id="direction" style="font-size:20px !important; color:rgba(255, 233, 233, 0.9) !important;position:fixed;top:40px;left:35px;"></h4>
  <span id="border" style="font-size:15px !important; color:rgba(255, 233, 233, 0.65) !important;display:none;">|</span>
</section>
<div>
  <p style="position:fixed;top:28px;left:90px;width:140px;" id="zone"></p>
  <p id="street" style="position:fixed;top:48px;left:77px;width:150px;font-size:8px !important; color:rgba(255, 233, 233, 0.9) !important; padding-top:-10px;"></p>
</div>
</div>`

function setCompass(bool) {
    if (bool && setting['streethud']) {
        $('#location').append(compassstring)
        document.getElementById("location").style.display = 'block';
        document.getElementById("compass").style.display = 'block';
    } else {
        $('#location').html('')
        document.getElementById("location").style.display = 'none';
        document.getElementById("compass").style.display = 'none';
    }
}

var logostring = `<img style="border-radius: 50%;" id="pedface" src="https://nui-img/pedmugshot_01/pedmugshot_01?t123" height="70">`
var voipstring = `<i class="fas fa-octagon fa-stack-2x" style='font-size:15px;color:rgb(20 25 27 / 46%)'></i>
<i class="fal fa-octagon fa-stack-2x" style="font-size:14px;color:rgb(28, 52, 129)"></i>
<i id="microphone" class="fas fa-microphone fa-stack-1x" style='font-size:19px;z-index:1131;opacity:1.0;'></i>`
var uibarstring = `<div class="armor-bar"><span class="bar"><span class="armor_progress" id="armorbar"></span></span></div>
<div class="health-bar"><span class="bar"><span class="health_progress" id="healthbar"></span></span></div>`

function NormalUI() {
    if ($('#logo')) {
        $('#logo').html('')
    }
    if ($('#voip_1')) {
        $('#voip_1').html('')
    }
    if ($('#uibar')) {
        $('#uibar').html('')
    }
    if ($('#logo')) {
        $('#logo').append(logostring)
    }
    if ($('#voip_1')) {
        $('#voip_1').append(voipstring)
    }
    if ($('#uibar')) {
        $('#uibar').append(uibarstring)
    }
    pedface(true)
}

function setStatusUI(t) {
    var ver = t['ver']
    var type = t['type']
    if (setting['uilook'] == undefined) {
        setting['uilook'] = ver
        statusui = ver
    }
    if (setting['statusver']) {
        status_type = setting['statusver']
    } else {
        status_type = type
    }
    NormalUI()
    if (!t['enable'] && ver == 'simple') {
        if (document.getElementById("uibar")) {
            document.getElementById("uibar").innerHTML = '';
        }
        if (document.getElementById("logo")) {
            document.getElementById("logo").innerHTML = '';
        }
        if (document.getElementById("voip_1")) {
            document.getElementById("voip_1").innerHTML = '';
        }
        if (document.getElementById("statusnormal")) {
            document.getElementById("statusnormal").style.display = 'none';
        }
    }
    if (ver == 'simple' && t['enable']) {
        if (setting['uilook'] == undefined) {
            statusui = 'simple'
        }
        if (document.getElementById("healthdiv")) {
            document.getElementById("healthdiv").style.display = 'block';
        }
        if (document.getElementById("armor")) {
            document.getElementById("armor").style.display = 'block';
        }
        if (document.getElementById("armordiv")) {
            document.getElementById("armordiv").style.display = 'block';
        }
        if (type == 'icons' && document.getElementById("armorsimplebg")) {
            document.getElementById("armorsimplebg").style.display = 'block';
        }
        //document.getElementById("voip_2").style.marginLeft = '40px';
        if (document.getElementById("uibar")) {
            document.getElementById("uibar").innerHTML = '';
        }
        if ($("#statusver")) {
            $("#statusver").attr("src", "img/simplestatus.png")
        }
        if (document.getElementById("statusnormal")) {
            document.getElementById("statusnormal").style.display = 'none';
        }
        if (document.getElementById("logo")) {
            document.getElementById("logo").innerHTML = '';
        }
        if (document.getElementById("location")) {
            document.getElementById("location").style.top = '60px';
            document.getElementById("location").style.right = '60px';
            document.getElementById("location").style.width = '280px';
        }
        if (document.getElementById("voip_1")) {
            document.getElementById("voip_1").innerHTML = '';
        }
    } else if (t['enable']) {
        if (document.getElementById("voipdiv")) {
            document.getElementById("voipdiv").remove()
        }
    }
}

function setStatusUILocation(table) {
    if (locache == undefined) {
        locache = table
    }
    if (!RestoreStatusPosition()) {
        if (table['top']) {
            document.getElementById("statusv3").style.top = '' + table['top'] + '';
        } else {
            document.getElementById("statusv3").style.top = 'unset';
        }
        if (table['right']) {
            document.getElementById("statusv3").style.right = '' + table['right'] + '';
        } else {
            document.getElementById("statusv3").style.right = 'unset';
        }
        if (table['bottom']) {
            document.getElementById("statusv3").style.bottom = '' + table['bottom'] + '';
        } else {
            document.getElementById("statusv3").style.bottom = 'unset';
        }
        if (table['left']) {
            document.getElementById("statusv3").style.left = '' + table['left'] + '';
        } else {
            document.getElementById("statusv3").style.left = 'unset';
        }
    }
    if (!RestoreCarPosition()) {
        console.log("setting to default")
        if (document.getElementById("simple")) {
            $('#simple').css('inset', 'unset');
            document.getElementById("minimal").style.inset = 'unset';
            document.getElementById("simple").style.right = '-4.5%';
            document.getElementById("simple").style.bottom = '-20px';
            console.log("setting simple to default")
        }
        if (document.getElementById("minimal")) {
            $('#minimal').css('inset', 'unset');
            document.getElementById("minimal").style.inset = 'unset';
            document.getElementById("minimal").style.right = '-0.5%';
            document.getElementById("minimal").style.bottom = '-40px';
        }
        if (document.getElementById("modern")) {
            $('#modern').css('inset', 'unset');
            document.getElementById("modern").style.inset = 'unset';
            document.getElementById("modern").style.right = '-0.5%';
            document.getElementById("modern").style.bottom = '-40px';
        }
    }
}

function setMoveStatusUi(bool) {
    ////////console.log("MOVE UI")
    if (!RestoreStatusPosition()) {
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
}

function setNitro(nitro) {

}

function setWheelHealth(table) {

}

function setShowKeyless(bool) {

}

var currentvehicle = undefined
var openall = false
var alarm = false

function carlockcallback(type) {

}

function setKeyless(table) {

}

pressfuck = 0
var pressedkey1 = 0
var pressedkey2 = false
var pressedkey3 = false
document.onkeyup = function(data) {

    if (data.keyCode == '70') {
        $.post(`https://${GetParentResourceName()}/getoutvehicle`, {}, function(data) {});
        pressedkey1 = 0
    }
};

function playsound(table) {

}

function SetNotify(table) {
    ////////console.log("notify")
    new Notify({ status: table['type'], title: table['title'], text: table['message'], autoclose: true })
}

function applyFill(slider) {
    const percentage = 100 * (slider.value - slider.min) / (slider.max - slider.min);
    const bg = `linear-gradient(90deg, #0099ff ${percentage}%, #222222 ${percentage + 0.1}%)`;
    slider.style.background = bg;
}

function unsetradio() {
    $("input[type=radio][name=wheelsetting][value='off']").prop("checked", true);
}

function setMapVersion(table) {
    var type = table['type']
    var custom = table['custom']
    if (custom) {
        $("#mapimg").attr("src", "" + table['link'] + "")
    } else {
        $("#mapimg").attr("src", "img/" + type + ".webp")
    }
}

function setRadioChannel(channel) {
    if (channel !== false && channel !== undefined) {
        document.getElementById("radio").style.display = 'block';
        document.getElementById("mic-radio").innerHTML = '' + channel + '';
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

}

function setClotheState(table) {

}

function ResetClotheState(table) {

}

function CallbackCLothing(variant, variant2) {

}

function ResetClothes() {

}

function hasClass(element, className) {
    return (' ' + element.className + ' ').indexOf(' ' + className + ' ') > -1;
}

function changeallclass(s) {
    class_icon = s
    if (lasticon !== undefined && lasticon == class_icon || lasticon == class_icon) { return }
    if (lasticon == undefined) {
        lasticon = 'octagon'
    }
    const all = document.getElementsByClassName('fa-' + lasticon + '');
    if (setting['iconshape'] !== undefined) {
        class_icon = setting['iconshape']
    }
    if (lasticon !== class_icon) {
        for (var i = 0; i < all.length; i++) {
            const status = all[i].classList.toggle("fa-" + class_icon + "");
        }
        for (var i = 0; i < all.length; i++) {
            all[i].classList.remove("fa-" + lasticon + "");
        }
    }
    if (class_icon !== 'circle' && class_icon !== 'octagon') {
        var icon = document.getElementsByClassName('default');
        for (var i = 0; i < icon.length; i++) {
            icon[i].classList.toggle("square");
        }
    }
    lasticon = class_icon
}

function reverseArrayInPlace(array) {
    for (let i = 0, j = array.length - 1; i < j; i++, j--)
        [array[i], array[j]] = [array[j], array[i]];
}

function SetProgressCircle(id, percent) {
    var rpm = (percent);
    var e = document.getElementById(id);
    if (e) {
        let length = e.getTotalLength();
        let to = length * ((100 - percent) / 100);
        //e.style.strokeDashoffset = to;
        if (id == 'staminaval') {
            $('#' + id + '').velocity({ 'stroke-dashoffset': to }, { duration: 350, delay: 30 })
        } else {
            $('#' + id + '').velocity({ 'stroke-dashoffset': to }, { duration: 550, delay: 30 })
        }
    }
}

function carhudver() {
    var val = document.getElementById("carhudver").value;
    if (usersetting['carhud'] == undefined) {
        usersetting['carhud'] = {}
    }
    if (val) {
        usersetting['carhud']['version'] = val
    }
    if (val !== 'auto') {
        setCarui(val)
    }
}

var settingstring = `<div class="card">
    <div class="card__header">
      <div class="toolbar">
        <div class="toolbar__item toolbar__item--close"></div>
        <div class="toolbar__item toolbar__item--min"></div>
        <div class="toolbar__item toolbar__item--max"></div>
      </div><a href="#"><img src="https://forum.cfx.re/uploads/default/original/4X/b/1/9/b196908c7e5dfcd60aa9dca0020119fa55e184cb.png" height="50" alt="Renzu Hud v1.17"></a>
    </div>
    <div class="card__body">
      <div class="container">
        <div class="grid">
          <h1>Hud Setting</h1>
        </div>
      </div>
      <div class="container">
        <div class="grid grid--half" id="statussetting">
          <h3 style="color: #64fd64;">Status HUD</h3>
          <div class="form-item">
            <label class="form-item__label">Status Version</label>
            <div class="form-item__control">
              <select class="control control--select" id="statusversion" onchange="statusversion()">
                <option selected="selected" value="progressbar">Progress</option>
                <option value="icons">Icons</option>
              </select>
            </div>
          </div>
          <div class="form-item">
            <label class="form-item__label">UI Version</label>
            <div class="form-item__control">
              <select class="control control--select" id="uilook" onchange="uilook()">
                <option selected="selected" value="normal">Normal</option>
                <option value="simple">Simple</option>
              </select>
            </div>
          </div>
          <div class="form-item">
            <label class="form-item__label">Status Shapes</label>
            <div class="form-item__control">
              <select class="control control--select" id="iconshape" onchange="iconshape()">
                <option selected="selected" value="circle">Circle</option>
                <option value="octagon">Octagon</option>
                <option value="square">Square</option>
                <option value="hexagon">Hexagon</option>
                <option value="vector-square">Vector Square</option>
                <option value="draw-square">Draw Square</option>
                <option value="draw-circle">Draw Circle</option>
                <option value="badge">Badge</option>
                <option value="certificate">Certificate</option>
                <option value="comment">Comment</option>
                <option value="heart">Heart</option>
              </select>
            </div>
          </div>
          <h3>Name</h3>
          <h3 style="
          /* display: inline-block; */
          /* float: right; */
          /* margin-top: -30px; */
          margin-top: -30px;
          position: absolute;
          top: 163px;
          right: 50%;
          ">Hide%</h3>
          <h3 style="
          /* display: inline-block; */
          /* float: right; */
          margin-top: -30px;
          position: absolute;
          top: 165x;
          right: 5%;
          ">Type</h3>
          <h3 style="
          /* display: inline-block; */
          /* float: right; */
          margin-top: -30px;
          position: absolute;
          top: 163px;
          right: 27%;
          ">HideIfMax</h3>
        </div>
        <div class="grid grid--half">
          <h3 style="color: #64fd64;">Car HUD</h3>
          <div class="form-item">
            <label class="form-item__label">Version</label>
            <div class="form-item__control">
              <select class="control control--select" id="carhudver" onchange="carhudver()">
                <option selected="selected" value="auto">Auto</option>
                <option value="simple">Simple</option>
                <option value="minimal">Minimal</option>
                <option value="modern">Modern</option>
              </select>
            </div>
          </div>
          <div class="form-item">
            <label class="form-item__label">Speed Metric</label>
            <div class="form-item__control">
              <select class="control control--select" id="speedmetric" onchange="speedmetric()">
                <option selected="selected" value="mph">MPH</option>
                <option value="kmh">KMH</option>
              </select>
            </div>
          </div>
          <div class="form-item">
            <label class="form-item__label">Turbo Hud</label>
            <div class="form-item__control toggle" id='turbohud'>
              <div class="toggle__handle"></div>
            </div>
          </div>
          <div class="form-item">
            <label class="form-item__label">Manual Gears Hud</label>
            <div class="form-item__control toggle" id='manualhud'>
              <div class="toggle__handle"></div>
            </div>
          </div>
          <div class="form-item">
            <label class="form-item__label">Car Hud Refresh Rate</label>
            <div class="form-item__control"><small><strong><span class="slider__value" id="rval">500</span><span>ms</span></strong></small></div>
            <div class="slider">
              <input class="slider__input" type="range" value="0" min="0" max="300" id="refreshrate" />
              <div class="slider__positive" id="refreshrate2"></div>
            </div>
          </div>
          <p><small>Lower MS is Much Accurate but higher CPU Usage.</small></p>
          <h3 style="color: #64fd64;">Street Name HUD</h3>
          <div class="form-item">
            <label class="form-item__label">Enable/Disable</label>
            <div class="form-item__control toggle" id='streethud'>
              <div class="toggle__handle"></div>
            </div>
          </div>
          <h3 style="color: #64fd64;">Weapon HUD</h3>
          <div class="form-item">
            <label class="form-item__label">Enable/Disable</label>
            <div class="form-item__control toggle" id='weaponhud'>
              <div class="toggle__handle"></div>
            </div>
          </div>
          <p><small>Status HUD and CarHUD is Draggable.</small></p>
          <button class="button" onclick='resetsetting(true)' style="background:red;z-index:111;">RESET</button>
            <button style="z-index:111;" class="button" onclick='SavetoLocal()'>SAVE</button>
          </div>
        </div>
      </div>
    </div>
  </div>`

$("#settingui").append(settingstring)

function SettingHud(t) {
    if (t.bool) {
        document.getElementById('statusv3').innerHTML = ''
        document.getElementById('status_progress').innerHTML = ''
        document.getElementById('settingui').innerHTML = ''
        $("#settingui").append(settingstring);
        if (globalconfig['status'] && globalconfig['status']['data']) {
            SetStatusOrder(globalconfig['status'])
        }
        document.getElementById('settingui').style.display = 'block'
        if (setting['iconshape'] !== undefined) {
            class_icon = setting['iconshape']
        }
        lasticon = undefined
        changeallclass(class_icon)
    } else {
        //document.getElementById('statusv3').innerHTML = ''
        //document.getElementById('status_progress').innerHTML = ''
        document.getElementById('settingui').innerHTML = ''
        document.getElementById('settingui').style.display = 'none'
    }
}

function statusversion() {
    var val = document.getElementById("statusversion").value;
    status_type = val
    setting['statusver'] = val
    usersetting['statusver'] = val
    document.getElementById('statusv3').innerHTML = ''
    document.getElementById('status_progress').innerHTML = ''
    document.getElementById('settingui').innerHTML = ''
    localStorage.setItem("UISETTING", JSON.stringify(usersetting));
    $("#settingui").append(settingstring);
    if (globalconfig['status'] && globalconfig['status']['data']) {
        SetStatusOrder(globalconfig['status'])
    }
}

function iconshape() {
    var val = document.getElementById("iconshape").value;
    class_icon = val
    setting['iconshape'] = val
    usersetting['iconshape'] = val
    document.getElementById('statusv3').innerHTML = ''
    document.getElementById('status_progress').innerHTML = ''
    document.getElementById('settingui').innerHTML = ''
    localStorage.setItem("UISETTING", JSON.stringify(usersetting));
    $("#settingui").append(settingstring);
    if (globalconfig['status'] && globalconfig['status']['data']) {
        SetStatusOrder(globalconfig['status'])
    }
    changeallclass(setting['iconshape'])
}

function uilook() {
    var val = document.getElementById("uilook").value;
    statusui = val
    setting['uilook'] = val
    usersetting['uilook'] = val
    document.getElementById('statusv3').innerHTML = ''
    document.getElementById('status_progress').innerHTML = ''
    document.getElementById('settingui').innerHTML = ''
    localStorage.setItem("UISETTING", JSON.stringify(usersetting));
    $("#settingui").append(settingstring);
    $('#logo').html('')
    $('#voip_1').html('')
    $('#uibar').html('')
    document.getElementById("statusnormal").style.display = 'none';
    if (statusui == 'normal') {
        NormalUI()
        document.getElementById("statusnormal").style.display = 'block';
    }
    if (globalconfig['status'] && globalconfig['status']['data']) {
        SetStatusOrder(globalconfig['status'])
    }
    if (statusui == 'normal') {
        if (document.getElementById("healthdiv")) {
            document.getElementById("healthdiv").innerHTML = '';
        }
        if (document.getElementById("voipdiv")) {
            document.getElementById("voipdiv").style.display = 'none';
        }
        if (document.getElementById("armordiv")) {
            document.getElementById("armordiv").innerHTML = '';
        }
    }
}

function speedmetric() {
    var val = document.getElementById("speedmetric").value;
    SetMetrics(val, true)
    usersetting['carhud']['speedmetric'] = val
}

function statustype(st) {
    var val = document.getElementById("" + st + "statustype").value;
    if (usersetting['status'] == undefined) { usersetting['status'] = {} }
    if (usersetting['status'][st] == undefined) { usersetting['status'][st] = {} }
    setting['status'][st].type = val
    usersetting['status'][st].type = val
    document.getElementById('statusv3').innerHTML = ''
    document.getElementById('status_progress').innerHTML = ''
    document.getElementById('settingui').innerHTML = ''
    localStorage.setItem("UISETTING", JSON.stringify(usersetting));
    $("#settingui").append(settingstring);
    if (globalconfig['status'] && globalconfig['status']['data']) {
        SetStatusOrder(globalconfig['status'])
    }
}

function SavetoLocal() {
    post("hidecarlock", {})
    resetsetting(false)
    localStorage.setItem("UISETTING", JSON.stringify(usersetting));
}

function resetsetting(force) {
    if (force) {
        usersetting = {}
        if (setting['statusver'] == undefined || usersetting['statusver'] == undefined) {
            status_type = globalconfig['statusver']
            setting['statusver'] = globalconfig['statusver']
            usersetting['statusver'] = globalconfig['statusver']
        }
        if (setting['uilook'] == undefined || usersetting['uilook'] == undefined) {
            statusui = globalconfig['uilook']
            setting['uilook'] = globalconfig['uilook']
            usersetting['uilook'] = globalconfig['uilook']
        }
        if (setting['iconshape'] == undefined || usersetting['iconshape'] == undefined) {
            class_icon = globalconfig['iconshape']
            setting['iconshape'] = globalconfig['iconshape']
            usersetting['iconshape'] = globalconfig['iconshape']
        }
        localStorage.removeItem("UISETTING")
        ResetStorages()
        NormalUI()
        document.getElementById('statusv3').innerHTML = ''
        document.getElementById('status_progress').innerHTML = ''
        document.getElementById('settingui').innerHTML = ''
        $("#settingui").append(settingstring);
        if (globalconfig['status'] && globalconfig['status']['data']) {
            SetStatusOrder(globalconfig['status'])
        }
        var temp = {}
        temp['bottom'] = '20px'
        temp['left'] = '20px'
        setStatusUILocation(temp)
        if (globalconfig['uilook'] == 'simple') {
            document.getElementById("uibar").innerHTML = '';
            document.getElementById("logo").innerHTML = '';
            document.getElementById("voip_1").innerHTML = '';
            document.getElementById("statusnormal").style.display = 'none';
        }
    }
    if (usersetting['carhud'] == undefined) {
        usersetting['carhud'] = {}
    }
    if (setting['carhud'] == undefined) {
        setting['carhud'] = {}
    }
    if (setting['statusver'] == undefined || usersetting['statusver'] == undefined) {
        status_type = globalconfig['statusver']
        setting['statusver'] = globalconfig['statusver']
        usersetting['statusver'] = globalconfig['statusver']
    }
    if (setting['uilook'] == undefined || usersetting['uilook'] == undefined) {
        setting['uilook'] = globalconfig['uilook']
        statusui = globalconfig['uilook']
        usersetting['uilook'] = globalconfig['uilook']
        console.log("set default")
    }
    if (setting['iconshape'] == undefined || usersetting['iconshape'] == undefined) {
        class_icon = globalconfig['iconshape']
        setting['iconshape'] = globalconfig['iconshape']
        usersetting['iconshape'] = globalconfig['iconshape']
    }
    if (setting['streethud'] == undefined || usersetting['streethud'] == undefined) {
        setting['streethud'] = globalconfig['streethud']
        usersetting['streethud'] = globalconfig['streethud']
        setCompass(setting['streethud'])
    }
    if (setting['weaponhud'] == undefined && globalconfig['weaponhud'] !== undefined || usersetting['weaponhud'] == undefined) {
        setting['weaponhud'] = globalconfig['weaponhud']
        usersetting['weaponhud'] = globalconfig['weaponhud']
        setWeaponUi(setting['weaponhud'], true)
    }
    for (const i in globalconfig['carhud']) {
        if (i == 'version' && setting['carhud']['version'] == undefined || i == 'version' && usersetting['carhud']['version'] == undefined) {
            setting['carhud']['version'] = globalconfig['carhud'][i]
            usersetting['carhud']['version'] = globalconfig['carhud'][i]
            carui = setting['carhud']['version']
            setCarui(setting['carhud']['version'])
        }
        if (i == 'speedmetric' && setting['carhud']['speedmetric'] == undefined || i == 'speedmetric' && usersetting['carhud']['speedmetric'] == undefined) {
            setting['carhud']['speedmetric'] = globalconfig['carhud'][i]
            usersetting['carhud']['speedmetric'] = globalconfig['carhud'][i]
            SetMetrics(setting['carhud']['speedmetric'], true)
        }
        if (i == 'turbohud' && setting['carhud']['turbohud'] == undefined || i == 'turbohud' && usersetting['carhud']['turbohud'] == undefined) {
            setting['carhud']['turbohud'] = globalconfig['carhud'][i]
            usersetting['carhud']['turbohud'] = globalconfig['carhud'][i]
            setShowTurboBoost(setting['carhud']['turbohud'], true)
        }
        if (i == 'manualhud' && setting['carhud']['manualhud'] == undefined || i == 'manualhud' && usersetting['carhud']['manualhud'] == undefined) {
            setting['carhud']['manualhud'] = globalconfig['carhud'][i]
            usersetting['carhud']['manualhud'] = globalconfig['carhud'][i]
            setManual(setting['carhud']['manualhud'], true)
        }
        if (i == 'refreshrate' && setting['carhud']['refreshrate'] == undefined && i == 'refreshrate' && usersetting['carhud']['refreshrate'] == undefined) {
            setting['carhud']['refreshrate'] = globalconfig['carhud'][i]
            usersetting['carhud']['refreshrate'] = globalconfig['carhud'][i]
            post("setrefreshrate", { val: setting['carhud']['refreshrate'] })
        }
    }
}

function reimportsetting(c) {
    $("#settingui").append(settingstring);
    console.log("Checking User Setting...")
    globalconfig = c
    const sett = JSON.parse(localStorage.getItem("UISETTING"))
    if (sett && sett['uilook']) {
        usersetting = sett
        setting = sett
        for (const i in globalconfig) {
            if (usersetting[i] == undefined) {
                usersetting[i] = globalconfig[i]
            }
        }
        if (setting['uilook']) {
            statusui = usersetting['uilook']
        }
        if (setting['iconshape']) {
            class_icon = usersetting['iconshape']
        }
        if (setting['statusver']) {
            status_type = usersetting['statusver']
        }
        //setting = usersetting
        console.log("User Setting Activated")
        if (usersetting['carhud']['version']) {
            post("setcarui", { val: setting['carhud']['version'] })
            console.log("custom Car HUD")
        }
        if (usersetting['carhud']['refreshrate']) {
            post("setrefreshrate", { val: setting['carhud']['refreshrate'] })
            console.log("Custom CarHUD Refresh Rate")
        }
        for (const i in globalconfig['carhud']) {
            if (setting['carhud'] == undefined) {
                setting['carhud'] = {}
            }
            if (i == 'version' && setting['carhud']['version'] == undefined && globalconfig['carhud'][i] !== undefined) {
                setting['carhud']['version'] = globalconfig['carhud'][i]
                carui = setting['carhud']['version']
                setCarui(setting['carhud']['version'])
            }
            if (i == 'speedmetric' && setting['carhud']['speedmetric'] == undefined && globalconfig['carhud'][i] !== undefined) {
                setting['carhud']['speedmetric'] = globalconfig['carhud'][i]
                SetMetrics(setting['carhud']['speedmetric'], true)
            }
            if (i == 'turbohud' && setting['carhud']['turbohud'] == undefined && globalconfig['carhud'][i] !== undefined) {
                setting['carhud']['turbohud'] = globalconfig['carhud'][i]
                setShowTurboBoost(setting['carhud']['turbohud'], true)
            }
            if (i == 'manualhud' && setting['carhud']['manualhud'] == undefined & globalconfig['carhud'][i] !== undefined) {
                setting['carhud']['manualhud'] = globalconfig['carhud'][i]
                setManual(setting['carhud']['manualhud'], true)
            }
            if (i == 'refreshrate' && setting['carhud']['refreshrate'] == undefined && globalconfig['carhud'][i] !== undefined) {
                setting['carhud']['refreshrate'] = globalconfig['carhud'][i]
                post("setrefreshrate", { val: setting['carhud']['refreshrate'] })
            }
        }
    } else {
        resetsetting()
    }
}

function changelinecolor(s) {
    console.log(s)
}

function componentFromStr(numStr, percent) {
    var num = Math.max(0, parseInt(numStr, 10));
    return percent ?
        Math.floor(255 * Math.min(100, num) / 100) : Math.min(255, num);
}

function rgbToHex(rgb) {
    var rgbRegex = /^rgb\(\s*(-?\d+)(%?)\s*,\s*(-?\d+)(%?)\s*,\s*(-?\d+)(%?)\s*\)$/;
    var result, r, g, b, hex = "";
    if ((result = rgbRegex.exec(rgb))) {
        r = componentFromStr(result[1], result[2]);
        g = componentFromStr(result[3], result[4]);
        b = componentFromStr(result[5], result[6]);

        hex = "#" + (0x1000000 + (r << 16) + (g << 8) + b).toString(16).slice(1);
    }
    return hex;
}
var toggle = undefined

function SetStatusOrder(t) {
    if (t['data'] == undefined) { return }
    statcache = t['data']
    console.log("status ordering")
    var s = t['data']
    statleft = t['float']
    var offsetplus = -35
    var statuses = s
    if (setting['status'] == undefined) {
        setting['status'] = {}
    }
    if (setting['statusver'] == undefined) {
        setting['statusver'] = status_type
    }
    if (setting['iconshape'] == undefined) {
        setting['iconshape'] = class_icon
    }
    for (const i in statuses) {
        if (statuses[i].enable) {
            var offset = 275
            if (statuses[0] !== undefined) {
                offset = statuses[0].offset
            } else {
                offset = statuses['health'].offset
            }
            offsetplus = offsetplus + 35
            offset = (+offset - +offsetplus)
            var fa = statuses[i].fa
            var class1 = statuses[i].i_id_1_class
            var class2 = statuses[i].i_id_2_class
            var color1 = statuses[i].i_id_1_color
            var color2 = statuses[i].i_id_2_color
            var bg = statuses[i].bg
            if (localStorage.getItem("" + statuses[i].status + "color2")) {
                bg = localStorage.getItem("" + statuses[i].status + "color2")
            }
            if (localStorage.getItem("" + statuses[i].status + "color1")) {
                color1 = localStorage.getItem("" + statuses[i].status + "color1")
            }
            var divid = statuses[i].status + 'div'
            var i_id_1 = statuses[i].status + 'val'
            var i_id_2 = statuses[i].status + 'simplebg'
            var rpuidiv = statuses[i].status + 'bar'
            var blink = statuses[i].status + 'blink'
            var hidemax = statuses[i].min_val_hide
            if (hidemax == undefined) {
                hidemax = 100
            }
            if (statleft == 'top-left' || statleft == 'bottom-left') {
                float = 'left'
            } else {
                float = 'right'
            }
            if (setting['status'][statuses[i].status] == undefined) {
                setting['status'][statuses[i].status] = {}
            }
            if (usersetting['status'] && usersetting['status'][statuses[i].status] !== undefined) {
                setting['status'][statuses[i].status].min_val_hide = usersetting['status'][statuses[i].status].min_val_hide
                setting['status'][statuses[i].status].hideifmax = usersetting['status'][statuses[i].status].hideifmax
                if (usersetting['status'][statuses[i].status].type == undefined) {
                    usersetting['status'][statuses[i].status].type = statuses[i].type
                }
                if (setting['status'][statuses[i].status].hideifmax == undefined) {
                    setting['status'][statuses[i].status].hideifmax = statuses[i].hideifmax
                }
                if (usersetting['status'][statuses[i].status].hideifmax == undefined) {
                    usersetting['status'][statuses[i].status].hideifmax = statuses[i].hideifmax
                }
                setting['status'][statuses[i].status].type = usersetting['status'][statuses[i].status].type
            } else {
                setting['status'][statuses[i].status].min_val_hide = hidemax
                setting['status'][statuses[i].status].hideifmax = statuses[i].hideifmax
                setting['status'][statuses[i].status].type = statuses[i].type
                if (usersetting['status'] == undefined) {
                    usersetting['status'] = {}
                }
                if (usersetting['status'][statuses[i].status] == undefined) { usersetting['status'][statuses[i].status] = {} }
                usersetting['status'][statuses[i].status].min_val_hide = hidemax
                usersetting['status'][statuses[i].status].hideifmax = statuses[i].hideifmax
                usersetting['status'][statuses[i].status].type = statuses[i].type
            }
            hex = rgbToHex(statuses[i].bg)
            if (hex == undefined) { hex = '#000000' }
            //console.log(setting['status'][statuses[i].status].hideifmax)
            $("#statussetting").append(`<div class="form-item">
                <div style="position: absolute;
                left: -25px;
                font-size: 15px;">
                <input style="width: 30px;opacity:0.3;" type="color" id="` + statuses[i].status + `color" name="` + statuses[i].status + `color"
                value="` + rgbToHex(statuses[i].i_id_1_color) + `">
                </div>
                <div style="position: absolute;
                left: -55px;
                font-size: 15px;">
                <input style="width: 30px;opacity:0.3;" type="color" id="` + statuses[i].status + `color2" name="` + statuses[i].status + `color"
                value="` + rgbToHex(statuses[i].bg) + `">
                </div>
                <label class="form-item__label">` + statuses[i].status + `</label>
                <div class="slider" style="width:30%;">
                    <input id="` + statuses[i].status + `range" class="slider__input" type="range" value="` + setting['status'][statuses[i].status].min_val_hide + `" min="0" max="100"/>
                    <div class="slider__positive" style="width: ` + setting['status'][statuses[i].status].min_val_hide + `%;" id="` + statuses[i].status + `widthbar"></div>
                </div>
                <div class="form-item__control toggle" data-id="` + statuses[i].status + `" id="` + statuses[i].status + `toggle">
                  <div class="toggle__handle"></div>
                </div>
                <div class="form-item__control" style="width: 15%;display: inline-flex;">
                    <select class="control control--select" id="` + statuses[i].status + `statustype" onchange="statustype('` + statuses[i].status + `')">
                        <option selected="selected" value="1">1</option>
                        <option value="0">0</option>
                    </select>
                </div>
              </div>`);
            $("#" + statuses[i].status + "color").on("input", function() {
                document.getElementById(statuses[i].status + 'val').style.stroke = '' + $(this).val() + '';
                localStorage.setItem("" + statuses[i].status + "color1", $(this).val());
            });
            $("#" + statuses[i].status + "color2").on("input", function() {
                document.getElementById('' + statuses[i].status + 'fabg').style.color = '' + $(this).val() + '';
                localStorage.setItem("" + statuses[i].status + "color2", $(this).val());
            });
            if (setting['status'][statuses[i].status] == undefined) { setting['status'][statuses[i].status] = {} }
            if (document.getElementById('' + statuses[i].status + 'statustype')) {
                document.getElementById('' + statuses[i].status + 'statustype').value = setting['status'][statuses[i].status].type;
            }
            if (setting['statusver'] && document.getElementById('statusversion')) {
                document.getElementById('statusversion').value = setting['statusver']
            }
            if (setting['uilook'] && document.getElementById('uilook')) {
                document.getElementById('uilook').value = setting['uilook']
            }
            if (setting['iconshape'] && document.getElementById('iconshape')) {
                document.getElementById('iconshape').value = setting['iconshape']
            }
            if (setting['carhud']['version'] && document.getElementById('carhudver')) {
                document.getElementById('carhudver').value = setting['carhud']['version']
            }
            if (setting['carhud']['speedmetric'] && document.getElementById('speedmetric')) {
                document.getElementById('speedmetric').value = setting['carhud']['speedmetric']
            }
            if (setting['status'][statuses[i].status].type == 1) {
                var appendto = false
                if (localStorage.getItem("statusleft")) {
                    if (localStorage.getItem("statusleft") > 1000) {
                        appendto = true
                    }
                }
                if (setting['statusver'] == 'icons') {
                    if (appendto) {
                        $("#statusv3").append('<span id="' + divid + '" class="fa-stack fa-2x" style="display:' + statuses[i].display + ';font-size:27px;position:relative;color:rgba(144, 144, 144, 0.876);float:right; margin-top:4px;margin-left:1px;"> <i class="fas fa-octagon fa-stack-2x" id="' + statuses[i].status + 'fabg" style="font-size:27px;color:' + bg + '"></i> <i id="' + blink + '" class="fal fa-octagon fa-stack-2x" style="font-size:26px;color:rgb(177 177 177 / 13%)"></i> <i id="' + i_id_1 + '" class="' + fa + ' fa-stack-1x" style="font-size:23px;color:' + color1 + ';z-index:1131;opacity:1.0;"></i> <i id="' + i_id_2 + '" class="' + fa + ' fa-stack-1x" style="font-size:23px;color:' + color2 + ';z-index:1130;opacity:1.0;"></i> </span>');
                    } else {
                        $("#statusv3").prepend('<span id="' + divid + '" class="fa-stack fa-2x" style="display:' + statuses[i].display + ';font-size:27px;position:relative;color:rgba(144, 144, 144, 0.876);float:left; margin-top:4px;margin-left:1px;"> <i class="fas fa-octagon fa-stack-2x" id="' + statuses[i].status + 'fabg" style="font-size:27px;color:' + bg + '"></i> <i id="' + blink + '" class="fal fa-octagon fa-stack-2x" style="font-size:26px;color:rgb(177 177 177 / 13%)"></i> <i id="' + i_id_1 + '" class="' + fa + ' fa-stack-1x" style="font-size:23px;color:' + color1 + ';z-index:1131;opacity:1.0;"></i> <i id="' + i_id_2 + '" class="' + fa + ' fa-stack-1x" style="font-size:23px;color:' + color2 + ';z-index:1130;opacity:1.0;"></i> </span>');
                    }
                } else {
                    if (appendto) {
                        float = 'right'
                        $("#statusv3").append('<div id="' + divid + '" style="float:' + float + ';height:2.9vw;width:2.9vw;position:relative;display:' + statuses[i].display + '"> <span class="fa-stack fa-2x" style="position:absolute;font-size:0.9vw;color:rgba(144, 144, 144, 0.876);bottom:1.0vw;"> <i class="fas fa-octagon fa-stack-2x" id="' + statuses[i].status + 'fabg" style="font-size:1.25vw;color:' + bg + ';margin-left:0.2vw;"></i> <i id="' + blink + '" class="fal fa-octagon fa-stack-2x" style="font-size:1.41vw;color:rgb(177 177 177 / 13%)"></i> <i id="' + i_id_2 + '" class="' + statuses[i].fa + ' fa-stack-1x" style="font-size:1.0vw;color:rgb(240, 240, 240);z-index:1131;opacity:1.0;left:1.19vw;"></i> <svg class="default" preserveAspectRatio="xMidYMin" style="position:absolute;left:-0.25vw;bottom:-0.312vw;display: block;margin:auto;z-index:1205;opacity:0.65;transform: rotate(0deg);height:2.55vw;" xmlns="http://www.w3.org/2000/svg" width="5.5vw" viewBox="0 0 200 200" data-value="1"> <path style="stroke-opacity:0.4;stroke-width:24px;" class="bg" stroke="' + color1 + '" d="M41 179.5a77 77 0 1 1 0.93 0"  fill="none"/> <path style="" id="' + i_id_1 + '" class="meter statushud" style="stroke-width:24px;" stroke="' + color1 + '" d="M41 179.5a77 77 0 1 1 0.93 0" fill="none" stroke-dasharray="480" stroke-dashoffset="480"/> </svg> </span>');
                    } else {
                        $("#statusv3").prepend('<div id="' + divid + '" style="float:' + float + ';height:2.9vw;width:2.9vw;position:relative;display:' + statuses[i].display + '"> <span class="fa-stack fa-2x" style="position:absolute;font-size:0.9vw;color:rgba(144, 144, 144, 0.876);bottom:1.0vw;"> <i class="fas fa-octagon fa-stack-2x" id="' + statuses[i].status + 'fabg" style="font-size:1.25vw;color:' + bg + ';margin-left:0.2vw;"></i> <i id="' + blink + '" class="fal fa-octagon fa-stack-2x" style="font-size:1.41vw;color:rgb(177 177 177 / 13%)"></i> <i id="' + i_id_2 + '" class="' + statuses[i].fa + ' fa-stack-1x" style="font-size:1.0vw;color:rgb(240, 240, 240);z-index:1131;opacity:1.0;left:1.19vw;"></i> <svg class="default" preserveAspectRatio="xMidYMin" style="position:absolute;left:-0.25vw;bottom:-0.312vw;display: block;margin:auto;z-index:1205;opacity:0.65;transform: rotate(0deg);height:2.55vw;" xmlns="http://www.w3.org/2000/svg" width="5.5vw" viewBox="0 0 200 200" data-value="1"> <path style="stroke-opacity:0.4;stroke-width:24px;" class="bg" stroke="' + color1 + '" d="M41 179.5a77 77 0 1 1 0.93 0"  fill="none"/> <path style="" id="' + i_id_1 + '" class="meter statushud" style="stroke-width:24px;" stroke="' + color1 + '" d="M41 179.5a77 77 0 1 1 0.93 0" fill="none" stroke-dasharray="480" stroke-dashoffset="480"/> </svg> </span>');
                    }
                }
                statusbars[statuses[i].status] = false
            } else {
                statusbars[statuses[i].status] = true
                $("#status_progress").append('<li style="height: 40px;position:relative;">\
                    <div class="prog-bar">\
                      <span class="bar">\
                        <span style="background: ' + statuses[i].i_id_1_color + ';" class="prog_progress" id="' + rpuidiv + '"></span>\
                      </span>\
                    </div>\
                    <i style="position:absolute;right:23px;top:27px;z-index: 1350;color:white;font-size:20px;" class="tikol ' + statuses[i].fa + '"></i>\
                    <img style="position:relative;z-index:1205 !important;height:40px;" src="img/status_bar.png" />\
                </li>');
                $("tikol").removeClass("fa-stack-1x");
            }
        }
    }
    console.log(statusui, 'statusui')
    if (statusui == 'normal') {
        //setting['uilook'] = statusui
        if (document.getElementById("healthdiv")) {
            document.getElementById("healthdiv").remove()
        }
        if (document.getElementById("armordiv")) {
            document.getElementById("armordiv").remove()
        }
        if (document.getElementById("voipdiv")) {
            document.getElementById("voipdiv").remove()
            NormalUI()
            document.getElementById("statusnormal").style.display = 'block';
        }
    }

    const toggle = document.querySelectorAll('.toggle');
    if (setting['carhud']['refreshrate']) {
        var p = (setting['carhud']['refreshrate'] / 300) * 100
        document.getElementById('rval').innerHTML = setting['carhud']['refreshrate']
        document.getElementById('refreshrate').value = setting['carhud']['refreshrate']
        document.getElementById('refreshrate2').style.width = '' + p + '%'
        post("setrefreshrate", { val: setting['carhud']['refreshrate'] })
    }
    for (var i = 0; toggle.length > i; i++) {
        var statusname = toggle[i].id
        statusname = statusname.replace("toggle", "");
        if (usersetting['status'] && usersetting['status'][statusname] !== undefined) {
            setting['status'][statusname].hideifmax = usersetting['status'][statusname].hideifmax
        }
        if (setting['status'][statusname] && setting['status'][statusname].hideifmax) {
            //console.log('toggle',statusname)
            toggle[i].classList.toggle('is-on');
        }
        //console.log(statusname)
        if (setting['streethud'] && statusname == 'streethud') {
            toggle[i].classList.toggle('is-on');
        }
        if (setting['carhud'] && setting['carhud']['turbohud'] && statusname == 'turbohud') {
            toggle[i].classList.toggle('is-on');
        }
        if (setting['carhud'] && setting['carhud']['manualhud'] && statusname == 'manualhud') {
            toggle[i].classList.toggle('is-on');
        }
        if (setting['weaponhud'] && statusname == 'weaponhud') {
            toggle[i].classList.toggle('is-on');
        }
        toggle[i].addEventListener('click', function() {
            this.classList.toggle('is-on');
            const statusname = this.id.replace("toggle", "")
            if (setting['status'][statusname] !== undefined) { // status only
                setting['status'][statusname].hideifmax = !setting['status'][statusname].hideifmax
                if (usersetting['status'] == undefined) {
                    usersetting['status'] = {}
                }
                if (usersetting['status'][statusname] == undefined) {
                    usersetting['status'][statusname] = {}
                }
                usersetting['status'][statusname].hideifmax = setting['status'][statusname].hideifmax
            }
            if (setting['carhud'][statusname] !== undefined && statusname == 'turbohud') { // status only
                setting['carhud'][statusname] = !setting['carhud'][statusname]
                usersetting['carhud'][statusname] = setting['carhud'][statusname]
                setShowTurboBoost(usersetting['carhud'][statusname], true)
            }

            if (setting['carhud'][statusname] !== undefined && statusname == 'manualhud') { // status only
                setting['carhud'][statusname] = !setting['carhud'][statusname]
                usersetting['carhud'][statusname] = setting['carhud'][statusname]
                setManual(usersetting['carhud'][statusname], true)
            }
            if (setting[statusname] !== undefined && statusname == 'streethud') { // status only
                setting[statusname] = !setting[statusname]
                usersetting[statusname] = setting[statusname]
                setCompass(setting['streethud'])
            }
            if (setting[statusname] !== undefined && statusname == 'weaponhud') { // status only
                setting[statusname] = !setting[statusname]
                usersetting[statusname] = setting[statusname]
                setWeaponUi(setting['weaponhud'], true)
            }
        });
    }
    const sliderInput = document.querySelectorAll('.slider__input');
    for (var i = 0; sliderInput.length > i; i++) {
        sliderInput[i].addEventListener('input', function() {
            var statusname = this.id
            statusname = statusname.replace("range", "");
            const valueContainer = this.parentNode.parentNode.querySelector('.slider__value');
            const sliderValue = this.value;
            const maxVal = this.getAttribute('max');
            const posWidth = this.value / maxVal;
            this.parentNode.querySelector('.slider__positive').style.width = posWidth * 100 + '%';
            if (setting['carhud'][statusname]) {
                setting['carhud'][statusname] = sliderValue
                valueContainer.innerHTML = sliderValue;
                if (usersetting['carhud'] == undefined) {
                    usersetting['carhud'] = {}
                }
                usersetting['carhud'][statusname] = sliderValue
                post("setrefreshrate", { val: sliderValue })
                v1 = sliderValue * 0.001
                v2 = sliderValue * 0.01
            }
            if (setting['status'][statusname]) {
                setting['status'][statusname].min_val_hide = sliderValue
                if (usersetting['status'] == undefined) {
                    usersetting['status'] = {}
                }
                if (usersetting['status'][statusname] == undefined) {
                    usersetting['status'][statusname] = {}
                }
                if (usersetting['status'][statusname]) {
                    usersetting['status'][statusname].min_val_hide = sliderValue
                }
            }
        });
    }
    RestoreStatusPosition()
}

console.clear();

const radioItem = document.querySelectorAll('.radio__item');

for (var i = 0; radioItem.length > i; i++) {
    radioItem[i].addEventListener('click', function() {
        const siblingItems = this.parentNode.getElementsByClassName('radio__item');
        for (var i = 0; siblingItems.length > i; i++) {
            siblingItems[i].classList.remove('is-active');
        }
        this.classList.toggle('is-active');
    });
}

function setShowTurboBoost(bool, s) {

}

function setTurboBoost(table) {

}

var carstatusstring = `<div id="carinfo">Car Status:</div>
    <img style="z-index:900;position:absolute;right:440px;top:100px;opacity:0.7;height:650px;" src="img/bodybg.png" />
    <!-- <div class="pulse" style="z-index: 1111;"></div> -->
    <img id="carstatimg" style="z-index:1001;position:absolute;right:500px;top:100px;opacity:1;height:550px;" src="img/carstatus.png" />
    <span id="brakelevel" style="-webkit-filter: drop-shadow(1px -1px 8px rgba(5, 122, 255, 0.575));z-index:1001;position:absolute;right:657px;border-radius:5px;top:250px;opacity:1.0;height:20px;color:#fff;font-size:11px;background:rgba(0, 0, 0, 0.555); padding:5px;overflow:hidden;" src="img/chest.png">LVL 1</span>
    <span id="enginelevel" style="-webkit-filter: drop-shadow(1px -1px 8px rgba(5, 122, 255, 0.575));z-index:1001;position:absolute;right:835px;top:250px;opacity:1.0;height:20px;color:#fff;font-size:11px;background:rgba(0, 0, 0, 0.555); padding:5px;overflow:hidden;" src="img/head.png">LVL 1</span>
    <span id="enginename" style="-webkit-filter: drop-shadow(1px -1px 8px rgba(5, 122, 255, 0.575));z-index:1001;position:absolute;right:905px;top:180px;opacity:1.0;height:20px;color:#fff;font-size:11px;background:rgba(0, 0, 0, 0.555); padding:5px;overflow:hidden;" src="img/head.png">Default Engine</span>
    <span id="suspensionlevel" style="-webkit-filter: drop-shadow(1px -1px 8px rgba(5, 122, 255, 0.575));z-index:1001;position:absolute;right:890px;top:384px;opacity:1.0;height:20px;color:#fff;font-size:11px;background:rgba(0, 0, 0, 0.555); padding:5px;overflow:hidden;" src="img/rightarm.png">LVL 1</span>
    <span id="trannytype" style="-webkit-filter: drop-shadow(1px -1px 8px rgba(5, 122, 255, 0.575));z-index:1001;position:absolute;right:945px;top:300px;opacity:1.0;height:20px;color:#fff;font-size:11px;background:rgba(0, 0, 0, 0.555); padding:5px;overflow:hidden;" src="img/head.png">Automatic</span>
    <span id="trannylevel" style="-webkit-filter: drop-shadow(1px -1px 8px rgba(5, 122, 255, 0.575));z-index:1001;position:absolute;right:608px;top:382px;opacity:1.0;height:20px;color:#fff;font-size:11px;background:rgba(0, 0, 0, 0.555); padding:5px;overflow:hidden;" src="img/leftarm.png">LVL 1</span>
    <span id="turbolevel" style="-webkit-filter: drop-shadow(1px -1px 8px rgba(5, 122, 255, 0.575));z-index:1001;position:absolute;right:840px;top:514.8px;opacity:1.0;height:20px;color:#fff;font-size:11px;background:rgba(0, 0, 0, 0.555); padding:5px;overflow:hidden;" src="img/rightleg.png">LVL 1</span>
    <span id="tirelevel" style="-webkit-filter: drop-shadow(1px -1px 8px rgba(5, 122, 255, 0.575));z-index:1001;position:absolute;right:654px;top:515.8px;opacity:1.0;height:20px;color:#fff;font-size:11px;background:rgba(0, 0, 0, 0.555); padding:5px;overflow:hidden;" src="img/leftleg.png">LVL 1</span>
    <img id="coolantlevel" style="-webkit-filter: drop-shadow(1px -1px 8px rgb(5, 84, 255));z-index:1001;position:absolute;right:974px;top:581.8px;opacity:1.0;height:40px;" src="img/coolant.png" />
    <span id="coolanttext" style="-webkit-filter: drop-shadow(1px -1px 8px rgba(5, 122, 255, 0.575));z-index:1001;position:absolute;right:934px;top:598.8px;opacity:1.0;height:20px;color:#fff;font-size:11px;overflow:hidden;" src="img/leftleg.png">LVL 1</span>
    <img id="oillevel" style="-webkit-filter: drop-shadow(1px -1px 8px rgb(5, 84, 255));z-index:1001;position:absolute;right:974px;top:641.8px;opacity:1.0;height:40px;" src="img/oil.png" />
    <span id="oiltext" style="-webkit-filter: drop-shadow(1px -1px 8px rgba(5, 122, 255, 0.575));z-index:1001;position:absolute;right:934px;top:658.8px;opacity:1.0;height:20px;color:#fff;font-size:11px;overflow:hidden;" src="img/leftleg.png">LVL 1</span>
    <img id="mileagelevel" style="-webkit-filter: drop-shadow(1px -1px 8px rgb(5, 84, 255));z-index:1001;position:absolute;right:744px;top:581.8px;opacity:1.0;height:40px;" src="img/mileage.png" />
    <span id="mileagetext" style="-webkit-filter: drop-shadow(1px -1px 8px rgba(5, 122, 255, 0.575));z-index:1001;position:absolute;right:654px;top:598.8px;opacity:1.0;height:20px;color:#fff;font-size:11px;overflow:hidden;" src="img/leftleg.png">LVL 1</span>
    <img id="tirelevel" style="-webkit-filter: drop-shadow(1px -1px 8px rgb(5, 84, 255));z-index:1001;position:absolute;right:744px;top:641.8px;opacity:1.0;height:40px;" src="img/tire.png" />
    <span id="tiretext" style="-webkit-filter: drop-shadow(1px -1px 8px rgba(5, 122, 255, 0.575));z-index:1001;position:absolute;right:654px;top:658.8px;opacity:1.0;height:20px;color:#fff;font-size:11px;overflow:hidden;" src="img/leftleg.png">LVL 1</span>`

function setShowCarStatus(table) {
    if (table['bool']) {
        $('#carstatusui').append(carstatusstring)
        $('#carstatusui').fadeIn('fast');
    } else {
        $('#carstatusui').html('')
        $('#carstatusui').fadeOut('fast');
    }
    for (const i in table) {
        //////console.log(i,table[i])
        if (i == 'brake') {
            $('#brakelevel').html("LVL " + (+table[i] + 1))
        }
        if (i == 'tranny') {
            $('#trannylevel').html("LVL " + (+table[i] + 1))
        }
        if (i == 'turbo') {
            if (table[i] == 'NOTURBO') {
                table[i] = 'NONE'
            }
            $('#turbolevel').html("LVL " + (+table[i] + 1))
        }
        if (i == 'engine') {
            $('#enginelevel').html("LVL " + (+table[i] + 1))
        }
        if (i == 'suspension') {
            $('#suspensionlevel').html("LVL " + (+table[i] + 1))
        }
        if (i == 'tire') {
            $('#tirelevel').html("LVL " + (+table[i] + 1))
        }
        if (i == 'coolant') {
            $('#coolanttext').html((+table[i]).toFixed(0) + "%")
        }
        if (i == 'oil') {
            $('#oiltext').html((+table[i]).toFixed(0) + "%")
        }
        if (i == 'tires_health') {
            $('#tiretext').html((+table[i]).toFixed(0) + "%")
        }
        if (i == 'mileage') {
            $('#mileagetext').html((+table[i]).toFixed(0) + " Km")
        }
        if (i == 'trannytype') {
            $('#trannytype').html(table[i])
        }
        if (i == 'enginename') {
            $('#enginename').html(table[i])
        }
    }
}

function setShooting(sleep) {}

function NuiLoop() {

}

function Drag(bool) {
    if (bool) {
        $('#statusv3').draggable({
            // ...
            drag: function(event, ui) {
                $('#statusv3').css('inset', 'unset');
            },
            stop: function(event, ui) {
                console.log(ui.position.top + " x " + ui.position.left);
                localStorage.setItem("statustop", ui.position.top);
                localStorage.setItem("statusleft", ui.position.left);
            },
            scroll: false
        }).draggable('enable');
    } else {
        $('#statusv3').draggable().draggable('disable');
    }
    if (bool) {
        $('#status_progress').draggable({
            // ...
            drag: function(event, ui) {},
            stop: function(event, ui) {
                console.log(ui.position.top + " x " + ui.position.left);
                localStorage.setItem("statusptop", ui.position.top);
                localStorage.setItem("statuspleft", ui.position.left);
            },
            scroll: false
        }).draggable('enable');
    } else {
        $('#status_progress').draggable().draggable('disable');
    }
}

function RestoreStatusPosition() {
    var havedefault = false
    if (localStorage.getItem("statusleft") && $('#statusv3')) {
        havedefault = true
        $('#statusv3').css('left', '' + localStorage.getItem("statusleft") + 'px');
        $('#statusv3').css('top', '' + localStorage.getItem("statustop") + 'px');
        $('#statusv3').css('right', 'unset');
        $('#statusv3').css('bottom', 'unset');
    }
    if (localStorage.getItem("statuspleft") && $('#status_progress')) {
        $('#status_progress').css('left', '' + localStorage.getItem("statuspleft") + 'px');
        $('#status_progress').css('top', '' + localStorage.getItem("statusptop") + 'px');
        $('#status_progress').css('right', 'unset');
        $('#status_progress').css('bottom', 'unset');
    }
    return havedefault
}

function RestoreCarPosition() {
    var havedefault = false
    var screenh = $(window).height();
    var screenw = $(window).width();
    if (localStorage.getItem("carhudleft")) {
        havedefault = true
        $('#' + carui + '').css('left', '' + screenw * localStorage.getItem("carhudleft") + 'px');
        $('#' + carui + '').css('top', '' + screenh * localStorage.getItem("carhudtop") + 'px');
        $('#' + carui + '').css('right', 'auto');
        $('#' + carui + '').css('bottom', 'auto');
        console.log("have default")
    }
    return havedefault
}

function ResetStorages() {
    localStorage.removeItem("carhudtop")
    localStorage.removeItem("carhudleft")
    localStorage.removeItem("statusptop")
    localStorage.removeItem("statuspleft")
    localStorage.removeItem("statustop")
    localStorage.removeItem("statusleft")
    for (const i in statcache) {
        if (statcache[i].enable) {
            localStorage.removeItem("" + statcache[i].status + "color1")
            localStorage.removeItem("" + statcache[i].status + "color2")
        }
    }
}

function DragCar(bool) {
    if (bool) {
        $('#simple').draggable({
            drag: function(event, ui) {
                $('#simple').css('inset', 'unset');
            },
            stop: function(event, ui) {
                var screenh = $(window).height();
                var screenw = $(window).width();
                var percentleft = ui.position.left / screenw
                var percenttop = ui.position.top / screenh
                console.log(ui.position.top + " x " + percenttop, screenh * percenttop, ui.position.top);
                localStorage.setItem("carhudtop", percenttop);
                localStorage.setItem("carhudleft", percentleft);
            },
            scroll: false
        }).draggable('enable');
        $('#minimal').draggable({
            drag: function(event, ui) {
                $('#minimal').css('inset', 'unset');
            },
            stop: function(event, ui) {
                var screenh = $(window).height();
                var screenw = $(window).width();
                var percentleft = ui.position.left / screenw
                var percenttop = ui.position.top / screenh
                console.log(ui.position.top + " x " + percenttop, screenh * percenttop, ui.position.top);
                localStorage.setItem("carhudtop", percenttop);
                localStorage.setItem("carhudleft", percentleft);
            },
            scroll: false
        }).draggable('enable');
        $('#modern').draggable({
            drag: function(event, ui) {
                $('#modern').css('inset', 'unset');
            },
            stop: function(event, ui) {
                var screenh = $(window).height();
                var screenw = $(window).width();
                var percentleft = ui.position.left / screenw
                var percenttop = ui.position.top / screenh
                console.log(ui.position.top + " x " + percenttop, screenh * percenttop, ui.position.top);
                localStorage.setItem("carhudtop", percenttop);
                localStorage.setItem("carhudleft", percentleft);
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
    status_type = type
}

function playerloaded() {
    document.getElementById("uibody").style.display = 'block'
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
    document.getElementById("uibody").style.display = '' + display + ''
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
    r.style.setProperty('--mscar', table.animation_mscar);
    r.style.setProperty('--transcar', table.transitioncar);
}

function SetMetrics(v, s) {
    if (setting !== undefined && setting['carhud'] !== undefined && setting['carhud']['speedmetric'] !== undefined) {
        if (setting['carhud']['speedmetric'] !== v && s) {
            metrics = v
        } else {
            metrics = setting['carhud']['speedmetric']
        }
    } else {
        metrics = v
    }
    if (document.getElementById("speedtext")) {
        document.getElementById("speedtext").innerHTML = metrics;
    }
}

function Talking(bool) {
    var voiceId = document.querySelector('#voipsimplebg');
    if (voiceId) {
        if (bool) {
            voiceId.classList.add('talking')
        } else {
            voiceId.classList.remove('talking')
        }
    }
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
    playerloaded,
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
    SettingHud,
    reimportsetting,
    Talking,
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
    SetMetrics,

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

setTimeout(function() {
    $(".fadeout").fadeOut();
    $(".loading").fadeOut();
    setMic(2)
}, 5000);
setShowCarStatus(false)