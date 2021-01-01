import processing.serial.*;
import themidibus.*; //Import the library
import java.util.Map;
import controlP5.*;

MidiBus myBus; // The MidiBus
SimpleMidiListener listener;
int threshold = 63;

JSONArray json;
int[] pitches;
HashMap<Integer,Integer> hm = new HashMap<Integer,Integer>();
byte relayStates = 0;

Serial myPort;  // Create object from Serial class
int val;        // Data received from the serial port
boolean portOpen = false;
int serialControlTimer = 100;
color green = color(0,255,0);
color red = color(255,0,0);
color serialControlColor = red;

ControlP5 cp5;

void setup() {
  size(400, 400);
  background(0);
  
  json = loadJSONArray("pitches.json");
  pitches = json.getIntArray();
  for(int i = 0; i < pitches.length; i++) {
    hm.put(pitches[i],i);
  }

  MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.

  myBus = new MidiBus(this, "PAD", "Bus 1"); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.
  myBus.addMidiListener(listener);
  
  printArray(Serial.list());
  
  //String portName = Serial.list()[6];
  //myPort = new Serial(this, portName, 9600);
  
  //GUI
  noStroke();
  cp5 = new ControlP5(this);
  cp5.addScrollableList("dropdownSerial")
     .setPosition(50, 130)
     .setSize(200, 100)
     .setBarHeight(20)
     .setItemHeight(20)
     .setOpen(false)
     .addItems(Serial.list())
     // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
     ;
  cp5.addScrollableList("dropdownMidi")
     .setPosition(50, 80)
     .setSize(200, 100)
     .setBarHeight(20)
     .setItemHeight(20)
     .setOpen(false)
     .addItems(MidiBus.availableInputs())
     ;
  cp5.addSlider("threshold")
     .setPosition(50,30)
     .setRange(0,127)
     .setSize(200,20)
     .setValue(63)
     ;
  
}

void draw() {
  background(0);
  //GUI
  if(portOpen){
    myPort.write(relayStates);
    serialControlColor = green;
  } else {
    serialControlColor = red;
  }
  fill(serialControlColor);
  ellipse(30,140,20,20);
  fill(255,255,255);
  text("sth. like \"/DEV/CU.USBMODEM145101\"",50,170);
}

void noteOn(int channel, int pitch, int velocity) {
  // Receive a noteOn
  println();
  println("Note On:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
  if(velocity >= threshold){
    int relay = hm.get(pitch);
    println(relay);
    relayStates |= 1 << relay;
  }
}

void noteOff(int channel, int pitch, int velocity) {
  // Receive a noteOn
  println();
  println("Note Off:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
  int relay = hm.get(pitch);
  println(relay);
  relayStates &= ~(1 << relay);
  println(relayStates);
}

//***************** GUI Controller ******************//

void dropdownSerial(int n) {
  String portName = Serial.list()[n];
  try{
    myPort = new Serial(this, portName, 9600);
    println(portName);
    portOpen = true;
  } catch (RuntimeException e){
    println(e);
    portOpen = false;
  }
}
