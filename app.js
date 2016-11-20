//ORDER OF EXECUTION:
//when the "Press PLay" button is pushed, sendNotesToPlay is called along with its parameters: an initial index of 1, the id of the input where notes are entered (ns1 initially), and the id of the canvas element where notes should be drawn.
//sendNotesToPlay calls stringParser which breaks up the text entered into corresponding notes, durations, and octaves.  
//stringParser returns an array of arrays.  At each index of stringParser the corresponding array is referenced for exact frequency, note duration, and octave value before being sent at a set interval (depending on tempo) to the play function which creates the sounds.
//if the add additional instrument button is pressed, a new input and corresponding canvas is added to the DOM.


var ctx = new ( window.AudioContext ) || ( window.webkitAudioContext );
var functionCaller = "clearCanvas(); sendNotesToPlay(1, 'ns1', 5);";
var cvs1 = document.getElementById("cvs1");
cvs1.width = window.innerWidth;



//takes in formatted array, determines hertz, sustain, and octave, and sends to main play function 
function sendNotesToPlay(index, id, blockX) {
    var arr = stringParser(id);

    //initial send, before setTimeout takes effect.
    if (arr !== undefined) {  
        if (index === 1) {
            play(noteHz(arr[index -1][0]), noteDuration(arr[index -1][1]), whichOctave(arr[index -1][2])); 
            noteDrawer(noteHz(arr[index -1][0]), noteDuration(arr[index -1][1]), arr[index -1][2], id, blockX); 
            blockX += (noteDuration(arr[index -1][1]) * 10);
        }
        
        if (arr.length > index) {
        
            setTimeout(function() {
                var octave = whichOctave(arr[index][2]);
                var sustain = noteDuration(arr[index][1]);
                var hertz = noteHz(arr[index][0]);

                //sends data to WebAudio player
                play(hertz, sustain, octave);

                //sends data for notes to be drawn
                noteDrawer(hertz, sustain, arr[index][2], id, blockX);
                blockX += (sustain * 10);

                //restarts function to play next note
                sendNotesToPlay(++index, id, blockX);
            }, tempo() * 1000 * noteDuration(arr[index -1][1]));
        }
    }
}



//gets input string and formats it into array of arrays to send to sendNotesToPlay function
function stringParser(id) {
    var noteString = document.getElementById(id).value.toLowerCase();  
    
    if (noteString.length !== 0) {
        var noteArr =  noteString.match(/([a-g,r]+#|[a-g,r])([whqes])(\d)/g); 
        var finalArr = noteArr.map(makeArrInArr);
      
        function makeArrInArr(item) {
            if (item.length === 4) {
                var arr = [];
                
                arr.push(item.slice(0,2));
                arr.push(item.slice(2,3));
                arr.push(item.slice(3,4));
                return arr;
            } 
          
            if (item.length === 3) {
                 var arr = [];
                 
                arr.push(item.slice(0,1));
                arr.push(item.slice(1,2));
                arr.push(item.slice(2,3));
                return arr;
            }
        }
        
        return finalArr;
    }
      // expected input ex: 'co1d#s4fw2', etc
      // expected output [[c,o,1],[d#,s,4],[f,w,2]], etc
}



//dertermines note duration
function noteDuration(char) {
    var duration = char;
    var sustain;      

    if (duration === "w")
    sustain = 4

    if (duration === "h")
    sustain = 2

    if (duration === "q")
    sustain = 1

    if (duration === "e")
    sustain = .5

    if (duration === "s")
    sustain = .25

return sustain;
}



//determines frequency
function noteHz(note){
    var frequencies = {
       	'c': 130.81,
       	'c#': 139.00,
       	'd': 146.83,
       	'd#': 156.00,
       	'e': 164.81,
       	'f': 174.61,
       	'f#': 185.00,
       	'g': 196.00,
       	'g#': 208.00,
       	'a': 220.00,
       	'a#': 233.00,
       	'b': 246.94,
       	'r': 0.0,
    };
    var hertz = frequencies[note];
    return hertz;
}



//determines octave number
function whichOctave(num) {
    if (num === 1)
    return num;
      
    else
    return Math.pow(2, num -1);
}



//determines song tempo
function tempo() {
    var bpm = document.getElementById("tempo").value;
    var tempo = 60 / bpm * .5;
    return tempo;
}



//main sound generating function.  Receives attributes and creates appropriate note
function play(hertz, sustain, octave) {
    var osc = ctx.createOscillator();
    var gainNode = ctx.createGain();
    var sustainF = sustain * tempo();
    
    osc.type = document.getElementById('wav-type').value;     
    osc.connect(gainNode);
    gainNode.connect(ctx.destination);
    gainNode.gain.value = 0.0;
    gainNode.gain.setTargetAtTime(.75, ctx.currentTime, 0.1);
    gainNode.gain.setTargetAtTime(0.0, ctx.currentTime + sustainF, 0.01)
    osc.frequency.value = hertz * octave / 4;
    osc.start();
    osc.stop(ctx.currentTime + sustainF + .01);
}



//adds extra input and canvas to website for generation of additional musical voices.
function addPart(index) {
    ++index;
    
    
    //create input and props
    var div = document.createElement('div');
    div.className = 'instrument-div';

    var color = randomColor({ hue: 'blue', luminosity: 'bright'})
    var input = document.createElement('input');
    input.placeholder = `Instrument ${index}: enter notes to play`;
    input.id = `ns${index}`;
    input.type = 'text';
    input.className = 'input';
    input.setAttribute('style', `color: ${color}`);

    //builds up the function that is called when "play" button is pressed.  Each time a new instrument is added, another function call is added.
    functionCaller += ` sendNotesToPlay(1, 'ns${index}', 5);`

    div.appendChild(input);
    document.getElementById('input-div').appendChild(div); 
    document.getElementById('instrument-button').setAttribute("onclick",`addPart(${index})`);
    document.getElementById('play-button').setAttribute("onclick", functionCaller);
}


//Sets up the canvas and draws the notes for each instrument.
function noteDrawer(hertz, sustain, octave, id, pos) {

    var cvs = document.getElementById(`cvs1`).getContext("2d");
    var cvsColor = window.getComputedStyle(document.getElementById(`${id}`), null).getPropertyValue('color');

    var blockLength = sustain * 10;
    var blockX = pos;
    var blockY = 200 - ((hertz / 5) * (octave * .5));

    cvs.fillStyle = cvsColor; 
    cvs.shadowOffsetX = 2;
    cvs.shadowOffsetY = 2;
    cvs.shadowBlur = 5;
    cvs.shadowColor = "rgba(0, 0, 0, 0.25)";
    cvs.beginPath();
    cvs.rect(blockX, blockY, blockLength, 5); 
    cvs.closePath();
    cvs.fill();
}

function clearCanvas() {
    var cvs = document.getElementById(`cvs1`).getContext("2d");
    
    cvs.clearRect(0,0, cvs1.width, 500);
}
