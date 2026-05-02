/**************************************************
 * BMO – CARDS DRAWER (Drawer 2) + RFID
 * BMO – CANDY DRAWER (Drawer 1) + SERVO DROP
 **************************************************/

#include <SPI.h>
#include <MFRC522.h>
#include <Servo.h>
#include <DHT.h>
Servo candyServo;
#define SERVO_PIN 9
#define VOLTAGE_PIN A1

const float VOLTAGE_DIVIDER_RATIO = 5.0;   // 0–25V module
const float REF_VOLTAGE = 5.0;
unsigned long lastVoltageRead = 0;
const unsigned long VOLTAGE_INTERVAL = 2000; // كل 2 ثانية
//wheels



// =================================================
// WHEELS H-BRIDGE PINS
// =================================================
#define ENA_W 7
#define ENB_W 8
#define IN1_W 26
#define IN2_W 27
#define IN3_W 28
#define IN4_W 29

// =================================================
// SPEED SETTINGS (DON'T CHANGE)
// =================================================
#define START_KICK 180
#define RUN_SPEED  90

// حركة دوران (مدة دوران تجريبية — عدّليها حسب روبوتك)
const int TURN_TIME_90 = 900;   // جرّبي 350-650ms حسب الواقع



#define TRIG_PIN 34
#define ECHO_PIN 35

#define OBSTACLE_DISTANCE 10   // سم





//
// =================================================
// RFID
// =================================================
#define SS_PIN 36
#define RST_PIN 37
MFRC522 rfid(SS_PIN, RST_PIN);

// =================================================
// DRAWER 2 – CARDS
// =================================================

bool emergencyLock = true;   // 🔐 حماية الجارور

#define IN1 22
#define IN2 23
#define ENA 5
#define OPEN_SW2 30
#define CLOSE_SW2 31

#define IR_DRAWER2 40  //  cards safety sensor (LOW = hand)
#define IR_DRAWER1 42  // موجود عندك بس مش رح نستعمله للcards

const unsigned long DRAWER_TIME   = 5000;  // 5s
const unsigned long HAND_TIMEOUT  = 2000;  // 2s after hand removed

bool cardsActive = false;
bool rfidEnabled = false;
unsigned long cardsOpenedAt = 0;
unsigned long handRemovedAt_cards = 0;
bool waitingToClose_cards = false;

// =================================================
// DRAWER 1 – CANDY (motor) + SERVO DROP
// =================================================
#define IN3 24
#define IN4 25
#define ENB 6
#define OPEN_SW1 32
#define CLOSE_SW1 33

bool candyDropped = false;
bool candyMode = false;
unsigned long candyOpenedAt = 0;

//gas
#define GAS_PIN A0
#define DHTPIN 38
#define DHTTYPE DHT11   // أو DHT22

DHT dht(DHTPIN, DHTTYPE);


unsigned long lastEnvRead = 0;
const unsigned long ENV_INTERVAL = 2000; // كل 2 ثانية
//gas






// =================================================
// SETUP
// =================================================
void setup() {
  Serial.begin(9600);
  delay(1500);
dht.begin();
  // ---- Drawer 2 ----
  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  pinMode(ENA, OUTPUT);
  pinMode(OPEN_SW2, INPUT_PULLUP);
  pinMode(CLOSE_SW2, INPUT_PULLUP);
  pinMode(IR_DRAWER2, INPUT_PULLUP);
  pinMode(IR_DRAWER1, INPUT_PULLUP);

  // ---- Drawer 1 ----
  pinMode(IN3, OUTPUT);
  pinMode(IN4, OUTPUT);
  pinMode(ENB, OUTPUT);
  pinMode(OPEN_SW1, INPUT_PULLUP);
  pinMode(CLOSE_SW1, INPUT_PULLUP);

  // ---- RFID ----
  pinMode(SS_PIN, OUTPUT);
  pinMode(RST_PIN, OUTPUT);
  digitalWrite(SS_PIN, HIGH);
  resetRFID();
  SPI.begin();
  rfid.PCD_Init();

  stopDrawer1();
  stopDrawer2();

  // ---- Servo ----
  candyServo.attach(SERVO_PIN);
  candyServo.write(125); // closed




  // ---- Wheels ----
  pinMode(ENA_W, OUTPUT);
  pinMode(ENB_W, OUTPUT);
  pinMode(IN1_W, OUTPUT);
  pinMode(IN2_W, OUTPUT);
  pinMode(IN3_W, OUTPUT);
  pinMode(IN4_W, OUTPUT);
  stopWheels();



pinMode(TRIG_PIN, OUTPUT);
pinMode(ECHO_PIN, INPUT);




  Serial.println("✅ BMO READY");
}

// =================================================
// LOOP
// =================================================
void loop() {
  handleSerial();

  handleCardsDrawer();   // ✅ Drawer 2 close + enable RFID
  handleCandyDrop();     // ✅ after servo drop, open candy drawer
  handleCandyDrawer();   // ✅ close candy drawer after 5s then IR check

  handleRFID();

  handleForcedOpening();
if (millis() - lastVoltageRead >= VOLTAGE_INTERVAL) {
  lastVoltageRead = millis();
 sendBatteryStatus();




}
//gas
if (millis() - lastEnvRead >= ENV_INTERVAL) {
  lastEnvRead = millis();
  sendEnvironmentStatus();}

//gas
avoidObstacleIfNeeded();

}

// =================================================
// SERIAL COMMANDS
// =================================================
void handleSerial() {
  if (!Serial.available()) return;

  String cmd = Serial.readStringUntil('\n');
  cmd.trim();

  // ---- Cards Mode ----
  if (cmd == "LEARN_CARDS") {
    Serial.println("📚 CARDS MODE START");
    openDrawer2();

    cardsActive = true;
    rfidEnabled = false;

    waitingToClose_cards = false;
    cardsOpenedAt = millis();
  }

  // ---- Candy Drawer manual ----
  if (cmd == "OPEN_CANDY") {
    Serial.println("🍬 OPEN CANDY");
    openDrawer1();
  }

  if (cmd == "CLOSE_CANDY") {
    Serial.println("🍬 CLOSE CANDY");
    closeDrawer1();
  }

  // ---- Drop candy ----
  if (cmd == "DROP_CANDY") {
    Serial.println("🍬 DROP CANDY");

    candyServo.write(180);
    delay(350);
    candyServo.write(125);

    candyDropped = true;
    return;
  }

  // ---- Wheels Commands ----
  if (cmd == "W_FWD") {
    Serial.println("🚗 WHEELS FORWARD");
    moveForwardWheels();
  }

  if (cmd == "W_STOP") {
    Serial.println("🛑 WHEELS STOP");
    stopWheels();
  }

  if (cmd == "W_RIGHT") {
    Serial.println("➡️ TURN RIGHT");
    moveRightWheels();
  }

  if (cmd == "W_LEFT") {
    Serial.println("⬅️ TURN LEFT");
   moveLeftWheels();
  }

  if (cmd.startsWith("W_STEP:")) {
    // مثال: W_STEP:400
    int ms = cmd.substring(7).toInt();
    Serial.print("👣 STEP FWD ");
    Serial.println(ms);
    stepForwardWheels(ms);
  }






}

// =================================================
// ✅ DRAWER 2 LOGIC (CARDS) — CLOSES + RFID ON
// =================================================
void handleCardsDrawer() {
  if (!cardsActive) return;

  unsigned long now = millis();

  // ⏱️ first 5 seconds: keep open (no IR check)
  if (now - cardsOpenedAt < DRAWER_TIME) {
    return;
  }

  // 👋 after 5 seconds: check IR_DRAWER2 (pin 40)
  bool hand = (digitalRead(IR_DRAWER1) == LOW);

  if (hand) {
    // hand inside -> don't start closing timer
    waitingToClose_cards = false;
    return;
  }

  // start closing timer once hand is not detected
  if (!waitingToClose_cards) {
    waitingToClose_cards = true;
    handRemovedAt_cards = now;
    return;
  }

  // close after HAND_TIMEOUT
  if (now - handRemovedAt_cards >= HAND_TIMEOUT) {
    closeDrawer2();
    cardsActive = false;

    rfidEnabled = true;
    Serial.println("RFID_ON");
  }
}

// =================================================
// ✅ CANDY DROP -> OPEN DRAWER 1 IMMEDIATELY
// =================================================
void handleCandyDrop() {
  if (!candyDropped) return;

  Serial.println("🍬 OPEN DRAWER AFTER CANDY");
  openDrawer1();

  candyOpenedAt = millis();
  candyMode = true;

  rfidEnabled = false;
  candyDropped = false;
}

// =================================================
// ✅ DRAWER 1 LOGIC (CANDY MODE) — WAIT 5s THEN IR CHECK
// =================================================
void handleCandyDrawer() {
  if (!candyMode) return;

  unsigned long now = millis();

  // first 5 seconds ignore IR
  if (now - candyOpenedAt < 5000) return;

  // after 5s check IR_DRAWER2 (pin 40) as you want
  bool hand = (digitalRead(IR_DRAWER2) == LOW);
  if (hand) return;

  closeDrawer1();
  candyMode = false;

  rfidEnabled = true;
  Serial.println("RFID_ON");
  Serial.println("🍬 CANDY DRAWER CLOSED");
}

// =================================================
// RFID
// =================================================
void handleRFID() {
  if (!rfidEnabled) return;

  if (!rfid.PICC_IsNewCardPresent()) return;
  if (!rfid.PICC_ReadCardSerial()) return;

  for (byte i = 0; i < rfid.uid.size; i++) {
    if (rfid.uid.uidByte[i] < 0x10) Serial.print("0");
    Serial.print(rfid.uid.uidByte[i], HEX);
  }
  Serial.println();

  rfid.PICC_HaltA();
  rfid.PCD_StopCrypto1();
  delay(800);
}

// =================================================
// DRAWER 2 MOTOR
// =================================================
void openDrawer2() {
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, HIGH);
  analogWrite(ENA, 180);
  while (digitalRead(CLOSE_SW2) == HIGH) {}
  stopDrawer2();
}

void closeDrawer2() {
  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, LOW);
  analogWrite(ENA, 180);
  while (digitalRead(OPEN_SW2) == HIGH) {}
  stopDrawer2();
}

void stopDrawer2() {
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, LOW);
  analogWrite(ENA, 0);
}

// =================================================
// DRAWER 1 MOTOR
// =================================================
void closeDrawer1() {
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, HIGH);
  analogWrite(ENB, 180);
  while (digitalRead(CLOSE_SW1) == HIGH) {}
  stopDrawer1();
}

void openDrawer1() {
  digitalWrite(IN3, HIGH);
  digitalWrite(IN4, LOW);
  analogWrite(ENB, 180);
  while (digitalRead(OPEN_SW1) == HIGH) {}
  stopDrawer1();
}

void stopDrawer1() {
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, LOW);
  analogWrite(ENB, 0);
}

// =================================================
// RFID RESET
// =================================================
void resetRFID() {
  digitalWrite(RST_PIN, LOW);
  delay(50);
  digitalWrite(RST_PIN, HIGH);
  delay(50);
}


// =================================================
// 🚨 ANTI-FORCE PROTECTION (SOFTWARE ONLY)
// =================================================
void handleForcedOpening() {
  if (!emergencyLock) return;

  // ❌ Drawer 2 (Cards) forced open
  if (!cardsActive && digitalRead(CLOSE_SW2) == LOW) {
    Serial.println("🚨 FORCED OPEN DETECTED: CARDS DRAWER");
    closeDrawer2();
  }

  // ❌ Drawer 1 (Candy) forced open
  if (!candyMode && digitalRead(OPEN_SW1) == LOW) {
    Serial.println("🚨 FORCED OPEN DETECTED: CANDY DRAWER");
    closeDrawer1();
  }

}





// =================================================
// 🔋 READ BATTERY VOLTAGE (NON-BLOCKING)
// =================================================
float readBatteryVoltage() {
  const int samples = 10;
  long sum = 0;

  for (int i = 0; i < samples; i++) {
    sum += analogRead(VOLTAGE_PIN);
    delay(5);
  }

  float avgRaw = sum / (float)samples;
  float voltageAtPin = (avgRaw * REF_VOLTAGE) / 1023.0;
  float batteryVoltage = voltageAtPin * VOLTAGE_DIVIDER_RATIO;

  return batteryVoltage;
}



int batteryPercentage(float voltage) {
  if (voltage >= 12.6) return 100;
  if (voltage >= 12.4) return 90;
  if (voltage >= 12.2) return 80;
  if (voltage >= 12.0) return 70;
  if (voltage >= 11.5 ) return 60;
  if (voltage >= 11.6) return 50;
  if (voltage >= 11.4) return 40;
  if (voltage >= 11.2) return 30;
  if (voltage >= 11.0) return 20;
  if (voltage >= 10.0 ) return 10;
  return 0;
}
void sendBatteryStatus() {
  float batteryVoltage = readBatteryVoltage();
  int percent = batteryPercentage(batteryVoltage);

  Serial.print("BATTERY:");
  Serial.print(batteryVoltage, 2);  // دقّة معقولة
  Serial.print(",");
  Serial.print(percent);
  Serial.println("%");
}
void sendEnvironmentStatus() {
  int gas = analogRead(GAS_PIN);
  float temp = dht.readTemperature();
  float hum  = dht.readHumidity();

  if (isnan(temp) || isnan(hum)) return;

  Serial.print("ENV:");
  Serial.print(temp, 1);
  Serial.print(",");
  Serial.print(hum, 1);
  Serial.print(",");
  Serial.println(gas);
}
void moveForwardWheels() {
  digitalWrite(IN1_W, HIGH);
  digitalWrite(IN2_W, LOW);
  digitalWrite(IN3_W, LOW);
  digitalWrite(IN4_W, HIGH);

  analogWrite(ENA_W, START_KICK);
  analogWrite(ENB_W, START_KICK);
  delay(200);

  analogWrite(ENA_W, RUN_SPEED);
  analogWrite(ENB_W, RUN_SPEED);
}

void stopWheels() {
  digitalWrite(IN1_W, LOW);
  digitalWrite(IN2_W, LOW);
  digitalWrite(IN3_W, LOW);
  digitalWrite(IN4_W, LOW);
  analogWrite(ENA_W, 0);
  analogWrite(ENB_W, 0);
}

void moveRightWheels() {
  // Left wheels forward, Right wheels backward
  digitalWrite(IN1_W, HIGH);
  digitalWrite(IN2_W, LOW);
  digitalWrite(IN3_W, HIGH);
  digitalWrite(IN4_W, LOW);
  analogWrite(ENA_W, START_KICK);
  analogWrite(ENB_W, START_KICK);
}


void moveLeftWheels() {
  // Left wheels backward, Right wheels forward
  digitalWrite(IN1_W, LOW);
  digitalWrite(IN2_W, HIGH);
  digitalWrite(IN3_W, LOW);
  digitalWrite(IN4_W, HIGH);
  analogWrite(ENA_W, START_KICK);
  analogWrite(ENB_W, START_KICK);
}


// تقدم “خفيف” خطوة خطوة (للاقتراب من الشخص)
void stepForwardWheels(int ms) {
  moveForwardWheels();
  delay(ms);
  stopWheels();
}
long readUltrasonic() {
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);

  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  long duration = pulseIn(ECHO_PIN, HIGH, 25000); // timeout
  if (duration == 0) return 999; // ما في قراءة

  long distance = duration * 0.034 / 2;
  return distance;
}
void avoidObstacleIfNeeded() {
  long dist = readUltrasonic();

  if (dist < OBSTACLE_DISTANCE) {
    Serial.println("🚧 OBSTACLE");

    stopWheels();
    delay(200);

    // لف يمين أولًا
    moveRightWheels();

    // إذا لسا في عائق، لف يسار
    dist = readUltrasonic();
    if (dist < OBSTACLE_DISTANCE) {
      moveLeftWheels();
      moveLeftWheels();  // لف أكتر
    }

    stopWheels();
  }
}
