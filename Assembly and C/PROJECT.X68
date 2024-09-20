*-----------------------------------------------------------
* Title      : Endless Runner Starter Kit
* Written by : FOLOSIYE ADEGBOLA PETER
* Date       : 08/03/2024

*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program


*-----------------------------------------------------------
* Section       : Trap Codes
* Description   : Trap Codes used throughout StarterKit
*-----------------------------------------------------------
* Trap CODES
TC_SCREEN   EQU         33          ; Screen size information trap code
TC_S_SIZE   EQU         00          ; Places 0 in D1.L to retrieve Screen width and height in D1.L
                                    ; First 16 bit Word is screen Width and Second 16 bits is screen Height
TC_KEYCODE  EQU         19          ; Check for pressed keys
TC_DBL_BUF  EQU         92          ; Double Buffer Screen Trap Code
TC_CURSR_P  EQU         11          ; Trap code cursor position

TC_EXIT     EQU         09          ; Exit Trapcode

*-----------------------------------------------------------
* Section       : Charater Setup
* Description   : Size of Player and Enemy and properties
* of these characters e.g Starting Positions and Sizes
*-----------------------------------------------------------
PLYR_W_INIT EQU         08          ; Players initial Width
PLYR_H_INIT EQU         08          ; Players initial Height

PLYR_DFLT_V EQU         01          ; Default Player Velocity
PLYR_JUMP_V EQU        -20          ; Player Jump Velocity
PLYR_DFLT_G EQU         01          ; Player Default Gravity

GND_TRUE    EQU         01          ; Player on Ground True
GND_FALSE   EQU         00          ; Player on Ground False

RUN_INDEX   EQU         00          ; Player Run Sound Index  
JMP_INDEX   EQU         01          ; Player Jump Sound Index  
OPPS_INDEX  EQU         02          ; Player Opps Sound Index

ENMY_W_INIT EQU         16          ; Enemy initial Width
ENMY_H_INIT EQU         16          ; Enemy initial Height

;2nd enemy
ENMY2_W_INIT EQU       16          ;
ENMY2_H_INIT EQU       16          ;

;3rd enemy
ENMY3_W_INIT EQU       16          ;
ENMY3_H_INIT EQU       16          ;

;4th enemy
ENMY4_W_INIT EQU       16          ;
ENMY4_H_INIT EQU       16          ;

;5th enemy
ENMY5_W_INIT EQU       16          ;
ENMY5_H_INIT EQU       16          ;




*-----------------------------------------------------------
* Section       : Game Stats
* Description   : Points
*-----------------------------------------------------------
POINTS      EQU         01          ; Points added

*-----------------------------------------------------------
* Section       : Keyboard Keys
* Description   : Spacebar and Escape or two functioning keys
* Spacebar to JUMP and Escape to Exit Game
*-----------------------------------------------------------
SPACEBAR    EQU         $20         ; Spacebar ASCII Keycode
ESCAPE      EQU         $1B         ; Escape ASCII Keycode
AKEY        EQU         $41         ; A ASCII KEYCODE
DKEY        EQU         $44         ; D ASCII Keycode
WKEY        EQU         $57         ; W ASCII Keycode
SKEY        EQU         $53         ; Z ASCII Keycode
*-----------------------------------------------------------
* Subroutine    : Initialise
* Description   : Initialise game data into memory such as 
* sounds and screen size
*-----------------------------------------------------------

*-----------------------------------------------------------
* section : Health block
HEALTH_BLOCK_W  EQU 10  ; Width of the health block
HEALTH_BLOCK_H  EQU 10  ; Height of the health block
INITIAL_HEALTH  EQU 100 ; Initial health value
*----------------------------------------------------------

INITIALISE:

    ;Initialise background
    MOVE.L  #WHITE, D1      ;BACKGROUNG COLOR TO WHITE
    MOVE.B  #80,    D0
    TRAP    #15
    

    ; Initialise Sounds
    BSR     RUN_LOAD                ; Load Run Sound into Memory
    BSR     JUMP_LOAD               ; Load Jump Sound into Memory
    BSR     OPPS_LOAD               ; Load Opps (Collision) Sound into Memory

    ; Screen Size
    MOVE.B  #TC_SCREEN, D0          ; access screen information
    MOVE.L  #TC_S_SIZE, D1          ; placing 0 in D1 triggers loading screen size information
    TRAP    #15                     ; interpret D0 and D1 for screen size
    MOVE.W  D1,         SCREEN_H    ; place screen height in memory location
    SWAP    D1                      ; Swap top and bottom word to retrive screen size
    MOVE.W  D1,         SCREEN_W    ; place screen width in memory location
    
    
    ; Initial Position for Enemy 1
    MOVE.L   #2500,       ENEMY_X    ; Set the X coordinates for Enemy 1
    MOVE.L   #250,        ENEMY_Y    ; Set the Y coordinates for Enemy 1
    
    ; Initial Position for Enemy 2
    MOVE.L   #2000,       ENMY2_X   ; Set the X coordinates for Enemy 2
    MOVE.L   #200,        ENMY2_Y   ; Set the Y coordinates for Enemy 2
    
    ; Initial Position for Enemy 3
    MOVE.L   #1500,       ENMY3_X   ; Set the X coordinates for Enemy 3
    MOVE.L   #280,        ENMY3_Y   ; Set the Y coordinates for Enemy 3
    
    ; Initial Position for Enemy 4
    MOVE.L   #1000,       ENMY4_X   ; Set the X coordinates for Enemy 4
    MOVE.L   #240,        ENMY4_Y   ; Set the Y coordinates for Enemy 4
    
    ; Initial Position for Enemy 5
    MOVE.L   #1000,       ENMY5_X   ; Set the X coordinates for Enemy 4
    MOVE.L   #240,        ENMY5_Y   ; Set the Y coordinates for Enemy 4



    ; Place the Player at the center of the screen
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on X Axis
    MOVE.L  D1,         PLAYER_X    ; Players X Position

    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  D1,         PLAYER_Y    ; Players Y Position

    ; Initialise Player Score
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  #00,        D1          ; Init Score
    MOVE.L  D1,         PLAYER_SCORE

    ; Initialise Player Velocity
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    ;MOVE.B  #PLYR_DFLT_V,D1         ; Init Player Velocity
    MOVE.L  D1,         PLYR_VELOCITY

    ; Initialise Player Gravity
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  #PLYR_DFLT_G,D1         ; Init Player Gravity
    MOVE.L  D1,         PLYR_GRAVITY

    ; Initialize Player on Ground
    MOVE.L  #GND_TRUE,  PLYR_ON_GND ; Init Player on Ground

    ; Initial Position for Enemy
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY_X     ; Enemy X Position

    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  D1,         ENEMY_Y     ; Enemy Y Position
    
    ; Initial Position for Second Enemy
    CLR.L   D1                           ; Clear contents of D1
    MOVE.L  ENEMY_X, D1                  ; Load the X position of the first enemy into D1
    SUB.W   #50, D1                      ; Subtract the desired distance behind from the X position
    ;MOVE.L  D1,     SECOND_ENEMY_X       ; Store the X position of the second enemy

    CLR.L   D1                           ; Clear contents of D1
    MOVE.W  ENEMY_Y, D1               ; Place the desired Y position of the second enemy in D1
    DIVU    #02,        D1               ; Divide by 2 for centering on Y Axis (if needed)
    ;MOVE.L  D1,     SECOND_ENEMY_Y       ; Store the Y position of the second enemy



    
    ; initialise health block position
    MOVE.W  #$50,       D1     ; Initial X position (example value)
    MOVE.W  #$50,       D2     ; Initial Y position (example value)
    MOVE.L  D1,         HEALTH_BLOCK_X
    MOVE.L  D2,         HEALTH_BLOCK_Y
    
    ; Initialize player's health
    ; Set the player's initial health
    MOVE.L #INITIAL_HEALTH, D1
    MOVE.L D1, PLAYER_HEALTH

    
    ; Enable the screen back buffer(see easy 68k help)
	MOVE.B  #TC_DBL_BUF,D0          ; 92 Enables Double Buffer
    MOVE.B  #17,        D1          ; Combine Tasks
	TRAP	#15                     ; Trap (Perform action)

    ; Clear the screen (see easy 68k help)
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
	MOVE.W  #$FF00,     D1          ; Fill Screen Clear
	TRAP	#15                     ; Trap (Perform action)
	
	

*-----------------------------------------------------------
* Subroutine    : Game
* Description   : Game including main GameLoop. GameLoop is like
* a while loop in that it runs forever until interupted
* (Input, Update, Draw). The Enemies Run at Player Jump to Avoid
*-----------------------------------------------------------
GAME:
    BSR     PLAY_RUN                ; Play Run Wav
GAMELOOP:
    ; Main Gameloop
    BSR     INPUT                   ; Check Keyboard Input
    BSR     UPDATE                  ; Update positions and points
    BSR     IS_PLAYER_ON_GND        ; Check if player is on ground
    BSR     CHECK_COLLISIONS        ; Check for Collisions
    BSR     RESTRICT_X
    BSR     RESTRICT_Y
    BSR     DRAW                    ; Draw the Scene
    BRA     GAMELOOP                ; Loop back to GameLoop

*-----------------------------------------------------------
* Subroutine    : Input
* Description   : Process Keyboard Input
*-----------------------------------------------------------
INPUT:
    ; Process Input
    CLR.L   D1                      ; Clear Data Register
    MOVE.B  #TC_KEYCODE,D0          ; Listen for Keys
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  D1,         D2          ; Move last key D1 to D2
    CMP.B   #00,        D2          ; Key is pressed
    BEQ     PROCESS_INPUT           ; Process Key
    TRAP    #15                     ; Trap for Last Key
    ; Check if key still pressed
    CMP.B   #$FF,       D1          ; Is it still pressed
    BEQ     PROCESS_INPUT           ; Process Last Key
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Process Input
* Description   : Branch based on keys pressed
*-----------------------------------------------------------
PROCESS_INPUT:
    MOVE.L  D2,         CURRENT_KEY ; Put Current Key in Memory
    CMP.L   #ESCAPE,    CURRENT_KEY ; Is Current Key Escape
    BEQ     EXIT                    ; Exit if Escape
    CMP.L   #SPACEBAR,  CURRENT_KEY ; Is Current Key Spacebar
    ;BEQ     JUMP                    ; Jump
    CMP.L   #AKEY,  CURRENT_KEY ; Is Current Key Spacebar
    BEQ     MOVE_LEFT                ; Jump
    CMP.L   #DKEY,  CURRENT_KEY ; Is Current Key Spacebar
    BEQ     MOVE_RIGHT                ; Jump
    CMP.L   #WKEY,  CURRENT_KEY ; Is Current Key Spacebar
    BEQ     MOVE_UP                ; Jump
    CMP.L   #SKEY,  CURRENT_KEY ; Is Current Key Spacebar
    BEQ     MOVE_DOWN                ; Jump

    BRA     IDLE                    ; Or Idle
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* RESTRICT PLAYER MOVEMENTS
*-----------------------------------------------------------
RESTRICT_X:
    CLR.L   D1
    CLR.L   D0
    MOVE.L  PLAYER_X,   D0
    CMP.L   #00,        D0
    BLE     BLOCK_PLAYER_X_LEFT
    CMP.L   #630,       D0
    BGE     BLOCK_PLAYER_X_RIGHT
    
    RTS

RESTRICT_Y:
    CLR.L   D1
    CLR.L   D0
    MOVE.L  PLAYER_Y,   D0
    CMP.L   #160,        D0
    BLE     BLOCK_PLAYER_Y_UP
    CMP.L   #480,       D0
    BGE     BLOCK_PLAYER_Y_DOWN
    
    RTS

*-----------------------------------------------------------
* Subroutine    : Update
* Description   : Main update loop update Player and Enemies
*-----------------------------------------------------------
UPDATE:

    MOVE.L #20000,  D1
    
    SLOW_LOOP:
    DBRA    D1, SLOW_LOOP
    ; Update the Players Positon based on Velocity and Gravity
    ;CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    ;MOVE.L  PLYR_VELOCITY, D1       ; Fetch Player Velocity
    ;MOVE.L  PLYR_GRAVITY, D2        ; Fetch Player Gravity
    ;ADD.L   D2,         D1          ; Add Gravity to Velocity
    ;MOVE.L  D1,         PLYR_VELOCITY ; Update Player Velocity
    ;ADD.L   PLAYER_Y,   D1          ; Add Velocity to Player
    ;MOVE.L  D1,         PLAYER_Y    ; Update Players Y Position 
    
    
    ; Move Enemy 1
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    CLR.L   D1                      ; Clear the contents of D0
    MOVE.L  ENEMY_X,    D1          ; Move the Enemy X Position to D0
    CMP.L   #00,        D1
    BLE     RESET_ENEMY_POSITION    ; Reset Enemy if off Screen
    BRA     MOVE_ENEMY              ; Move the Enemy


   ; Move Enemy 2
    CLR.L   D1                          ; Clear contents of D1 (XOR is faster)
    CLR.L   D1                          ; Clear contents of D1
    MOVE.L  ENMY2_X,    D1            ; Move the Enemy 2 X Position to D1
    CMP.L   #00,        D1 
    BLE     RESET_ENEMY_POSITION2       ; Reset Enemy 2 if off Screen
    BRA     MOVE_ENEMY_2                 ; Move Enemy 2

    ; Move Enemy 3
    CLR.L   D1                          ; Clear contents of D1 (XOR is faster)
    CLR.L   D1                          ; Clear contents of D1
    MOVE.L  ENMY3_X,    D1            ; Move the Enemy 3 X Position to D1
    CMP.L   #00,        D1 
    BLE     RESET_ENEMY_POSITION3       ; Reset Enemy 3 if off Screen
    BRA     MOVE_ENEMY_3                 ; Move Enemy 3

    ; Move Enemy 4
    CLR.L   D1                          ; Clear contents of D1 (XOR is faster)
    CLR.L   D1                          ; Clear contents of D1
    MOVE.L  ENMY4_X,    D1            ; Move the Enemy 4 X Position to D1
    CMP.L   #00,        D1
    BLE     RESET_ENEMY_POSITION4       ; Reset Enemy 4 if off Screen
    BRA     MOVE_ENEMY_4                 ; Move Enemy 4


    ; Move Enemy 5
    CLR.L   D1                          ; Clear contents of D1 (XOR is faster)
    CLR.L   D1                          ; Clear contents of D1
    MOVE.L  ENMY5_X,    D1            ; Move the Enemy 4 X Position to D1
    CMP.L   #00,        D1
    BLE     RESET_ENEMY_POSITION4       ; Reset Enemy 4 if off Screen
    BRA     MOVE_ENEMY_5                ; Move Enemy 4



    RTS                             ; Return to subroutine  

*-----------------------------------------------------------
* Subroutine    : Move Enemy
* Description   : Move Enemy Right to Left
*-----------------------------------------------------------
MOVE_ENEMY:
    
    SUB.L   #01,        ENEMY_X     ; Move enemy by X Value
    
MOVE_ENEMY_2:
    
    SUB.L   #01,        ENMY2_X     ; Move enemy2 by X Value
    
MOVE_ENEMY_3:

    SUB.L   #01,        ENMY3_X     ; Move enemy3 by X Value
    
MOVE_ENEMY_4:

    SUB.L   #01,        ENMY4_X     ; Move enemy4 by X Value
    
MOVE_ENEMY_5:

    SUB.L   #01,        ENMY5_X     ; Move enemy5 by X Value


    



    RTS

*-----------------------------------------------------------
* Subroutine    : Reset Enemy
* Description   : Reset Enemy if to passes 0 to Right of Screen
*-----------------------------------------------------------
RESET_ENEMY_POSITION:
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY_X     ; Enemy X Position
    
 RESET_ENEMY_POSITION2:   
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY_X     ; Enemy X Position
    
 RESET_ENEMY_POSITION3:   
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY_X     ; Enemy X Position
    
RESET_ENEMY_POSITION4:
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY_X     ; Enemy X Position
    
RESET_ENEMY_POSITION5:
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY_X     ; Enemy X Position
    

    

    RTS
    
*-----------------------------------------------------------
BLOCK_PLAYER_X_LEFT:
    CLR.L   D1
    MOVE.W  #00,        D1
    MOVE.L  D1,         PLAYER_X
    RTS
*-----------------------------------------------------------


*-----------------------------------------------------------
BLOCK_PLAYER_X_RIGHT:
    CLR.L   D1
    MOVE.W  #600,        D1
    MOVE.L  D1,         PLAYER_X
    RTS
*-----------------------------------------------------------

*-----------------------------------------------------------
BLOCK_PLAYER_Y_UP:
    CLR.L   D1
    MOVE.W  #160,        D1
    MOVE.L  D1,         PLAYER_Y
    RTS
*-----------------------------------------------------------

*-----------------------------------------------------------
BLOCK_PLAYER_Y_DOWN:
    CLR.L   D1
    MOVE.W  #480,        D1
    MOVE.L  D1,         PLAYER_Y
    RTS
*-----------------------------------------------------------



*-----------------------------------------------------------
* Subroutine    : Draw
* Description   : Draw Screen
*-----------------------------------------------------------
DRAW: 

    BSR     DRAW_ENEMY               ; Draw Enemy
    BSR     DRAW_ENEMY_2             ; Draw Enemy 2
    BSR     DRAW_ENEMY_3             ; Draw Enemy 3
    BSR     DRAW_ENEMY_4             ; Draw Enemy 4
    BSR     DRAW_ENEMY_5

    ; Enable back buffer
    MOVE.B  #94,        D0
    TRAP    #15

    ; Clear the screen
    MOVE.B	#TC_CURSR_P,D0          ; Set Cursor Position
	MOVE.W	#$FF00,     D1          ; Clear contents
	TRAP    #15                     ; Trap (Perform action)

    BSR     DRAW_PLYR_DATA          ; Draw Draw Score, HUD, Player X and Y
    BSR     DRAW_PLAYER             ; Draw Player
    BSR     DRAW_ENEMY              ; Draw Enemy
    BSR     DRAW_HEALTH_BLOCK
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Draw Player Data
* Description   : Draw Player X, Y, Velocity, Gravity and OnGround
*-----------------------------------------------------------
DRAW_PLYR_DATA:
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)

    ; Player Score Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0201,     D1          ; Col 02, Row 01
    TRAP    #15                     ; Trap (Perform action)
    LEA     SCORE_MSG,  A1          ; Score Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; Player Score Value
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0901,     D1          ; Col 09, Row 01
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLAYER_SCORE,D1         ; Move Score to D1.L
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player X Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0202,     D1          ; Col 02, Row 02
    TRAP    #15                     ; Trap (Perform action)
    LEA     X_MSG,      A1          ; X Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player X
    MOVE.B  #TC_CURSR_P, D0          ; Set Cursor Position
    MOVE.W  #$0502,     D1          ; Col 05, Row 02
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLAYER_X,   D1          ; Move X to D1.L
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player Y Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$1002,     D1          ; Col 10, Row 02
    TRAP    #15                     ; Trap (Perform action)
    LEA     Y_MSG,      A1          ; Y Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player Y
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$1202,     D1          ; Col 12, Row 02
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLAYER_Y,   D1          ; Move X to D1.L
    TRAP    #15                     ; Trap (Perform action) 

    ; Player Velocity Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0203,     D1          ; Col 02, Row 03
    TRAP    #15                     ; Trap (Perform action)
    LEA     V_MSG,      A1          ; Velocity Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player Velocity
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0503,     D1          ; Col 05, Row 03
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLYR_VELOCITY,D1        ; Move X to D1.L
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player Gravity Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$1003,     D1          ; Col 10, Row 03
    TRAP    #15                     ; Trap (Perform action)
    LEA     G_MSG,      A1          ; G Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player Gravity
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$1203,     D1          ; Col 12, Row 03
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLYR_GRAVITY,D1         ; Move Gravity to D1.L
    TRAP    #15                     ; Trap (Perform action)

    ; Player On Ground Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #22,     D1          ; Col 10, Row 03
    TRAP    #15                     ; Trap (Perform action)
    LEA     GND_MSG,    A1          ; On Ground Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player On Ground Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #10,     D1          ; Col 10, Row 03
    TRAP    #15                     ; Trap (Perform action)
    LEA     GND_MSG,    A1          ; On Ground Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player On Ground Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #2,     D1          ; Col 10, Row 03
    TRAP    #15                     ; Trap (Perform action)
    LEA     GND_MSG,    A1          ; On Ground Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)


    
    ; Player On Ground
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0604,     D1          ; Col 06, Row 04
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLYR_ON_GND,D1          ; Move Play on Ground ? to D1.L
    TRAP    #15                     ; Trap (Perform action)

    ; Show Keys Pressed
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$2001,     D1          ; Col 20, Row 1
    TRAP    #15                     ; Trap (Perform action)
    LEA     KEYCODE_MSG, A1         ; Keycode
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; Show KeyCode
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$3001,     D1          ; Col 30, Row 1
    TRAP    #15                     ; Trap (Perform action)    
    MOVE.L  CURRENT_KEY,D1          ; Move Key Pressed to D1
    MOVE.B  #03,        D0          ; Display the contents of D1
    TRAP    #15                     ; Trap (Perform action)

    ; Show if Update is Running
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0205,     D1          ; Col 02, Row 05
    TRAP    #15                     ; Trap (Perform action)
    LEA     UPDATE_MSG, A1          ; Update
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; Show if Draw is Running
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0206,     D1          ; Col 02, Row 06
    TRAP    #15                     ; Trap (Perform action)
    LEA     DRAW_MSG,   A1          ; Draw
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; Show if Idle is Running
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0207,     D1          ; Col 02, Row 07
    TRAP    #15                     ; Trap (Perform action)
    LEA     IDLE_MSG,   A1          ; Move Idle Message to A1
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    RTS  
    
*-----------------------------------------------------------
* Subroutine    : Player is on Ground
* Description   : Check if the Player is on or off Ground
*-----------------------------------------------------------
IS_PLAYER_ON_GND:
    ; Check if Player is on Ground
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    CLR.L   D2                      ; Clear contents of D2 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  PLAYER_Y,   D2          ; Player Y Position
    CMP     D1,         D2          ; Compare middle of Screen with Players Y Position 
    BGE     SET_ON_GROUND           ; The Player is on the Ground Plane
    BLT     SET_OFF_GROUND          ; The Player is off the Ground
    RTS                             ; Return to subroutine


*-----------------------------------------------------------
* Subroutine    : On Ground
* Description   : Set the Player On Ground
*-----------------------------------------------------------
SET_ON_GROUND:
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  D1,         PLAYER_Y    ; Reset the Player Y Position
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  #00,        D1          ; Player Velocity
    MOVE.L  D1,         PLYR_VELOCITY ; Set Player Velocity
    MOVE.L  #GND_TRUE,  PLYR_ON_GND ; Player is on Ground
    RTS

*-----------------------------------------------------------
* Subroutine    : Off Ground
* Description   : Set the Player Off Ground
*-----------------------------------------------------------
SET_OFF_GROUND:
    MOVE.L  #GND_FALSE, PLYR_ON_GND ; Player if off Ground
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Jump
* Description   : Perform a Jump
*-----------------------------------------------------------
MOVE_LEFT:
    SUB.L   #05, PLAYER_X        ; Return to subroutine
    RTS
MOVE_RIGHT:
    ADD.L   #03, PLAYER_X        ; Return to subroutine
    RTS
MOVE_UP:
    SUB.L   #03, PLAYER_Y        ; Return to subroutine
    RTS
MOVE_DOWN:
    ADD.L   #03, PLAYER_Y        ; Return to subroutine
    RTS


*-----------------------------------------------------------
* Subroutine    : Idle
* Description   : Perform a Idle
*----------------------------------------------------------- 
IDLE:
    BSR     PLAY_RUN                ; Play Run Wav
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutines   : Sound Load and Play
* Description   : Initialise game sounds into memory 
* Current Sounds are RUN, JUMP and Opps for Collision
*-----------------------------------------------------------
RUN_LOAD:
    LEA     RUN_WAV,    A1          ; Load Wav File into A1
    MOVE    #RUN_INDEX, D1          ; Assign it INDEX
    MOVE    #71,        D0          ; Load into memory
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

PLAY_RUN:
    MOVE    #RUN_INDEX, D1          ; Load Sound INDEX
    MOVE    #72,        D0          ; Play Sound
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

JUMP_LOAD:
    LEA     JUMP_WAV,   A1          ; Load Wav File into A1
    MOVE    #JMP_INDEX, D1          ; Assign it INDEX
    MOVE    #71,        D0          ; Load into memory
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

PLAY_JUMP:
    MOVE    #JMP_INDEX, D1          ; Load Sound INDEX
    MOVE    #72,        D0          ; Play Sound
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

OPPS_LOAD:
    LEA     OPPS_WAV,   A1          ; Load Wav File into A1
    MOVE    #OPPS_INDEX,D1          ; Assign it INDEX
    MOVE    #71,        D0          ; Load into memory
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

PLAY_OPPS:
    MOVE    #OPPS_INDEX,D1          ; Load Sound INDEX
    MOVE    #72,        D0          ; Play Sound
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine
    
    
*----------------------------------------------------------
DRAW_HEALTH:
    ; Set Cursor Position for Health Value
    MOVE.B  #TC_CURSR_P, D0      ; Command to set cursor position
    MOVE.W  #1002, D1            ; Position at Column 10, Row 02 for example
    TRAP    #15                  ; Execute the trap task

    ; Fetch current health
    MOVE.L  PLAYER_HEALTH, D1    ; Load current health value into D1

    ; Convert and display the number
    MOVE.B  #3, D0               ; Task number for displaying number in D1
    TRAP    #15                  ; Display the number at the cursor position

    RTS                          ; Return from subroutine
    SUB.L #HEALTH_LOSS, PLAYER_HEALTH
    CMP.L #0, PLAYER_HEALTH
    BGE   .noNegativeHealth
    MOVE.L #0, PLAYER_HEALTH
    .noNegativeHealth:

; Example of gaining health
    ADD.L #HEALTH_GAIN, PLAYER_HEALTH
    CMP.L #MAX_HEALTH, PLAYER_HEALTH
    BLE   .noExceedMax
    MOVE.L #MAX_HEALTH, PLAYER_HEALTH
    .noExceedMax:

; Check if the player's health is zero or less
    MOVE.L PLAYER_HEALTH, D1
    CMP.L #0, D1
   ; BLE   GAME_OVER
    DRAW_HEALTH_BLOCK:
    
    ; Set Pixel Colors (example colors)
    MOVE.L  #GREEN,     D1     ; Set health block color
    MOVE.B  #70,        D0     ; Task for color
    TRAP    #15                ; Trap (Perform action)
    
    ; Draw health block
    MOVE.L  HEALTH_BLOCK_X, D1
    MOVE.L  HEALTH_BLOCK_Y, D2
    MOVE.L  HEALTH_BLOCK_X, D3
    ADD.L   #HEALTH_BLOCK_W, D3 ; Calculate X + Width
    MOVE.L  HEALTH_BLOCK_Y, D4
    ADD.L   #HEALTH_BLOCK_H, D4 ; Calculate Y + Height
    MOVE.B  #87,        D0     ; Draw rectangle
    TRAP    #15                ; Trap (Perform action)

*-----------------------------------------------------------
* Subroutine    : Draw Player
* Description   : Draw Player Square
*-----------------------------------------------------------
DRAW_PLAYER:
    ; Set Pixel Colors
    MOVE.L  #BLUE,     D1          ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)

    ; Set X, Y, Width and Height
    MOVE.L  PLAYER_X,   D1          ; X
    MOVE.L  PLAYER_Y,   D2          ; Y
    MOVE.L  PLAYER_X,   D3
    ADD.L   #PLYR_W_INIT,   D3      ; Width
    MOVE.L  PLAYER_Y,   D4 
    ADD.L   #PLYR_H_INIT,   D4      ; Height
    
    ; Draw Player
    MOVE.B  #87,        D0          ; Draw Player
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Draw Enemy
* Description   : Draw Enemy Square
*-----------------------------------------------------------
DRAW_ENEMY:
    ; Set Pixel Colors
    CLR     D1
    MOVE.L  #RED,       D1          ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)
    
    


    ; Set X, Y, Width and Height
    MOVE.L  ENEMY_X,    D1          ; X
    MOVE.L  ENEMY_Y,    D2          ; Y
    ;MOVE.W  #40,         D3
    MOVE.L  ENEMY_X,    D3
    ADD.L   #ENMY_W_INIT,   D3      ; Width
    MOVE.L  ENEMY_Y,    D4 
    ADD.L   #ENMY_H_INIT,   D4      ; Height
    
    ; Draw Enemy 
                     ; Trap (Perform action)
    MOVE.B  #88,        D0          ; Draw Enemy
    TRAP    #15                     ; Trap (Perform action)
    
    
    DRAW_ENEMY_2:
    ; Set Pixel Colors
    CLR D1
    MOVE.L  #WHITE,      D1         ; Enemy colour
    MOVE.B  #80,        D0          ; Task for enemy Color
    TRAP    #15                     ; Trap (Perform action)

    ; Set X, Y, Width and Height
    MOVE.L  ENMY2_X,    D1          ; Copy X position to D1
    MOVE.L  ENMY2_Y,    D2          ; Copy Y position to D2
    MOVE.L  ENMY2_X,    D3          ; Copy X position to D3
    ADD.L   #ENMY2_W_INIT,   D3      ; Add width to X to get right boundary
    MOVE.L  ENMY2_Y,    D4          ; Copy Y position to D4
    ADD.L   #ENMY2_H_INIT,   D4      ; Add height to Y to get bottom boundary
    
    ; Draw Enemy    
    MOVE.B  #87,        D0          ; Draw Enemy
    TRAP    #15                     ; Trap (Perform action)
    
DRAW_ENEMY_3:
    ; Set Pixel Colors
    MOVE.L  #GREEN,     D1          ; Set enemy color
    MOVE.B  #80,        D0          ; Task for enemy Color
    TRAP    #15                     ; Trap (Perform action)

   ; Set X, Y, Width and Height
    MOVE.L  ENMY3_X,    D1          ; Copy X position to D1
    MOVE.L  ENMY3_Y,    D2          ; Copy Y position to D2
    MOVE.L  ENMY3_X,    D3          ; Copy X position to D3
    ADD.L   #ENMY3_W_INIT,   D3       ; Add width to X to get right boundary
    MOVE.L  ENEMY_Y,    D4          ; Copy Y position to D4
    ADD.L   #ENMY3_H_INIT,   D4       ; Add height to Y to get bottom boundary
    
    ; Draw Enemy    
    MOVE.B  #87,        D0          ; Draw Enemy
    TRAP    #15                     ; Trap (Perform action)
    
DRAW_ENEMY_4:
    ; Set Pixel Colors
    MOVE.L  #RED,       D1          ; Set enemy color
    MOVE.B  #80,        D0          ; Task for enemy Color
    TRAP    #15                     ; Trap (Perform action)

   ; Set X, Y, Width and Height
    MOVE.L  ENMY4_X,    D1          ; Copy X position to D1
    MOVE.L  ENMY4_Y,    D2          ; Copy Y position to D2
    MOVE.L  ENMY4_X,    D3          ; Copy X position to D3
    ADD.L   #ENMY4_W_INIT,   D3      ; Add width to X to get right boundary
    MOVE.L  ENMY4_Y,    D4          ; Copy Y position to D4
    ADD.L   #ENMY4_H_INIT,   D4      ; Add height to Y to get bottom boundary
    
    ; Draw Enemy    
    MOVE.B  #87,        D0          ; Draw Enemy
    TRAP    #15                     ; Trap (Perform action)
    
DRAW_ENEMY_5:
    ; Set Pixel Colors
    MOVE.L  #RED,       D1          ; Set enemy color
    MOVE.B  #80,        D0          ; Task for enemy Color
    TRAP    #15                     ; Trap (Perform action)

   ; Set X, Y, Width and Height
    MOVE.L  ENMY5_X,    D1          ; Copy X position to D1
    MOVE.L  ENMY5_Y,    D2          ; Copy Y position to D2
    MOVE.L  ENMY5_X,    D3          ; Copy X position to D3
    ADD.L   #ENMY5_W_INIT,   D3      ; Add width to X to get right boundary
    MOVE.L  ENMY4_Y,    D4          ; Copy Y position to D4
    ADD.L   #ENMY5_H_INIT,   D4      ; Add height to Y to get bottom boundary
    
    ; Draw Enemy    
    MOVE.B  #87,        D0          ; Draw Enemy
    TRAP    #15                     ; Trap (Perform action)



    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Collision Check
* Description   : Axis-Aligned Bounding Box Collision Detection
* Algorithm checks for overlap on the 4 sides of the Player and 
* Enemy rectangles
* PLAYER_X <= ENEMY_X + ENEMY_W &&
* PLAYER_X + PLAYER_W >= ENEMY_X &&
* PLAYER_Y <= ENEMY_Y + ENEMY_H &&
* PLAYER_H + PLAYER_Y >= ENEMY_Y
*-----------------------------------------------------------
CHECK_COLLISIONS:
    CLR.L   D1                      ; Clear D1
    CLR.L   D2                      ; Clear D2
PLAYER_X_LTE_TO_ENEMY_X_PLUS_W:
    MOVE.L  PLAYER_X,   D1          ; Move Player X to D1
    MOVE.L  ENEMY_X,    D2          ; Move Enemy X to D2
    ADD.L   ENMY_W_INIT,D2          ; Set Enemy width X + Width
    CMP.L   D1,         D2          ; Do the Overlap ?
    BLE     PLAYER_X_PLUS_W_LTE_TO_ENEMY_X  ; Less than or Equal ?
        
    
    MOVE.L  PLAYER_X,   D1          ; Move Player X to D1
    MOVE.L  ENMY2_X,    D2          ; Move Enemy X to D2
    ADD.L   ENMY_W_INIT,D2          ; Set Enemy width X + Width
    CMP.L   D1,         D2          ; Do the Overlap ?
    BLE     PLAYER_X_PLUS_W_LTE_TO_ENEMY_X_2  ; Less than or Equal ?
    
    
    MOVE.L  PLAYER_X,   D1          ; Move Player X to D1
    MOVE.L  ENMY3_X,    D2          ; Move Enemy X to D2
    ADD.L   ENMY_W_INIT,D2          ; Set Enemy width X + Width
    CMP.L   D1,         D2          ; Do the Overlap ?
    BLE     PLAYER_X_PLUS_W_LTE_TO_ENEMY_X_3  ; Less than or Equal ?
    
    
    MOVE.L  PLAYER_X,   D1          ; Move Player X to D1
    MOVE.L  ENMY4_X,    D2          ; Move Enemy X to D2
    ADD.L   ENMY_W_INIT,D2          ; Set Enemy width X + Width
    CMP.L   D1,         D2          ; Do the Overlap ?
    BLE     PLAYER_X_PLUS_W_LTE_TO_ENEMY_X_4  ; Less than or Equal ?
    BRA     COLLISION_CHECK_DONE
    
    MOVE.L  PLAYER_X,   D1          ; Move Player X to D1
    MOVE.L  ENMY5_X,    D2          ; Move Enemy X to D2
    ADD.L   ENMY_W_INIT,D2          ; Set Enemy width X + Width
    CMP.L   D1,         D2          ; Do the Overlap ?
    BLE     PLAYER_X_PLUS_W_LTE_TO_ENEMY_X_5  ; Less than or Equal ?
    BRA     COLLISION_CHECK_DONE    ; If not no collision
    
    
PLAYER_X_PLUS_W_LTE_TO_ENEMY_X:     ; Check player is not  
    ADD.L   PLYR_W_INIT,D1          ; Move Player Width to D1
    MOVE.L  ENEMY_X,    D2          ; Move Enemy X to D2
    CMP.L   D1,         D2          ; Do they OverLap ?
    BGE     PLAYER_Y_LTE_TO_ENEMY_Y_PLUS_H  ; Less than or Equal
        ; If not no collision   
    
    PLAYER_X_PLUS_W_LTE_TO_ENEMY_X_2:     ; Check player is not  
    ADD.L   PLYR_W_INIT,D1          ; Move Player Width to D1
    MOVE.L  ENEMY_X,    D2          ; Move Enemy X to D2
    CMP.L   D1,         D2          ; Do they OverLap ?
    BGE     PLAYER_Y_LTE_TO_ENEMY_Y_PLUS_H  ; Less than or Equal
        ; If not no collision   
    
    PLAYER_X_PLUS_W_LTE_TO_ENEMY_X_3:     ; Check player is not  
    ADD.L   PLYR_W_INIT,D1          ; Move Player Width to D1
    MOVE.L  ENEMY_X,    D2          ; Move Enemy X to D2
    CMP.L   D1,         D2          ; Do they OverLap ?
    BGE     PLAYER_Y_LTE_TO_ENEMY_Y_PLUS_H  ; Less than or Equal
    
    ; If not no collision  
 
    PLAYER_X_PLUS_W_LTE_TO_ENEMY_X_4:     ; Check player is not  
    ADD.L   PLYR_W_INIT,D1          ; Move Player Width to D1
    MOVE.L  ENEMY_X,    D2          ; Move Enemy X to D2
    CMP.L   D1,         D2          ; Do they OverLap ?
    BGE     PLAYER_Y_LTE_TO_ENEMY_Y_PLUS_H  ; Less than or Equal
    BRA     COLLISION_CHECK_DONE    ; If not no collision   
    
    PLAYER_X_PLUS_W_LTE_TO_ENEMY_X_5:     ; Check player is not  
    ADD.L   PLYR_W_INIT,D1          ; Move Player Width to D1
    MOVE.L  ENEMY_X,    D2          ; Move Enemy X to D2
    CMP.L   D1,         D2          ; Do they OverLap ?
    BGE     PLAYER_Y_LTE_TO_ENEMY_Y_PLUS_H  ; Less than or Equal
    BRA     COLLISION_CHECK_DONE    ; If not no collision   




PLAYER_Y_LTE_TO_ENEMY_Y_PLUS_H:     
    MOVE.L  PLAYER_Y,   D1          ; Move Player Y to D1
    MOVE.L  ENEMY_Y,    D2          ; Move Enemy Y to D2
    ADD.L   ENMY_H_INIT,D2          ; Set Enemy Height to D2
    CMP.L   D1,         D2          ; Do they Overlap ?
    BLE     PLAYER_Y_PLUS_H_LTE_TO_ENEMY_Y  ; Less than or Equal
    BRA     COLLISION_CHECK_DONE    ; If not no collision 
PLAYER_Y_PLUS_H_LTE_TO_ENEMY_Y:     ; Less than or Equal ?
    ADD.L   PLYR_H_INIT,D1          ; Add Player Height to D1
    MOVE.L  ENEMY_Y,    D2          ; Move Enemy Height to D2  
    CMP.L   D1,         D2          ; Do they OverLap ?
    BGE     COLLISION               ; Collision !
    BRA     COLLISION_CHECK_DONE    ; If not no collision
    
    ;BSR CHECK_HEALTH_COLLISIONS
    
COLLISION_CHECK_DONE:               ; No Collision Update points
    ADD.L   #POINTS,    D1          ; Move points upgrade to D1
    ADD.L   PLAYER_SCORE,D1         ; Add to current player score
    MOVE.L  D1, PLAYER_SCORE        ; Update player score in memory
    RTS                             ; Return to subroutine

COLLISION:
    BSR     PLAY_OPPS               ; Play Opps Wav
    MOVE.L  #00, PLAYER_SCORE       ; Reset Player Score
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : EXIT
* Description   : Exit message and End Game
*-----------------------------------------------------------
EXIT:
    ; Show if Exiting is Running
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$4004,     D1          ; Col 40, Row 1
    TRAP    #15                     ; Trap (Perform action)
    LEA     EXIT_MSG,   A1          ; Exit
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #TC_EXIT,   D0          ; Exit Code
    TRAP    #15                     ; Trap (Perform action)
    SIMHALT

*-----------------------------------------------------------
* Section       : Messages
* Description   : Messages to Print on Console, names should be
* self documenting
*-----------------------------------------------------------
SCORE_MSG       DC.B    'Score : ', 0       ; Score Message
KEYCODE_MSG     DC.B    'KeyCode : ', 0     ; Keycode Message
JUMP_MSG        DC.B    'Jump....', 0       ; Jump Message

IDLE_MSG        DC.B    'Idle....', 0       ; Idle Message
UPDATE_MSG      DC.B    'Update....', 0     ; Update Message
DRAW_MSG        DC.B    'Draw....', 0       ; Draw Message

X_MSG           DC.B    'X:', 0             ; X Position Message
Y_MSG           DC.B    'Y:', 0             ; Y Position Message
V_MSG           DC.B    'V:', 0             ; Velocity Position Message
G_MSG           DC.B    'G:', 0             ; Gravity Position Message
GND_MSG         DC.B    '-------------------------------------------------------------------------------', 0           ; On Ground Position Message

EXIT_MSG        DC.B    'Exiting....', 0    ; Exit Message

*-----------------------------------------------------------
* Section       : Graphic Colors
* Description   : Screen Pixel Color
*-----------------------------------------------------------
BLUE           EQU     $0000FF00
RED            EQU     $00FFFFF0
GREEN          EQU     $0000FF00
WHITE          EQU     $00FFFFFF
    
*-----------------------------------------------------------
* Section       : Screen Size
* Description   : Screen Width and Height
*-----------------------------------------------------------
SCREEN_W        DS.W    01  ; Reserve Space for Screen Width
SCREEN_H        DS.W    01  ; Reserve Space for Screen Height

*-----------------------------------------------------------
* Section       : Keyboard Input
* Description   : Used for storing Keypresses
*-----------------------------------------------------------
CURRENT_KEY     DS.L    01  ; Reserve Space for Current Key Pressed

*-----------------------------------------------------------
* Section       : Character Positions
* Description   : Player and Enemy Position Memory Locations
*-----------------------------------------------------------
PLAYER_X        DS.L    01  ; Reserve Space for Player X Position
PLAYER_Y        DS.L    01  ; Reserve Space for Player Y Position
PLAYER_SCORE    DS.L    01  ; Reserve Space for Player Score

PLYR_VELOCITY   DS.L    01  ; Reserve Space for Player Velocity
PLYR_GRAVITY    DS.L    01  ; Reserve Space for Player Gravity
PLYR_ON_GND     DS.L    01  ; Reserve Space for Player on Ground

ENEMY_X         DS.L    02  ; Reserve Space for Enemy X Position
ENEMY_Y         DS.L    02  ; Reserve Space for Enemy Y Position

ENMY2_X        DS.L    01  ; Reserve Space for Enemy X Position
ENMY2_Y        DS.L    01  ; Reserve Space for Enemy Y Position


ENMY3_X        DS.L    01  ; Reserve Space for Enemy X Position
ENMY3_Y        DS.L    01  ; Reserve Space for Enemy Y Position

ENMY4_X        DS.L    01  ; Reserve Space for Enemy X Position
ENMY4_Y        DS.L    01  ; Reserve Space for Enemy Y Position

ENMY5_X        DS.L    01  ; Reserve Space for Enemy X Position
ENMY5_Y        DS.L    01  ; Reserve Space for Enemy Y Position

*-----------------------------------------------------------
* Section       : Sounds
* Description   : Sound files, which are then loaded and given
* an address in memory, they take a longtime to process and play
* so keep the files small. Used https://voicemaker.in/ to 
* generate and Audacity to convert MP3 to WAV
*-----------------------------------------------------------
JUMP_WAV        DC.B    'jump.wav',0        ; Jump Sound
RUN_WAV         DC.B    'run.wav',0         ; Run Sound
OPPS_WAV        DC.B    'opps.wav',0        ; Collision Opps

*-----------------------------------------------------------
* sECTION: Health block
HEALTH_BLOCK_X  DS.L 01  ; X position of the health block
HEALTH_BLOCK_Y  DS.L 01  ; Y position of the health block
PLAYER_HEALTH   DS.L 01  ; Player's health

* Constants
INITIAL_HEALTH EQU 100  ; Initial health of the player.
MAX_HEALTH     EQU 200  ; Maximum health the player can have.
HEALTH_LOSS    EQU 10   ; Health lost per enemy collision.
HEALTH_GAIN    EQU 20   ; Health gained per health pickup.
    END    START        ; last line of source












*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
