	ifdef BuildGMB
HardwareJoystick equ 1
		read "..\SrcGB\GB_V1_ReadJoystick.asm"
	endif
	ifdef BuildGBC
HardwareJoystick equ 1
		read "..\SrcGB\GB_V1_ReadJoystick.asm"
	endif
	
	
	ifdef BuildSMS
HardwareJoystick equ 1
		read "..\SrcSMS\SMS_V1_ReadJoystick.asm"
	endif
	ifdef BuildSGG
HardwareJoystick equ 1
		read "..\SrcSMS\SMS_V1_ReadJoystick.asm"
	endif

	
	ifndef HardwareJoystick
		;no hardware joystick, we're using a keymatrix system
		read "..\SrcALL\Multiplatform_ScanKeys.asm"
		read "..\SrcALL\Multiplatform_KeyboardDriver.asm"
		read "..\SrcALL\Multiplatform_ReadJoystickKeypressHandler.asm"

	endif
	
	
	
	
	
	