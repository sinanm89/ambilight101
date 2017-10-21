import java.awt.*;
import java.awt.image.*;
import processing.serial.*;

// using 50 RGB LEDs
static final int led_num_x = 15;
static final int led_num_y = 10;
static final int leds[][] = new int[][] {
  {8,9}, {7,9}, {6,9}, {5,9}, {4,9}, {3,9}, {2,9}, {1,9}, {0,9}, // Bottom edge, left half
  {0,8}, {0,7}, {0,6}, {0,5}, {0,4}, {0,3}, {0,2}, {0,1}, // Left edge
  {0,0}, {1,0}, {2,0}, {3,0}, {4,0}, {5,0}, {6,0}, {7,0}, {8,0}, {9,0}, {10,0}, {11,0}, {12,0}, {13,0}, {14, 0}, // Top edge
  {14,1}, {14,2}, {14,3}, {14,4}, {14,5}, {14,6}, {14,7}, {14,8}, // Right edge
  {14,9}, {13,9}, {12,9}, {11,9}, {10,9}, {9,9}  // Bottom edge, right half
};

static final short fade = 70;

static final int minBrightness = 120;

// Preview windows
int window_width;
int window_height;
// int preview_pixel_width;
// int preview_pixel_height;

int[][] pixelOffset = new int[leds.length][256];

// RGB values for each LED
short[][]  ledColor    = new short[leds.length][3],
      prevColor   = new short[leds.length][3];

byte[][]  gamma       = new byte[256][3];
byte[]    serialData  = new byte[ leds.length * 3 + 2];
int data_index = 0;

//creates object from java library that lets us take screenshots
Robot bot;

// bounds area for screen capture
Rectangle dispBounds;

// Monitor Screen information
GraphicsEnvironment     ge;
GraphicsConfiguration[] gc;
GraphicsDevice[]        gd;

Serial           port;

void setup(){

  int[] x = new int[16];
  int[] y = new int[16];

  // ge - Grasphics Environment
  ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
  // gd - Grasphics Device
  gd = ge.getScreenDevices();
  DisplayMode mode = gd[0].getDisplayMode();
  dispBounds = new Rectangle(0, 0, mode.getWidth(), mode.getHeight());

  // Preview windows
  //window_width      = mode.getWidth()/5;
  //window_height      = mode.getHeight()/5;
  //preview_pixel_width     = window_width/led_num_x;
  //preview_pixel_height   = window_height/led_num_y;

  // Preview window size
  //size(400, 400);

  //standard Robot class error check
  try   {
    bot = new Robot(gd[0]);
  }
  catch (AWTException e)  {
    println("Robot class not supported by your system!");
    exit();
  }

  float range, step, start;

  for(int i=0; i<leds.length; i++) { // For each LED...

    // Precompute columns, rows of each sampled point for this LED

    // --- for columns -----
    range = (float)dispBounds.width / led_num_x;
    // we only want 256 samples, and 16*16 = 256
    step  = range / 16.0;
    start = range * (float)leds[i][0] + step * 0.5;

    for(int col=0; col<16; col++) {
      x[col] = (int)(start + step * (float)col);
    }

    // ----- for rows -----
    range = (float)dispBounds.height / led_num_y;
    step  = range / 16.0;
    start = range * (float)leds[i][1] + step * 0.5;

    for(int row=0; row<16; row++) {
      y[row] = (int)(start + step * (float)row);
    }

    // ---- Store sample locations -----

    // Get offset to each pixel within full screen capture
    for(int row=0; row<16; row++) {
      for(int col=0; col<16; col++) {
        pixelOffset[i][row * 16 + col] = y[row] * dispBounds.width + x[col];
      }
    }

  }

  // Open serial port. this assumes the Arduino is the
  // first/only serial device on the system.  If that's not the case,
  // change "Serial.list()[0]" to the name of the port to be used:
  // you can comment it out if y  ou only want to test it without the Arduino
  println(Serial.list());
 //port = new Serial(this, "/dev/cu.usbmodem1421", 9600);
 port = new Serial(this, Serial.list()[0], 9600);

  // A special header expected by the Arduino, to identify the beginning of a new bunch data.
  serialData[0] = 'o';
  serialData[1] = 'z';

}

void draw(){

  //get screenshot into object "screenshot" of class BufferedImage
  BufferedImage screenshot = bot.createScreenCapture(dispBounds);

  // Pass all the ARGB values of every pixel into an array
  int[] screenData = ((DataBufferInt)screenshot.getRaster().getDataBuffer()).getData();

  data_index = 2; // 0, 1 are predefined header

  for(int i=0; i<leds.length; i++) {  // For each LED...

    int r = 0;
    int g = 0;
    int b = 0;

    for(int o=0; o<256; o++) {       //ARGB variable with 32 int bytes where
      int pixel = screenData[ pixelOffset[i][o] ];
      r += pixel & 0x00ff0000;
      g += pixel & 0x0000ff00;
      b += pixel & 0x000000ff;
    }     // Blend new pixel value with the value from the prior frame
    ledColor[i][0]  = (short)(((( r >> 24) & 0xff) * (255 - fade) + prevColor[i][0] * fade) >> 8);
    ledColor[i][1]  = (short)(((( g >> 16) & 0xff) * (255 - fade) + prevColor[i][1] * fade) >> 8);
    ledColor[i][2]  = (short)(((( b >>  8) & 0xff) * (255 - fade) + prevColor[i][2] * fade) >> 8);

    serialData[data_index++] = (byte)ledColor[i][0];
    serialData[data_index++] = (byte)ledColor[i][1];
    serialData[data_index++] = (byte)ledColor[i][2];

    // float preview_pixel_left  = (float)dispBounds.width  /5 / led_num_x * leds[i][0] ;
    // float preview_pixel_top    = (float)dispBounds.height /5 / led_num_y * leds[i][1] ;

    color rgb = color(ledColor[i][0], ledColor[i][1], ledColor[i][2]);
    // fill(rgb);
    // rect(preview_pixel_left, preview_pixel_top, preview_pixel_width, preview_pixel_height);

  }

    if(port != null) {

        // wait for Arduino to send data
        for(;;){

            if(port.available() > 0){
              println("available as fuck");
                int inByte = port.read();
                if (inByte == 'y')
                    break;
            }

        }
        port.write(serialData); // Issue data to Arduino

    }

  // Benchmark, how are we doing?
  println(frameRate);
  arraycopy(ledColor, 0, prevColor, 0, ledColor.length);

}