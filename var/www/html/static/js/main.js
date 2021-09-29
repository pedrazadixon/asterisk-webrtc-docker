var phone;
var comfirmCall;
var session;
var socket = new JsSIP.WebSocketInterface('wss://' + asteriskIp + ':8089/ws');
var configuration = {
    sockets: [socket],
    uri: 'sip:' + asteriskUser + '@' + asteriskIp,
    password: asteriskUserPass,
    authorization_user: null,
    contact_uri: null,
    display_name: asteriskUser,
    instance_id: null,
    registrar_server: asteriskIp,
    session_timers: true,
    use_preloaded_route: false
};

var remoteAudio      = new window.Audio();
// var remoteAudio = document.getElementById('audio_remote');
remoteAudio.autoplay = true;

var callOptions = {
    pcConfig: {
        iceServers: []
    },
    mediaConstraints: {
        audio: true,
        video: false
    },
    rtcOfferConstraints: {
        offerToReceiveAudio: 1,
        offerToReceiveVideo: 1
    }
};
if (configuration.uri && configuration.password) {

    // JsSIP.debug.enable('JsSIP:*');

    phone = new JsSIP.UA(configuration);


    phone.on('connected', function (ev) {
        console.log('%c connected on ' + ev.socket.socket.url, 'background: black; color: green');
    });

    phone.on('registered', function (ev) {
        console.log('%c Registered on SIP', 'background: black; color: green');
    });

    phone.on('registrationFailed', function (ev) {
        console.log('%c Registering on SIP server failed with error: ' + ev.cause, 'background: black; color: red');
        configuration.uri = null;
        configuration.password = null;
        updateUI();
    });

    phone.on('newRTCSession', function (ev) {

        console.log('on newRTCSession fired');

        var newSession = ev.session;

        if (session) {
            session.terminate();
        }

        session = newSession;

        if (session.connection) {
            const peerconnection = session.connection;
            peerconnection.addEventListener('addstream', (event) => {
                ringTone.pause();
                remoteAudio.src = window.URL.createObjectURL(event.stream);
            });
        }

        var completeSession = function () {
            session = null;
            updateUI();
        };

        session.on('ended', function () {
            console.log('on ended fired');
            completeSession();
        });

        session.on('failed', function () {
            console.log('on failed fired');
            completeSession();
        });

        session.on('accepted', function (event) {
            console.log('on accepted fired');
            const peerconnection = session.connection;
            var remoteStream = peerconnection.getRemoteStreams()[0];
            remoteAudio.src = window.URL.createObjectURL(remoteStream)
            updateUI();
        });

        session.on('confirmed', updateUI);

        console.log('on confirmed fired');

        if (session._direction == 'incoming') {
            console.log('incoming direction fired');
            ringTone.play();
        }
        updateUI();

    });
    phone.start();
}

updateUI();

$('#connectCall').click(function () {
    var dest = $('#toField').val();
    phone.call(dest, callOptions);
    updateUI();
});
$('#answer').click(function () {
    session.answer(callOptions);
    if (comfirmCall) {
        clearTimeout(comfirmCall);
        comfirmCall = false;
    }
});
var hangup = function () {
    session.terminate();
};

$('#hangUp').click(hangup);

$('#reject').click(hangup);

$('#mute').click(function () {
    if (session.isMuted().audio) {
        session.unmute({
            audio: true
        });
    } else {
        session.mute({
            audio: true
        });
    }
    updateUI();
});

$('#toField').keypress(function (e) {
    if (e.which === 13) { //enter
        $('#connectCall').click();
    }
});
var lock_dtmf_while_playing = false; //inorder to lock multiple input until playing ends
dtmfTone.onended = function () {
    lock_dtmf_while_playing = false;
};
$('#inCallButtons').on('click', '.dialpad-char', function (e) {
    if (!lock_dtmf_while_playing) {
        lock_dtmf_while_playing = true;
        dtmfTone.play();
        var $target = $(e.target);
        var value = $target.data('value');
        session.sendDTMF(value.toString());
    }
});

function updateUI() {

    if (session) session.unmute();

    if (configuration.uri && configuration.password) {
        $('#errorMessage').hide();
        $('#wrapper').show();
        if (session) {
            if (session.isInProgress()) {
                if (session._direction === 'incoming') {
                    $('#incomingCallNumber').html(session.remote_identity.uri);
                    $('#incomingCall').show();
                    $('#callControl').hide();
                    $('#incomingCall').show();
                } else {
                    $('#callInfoText').html('Ringing...');
                    $('#callInfoNumber').html(session.remote_identity.uri.user);
                    $('#callStatus').show();
                }

            } else if (session.isEstablished()) {
                $('#callStatus').show();
                $('#incomingCall').hide();
                $('#callInfoText').html('In Call');
                $('#callInfoNumber').html(session.remote_identity.uri.user);
                $('#inCallButtons').show();
                ringTone.pause();
            }
            $('#callControl').hide();
        } else {
            $('#incomingCall').hide();
            $('#callControl').show();
            $('#callStatus').hide();
            $('#inCallButtons').hide();
            ringTone.pause();
        }
        if (session && session.isMuted().audio) {
            $('#muteIcon').addClass('fa-microphone-slash');
            $('#muteIcon').removeClass('fa-microphone');
        } else {
            $('#muteIcon').removeClass('fa-microphone-slash');
            $('#muteIcon').addClass('fa-microphone');
        }
    } else {
        $('#wrapper').hide();
        $('#errorMessage').show();
    }
}

window.onbeforeunload = function (event) {
    return false;
};