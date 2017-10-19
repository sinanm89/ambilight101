#include <Adafruit_NeoPixel.h>

#define PIN 6
#define NUM_LED 50
#define NUM_DATA 152 // NUM_LED * 3 + 2
#define RECON_TIME 2000 // after x seconds idle time, send afk again.

// Parameter 1 = number of pixels in strip
// Parameter 2 = pin number (most are valid)
// Parameter 3 = pixel type flags, add together as needed:
//   NEO_KHZ800  800 KHz bitstream (most NeoPixel products w/WS2812 LEDs)
//   NEO_KHZ400  400 KHz (classic 'v1' (not v2) FLORA pixels, WS2811 drivers)
//   NEO_GRB     Pixels are wired for GRB bitstream (most NeoPixel products)
//   NEO_RGB     Pixels are wired for RGB bitstream (v1 FLORA pixels, not v2)
//Adafruit_NeoPixel strip = Adafruit_NeoPixel(NUM_LED, PIN, NEO_GRB + NEO_KHZ800);
Adafruit_NeoPixel strip = Adafruit_NeoPixel(NUM_LED, PIN, NEO_RGB + NEO_KHZ800);

uint8_t led_color[NUM_DATA];
int _index = 0;
unsigned long last_afk = 0;
unsigned long cur_time = 0;

void setup() {
    Serial.begin(9600);
    strip.begin();
    strip.show(); // Initialize all pixels to 'off'
    Serial.print("ozy"); // Send ACK string to hos
    for(;;){
        if (Serial.available() > 0) {
            led_color[_index++] = (uint8_t)Serial.read();

            if (_index >= NUM_DATA){
                Serial.write('y');
                last_afk =  millis();
                _index = 0;

                if ((led_color[0] == 'o') && (led_color[1] == 'z')){
                    // update LEDs
                    for(int i=0; i<NUM_LED; i++){
                       int led_index = i*3 + 2;
                       strip.setPixelColor(i, strip.Color(led_color[led_index], led_color[led_index+1], led_color[led_index+2]));
                    }
                strip.show();
        }}} else{
            cur_time = millis();
            if (cur_time - last_afk > RECON_TIME){
                Serial.write('y');
                strip.setPixelColor(22, strip.Color(0,150,0));
                strip.show();
                last_afk =  cur_time;
                _index = 0;
            }
        }
    }

}

void loop() {
}
