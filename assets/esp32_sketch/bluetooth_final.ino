/*
    Based on those sources
    
    Source: https://github.com/nkolban/esp32-snippets/blob/master/cpp_utils/tests/BLETests/Arduino/BLE_notify/BLE_notify.ino => Set up a BLE Server on ESP32
    Source: https://github.com/ThingPulse/esp8266-oled-ssd1306 => Connect the OLED Display to ESP32
    
    edited by Mark Linke

   Steps to Set Up the Bluetooth Server:
   
   1. Create a BLE server
   2. Create a BLE service
   3. Create a BLE characteristic on the service
   4. Create a BLE descriptor on the characteristic
   5. Start the service.
   6. Start advertising.
  
*/

#include <Wire.h>
#include "SSD1306.h" 

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

SSD1306  display(0x3c, 21, 22);

BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic = NULL;
bool deviceConnected = false;
bool oldDeviceConnected = false;
int value = 0;

// See the following for generating UUIDs:
// https://www.uuidgenerator.net/

#define SERVICE_UUID        "2d70aaee-2170-11ea-978f-2e728ce88125"
#define CHARACTERISTIC_UUID "2d70ad8c-2170-11ea-978f-2e728ce88125"


class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
      //BLEDevice::startAdvertising();
    };

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
    }
};



void setup() {
  Serial.begin(115200);
  display.init();

  // Create the BLE Device
  BLEDevice::init("ESP32 BloodSugar Measurement");

  // Create the BLE Server
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // Create the BLE Service
  BLEService *pService = pServer->createService(SERVICE_UUID);

  // Create a BLE Characteristic
  pCharacteristic = pService->createCharacteristic(
                      CHARACTERISTIC_UUID,
                      // BLECharacteristic::PROPERTY_READ  | 
                      // BLECharacteristic::PROPERTY_WRITE | 
                      BLECharacteristic::PROPERTY_NOTIFY 
                      // BLECharacteristic::PROPERTY_INDICATE
                    );

  // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.descriptor.gatt.client_characteristic_configuration.xml
  // Create a BLE Descriptor
  pCharacteristic->addDescriptor(new BLE2902());

  // Start the service
  pService->start();

  // Start advertising
  display.clear();
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(false);
  pAdvertising->setMinPreferred(0x0);  // set value to 0x00 to not advertise this parameter
  BLEDevice::startAdvertising();
  Serial.println("Waiting a client connection to notify...");
  display.drawString(0, 0, "Waiting a client connection to notify...");
  display.display();
}

void loop() {
    // notify changed value
    if (deviceConnected) {
        display.clear();
        int rando = random(40,500);
        char randoString[8];
        dtostrf(rando, 1, 2, randoString);
        pCharacteristic->setValue(randoString);
        pCharacteristic->notify();
        Serial.println("Current Value   " + String(rando));
        display.drawString(0, 0, "Aktueller Wert   " + String(rando));
        display.display();
        delay(3000);
        display.clear(); 
    }
    // disconnecting
    if (!deviceConnected && oldDeviceConnected) {
        delay(500); // give the bluetooth stack the chance to get things ready
        pServer->startAdvertising(); // restart advertising
        Serial.println("start advertising");
        oldDeviceConnected = deviceConnected;
    }
    // connecting
    if (deviceConnected && !oldDeviceConnected) {
        // do stuff here on connecting
        oldDeviceConnected = deviceConnected;
    }
}
