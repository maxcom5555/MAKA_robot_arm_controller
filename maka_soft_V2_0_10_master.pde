import java.awt.event.KeyEvent;
import javax.swing.JOptionPane;
import processing.serial.*;
import controlP5.*;
import java.util.*;


Serial port = null;
ControlP5 cp5;
Textarea myTextarea;

// select and modify the appropriate line for your operating system
// leave as null to use interactive port (press 'p' in the program)
//String portname = null;
//String portname = Serial.list()[0]; // Mac OS X
//String portname = "/dev/ttyUSB0"; // Linux
String portname = "COM9"; // Windows

boolean saveNow=false;

float x_pos;
float y_pos;
float z_pos;
boolean streaming = false;
float speed = 5000;
float speed_old =5000;
int nr;
String[] gcode;
String[] gcode2;
String[] action_lines= new String[nr];
int init = 0;
int add =0;
int i = 0;
float base =0;
float base_old = base;
float J1 = 0;
float J1_old = 0;
float J2 = 0;
float J2_old = 0;
int mana = 90;
int scroll=0;
int selector=1;
int sy=43;
int sdy=12;
int l_nr=0;

PrintWriter output;
PrintWriter output_2;
PrintWriter output_3;
PrintWriter output_4;

void openSerialPort()
{
  if (portname == null) return;
  if (port != null) port.stop();
  
  port = new Serial(this, portname, 250000);
  
  port.bufferUntil('\n');
}

void selectSerialPort()
{
  String result = (String) JOptionPane.showInputDialog(frame,
    "Select the serial port that corresponds to your Arduino board.",
    "Select serial port",
    JOptionPane.QUESTION_MESSAGE,
    null,
    Serial.list(),
    0);
    
  if (result != null) {
    portname = result;
    openSerialPort();
  }
}

void setup()
{
  size(1300, 800);
  cp5 = new ControlP5(this);
  
 output = createWriter("actions.txt"); 

 
                cp5.addButton("RESET_ROBOT")
     .setColorForeground(#37b448)
     .setColorBackground(#386665)
     .setColorActive(#a3ca61)
     .setPosition(720,50)
     .setSize(70,30)
     ;

               cp5.addSlider("base")
     .setCaptionLabel("BasE")
     .setValue(base)
     .setPosition(30,50)
     .setSize(650,20)
     .setRange(0,1100)
     .setScrollSensitivity(0.002)
     ;

               cp5.addSlider("J1")         
     .setPosition(30,80)
     .setSize(650,20)
     .setRange(0,500)
     .setScrollSensitivity(0.01)
     ;

                   cp5.addSlider("J2")
     .setPosition(30,110)
     .setSize(650,20)
     .setRange(0,350)
     .setScrollSensitivity(0.02)
     ;
            cp5.addSlider("TOOL")
     .setPosition(30,140)
     .setSize(650,20)
     .setRange(1,180)
     ;
          cp5.addSlider("speed")
     .setPosition(30,200)
     .setSize(650,20)
     .setValue(8000)
     .setRange(200,10000)
     ;

     

     
                   cp5.addButton("Home_Base")
     .setPosition(720,110)
     .setSize(70,20)
     ;
     
                   cp5.addButton("Home_J1")
     .setPosition(720,140)
     .setSize(70,20)
     ;
     
                   cp5.addButton("Home_J2")
     .setPosition(720,170)
     .setSize(70,20)
     ;
     
                   cp5.addButton("up")
     .setPosition(720,230)
     .setSize(70,20)
     ;
     
                        cp5.addButton("down")
     .setPosition(720,260)
     .setSize(70,20)
     ;
     
               cp5.addButton("add_position")
                    .setCaptionLabel("ADD POSITION")
     .setPosition(720,320)
     .setSize(70,20)
     ;
     
                    cp5.addButton("insert_position")
                    .setCaptionLabel("INSERT POSITION")
     .setPosition(720,350)
     .setSize(70,20)
     ;
     
                             cp5.addButton("delete")
                                  .setCaptionLabel("DELETE LINE")
                             
     .setPosition(720,380)
     .setSize(70,20)
     ;
                                  cp5.addButton("go_to_line")
                                       .setCaptionLabel("GO TO LINE")
     .setPosition(720,410)
     .setSize(70,20)
     ;
     
                                       cp5.addButton("go_all")
                                            .setCaptionLabel("GO ALL")
     .setPosition(720,440)
     .setSize(70,20)
     ;
     
                    cp5.addButton("load_actions")
                         .setCaptionLabel("LOAD")
     .setPosition(720,500)
     .setSize(70,20)
     ;
                    cp5.addButton("save_actions")
                         .setCaptionLabel("SAVE")
     .setPosition(720,530)
     .setSize(70,20)
     ;

//  openSerialPort();
selectSerialPort();

}

void draw()
{
  
  
   if(saveNow){
    saveNow=false;
    drawAndSave();
  }


  background(0);  
  fill(150);
  textSize(20);
  text("MAKA ROBOT CONTROLLER",200, 30);
  textSize(12);
  
  if (base_old != base) {
   port.write("G0 X" + base + "F" +speed+"\n");
    base_old = base;
 }
   if (J1_old != J1) {
   port.write("G0 Y" + J1 + "F" +speed+"\n");
    J1_old = J1;
 }
    if (J2_old != J2) {
   port.write("G0 Z" + J2 + "F" +speed+"\n");
    J2_old = J2;
 }
 
   int y = 700, dy = 12;
  text("INSTRUCTIONS", 12, y); y += dy;
//  text("p: select serial port", 12, y); y += dy;
//  text("g: stream a g-code file", 12, y); y += dy;
  text("x: stop streaming g-code (this is NOT immediate)", 12, y); y += dy;
//  text("e: enable steppers", 12, y); y += dy;
//  text("d: disable steppers", 12, y); y += dy;

  y = height - dy;
  text("current serial port: " + portname, 12, y); y -= dy;
  
    
 //   text(" X " + base + "    Y " + J1 + "    Z " + J2 + "    F " + speed, 130, 355);  
//fill(0,116,217);
fill(0,45,90);
rect(800, 40, 480, 740, 2);
if (l_nr > 0){
//  fill(0,45,90);
fill(0,116,217);
rect(800, sy, 480, 13, 2);
}
fill(250,250,250);
  text("ACTIONS", 810, 30);
         int g = 54, dg = 12;
   String lines[] = loadStrings("actions.txt");
    
 for (int i = 0; i < lines.length ; i++) {
     text(i +" : "+ lines[i],810,g); g += dg;
 }

//text(selector,1000,30);
//text(l_nr,1030,30);



}

public void insert_position(){

  output_2 = createWriter("actions_temp.txt"); 
    if (selector > 0 & l_nr >0) {
      l_nr++;
      //   if (selector == l_nr+1) up();
      String lines[] = loadStrings("actions.txt");
   
        for (int i = 0; i < lines.length ; i++) {

           if (i == selector-1) {
      
               output_2.println("G0 X " + base + "    Y " + J1 + "    Z " + J2  + "    F " + speed);
               output_2.println(lines[i]);
            }
           else {
               output_2.println(lines[i]);
           }
       }
    output_2.flush();
  
    output = createWriter("actions.txt");
    
   String lines2[] = loadStrings("actions_temp.txt");
    
 for (int i = 0; i < lines2.length ; i++) {
   output.println(lines2[i]);
 }
 output.flush();
    }
  
}

public void up() {
  
if (selector > 1) {
  selector--;
  sy -= sdy;
}
}

public void down() {
  
if (selector < 61 & selector < l_nr) {
  selector++;
  sy += sdy;
}
}
public void delete() {
   output_2 = createWriter("actions_temp.txt"); 
if (selector > 0 & l_nr >0) {
   l_nr--;
   if (selector == l_nr+1) up();
   String lines[] = loadStrings("actions.txt");
    
 for (int i = 0; i < lines.length ; i++) {
   if (i != selector-1) output_2.println(lines[i]);
 }
  output_2.flush();
  
    output = createWriter("actions.txt");
    
   String lines2[] = loadStrings("actions_temp.txt");
    
 for (int i = 0; i < lines2.length ; i++) {
   output.println(lines2[i]);
 }
 output.flush();
}
}

public void add_position() {  
  l_nr ++;
  output.println("G0 X " + base + "    Y " + J1 + "    Z " + J2  + "    F " + speed); // Write the coordinate to the file
  output.flush();
//  output.close(); // Finishes the file

}

public void load_actions() {  
     File start1 = new File(sketchPath("")+"/*.maka");
     gcode = null; i = 0;
  //  File file = null; 
    println("Loading file...");
    selectInput("Select a file to process:", "fileSelected", start1);
}

 
public void RESET_ROBOT() {
port.write("M17\n"); 
port.write("G28 Z\n");
port.write("G28 Y\n");
port.write("G28 X\n");
port.write("G0 X550 F" + speed+ "\n"); // go to middle poin
cp5.getController("base").setValue(550);
cp5.getController("J1").setValue(0);
cp5.getController("J2").setValue(0);

}
public void Home_Base(int theValue) {
port.write("G28 X\n");
cp5.getController("base").setValue(0);
}
public void Home_J1(int theValue) {
port.write("G28 Y\n");
cp5.getController("J1").setValue(0);
}
public void Home_J2(int theValue) {
port.write("G28 Z\n");
cp5.getController("J2").setValue(0);
}
void keyPressed()
{
  
 // if (key == 'e') port.write("M17\n"); 
 // if (key == 'd') port.write("M18\n"); 
  
//  if (!streaming) {
//    if (key == 'p') selectSerialPort();
// }
  
//  if (!streaming && key == 'g') {
//    gcode = null; i = 0;
//    File file = null; 
//    println("Loading file...");
//    selectInput("Select a file to process:", "fileSelected", file);
//  }  
  if (key == 'x') streaming = false;
}
public void save_actions(){
   File start1 = new File(sketchPath("")+"/*.maka"); 
     selectOutput("Select desination;", "saveMAKA", start1); 
}

public void drawAndSave() {
  
     String lines[] = loadStrings("actions.txt");
     
     for (int i = 0; i < lines.length ; i++) {
     output_4.println(lines[i]);}
     output_4.flush();
     output_4.close();
     
}
 
void saveMAKA(File destination) {
  if (destination != null) {
    saveNow=true;
    output_4 = createWriter(destination.getAbsolutePath()+".maka"); 
  }
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    gcode = loadStrings(selection.getAbsolutePath());
    if (gcode == null) return;    
        if (gcode[i].trim().length() == 0) i++;        
        output = createWriter("actions.txt"); 
 for (int i = 0; i < gcode.length ; i++) {
   output.println(gcode[i]);
   l_nr=i+1;
 }
    output.flush();

  }
//    streaming = true;
//    stream();
  }
  
  
    public void go_to_line()
  {
    gcode2 = loadStrings("actions.txt");
    if (selector-1 < gcode2.length) {
 //  output.println(lines2[i]);
     String[] q = splitTokens(gcode2[selector-1].trim(), ", ");
    float f1 = float (q[2]) ;
    float f2 = float (q[4]) ;
    float f3 = float (q[6]) ;
    float f4 = float (q[8]) ;
    base = f1 ;
    J1 = f2 ;
    J2 = f3 ;
    speed = f4 ;
    cp5.getController("base").setValue(base);
    cp5.getController("J1").setValue(J1);
    cp5.getController("J2").setValue(J2);
    cp5.getController("speed").setValue(speed);
   port.write(gcode2[selector-1] + '\n');
 }
    

  }
  
  
  
  public void go_all()
  {
    if (!streaming){
      gcode = null; i = 0;  
    }
    
    gcode = loadStrings("actions.txt");
    if (gcode == null) return;
    streaming = true;
//    i=0;
    stream();  

  }
  
  void stream()
{
  if (!streaming) return;
  
  while (true) {
    if (i == gcode.length) {
      streaming = false;
      return;
    }
    
    if (gcode[i].trim().length() == 0) i++;
    else break;
  }
  
  println(gcode[i]);
  port.write(gcode[i] + '\n');
//    String[] q = splitTokens(gcode[i].trim(), ", ");
//    float f1 = float (q[2]) ;
//    float f2 = float (q[4]) ;
//    float f3 = float (q[6]) ;
//    float f4 = float (q[8]) ;
//    base = f1 ;
//    J1 = f2 ;
//    J2 = f3 ;
//    speed = f4 ;
//    cp5.getController("base").setValue(base);
//    cp5.getController("J1").setValue(J1);
//    cp5.getController("J2").setValue(J2);
//    cp5.getController("speed").setValue(speed);
//    selector=i+1;
//    down();
  i++;
  
}

void serialEvent(Serial p)
{
  String s = p.readStringUntil('\n');
  println(s.trim());
  
  if (s.trim().startsWith("ok")) stream();
  if (s.trim().startsWith("start")) RESET_ROBOT();
  if (s.trim().startsWith("error")) stream(); // XXX: really?
}
