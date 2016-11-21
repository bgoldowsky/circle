int slices = 8;

int screenheight = 500;
int screenwidth = 750;

PFont largeFont;
PFont smallFont;
  
float buttonarea = 100;
float buttony = screenheight - buttonarea/2;

int nButtons = 7;
Button[] button = new Button[nButtons];

float diam = 300; // diameter
float edgewidth = 10;
float rad = diam/2; // radius

float circlex = screenwidth/2;
float circley = (screenheight-buttonarea)/2;

int explosion = 0;
int xmotion = 0;
int xms = 30;
int ymotion = 0;
int yms = 20;

boolean go = false;
int step;

void setup() {
  noLoop();
  // size() with variables doesn't work in JS mode
  // size(screenwidth, screenheight);
  size(750, 500);
  frameRate(20);
  smooth();
  
  largeFont = loadFont("UMingCN-48.vlw");
  smallFont = loadFont("UMingCN-32.vlw");
  textAlign(CENTER, CENTER);
  rectMode(CENTER);
  ellipseMode(CENTER);
  strokeCap(SQUARE);
  
  // Button 0: plus
  button[0] = new Button("+");
  button[0].x = 420;
  button[0].width = 40;
  button[0].height = 40;
  button[0].incr = 1;

  // Button 1: minus
  button[1] = new Button("-");
  button[1].x = 470;
  button[1].width = 40;
  button[1].height = 40;
  button[1].incr = -1;
  
  // Button 2: go/stop/back
  button[2] = new GoButton();
  button[2].x = 100;
  button[2].width = 100;
  
  // Buttons 3, 4, 5: set number of slices
  button[3] = new CircleButton("8");
  button[3].x = 550;
  button[3].value = 8;

  button[4] = new CircleButton("16");
  button[4].x = 620;
  button[4].value = 16;

  button[5] = new CircleButton("50");
  button[5].x = 690;
  button[5].value = 50;
  
  // Button 6: help
  button[6] = new HelpButton();
  button[6].x = 690;
  button[6].y = 50;

  drawSlices();
}

void drawBasics() {
  background(#FFFFFF);
  strokeWeight(1);

  for (int i=0; i<nButtons; i++) {
    button[i].paint();
  } 
  
  sliceLabel();
}

void sliceLabel() {
  float slice_label_x = 350;
  strokeWeight(1);
  fill(#FFFFFF);
  rect(slice_label_x, buttony, 80, 50);
  fill(#711B1B);
  textFont(largeFont);
  text(slices, slice_label_x, buttony);
  redraw();
}

void resetVars() {
  noLoop();
  resetMatrix();
  go = false;
  step = 1;
  explosion = 0;
  xmotion = 0;
  ymotion = 0;
}  

void reset (int n) {
  resetVars();
  if (n>1)
    slices = n;
  drawSlices();
}

void drawSlices() {
  drawBasics();
  strokeWeight(1);
  fill(#000000);
  for (int i=0; i<slices; i++)
    drawSlice(i);
}

void moveSlices() {
  explosion = 0;
  loop();  
}

void drawSlice(int i) {
  pushMatrix();
  
  boolean isTop = i>=(float)slices/2;
  
  float startangle = TWO_PI * (i+.5)/slices;
  float finalangle = isTop ? PI*3/2 : PI/2;
  float midangle = ((xms-xmotion)*startangle + xmotion*finalangle) / xms;
  
  // explode (step 3)
  translate(explosion*cos(midangle), explosion*sin(midangle));
  
  // move and rotate (step 4)
  if (isTop) {
    translate(sin(PI/slices)*diam*xmotion/xms*(i+.25-3*slices/4.0), 0);
  } else {
    translate(sin(PI/slices)*diam*xmotion/xms*(slices/4.0-i-.25), 0);
  }
  
  // converge (step 5)
  // move up/down by diam/4 times cosine factor to avoid overlap when angles are large
  translate(0, diam/4 * cos(PI/slices) * ymotion/yms * (isTop ? 1 : -1));
  
  float angle1 = midangle - PI/slices;
  float angle2 = midangle + PI/slices;

  fill(#FABA00);
  stroke(#711B1B);
  strokeWeight(edgewidth);
  arc(circlex, circley, diam-edgewidth, diam-edgewidth, angle1, angle2);

  stroke(#711B1B);
  strokeWeight(2);
  line(circlex, circley, circlex+rad*cos(angle1), circley+rad*sin(angle1));
  line(circlex, circley, circlex+rad*cos(angle2), circley+rad*sin(angle2));
  popMatrix();
}

void draw() {
  if (step == 6) {
    drawSlices();
    noLoop();
  }
  
  if (step == 5) {
    ymotion ++;
    drawSlices();
    if (ymotion >= yms) {
      step = 6;
    }
  }
  
  if (step == 4) {
    if (explosion>0) // unexplode
      explosion --;
    xmotion ++;
    drawSlices();
    if (xmotion >= xms) {
      step = 5;
    }
  }
  
  if (step == 3) {
    explosion ++;
    drawSlices();
    if (explosion >= 10) {
      step = 4;
    }
  }
  
}

void mouseClicked() {
  //System.out.println("Mouse clicked: " + mouseX + ", " + mouseY);
  noLoop();
  for (int i=0; i<nButtons; i++) {
    if (button[i].checkclick())
      return;
  }
}

////////////////////////////////////////////////////////////

class Button {
 
 float x;
 float y = buttony;
 float width = 50;
 float height = 50;
 
 String txt;
 
 // set if incrementing
 int incr = 0;
 // set if value should be simply set
 int value = 0;
 
 Button (String txt) {
   this.txt = txt;
 }

 void paint() {
   fill(#711B1B);
   rect(x, y, width, height);
   fill(#FFFFFF);
   textFont(largeFont);
   text(txt, x, y, width, height);
 }
 
 boolean checkclick() {
   if (abs(mouseX-x)<width/2 && abs(mouseY-y)<height/2) {
      click();
      return true;
   }
   return false;
 }
 
 void click() {
   if (value != 0)
     reset (value);
   else 
     reset(slices+incr);
 }
 
}

//////////////////////////////////////////////////////////////////

class CircleButton extends Button {
  
  CircleButton(String txt) {
    super(txt);
  }
  
  void paint() {
    fill(#711B1B);
    ellipse(x, y, width, height);
    fill(#FFFFFF);
    textFont(smallFont);
    text(txt, x, y, width, height);
  }

  boolean checkclick() {
    if (sqrt((mouseX-x)*(mouseX-x) + (mouseY-y)*(mouseY-y))<width/2) {
      click();
      return true;
    }
    return false;
  }
  
}

//////////////////////////////////////////////////////////////////

class GoButton extends Button {
  
  GoButton() {
    super("");
  }
  
  void paint() {
    fill(#711B1B);
    rect(x, y, width, height);
    fill(#FFFFFF);
    textFont(largeFont);
    text(go? (step==6 ? "Back" : "Stop") : "Go", x, y, width, height);
  }
  
  void click() {
    if (!go) {
      go = true; 
      step = 3;
      moveSlices();
    } else {
      go = false;
      reset(slices);
    }
  }
 
}
  
//////////////////////////////////////////////////////////////////

class HelpButton extends CircleButton {
  
  HelpButton() {
    super("?");
  }
  
  void click() {
    step = 1;
    resetVars();
    drawBasics();
    textFont(smallFont);
    textAlign(LEFT);
    text("You can measure the radius and circumference of a circle. " +
    "You'll find the circumference is 2·π·the radius.\n" +
    "What is the area of the circle?\n" +
    "Answer this by cutting the circle up\n" +
    "and rearranging it into something like a rectangle.\n" +
    "What is the width and height of the rectangle?" ,
      screenwidth/2, screenheight/2, 
      screenwidth-100, screenheight-buttonarea-100);
      
    textAlign(CENTER, CENTER);
  }
}
  

  

