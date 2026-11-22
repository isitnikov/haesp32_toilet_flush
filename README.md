# Toilet Flush with Home Assistant

The **Flush** button (`Змити` in the firmware) in Home Assistant triggers an MG90S servo through ESPHome. The servo sits under the tank lid and briefly lifts the flush valve chain. After a short pause, the servo horn returns, giving the chain enough slack for the valve to close. The original handle remains available for manual flushing. The button works without a trigger sensor.

## Parts

| Part | Purpose |
| --- | --- |
| **ESP8266 D1 mini** | Wi-Fi controller running ESPHome. The firmware uses the `d1_mini` board setting. |
| **MG90S**, servo horn, and horn screw | The horn pulls the flush valve chain. |
| Two screws for the MG90S mounting tabs | Fasten the servo to the printed clip. The model has 2.2 mm diameter holes spaced 27.5 mm apart on center. Check these dimensions against your servo. |
| Short chain or linkage with a hook | Connects the servo horn to the flush valve while allowing the original handle to lift it. |
| **5 V / 2 A** power supply | Powers the D1 mini and servo in parallel. |
| Wire, splitters for 5 V and GND, and a USB cable for flashing | Connect the power supply, controller, and servo. Use a three-wire servo extension if needed. |
| Printed clip and two enclosure halves | The clip holds the servo on the tank rim. The enclosure protects the board from accidental contact and keeps the wiring in place. |

## 3D models

| File | Part |
| --- | --- |
| [MG90S-tank-clip.scad](3d/MG90S-tank-clip.scad) | Parametric clip that slides over the ceramic tank rim, with the servo pocket facing into the tank. |
| [D1-mini-base-cable.stl](3d/D1-mini-base-cable.stl) | D1 mini enclosure base with a notch open at the top for a flat cable. The nominal notch dimensions are 4.5 × 1.8 mm. |
| [D1-mini-cap-cable.stl](3d/D1-mini-cap-cable.stl) | Lid with a matching notch. Lay the cable in the notch in the base before closing the enclosure. |

The D1 mini enclosure base was adapted from [this Thingiverse model](https://www.thingiverse.com/thing:6840294).

## Mounting

1. **Size the clip to the tank.** Remove the lid and measure the rim at its thickest point within the depth covered by the clip. In OpenSCAD, adjust `rim_thickness` (10 mm by default) and, if needed, `rim_clearance` (0.8 mm). Check the space under the lid for the bridge (`bridge_thickness`, 2 mm) and the dimensions of the cable groove (5 × 1.2 mm).
2. **Test the fit.** Set `part = "fit_check"`, render with **F6**, and export an STL. Test the fit beside the flush mechanism, checking that the lid seats properly and the chain can move freely. Then set `part = "bracket"` and export the full part.
3. **Install the MG90S.** Feed the connector through the opening at the top of the pocket. Insert the servo from the inside of the tank with its shaft pointing toward the center of the tank, then install two screws through its mounting tabs. Slide the clip over the rim with the pocket inside the tank. Lay the cable in the groove over the rim and check that the lid sits flat without pinching the cable. Keep the servo above the waterline and away from direct splashes. Place the D1 mini enclosure and power supply outside the tank in a dry location.
4. **Set the horn position and attach the linkage.** Run a cycle with the chain disconnected to check the direction and endpoints. With the servo at its home position, attach the horn so its travel lifts the valve. Leave some slack in the chain so the valve can reseat and the original handle can move freely even when power is off.
5. **Test the flush.** Start with a small travel angle and increase it until the valve opens reliably. Check that the horn and linkage clear the float, tank wall, and lid, and that the servo stays clear of its mechanical stops.

## Wiring

| From | To |
| --- | --- |
| Power supply `+5V` | D1 mini `5V` pin and MG90S red wire |
| Power supply `GND` | D1 mini `GND` pin and MG90S brown wire |
| D1 mini `D5` (`GPIO14`) | MG90S orange signal wire |

These colors are typical for the MG90S. Verify the wiring for your servo before connecting it. The board and servo share a common ground. Feed the servo directly from the power supply through a splitter. The firmware uses a PWM frequency of 50 Hz.

## Flashing and setup

1. Add [toilet-flush.yaml](toilet-flush.yaml) to ESPHome. Set `wifi_ssid`, `wifi_password`, `toilet_flush_api_key`, and `toilet_flush_ota_password` in `secrets.yaml`.
2. For the initial USB flash, disconnect the external 5 V supply and the servo. After flashing, unplug USB, reconnect everything as shown in the wiring table, and add the **Toilet Flush** device to the ESPHome integration in Home Assistant.
3. Adjust the servo travel in Home Assistant. The **Flush** button runs one cycle and can also be triggered by a Home Assistant automation.

| Setting | Default |
| --- | --- |
| Home angle | 90° |
| Travel direction | Toward the larger angle |
| Travel angle | 15° |
| Lift time | 0.6 s |
| Hold time | 0.5 s |
| Return time | 0.6 s |

Settings persist across restarts. The angles are nominal, so use the actual horn travel to guide adjustments. The target is the home angle plus or minus the travel angle, depending on the selected direction. If the target falls outside 0–180°, the firmware skips the cycle and logs a warning. Additional button presses during a flush are ignored. PWM output stops after the servo returns to its home position.
