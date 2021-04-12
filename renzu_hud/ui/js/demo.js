function pedface() {
    console.log("REQUESTING")
    $.post(`https://${GetParentResourceName()}/requestface`, {}, function(data) {
        console.log("POSTED")
        let face = data;
        console.log(face)
        console.log(face)
        console.log(face)
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
pedface();

function setArmor(s) {
    document.getElementById("armor").style.width = ''+s+'%'
}

function setHp(s) {
    console.log(s)
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
      
        // jQuery #direction to proper color & font-size configuration
        $('#direction').css('color', 'rgba('+direction.join(', ')+')');
        $('#direction').css('font-size', item.direction.size + 'vh');

        // jQuery #street to proper color & font-size configuration
        $('#street').css('color', 'rgba('+street.join(', ')+')');
        $('#street').css('font-size', item.street.size + 'vh');

        // jQuery #zone to proper color & font-size configuration
        $('#zone').css('color', 'rgba('+zone.join(', ')+')');
        $('#zone').css('font-size', item.zone.size + 'vh');

        for (let i=0; i < borderDOM.length; i++) {
            borderDOM[i].style.color = 'rgba('+border.join(', ')+')';
            borderDOM[i].style.fontSize = item.border.size + 'vh';
        }
    }
}

function setStatus(table) {
    console.log("Status")
    console.log(table.hunger)
    document.getElementById("hunger").style.width = ''+table.hunger+'%'
    document.getElementById("thirst").style.width = ''+table.thirst+'%'
    document.getElementById("stressbar").style.width = ''+table.stress+'%'
    document.getElementById("staminabar").style.width = ''+table.stamina+'%'
    document.getElementById("oxygenbar").style.width = ''+table.oxygen+'%'
    document.getElementById("energybar").style.width = ''+table.energy+'%'
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

function setRpm(percent) {
    var rpm = (percent * 100);
    //tacho = rpm * 0.01;
    // const meters = document.querySelectorAll('svg[data-value] .meter');
    // meters.forEach( (path) => {
    //     let length = path.getTotalLength();
    //     let value = rpm;
    //     let to = length * ((100 - value) / 100);
    //     //path.getBoundingClientRect();
    //     path.style.strokeDashoffset = Math.max(0, to);
    // });
    rpm2 = rpm.toFixed(0) * 100
    document.getElementById("rpmmeter").innerHTML = ""+rpm2+"";
    var e = document.getElementById("rpmpath");
    let length = e.getTotalLength();
    let value = rpm;
    let to = length * ((100 - value) / 100);
    val = to / 1000
    //console.log(to);
    e.style.strokeDashoffset = to;
    //$('#rpm').data('value', tacho); 
}

function setSpeed(s) {
    var takbo = (s * 3.6)
    var max = 350
    var bilis = takbo / max
    speed = bilis * 100;
    takbo = takbo.toFixed(0)
    if (takbo >= 100) {
        document.getElementById("speedmeter").style.right = "330px";
    } else if (takbo >= 10) {
        document.getElementById("speedmeter").style.right = "340px";
    } else {
        document.getElementById("speedmeter").style.right = "350px";
    }
    document.getElementById("speedmeter").innerHTML = ""+takbo+"";
    var e = document.getElementById("speedpath");
    let length = e.getTotalLength();
    let value = speed;
    let to = length * ((100 - value) / 100);
    val = to / 1000
    console.log(speed);
    e.style.strokeDashoffset = to;
}

var manual = false
function setShow(value) {
    //console.log(value)
  if (value) {
        $("#car").animate({
            opacity: "1"
        },400);
  } else {
    $("#car").animate({
      opacity: "0"
    },400);
  }
}

//FUNCTIONS
var evt = {
    setArmor,
    setHp,
    setMic,
    setStatus,
    setShowstatus,

    //CAR
    setRpm,
    setSpeed,
};
setMic(2);

window.addEventListener("message", event => {
    const item = event.data || event.detail;
    //console.log(item.type);
    if (evt[item.type]) {
      evt[item.type](item.content);
    }
    if (item.hud) {
        evt[item.hud](item.content);
        //document.getElementById("diagram").innerHTML = '';
        //$(function(){ o.init(evt[item.hud](item.content)); });
    }
    if (item.compass) {
        onMessageRecieved(event.data);
        //document.getElementById("diagram").innerHTML = '';
        //$(function(){ o.init(evt[item.hud](item.content)); });
    }
  });