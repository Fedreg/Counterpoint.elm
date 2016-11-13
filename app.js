//ORDER OF EXECUTION:
//when the "Press PLay" button is pushed, sendNotesToPlay is called along with its parameters: an initial index of 1, the id of the input where notes are entered (ns1 initially), and the id of the canvas element where notes should be drawn.
//sendNotesToPlay calls stringParser which breaks up the text entered into corresponding notes, durations, and octaves.  
//stringParser returns an array of arrays.  At each index of stringParser the corresponding array is referenced for exact frequency, note duration, and octave value before being sent at a set interval (depending on tempo) to the play function which creates the sounds.
//if the add additional instrument button is pressed, a new input and corresponding canvas is added to the DOM.


const ctx = new window.AudioContext //|| new window.webkitAudioContext;
let functionCaller = "sendNotesToPlay(1, 'ns1', 'cvs1', 5);";



//takes in formatted array, determines hertz, sustain, and octave, and sends to main play function 
function sendNotesToPlay(index, id, cvsId, blockX) {
    var arr = stringParser(id);

    //initial send, before setTimeout takes effect.
    if (arr !== undefined) {  
        if (index === 1) {
            play(noteHz(arr[index -1][0]), noteDuration(arr[index -1][1]), whichOctave(arr[index -1][2])); 
            noteDrawer(noteHz(arr[index -1][0]), noteDuration(arr[index -1][1]), arr[index -1][2], cvsId, blockX); 
            blockX += (noteDuration(arr[index -1][1]) * 5);
        }
        
        if (arr.length > index) {
        
            setTimeout(function() {
                var octave = whichOctave(arr[index][2]);
                var sustain = noteDuration(arr[index][1]);
                var hertz = noteHz(arr[index][0]);

                //sends data to WebAudio player
                play(hertz, sustain, octave);

                //sends data for notes to be drawn
                noteDrawer(hertz, sustain, arr[index][2], cvsId, blockX);
                blockX += (sustain * 5);

                //restarts function to play next note
                sendNotesToPlay(++index, id, cvsId, blockX);
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
    let bpm = document.getElementById("tempo").value;
    let tempo = 60 / bpm * .5;
    return tempo;
}



//main sound generating function.  Receives attributes and creates appropriate note
function play(hertz, sustain, octave) {
    const osc = ctx.createOscillator();
    const gainNode = ctx.createGain();
    const sustainF = sustain * tempo();
    
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
    
    let color = randomColor();
    
    //create input and props
    let input = document.createElement('input');
    input.placeholder = `Instrument ${index}: enter notes to play`;
    input.id = `ns${index}`;
    input.type = 'text';
    
    //create canvas and props
    let canvas = document.createElement('canvas');
    canvas.height = '75';
    canvas.width = '1000';
    canvas.id = `cvs${index}`;

    //builds up the function that is called when "play" button is pressed.  Each time a new instrument is added, another function call is added.
    functionCaller += ` sendNotesToPlay(1, 'ns${index}', 'cvs${index}', 5);`

    document.getElementById('input-div').appendChild(canvas); 
    document.getElementById('input-div').appendChild(input); 
    document.getElementById('instrument-button').setAttribute("onclick",`addPart(${index})`);
    document.getElementById('play-button').setAttribute("onclick", functionCaller);
    console.log(color);
}


//Sets up the canvas and draws the notes for each instrument.
function noteDrawer(hertz, sustain, octave, id, pos) {

    const cvs = document.getElementById(`${id}`).getContext("2d");

    let blockLength = sustain * 5;
    let blockX = pos;
    let blockY = 70 - ((hertz / 10) * (octave * .5));

    cvs.fillStyle = "blue";
    cvs.beginPath();
    cvs.rect(blockX, blockY, blockLength, 10); 
    cvs.closePath();
    cvs.fill();

}
