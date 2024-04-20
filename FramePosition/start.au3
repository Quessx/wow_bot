Global $WinName = "World of Warcraft"
Global $state = "stop" 
Opt("PixelCoordMode", 2) ;Отсчет координат пикселей от левого верхнего угла клиентской части окна
Opt("MouseCoordMode", 2) ;Отсчет координат мыши от левого верхнего угла клиентской части окна
HotKeySet("{NUMPAD1}", "GoRotate")
HotKeySet("{NUMPAD3}", "_Exit")

WinActivate($WinName)
WinWaitActive($WinName)	
#include <MsgBoxConstants.au3>
;~ red 16711680
;~ green 65280
$upColor = PixelGetColor(98,137)
$leftColor = PixelGetColor(76,209)
$rightColor = PixelGetColor(126,209)
$manaColor = PixelGetColor(77,261) ;~ def 255 blue
$targetColor = PixelGetColor(126,236) ;~ def 11382016 yellow
$castSpell = PixelGetColor(101,286)

;~ MsgBox($MB_ICONINFORMATION, '', $targetColor)

;~ Exit
;~ Running()
While 1
	sleep(10)
	Running(); бесконечный вызов этой функции, которая делает необходимое в данный момент действие
WEnd

Func _Exit()
    Exit
EndFunc

Func GoRotate()
	$state = "rotating" 
EndFunc
Func LetsGo()

EndFunc
Func  Running()
	Switch $state
		Case  "rotating" 
			Rotating()
		Case "startrunning"
		Case "attack"
			AttackMob()
	EndSwitch
EndFunc

Func Rotating()
	While $state = "rotating"
		$upColor = PixelGetColor(96,136)
		$leftColor = PixelGetColor(78,184)
		$rightColor = PixelGetColor(126,181)
		$manaColor = PixelGetColor(77,230)
        $targetColor = PixelGetColor(126,236)

		if $targetColor = 65280 Then
			Send("{UP up}")
			Send("{LEFT up}")
			Send("{RIGHT up}")

			$state = "attack"
			;~ AttackMob()
		ElseIf $upColor = 65280 Then
			Send("{UP down}")
			Send("{TAB down}")
			Send("{TAB up}")
			While $upColor = 65280
				$upColor = PixelGetColor(96,136)
				$targetColor = PixelGetColor(126,236)
				Send("{TAB down}")
				Send("{TAB up}")
				if $targetColor = 65280 Then
					Send("{UP up}")
					$state = "attack"
				EndIf
				Sleep(2)
			Wend
			;~ While $upColor = 65280
			;~ 	Send("{TAB down}")
			;~ 	Send("{TAB up}")
			;~ 	sleep(10)
			;~ WEnd
			Send("{UP up}")
			;~ Send("{TAB up}")
		ElseIf $leftColor = 65280 Then; поворот налево
			Send("{LEFT down}"); жмем кнопку "влево" и засыпаем пока не погаснет сигнал семафора, поворот налево - плавный, иногда поворачивает лишнего из-за этого
			sleep(20)
			Send("{LEFT up}")
		ElseIf $rightColor = 65280 Then ; поворот направо - не плавный, чтобы более точно поворачивать
			Send("{RIGHT down}");
			sleep(20);
			Send("{RIGHT up}");
		EndIf
	WEnd
EndFunc

Func AttackMob()
	Send("{UP up}")
	While $state = 'attack'
		$targetColor = PixelGetColor(126,260)
		$upColor = PixelGetColor(96,136)
		$leftColor = PixelGetColor(78,184)
		$rightColor = PixelGetColor(126,181)
		$castSpell = PixelGetColor(101,286)

		if $upColor = 65280 or $leftColor = 65280 or $rightColor = 65280 Then
			$state = 'rotating'
		ElseIf $targetColor = 65280 and $castSpell = 16711680 Then
			Send("{` up}")
			if $castSpell = 16711680 Then
				Send("{` down}")
				Send("{1 down}")
				Sleep(1110)
				Send("{1 up}")
				Send("{2 down}")
				Sleep(1110)
				Send("{V down}")
				Sleep(1101)
				Send("{V up}")
				Send("{3 down}")
			EndIf
			;~ Sleep(1110)
			
			;~ Sleep(1100)
			;~ Send("{1 down}")
			;~ Sleep(1110)
			;~ Send("{2 down}")
			;~ Sleep(2656)
			;~ Send("{3 down}")
			;~ Sleep(15)
			;~ Send("{V up}")
			;~ Sleep(1100)
			;~ While $targetColor = 65280
			;~ 	Sleep(20)
			;~ WEnd
		EndIf
	WEnd
EndFunc