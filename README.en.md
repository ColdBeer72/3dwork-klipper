* * *

## description: Pack of macros, settings and other utilities for Klipper

# 3Dwork Clipper Bundle

[![](<../../.gitbook/assets/image (1986).png>)- English](https://klipper-3dwork-io.translate.goog/klipper/mejoras/3dwork-klipper-bundle?_x_tr_sl=es&_x_tr_tl=en&_x_tr_hl=es&_x_tr_pto=wapp)

{% hint style="danger" %}<mark style="color:red;">**GUIDE IN PROCESS!!! Although the macros are fully functional, they are under continuous development.**</mark>

<mark style="color:orange;">**Use them at your own risk!!!**</mark>{% endint %}

<details>

<summary>Changelog</summary>

12/07/2023 - Added support to automate the creation of Bigtreetech electronic firmware

</details>

From**Your excuses**We have compiled and fine-tuned a set of macros, machine and electronic settings, as well as other tools for simple and powerful Klipper management.

Much of this package is based on[**Rats**](https://os.ratrig.com/)improving the parts that we think are interesting, as well as other contributions from the community.

## Installation

To install our package for Klipper we will follow the following steps

### Download from the repository

We will connect to our host via SSH and issue the following commands:

```bash
cd ~/printer_data/config
git clone https://github.com/3dwork-io/3dwork-klipper.git
```

{% hint style="warning" %}
If your Klipper configuration directory is customized, remember to adjust the first command appropriately for your installation.
{% endhint %}

{% hint style="info" %}
In new installations:

Since Klipper does not allow access to macros until it has a correct printer.cfg and connects to an MCU, we can "trick" Klipper with the following steps that will allow us to use the macros in our bundle to, for example, launch the Klipper firmware compilation macro if we use compatible electronics:

-   We make sure we have our[host as second MCU](raspberry-como-segunda-mcu.md)
-   Next we will add a printer.cfg, remember that these steps are for a clean installation where you do not have any printer.cfg and you want to launch the macro to create firmware, like the one you can see below:

```django
[mcu]
serial: /tmp/klipper_host_mcu

[printer]
kinematics: none
max_velocity: 1
max_accel: 1

[gcode_macro PAUSE]
rename_existing: PAUSE_BASE
gcode:
  M118 Please install a config first!

[gcode_macro RESUME]
rename_existing: RESUME_BASE
gcode:
  M118 Please install a config first!

[gcode_macro CANCEL_PRINT]
rename_existing: CANCEL_BASE
gcode:
  M118 Please install a config first!
  
[idle_timeout]
gcode:
  {% raw %}
{% if printer.webhooks.state|lower == 'ready' %}
    {% if printer.pause_resume.is_paused|lower == 'false' %}
      M117 Idle timeout reached
      TURN_OFF_HEATERS
      M84
    {% endif %}
  {% endif %}
{% endraw %}
# 2 hour timeout
timeout: 7200

[temperature_sensor raspberry_pi]
sensor_type: temperature_host

[skew_correction]

[input_shaper]

[virtual_sdcard]
path: ~/printer_data/gcodes

[display_status]

[pause_resume]

[force_move]
enable_force_move: True

[respond]
```

With this we can start Klipper to give us access to our macros.
{% endhint %}

### Using Moonraker to always be up to date

Thanks to Moonraker we can use its update_manager to be able to stay up to date with the improvements that we may introduce in the future.

From Mainsail/Fluidd we will edit our moonraker.conf (it should be at the same height as your printer.cfg) and we will add to the end of the configuration file:

```django
[include 3dwork-klipper/moonraker.conf]
```

{% hint style="warning" %}<mark style="color:orange;">**Remember to do the installation step beforehand, otherwise Moonraker will generate an error and will not be able to start.**</mark>

**On the other hand, if the directory of your Klipper configuration is customized, remember to adjust the path appropriately for your installation.**{% endint %}

## Macros

We have always commented that RatOS is one of the best Klipper distributions, with support for Raspberry and CB1 modules, largely due to its modular configurations and its great macros.

Some added macros that will be useful to us:

### **General Purpose Macros**

| Macro                                                                                  | Description                                                                                                                                                                                                                 |
| -------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **MAYBE_HOME**                                                                         | It allows us to optimize the homing process only by performing it on those axes that are not homing.                                                                                                                        |
| **PAUSE**                                                                              | Through the related variables it allows us to manage a pause with a more versatile head parking than normal macros.                                                                                                         |
| <p><strong>SET_PAUSE_AT_LAYER</strong><br><strong>SET_PAUSE_AT_NEXT_LAYER</strong></p> | <p>A very useful macro that Mainsail integrates into its UI to be able to pause on demand in a specific layer... in case we forgot when laminating.<br>We also have another one to execute the pause on the next layer.</p> |
| **RESUME**                                                                             | Improved since it allows us to detect if our nozzle is not at the extrusion temperature in order to solve it before it shows an error and damages our printing.                                                             |
| **CANCEL_PRINT**                                                                       | Which allows the use of the rest of the macros to perform a print cancellation correctly.                                                                                                                                   |

-   **Paused on layer change**, some very interesting macros that allow us to pause a layer or launch a command when starting the next layer. \\![](<../../.gitbook/assets/image (143).png>)![](<../../.gitbook/assets/image (1003).png>)\\
    Additionally, another advantage of them is that they are integrated with Mainsail, so we will have new functions in our UI as you can see below:\\![](<../../.gitbook/assets/image (725).png>)![](<../../.gitbook/assets/image (1083).png>)

### **Print management macros**

<table><thead><tr><th width="170">Macro</th><th>Descripción</th></tr></thead><tbody><tr><td><strong>START_PRINT</strong></td><td>Nos permitirá poder iniciar nuestras impresiones de una forma segura y al estilo Klipper. Dentro de esta encontraremos algunas funciones interesantes como:<br>- precalentado de nozzle inteligente en el caso de contar con sensor probe<br>- posibilidad de uso de z-tilt mediante variable<br>- mallado de cama adaptativo, forzado o desde una malla guardada<br>- línea de purga personalizable entre normal, línea de purgado adaptativa o gota de purgado<br>- macro segmentada para poder personalizarse tal como os mostraremos más adelante</td></tr><tr><td><strong>END_PRINT</strong></td><td>Macro de fin de impresión donde también disponemos de segmentación para poder personalizar nuestra macro. También contamos con aparcado dinámico del cabezal.</td></tr></tbody></table>

-   **Adaptive bed mesh**Thanks to the versatility of Klipper we can do things that today seem impossible... an important process for printing is having a mesh of deviations from our bed that allows us to correct these to have perfect adhesion of the first layers. \\
    On many occasions we do this meshing before printing to ensure that it works correctly and this is done on the entire surface of our bed.\\
    With adaptive bed meshing, this will be done in the printing area, making it much more precise than the traditional method... in the following screenshots we will see the differences between a traditional mesh and an adaptive one.\\![](<../../.gitbook/assets/image (1220).png>)![](<../../.gitbook/assets/image (348).png>)

### **Filament management macros**

Set of macros that will allow us to manage different actions with our filament, such as loading or unloading it.

| Macro               | Description                                                                                         |
| ------------------- | --------------------------------------------------------------------------------------------------- |
| **M600**            | It will allow us compatibility with the M600 gcode normally used in laminators for filament change. |
| **UNLOAD_FILAMENT** | Configurable through the variables, it will allow us for assisted filament discharge.               |
| **LOAD_FILAMENT**   | Same as the previous one but related to the filament load.                                          |

### <mark style="color:orange;">**Filament spool management macros (Spoolman)**</mark>

{% hint style="warning" %}**SECTION IN PROCESS!!!**{% endint %}

[**Spoolman**](https://github.com/Donkie/Spoolman)is a filament spool manager that is integrated into Moonraker and that allows us to manage our filament stock and availability.

<figure><img src="../../.gitbook/assets/image (1990).png" alt=""><figcaption></figcaption></figure>

We are not going to go into the installation and configuration of this since it is relatively simple using the[**instructions from your Github**](https://github.com/Donkie/Spoolman)**,**in any case**we advise you to use Docker**for simplicity and remember**activate settings in Moonraker**required:

{% code title="moonraker.conf" %}

```django
[spoolman]
server: http://192.168.0.123:7912
#   URL to the Spoolman instance. This parameter must be provided.
sync_rate: 5
#   The interval, in seconds, between sync requests with the
#   Spoolman server.  The default is 5.
```

{%endcode%}

| Macro              | Description                                                 |
| ------------------ | ----------------------------------------------------------- |
| SET_ACTIVE_SPOOL   | It allows us to indicate which is the ID of the coil to use |
| CLEAR_ACTIVE_SPOOL | It allows us to reset the active coil                       |

The ideal in each case would be to add to our laminator,**in the filament gcodes for each coil the call to this**, and remember**change its ID once consumed**to be able to keep track of what remains of filament in it!!!

<figure><img src="../../.gitbook/assets/image (1991).png" alt=""><figcaption></figcaption></figure>

### <mark style="color:orange;">**Print surface management macros**</mark>

{% hint style="warning" %}**SECTION IN PROCESS!!!**{% endint %}

It is usually normal that we have different printing surfaces depending on the finish we want to have or the type of filament.

This set of macros, created by[Garethky](https://github.com/garethky), they will allow us to have control of these and especially the correct adjustment of ZOffset in each of them in the style that we have in Prusa machines. Below you can see some of its functions:

-   We can store the number of printing surfaces we want, each one having a unique name
-   each printing surface will have its own ZOffset
-   If we make Z adjustments during a print (Babystepping) from our Klipper, this change will be stored in the surface enabled at that moment

On the other hand we have some**requirements to implement it**<mark style="color:orange;">**(it will try to add in the PRINT logic_START of the bundle in the future by activating this function by variable and creating a previous and subsequent user macro to be able to enter user events)**</mark>:

-   the use of\[save_variables], in our case we will use~/variables.cfg to store the variables and that is already inside the cfg of these macros. \\
    This will automatically create a variables file for us_build_sheets.cfg where it will save our variables on disk.

{% code title="Example of variables config file" %}

```django
[Variables]
build_sheet flat = {'name': 'flat', 'offset': 0.0}
build_sheet installed = 'build_sheet textured_pei'
build_sheet smooth_pei = {'name': 'Smooth PEI', 'offset': -0.08999999999999997}
build_sheet textured_pei = {'name': 'Textured PEI', 'offset': -0.16000000000000003}
```

{%endcode%}

-   we must include a call to APPLY_BUILD_SHEET_ADJUSTMENT in our PRINT_START to be able to apply the ZOffset of the selected surface
-   It is important that for the previous macro, APPLY_BUILD_SHEET_ADJUSTMENT, to work correctly we have to add a SET_GCODE_OFFSET Z=0.0 just before calling APPLY_BUILD_SHEET_ADJUSTMENT

```django
# Load build sheet
SHOW_BUILD_SHEET                ; show loaded build sheet on console
SET_GCODE_OFFSET Z=0.0          ; set zoffset to 0
APPLY_BUILD_SHEET_ADJUSTMENT    ; apply build sheet loaded zoffset
```

On the other hand, it is interesting to have macros to activate one surface or another or even pass it as a parameter from our laminator so that with different printer or filament profiles we can load one or the other automatically:

{% hint style="warning" %}
It is important that the value in NAME="xxxx" matches the name we gave when installing our printing surface
{% endhint %}

{% code title="printer.cfg or include cfg" %}

```django
## Every Build Plate you want to use needs an Install Macro
[gcode_macro INSTALL_TEXTURED_SHEET]
gcode:
    INSTALL_BUILD_SHEET NAME="Textured PEI"

[gcode_macro INSTALL_SMOOTH_SHEET]
gcode:
    INSTALL_BUILD_SHEET NAME="Smooth PEI"
    
[gcode_macro INSTALL_SMOOTH_GAROLITE_SHEET]
gcode:
    INSTALL_BUILD_SHEET NAME="Smooth Garolite"
```

{%endcode%}

Also in the case of having KlipperScreen we can add a specific menu to manage the loading of the different surfaces, where we will include a call to the macros previously created for the loading of each surface:

{% code title="~/printer_data/config/KlipperScreen.conf" %}

```django
[menu __main actions build_sheets]
name: Build Sheets
icon: bed-level

[menu __main actions build_sheets smooth_pei]
name: Smooth PEI
method: printer.gcode.script
params: {"script":"INSTALL_SMOOTH_PEI_SHEET"}

[menu __main actions build_sheets textured_pei]
name: Textured PEI
method: printer.gcode.script
params: {"script":"INSTALL_TEXTURED_PEI_SHEET"}

[menu __main actions build_sheets smooth_garolite]
name: Smooth Garolite
method: printer.gcode.script
params: {"script":"INSTALL_SMOOTH_GAROLITE_SHEET"}
```

{%endcode%}

| Macro                        | Description |
| ---------------------------- | ----------- |
| INSTALL_BUILD_SHEET          |             |
| SHOW_BUILD_SHEET             |             |
| SHOW_BUILD_SHEETS            |             |
| SET_BUILD_SHEET_OFFSET       |             |
| RESET_BUILD_SHEET_OFFSET     |             |
| SET_GCODE_OFFSET             |             |
| APPLY_BUILD_SHEET_ADJUSTMENT |             |

### **Machine configuration macros**

| Macro                                                                                        | Description                                                                                                                                                                                                                                         |
| -------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **COMPILE_FIRMWARE**                                                                         | <p>With this macro we can compile the Klipper firmware in a simple way, have the firmware accessible from the UI for greater simplicity and be able to apply it to our electronics.<br>Here you have more details on the supported electronics.</p> |
| **CALCULATE_BED_MESH**                                                                       | An extremely useful macro to calculate the area for our mesh because sometimes it can be a complicated process.                                                                                                                                     |
| <p><strong>PID_ALL</strong><br><strong>PID_EXTRUDER</strong><br><strong>PID_BED</strong></p> | These macros, where we can pass the temperatures to the PID in the form of parameters, will allow us to perform the temperature calibration in an extremely simple way.                                                                             |
| <p><strong>TEST_SPEED</strong><br><strong>TEST_SPEED_DELTA</strong></p>                      | Companion's original macro[Ellis](https://github.com/AndrewEllis93)They will allow us in a fairly simple way to test the speed at which we can move our machine precisely and without loss of steps.                                                |

-   **Compiled firmware for supported electronics**, to facilitate the process of creating and maintaining our Klipper firmware for our MCUs we have the COMPILE macro_FIRMWARE that when executed, we can use our electronics as a parameter to do only this, Klipper will compile for all the electronics supported by our bundle:\\![](<../../.gitbook/assets/image (1540).png>)\\
    We will find these easily accessible from our web UI in the firmware directory_binaries in our MACHINE tab (if we use Mainsail):\\![](../../.gitbook/assets/telegram-cloud-photo-size-4-6019366631093943185-y.jpg)\\
    Below is the list of supported electronics:

{% hint style="warning" %}**IMPORTANT!!!**

-   These scripts are prepared to work on a Raspbian system with pi user, if this is not your case you will have to adapt it.
-   The firmwares are generated for use with a USB connection, which is always what we recommend. Furthermore, the USB mounting point is always the same, so your MCU connection configuration will not change if they are generated with our macro/script.
-   **In order for Klipper to execute shell macros, an extension must be installed, thanks to the companion**[**arcsine**](https://github.com/Arksine)**, that allows it.**

        <mark style="color:green;">**Dependiendo de la distro de Klipper usada pueden venir ya habilitadas.**</mark>

        ![](<../../.gitbook/assets/image (770).png>)

        La forma más sencilla es usando [**Kiauh**](../instalacion/#instalando-kiauh) donde encontraremos en una de sus opciones la posibilidad de instalar esta extensión:

        ![](../../.gitbook/assets/telegram-cloud-photo-size-4-5837048490604215201-x\_partial.jpg)

        También podemos realizar el proceso a mano copiaremos manualmente el plugin para Klipper[ **gcode\_shell\_extension**](https://raw.githubusercontent.com/Rat-OS/RatOS/master/src/modules/ratos/filesystem/home/pi/klipper/klippy/extras/gcode\_shell\_command.py) dentro de nuestro directorio _**`~/klipper/klippy/extras`**_ usando SSH o SCP y reiniciamos Klipper.

    {% endint %}

{%tabs%}
{%tab title="Bigtreetech"%}
| Electronics | Parameter name to use in macro |
\| ------------------ \| ----------------------------------- \|
| Blanket E3 EZ | btt-from-e3ez |
| Blanket M4P | btt-from-m4p |
| Blanket M4P v2.2 | btt-from-m4p-22 |
| Blanket M8P | btt-from-m8p |
| Blanket M8P v1.1 | btt-from-m8p-11 |
| Octopus Max EZ | btt-octopus-max-ez |
| Octopus Pro (446) | btt-octopus-pro-446 |
| Octopus Pro (429) | btt-octopus-pro-429 |
| Octopus Pro (H723) | btt-octopus-pro-h723 |
| Octopus v1.1 | btt-octopus-11 |
| Octopus v1.1 (407) | btt-octopus-11-407 |
| SKR Pro v1.2 | skr_pro_12 |
| SEK 3 | btt_skr_3 |
| SKR 3 (H723) | btt-skr-3-h723 |
| SKR 3 EZ | btt-skr-3-ez |
| SKR 3 EZ (H723) | btt-skr-3-ez-h723 |
| SEK 2 (429) | btt-skr-2-429 |
| SKR 2 (407) | btt-skr-2-407 |
| SKR RAT | btt-skrat-10 |
| SKR 1.4 Turbo | btt-skr-14-turbo |
| SKR Mini E3 v3 | btt_skr_mini_ez_30              |

| Toolhead (CAN) | Parameter name to use in macro |
| -------------- | ------------------------------ |
| EBB42 v1       | btt_ebb42_10                   |
| EBB36 v1       | btt_ebb36_10                   |
| EBB42 v1.1     | btt_ebb42_11                   |
| EBB36 v1.1     | btt_ebb36_11                   |
| EBB42 v1.2     | btt_ebb42_12                   |
| EBB36 v1.2     | btt_ebb36_12                   |

{% end loss %}

{% tab title="MKS/ZNP" %}
| Electronics | Parameter name to use in macro |
\| -------------------- \| ----------------------------------- \|
| ZNP Robin Nano DW v2 | znp_robin_nano_dw_v2 |
{% endtab %}

{% tab title="Mellow" %}
| Toolhead (CAN) | Parameter name to use in macro |
\| ----------------- \| ----------------------------------- \|
| Mellow FLY SHT 42 | mellow_fly_sht_42                |
| Mellow FLY SHT 36 | mellow_fly_sht_36 |
{% end loss %}

{% tab title="Fysetc" %}
| Electronics | Parameter name to use in macro |
\| ------------- \| ----------------------------------- \|
| Fysetc Spider | fysetc_spider                      |
{% endtab %}
{% endtabs %}

### Adding 3Dwork macros to our installation

From our interface, Mainsail/Fluidd, we will edit our printer.cfg and add:

{% code title="printer.cfg" %}

    ## 3Dwork standard macros
    [include 3dwork-klipper/macros/macros_*.cfg]
    ## 3Dwork shell macros
    [include 3dwork-klipper/shell-macros.cfg]

{%endcode%}

{% hint style="info" %}
It is important that we add these lines to the end of our configuration file... just above the section so that if there are macros in our cfg or includes they will be overwritten by ours :\\#\*# &lt;---------------------- SAVE_CONFIG ---------------------->
{% endhint %}

{% hint style="warning" %}
Normal macros have been separated from**macros shell**given that**To enable these, it is necessary to perform additional steps manually, in addition to the fact that they are currently being tested.**y**They may require extra permissions to assign execution permissions for which the instructions have not been indicated since they are trying to automate.**\\<mark style="color:red;">**If you use them it is at your own risk.**</mark>{% endint %}

### Configuration of our laminator

Since our macros are dynamic, they will extract certain information from our printer configuration and the laminator itself. To do this, we advise you to configure your laminators as follows:

-   **start gcode START_PRINT**, using placeholders to pass filament and bed temperature values ​​dynamically:

{% tabs %}
{% tab title="PrusaSlicer-SuperSlicer" %}**Prusa Slicer**

```gcode
M190 S0 ; Prevents prusaslicer from prepending m190 to the gcode ruining our macro
M109 S0 ; Prevents prusaslicer from prepending m109 to the gcode ruining our macro
SET_PRINT_STATS_INFO TOTAL_LAYER=[total_layer_count] ; Provide layer information
START_PRINT EXTRUDER_TEMP=[first_layer_temperature[initial_extruder]] BED_TEMP=[first_layer_bed_temperature] PRINT_MIN={first_layer_print_min[0]},{first_layer_print_min[1]} PRINT_MAX={first_layer_print_max[0]},{first_layer_print_max[1]}
```

**SuperSlicer**- we have the option to adjust the enclosure temperature (CHAMBER)

```gcode
M190 S0 ; Prevents prusaslicer from prepending m190 to the gcode ruining our macro
M109 S0 ; Prevents prusaslicer from prepending m109 to the gcode ruining our macro
SET_PRINT_STATS_INFO TOTAL_LAYER=[total_layer_count] ; Provide layer information
START_PRINT EXTRUDER_TEMP=[first_layer_temperature[initial_extruder]] BED_TEMP=[first_layer_bed_temperature] CHAMBER=[chamber_temperature] PRINT_MIN={first_layer_print_min[0]},{first_layer_print_min[1]} PRINT_MAX={first_layer_print_max[0]},{first_layer_print_max[1]}
```

![Ejemplo para PrusaSlicer/SuperSlicer](<../../.gitbook/assets/image (1104).png>){% end loss %}

{% tab title="Bambu Studio/OrcaSlicer" %}

```gcode
M190 S0 ; Prevents prusaslicer engine from prepending m190 to the gcode ruining our macro
M109 S0 ; Prevents prusaslicer engine from prepending m109 to the gcode ruining our macro
SET_PRINT_STATS_INFO TOTAL_LAYER=[total_layer_count] ; Provide layer information
START_PRINT EXTRUDER_TEMP=[nozzle_temperature_initial_layer] BED_TEMP=[first_layer_bed_temperature] CHAMBER=[chamber_temperature] PRINT_MIN={first_layer_print_min[0]},{first_layer_print_min[1]} PRINT_MAX={first_layer_print_max[0]},{first_layer_print_max[1]}
```

<figure><img src="../../.gitbook/assets/image (1760).png" alt=""><figcaption></figcaption></figure>
{% endtab %}

{% tab title="Cura" %}

```gcode
START_PRINT EXTRUDER_TEMP={material_print_temperature_layer_0} BED_TEMP={material_bed_temperature_layer_0} PRINT_MIN=%MINX%,%MINY% PRINT_MAX=%MAXX%,%MAXY%
```

{% hint style="warning" %}
We will have to install the plugin[**Post Process Plugin (by frankbags)**](https://gist.github.com/frankbags/c85d37d9faff7bce67b6d18ec4e716ff)from the menu_**Help/Show**_configuration Folder... we will copy the script from the previous link into the script folder. \\
We restart Cura and we will go to_**Extensions/Post processing/Modify G-Code**_and we will select_**Mesh Print Size**_,
{% endint %}
{% indtab %}

{% tab title="IdeaMaker" %}

```gcode
START_PRINT EXTRUDER_TEMP={temperature_extruder1} BED_TEMP={temperature_heatbed}
```

{% end loss %}

{% tab title="Simplify3D" %}

```gcode
START_PRINT EXTRUDER_TEMP=[extruder0_temperature] BED_TEMP=[bed0_temperature]
```

{% end loss %}
{% endloss %}

{% hint style="info" %}
Los**placeholders are "aliases" or variables that the laminators use so that when generating the gcode they are replaced by the values ​​configured in the profile**of impression.

In the following links you can find a list of these for:[**Prusa Slicer**](https://help.prusa3d.com/es/article/lista-de-placeholders_205643),[**SuperSlicer**](https://github.com/supermerill/SuperSlicer/wiki/Macro-&-Variable-list)(in addition to those above),[**Bambu Studio**](https://wiki.bambulab.com/en/software/bambu-studio/placeholder-list)y[**Treatment**](http://files.fieldofview.com/cura/Replacement_Patterns.html).

The use of these allows our macros to be dynamic.
{% endhint %}

-   **gcode the final END_PRINT**, in this case by not using placeholders it is common to all laminators

```gcode
END_PRINT
```

### Variables

As we have already mentioned, these new macros will allow us to have some very useful functions as we listed above.

To adjust these to our machine we will use the variables that we will find in macros/macros_was_globals.cfg and which we detail below.

#### Message/notification language

Since many users like to have macro notifications in their language, we have devised a multi-language notification system, currently Spanish (es) and English (en). In the following variable we can adjust it:

<table><thead><tr><th width="189">Variable</th><th width="247">Descripción</th><th width="163">Valores posibles</th><th>Valor por defecto</th></tr></thead><tbody><tr><td>variable_language</td><td>Nos permite seleccionar el idioma de las notificaciones. En el caso de no estar bien definido se usará en (inglés)</td><td>es / en</td><td>es</td></tr></tbody></table>

#### Relative Extrusion

It allows us to control which extrusion mode we will use at the end of our START.\_PRINT The value will depend on the configuration of our laminator.

{% hint style="success" %}
It is advisable that you configure your laminator to use relative extrusion and set this variable to True.
{% endhint %}

| Variable                    | Description                                                        | Possible values | Default value |
| --------------------------- | ------------------------------------------------------------------ | --------------- | ------------- |
| variable_relative_extrusion | It allows us to indicate the extrusion mode used in our laminator. | True / False    | True          |

#### Speeds

To manage the speeds used in macros.

| Variable                    | Description               | Possible values | Default value |   |
| --------------------------- | ------------------------- | --------------- | ------------- | - |
| variable_macro_travel_speed | Transfer speed            | numeric         | 150           |   |
| variable_macro_z_speed      | Transfer speed for Z axis | numeric         | 15            |   |

#### Homing

Set of variables related to the homing process.

| Variable | Description | Possible values | Default value |
| -------- | ----------- | --------------- | ------------- |
|          |             |                 |               |

#### Heating

Variables related to the heating process of our machine.

| Variable                                   | Description                                                                                     | Possible values | Default value |
| ------------------------------------------ | ----------------------------------------------------------------------------------------------- | --------------- | ------------- |
| variable_preheat_extruder                  | Enables preheating of the nozzle to the temperature indicated in variable_preheat_extruder_temp | True / False    | True          |
| variable_preheat_extruder_temp             | Nozzle preheat temperature                                                                      | numeric         | 150           |
| variable_start_print_heat_chamber_bed_temp | Bed temperature during the process of heating our enclosure                                     | numeric         | 100           |

{% hint style="success" %}
Benefits of using preheated nozzle:

-   It allows us additional time so that the bed can reach its temperature uniformly.
-   If we use an inductive sensor that does not have temperature compensation, it will allow our measurements to be more consistent and precise.
-   Allows you to soften any remaining filament in the nozzle, which means that, in certain configurations, these remains do not affect the activation of the sensor.
    {% endhint %}

#### Bed Mesh

To control the leveling process we have variables that can be very useful. For example, we can control the type of leveling we want to use by always creating a new mesh, loading a previously stored one, or using adaptive meshing.

| Variable                    | Description                                                                                                                                                                                                                                                                                                                                                                                 | Possible values                                     | Default value |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------- | ------------- |
| variable_calibrate_bed_mesh | <p>It allows us to select what type of mesh we will use in our START_PRINT:<br>- new mesh, it will mesh each print<br>- storedmesh, will load a stored mesh and will not perform the bed poll<br>- adaptive, it will make a new mesh but adapted to the printing area, often improving our first layers<br>- nomesh, in case we do not have a sensor or we use mesh to skip the process</p> | <p>new mesh / stored mesh / adaptive /<br>names</p> | adaptive      |
| variable_bed_mesh_profile   | The name used for our stored mesh                                                                                                                                                                                                                                                                                                                                                           | text                                                | default       |

{% hint style="warning" %}
We advise you to use adaptive leveling since it will always adjust the mesh to the size of our print, allowing you to have an adjusted mesh area.

It is important that we have in our[start gcode of our laminator](../empezamos/configuracion-klipper-en-laminadores.md#configurando-nuestro-laminador-para-usar-nustras-macros-start_print-y-end_print), in the call to our START_PRINT, PRINT values_MAX y PRINT_Man.
{% endint %}

#### purged

An important phase of our start of printing is a correct purging of our nozzle to avoid filament remains or that these could damage our printing at some point. Below you have the variables that intervene in this process:

| Variable                               | Description                                                                                                                                                                                                                                                                                                                                                                                         | Possible values                                                        | Default value       |
| -------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------- | ------------------- |
| variable_nozzle_priming                | <p>We can choose between different purging options:<br>- primeline will draw the typical purge line<br>- primelineadaptative will generate a purge line that adapts to the area of ​​the printed part using variable_nozzle_priming_objectdistance as a margin<br>- primeblob will make us a drop of filament in a corner of our bed, very effective for cleaning the nozzle and easy to remove</p> | <p>prime line /</p><p>primelineadaptive /<br>prime blob /<br>False</p> | adaptive primelines |
| variable_nozzle_priming_objectdistance | If we use adaptive bleed line it will be the margin to be used between the bleed line and the printed object                                                                                                                                                                                                                                                                                        | numeric                                                                | 5                   |
| variable_nozzle_prime_start_x          | <p>Where we want to locate our purge line:<br>- min will do it at X=0 (plus a small safety margin)<br>- max will do so at X=max (minus a small safety margin)<br>- number will be the X coordinate where to locate the purge</p>                                                                                                                                                                    | <p>min /<br>max /<br>number</p>                                        | max                 |
| variable_nozzle_prime_start_y          | <p>Where we want to locate our purge line:<br>- min will do it at Y=0 (plus a small safety margin)<br>- max will do so at Y=max (minus a small safety margin)<br>- number will be the Y coordinate where to locate the purge</p>                                                                                                                                                                    | <p>min /<br>max /<br>number</p>                                        | min                 |
| variable_nozzle_prime_direction        | <p>The address of our line or drop:<br>- backwards the head will move to the front of the printer<br>- forwards will move to the back<br>- auto will go towards the center depending on variable_nozzle_prime_start_y</p>                                                                                                                                                                           | <p>auto /<br>forwards /<br>backwards</p>                               | auto                |

#### Filament loading/unloading

In this case, this group of variables will facilitate the management of loading and unloading our filament used in emulation of the M600, for example, or when launching the filament loading and unloading macros:

| Variable                        | Description                                                                                                                                                                                                                                                                                                                                                                        | Possible values | Default value |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------- | ------------- |
| variable_filament_unload_length | How much to retract the filament in mm, adjust to your machine, normally the measurement from your nozzle to the gears of your extruder adding an extra margin.                                                                                                                                                                                                                    | number          | 130           |
| variable_filament_unload_speed  | Filament retraction speed in mm/sec normally a slow speed is used.                                                                                                                                                                                                                                                                                                                 | number          | 5             |
| variable_filament_load_length   | Distance in mm to load the new filament... as well as in variable_filament_unload_length we will use the measurement from your gear to extruder adding an extra margin, in this case this extra value will depend on how much you want it to purge... normally you can give it more margin than the previous value to ensure that the extrusion of the previous filament is clean. | number          | 150           |
| variable_filament_load_speed    | Filament loading speed in mm/sec, normally a faster speed is used than the unloading speed.                                                                                                                                                                                                                                                                                        | number          | 10            |

{% hint style="warning" %}
Another necessary setting for your section\[extrude] is indicated[<mark style="color:green;">**max_extrude_only_distance**</mark>](https://www.klipper3d.org/Config_Reference.html#extruder)...the advisable value is usually >101 (if not defined, use 50) to, for example, allow typical extruder calibration tests. \\
You should adjust the value based on what was previously mentioned about the test or the configuration of your**variable_filament_unload_length**I**variable_filament_load_length**,
{% endint %}

#### Parking

In certain processes of our printer, such as paused, it is advisable to park our head. The macros in our bundle have this option in addition to the following variables to manage:

| Variable                           | Description                                                                                                                                                                                                                                                                      | Possible values                    | Default value |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------- | ------------- |
| variable_start_print_park_in       | Location where to park the head during pre-heating.                                                                                                                                                                                                                              | <p>back /<br>center /<br>front</p> | back          |
| variable_start_print_park_z_height | Z height during pre-heating                                                                                                                                                                                                                                                      | number                             | 50            |
| variable_end_print_park_in         | Location where to park the head when finishing or canceling a print.                                                                                                                                                                                                             | <p>back /<br>center /<br>front</p> | back          |
| variable_end_print_park_z_hop      | Distance to rise in Z at the end of printing.                                                                                                                                                                                                                                    | number                             | 20            |
| variable_pause_print_park_in       | Location where to park the head when pausing printing.                                                                                                                                                                                                                           | <p>back /<br>center /<br>front</p> | back          |
| variable_pause_idle_timeout        | Value, in seconds, of the activation of the inactivity process in the machine that releases motors and causes coordinates to be lost,**A high value is advisable so that when activating the PAUSE macro it takes enough time to perform any action before losing coordinates.** | number                             | 43200         |

#### Z-Tilt

Making the most of our machine so that it self-levels and ensuring that our machine is always in the best condition is essential.

**Z-TILT is basically a process that helps us align our Z motors with respect to our X (Cartesian) or XY (CoreXY) axis/gantry.**. With this**we ensure that we always have our Z aligned perfectly and precisely and automatically**.

| Variable                  | Description                                                                    | Possible values | Default value |
| ------------------------- | ------------------------------------------------------------------------------ | --------------- | ------------- |
| variable_calibrate_z_tilt | Allows, if enabled in our Klipper configuration, the Z-Tilt adjustment process | True / False    | False         |

#### Skew

The use of[SKEW](broken-reference)For the correction or precise adjustment of our printers it is extremely advisable if we have deviations in our prints. Using the following variable we can allow the use in our macros:

| Variable              | Description                                                                                                                                                                                                | Possible values | Default value   |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------- | --------------- |
| variable_skew_profile | It allows us to take into account our skew profile that will be loaded in our START macro_PRINT To activate it we must uncomment the variable and use the name of the skew profile from our configuration. | text            | my_skew_profile |

### Macro customization

Our module for Klipper uses the modular configuration system used in RatOS and takes advantage of the advantages of Klipper in processing its configuration files sequentially. This is why the order of the includes and custom settings that we want to apply to these modules is essential.

{% hint style="info" %}
When used as a module, 3Dwork configurations CANNOT be edited directly from the 3dwork-klipper directory within your Klipper configuration directory since it will be read-only for security.

That is why it is very important to understand how Klipper works and how to customize our modules to your machine.
{% endhint %}

#### **Customizing variables**

Normally, it will be what we will have to adjust, to make adjustments to the variables that we have by default in our module**Your excuses**para Cliffs.

Simply, what we have to do is paste the content of the macro\[gcode_macro GLOBAL_VARS] that we can find in macros/macros_was_globals.cfg in our printer.cfg.

We remind you of what we mentioned previously about how Klipper processes the configurations sequentially, so it is advisable to paste it after the includes that we mentioned.[here](3dwork-klipper-bundle.md#anadiendo-las-macros-3dwork-a-nuestra-instalacion).

We will have something like this (it is just a visual example):

<pre class="language-django"><code class="lang-django">### 3Dwork Klipper Includes
[include 3dwork-klipper/macros/macros_*.cfg]

### USER OVERRIDES
<strong>## VARIABLES 3DWORK
</strong>[gcode_macro GLOBAL_VARS]
description: GLOBAL_VARS variable storage macro, will echo variables to the console when run.
# Configuration Defaults
# This is only here to make the config backwards compatible.
# Configuration should exclusively happen in printer.cfg.

# Possible language values: "en" or "es" (if the language is not well defined, "en" is assigned by default.)
variable_language: "es"                         # Possible values: "en", "es"
...

<strong>
</strong>#*# &#x3C;---------------------- SAVE_CONFIG ---------------------->
#*# DO NOT EDIT THIS BLOCK OR BELOW. The contents are auto-generated.
#*#
</code></pre>

{% hint style="warning" %}
The three points (...) in the previous examples are merely to indicate that you can have more configurations between sections... in no case should they be added.
{% endhint %}

{% hint style="info" %}

-   We advise you to add comments as you see in the previous case to identify what each section does.
-   Although you do not need to touch all the variables, we advise you to copy all the content of\[gcode_macro GLOBAL_Year]
    {% endint %}

#### Customizing macros

The macros have been set up in a modular way so that they can be easily adjusted. As we have mentioned before, if we want to adjust them we will have to proceed the same as we did with the variables, copy the macro in question into our printer.cfg (or another include of our own) and make sure that it is after the include where we added our 3Dwork module for Klipper .

We have two groups of macros:

-   Macros to add user settings, these macros can be easily added and customized because they were added so that any user can customize the actions to their liking in certain parts of the processes carried out by each macro.

**START_PRINT**

<table><thead><tr><th width="400">Nombre Macro</th><th>Descripción</th></tr></thead><tbody><tr><td>_USER_START_PRINT_HEAT_CHAMBER</td><td>Se ejecuta justo después que nuestro cerramiento empiece a calentar, si CHAMBER_TEMP se pasa como parámetro a nuestro START_PRINT</td></tr><tr><td>_USER_START_PRINT_BEFORE_HOMING</td><td>Se ejecuta antes del homing inicial de inicio de impresión</td></tr><tr><td>_USER_START_PRINT_AFTER_HEATING_BED</td><td>Se ejecuta al llegar nuestra cama a su temperatura, antes de _START_PRINT_AFTER_HEATING_BED</td></tr><tr><td>_USER_START_PRINT_BED_MESH</td><td>Se lanza antes de _START_PRINT_BED_MESH</td></tr><tr><td>_USER_START_PRINT_PARK</td><td>Se lanza antes de _START_PRINT_PARK</td></tr><tr><td>_USER_START_PRINT_AFTER_HEATING_EXTRUDER</td><td>Se lanza antes de _START_PRINT_AFTER_HEATING_EXTRUDER</td></tr></tbody></table>

**END_PRINT**

| Macro Name                          | Description                                                                         |
| ----------------------------------- | ----------------------------------------------------------------------------------- |
| \_USER_END_PRINT_BEFORE_HEATERS_OFF | It is executed before turning off the heaters, before_END_PRINT_BEFORE_HEATERS_OFF  |
| \_USER_END_PRINT_AFTER_HEATERS_OFF  | It is executed after the heaters are turned off, before_END_PRINT_AFTER_HEATERS_OFF |
| \_USER_END_PRINT_PARK               | It is executed before the head is parked, before_END_PRINT_PARK                     |

**PRINT_BASICS**

| Macro Name          | Description                           |
| ------------------- | ------------------------------------- |
| \_USER_PAUSE_START  | Executed at the beginning of a PAUSE  |
| \_USER_PAUSE_END    | Executed at the end of a PAUSE        |
| \_USER_RESUME_START | Executed at the beginning of a RESUME |
| \_USER_RESUME_END   | Executed at the end of a RESUME       |

-   Internal macros are macros to divide the main macro into processes and are important for this. It is advisable that if adjustments are required, they be copied as is.

**START_PRINT**

<table><thead><tr><th width="405">Nombre Macro</th><th>Descripción</th></tr></thead><tbody><tr><td>_START_PRINT_HEAT_CHAMBER</td><td>Calienta el cerramiento en el caso de que el parámetro CHAMBER_TEMP sea recibido por nuestra macro START_PRINT desde el laminador</td></tr><tr><td>_START_PRINT_AFTER_HEATING_BED</td><td>Se ejecuta al llegar la cama a la temperatura, después de _USER_START_PRINT_AFTER_HEATING_BED. Normalmente, se usa para el procesado de calibraciones de cama (Z_TILT_ADJUST, QUAD_GANTRY_LEVELING,...)</td></tr><tr><td>_START_PRINT_BED_MESH</td><td>Se encarga de la lógica de mallado de cama.</td></tr><tr><td>_START_PRINT_PARK</td><td>Aparca el cabezal de impresión mientras calienta el nozzle a la temperatura de impresión.</td></tr><tr><td>_START_PRINT_AFTER_HEATING_EXTRUDER</td><td>Realiza el purgado del nozzle y carga el perfil SKEW en caso de que así definamos en las variables</td></tr></tbody></table>

## Printers and electronics

As we work with different models of printers and electronics, we will add those that are not directly supported by RatOS, whether they are contributions from us or from the community.

-   printers, in this directory we will have all the printer configurations
-   boards, here we will find the electronic ones

### Parameters and pins

Our module for Klipper uses the modular configuration system used in RatOS and takes advantage of the advantages of Klipper in processing its configuration files sequentially. This is why the order of the includes and custom settings that we want to apply to these modules is essential.

{% hint style="info" %}
When used as a module, 3Dwork configurations CANNOT be edited directly from the 3dwork-klipper directory within your Klipper configuration directory since it will be read-only for security.

That is why it is very important to understand how Klipper works and how to customize our modules to your machine.
{% endhint %}

As we explained in "[customizing macros](3dwork-klipper-bundle.md#personalizando-macros)"We will use the same process to adjust parameters or pins to fit our needs.

#### Customizing parameters

Just as we advise you to create a section in your printer.cfg called USER OVERRIDES, placed after the includes of our configurations, to be able to adjust and customize any parameter used in them.

In the following example we will see how in our case we are interested in customizing the parameters of our bed leveling (bed_mesh) by adjusting the probe points_count) with respect to the configuration that we have by default in the configurations of our Klipper module:

{% code title="printer.cfg" %}

```django
### 3Dwork Klipper Includes
[include 3dwork-klipper/macros/macros_*.cfg]

### USER OVERRIDES
## VARIABLES 3DWORK
[gcode_macro GLOBAL_VARS]
...

## PARAMETERS 3Dwork
[bed_mesh]
probe_count: 11,11
...

#*# <---------------------- SAVE_CONFIG ---------------------->
#*# DO NOT EDIT THIS BLOCK OR BELOW. The contents are auto-generated.
#*#
```

{%endcode%}

{% hint style="warning" %}
The three points (...) in the previous examples are merely to indicate that you can have more configurations between sections... in no case should they be added.
{% endhint %}

We can use this same process with any parameter we want to adjust.

#### Customizing pin configuration

We will proceed exactly as we have done previously, in our USER OVERRIDES area we will add those pin sections that we want to adjust to our liking.

In the following example we are going to customize which is the pin of our electronic fan (controller_fan) to assign it to a different one than the default one:

{% code title="printer.cfg" %}

```django
### 3Dwork Klipper Includes
[include 3dwork-klipper/macros/macros_*.cfg]

### USER OVERRIDES
## VARIABLES 3DWORK
[gcode_macro GLOBAL_VARS]
...

## PARAMETERS 3Dwork
[bed_mesh]
probe_count: 11,11
...

## PINS 3Dwork
[controller_fan controller_fan]
pin: PA8

#*# <---------------------- SAVE_CONFIG ---------------------->
#*# DO NOT EDIT THIS BLOCK OR BELOW. The contents are auto-generated.
#*#
```

{%endcode%}

{% hint style="warning" %}
The three points (...) in the previous examples are merely to indicate that you can have more configurations between sections... in no case should they be added.
{% endhint %}
