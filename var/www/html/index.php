<?php if (!isset($_GET['user']) || !isset($_GET['pass']) || !isset($_GET['host'])) exit('user or pass or host no set') ?>

<!doctype html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <!-- <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0"> -->
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>WebPhone with JsSip And Asterisk</title>
    <link rel="stylesheet" href="static/css/phone.css">
    <link rel="stylesheet" href="static/css/font-awesome.min.css">
</head>

<body>
    <div id="errorMessage">must set sip uri/password</div>
    <div id="wrapper">
        <div id="incomingCall" style="display: none">
            <div class="callInfo">
                <h3>Incoming Call</h3>
                <p id="incomingCallNumber">Unknown</p>
            </div>
            <div id="answer"><i class="fa fa-phone"></i></div>
            <div id="reject"><i class="fa fa-phone"></i></div>
        </div>
        <div id="callStatus" style="display: none">
            <div class="callInfo">
                <h3 id="callInfoText">info text goes here</h3>
                <p id="callInfoNumber">info number goes here</p>
            </div>
            <div id="hangUp"><i class="fa fa-phone"></i>
            </div>
        </div>
        <!---------TO FIELD---------------------------------------------------->
        <!---------DIALPAD---------------------------------------------------->
        <div id="inCallButtons" style="display: none">
            <div id="dialPad">

                <div class="dialpad-char" data-value="1" unselectable="on">1</div>
                <div class="dialpad-char" data-value="2" unselectable="on">2</div>
                <div class="dialpad-char" data-value="3" unselectable="on">3</div>
                <div class="dialpad-char" data-value="4" unselectable="on">4</div>
                <div class="dialpad-char" data-value="5" unselectable="on">5</div>
                <div class="dialpad-char" data-value="6" unselectable="on">6</div>
                <div class="dialpad-char" data-value="7" unselectable="on">7</div>
                <div class="dialpad-char" data-value="8" unselectable="on">8</div>
                <div class="dialpad-char" data-value="9" unselectable="on">9</div>
                <div class="dialpad-char" data-value="*" unselectable="on">*</div>
                <div class="dialpad-char" data-value="0" unselectable="on">0</div>
                <div class="dialpad-char" data-value="#" unselectable="on">#</div>
            </div>
            <div id="mute">
                <i id="muteIcon" class="fa fa-microphone"></i>
            </div>
        </div>

        <!---------DIAL CONTROLS-------------------------------------------->
        <div id="callControl">
            <div id="to">
                <input id="toField" type="text" placeholder="Enter number here" />
            </div>
            <div id="connectCall"><i class="fa fa-phone"></i>
            </div>
        </div>

    </div>

    <script>
        var ringTone = new window.Audio("static/audio/ringtone.mp3");
        var dtmfTone = new window.Audio("static/audio/dtmf.wav");
        var asteriskIp = "<?php echo $_GET['host'] ?>";
        var asteriskUser = "<?php echo $_GET['user'] ?>";
        var asteriskUserPass = "<?php echo $_GET['pass'] ?>";
        var asteriskUserName = "<?php echo $_GET['user'] ?>";
    </script>

    <script src="static/js/jquery.js"></script>
    <script src="static/js/jssip-3.2.11.js"></script>
    <script src="static/js/main.js"></script>

</body>

</html>