Scriptname CompanionGiveStuffScript extends Quest Conditional

ReferenceAlias Property Companion Auto Const mandatory
FormList Property lootItemsCommon Auto Const
FormList Property lootItemsRare Auto Const
FormList Property lootItemsUncommon Auto Const
;ActorValue Property CarryWeight Auto Const

float distanceCheck = 115.0

;ObjectReference curObjectLocal

Event onInit()
	Debug.Trace("CompanionGiveStuff - onInit")
	StartTimer(1, 0)
	Debug.Trace("CompanionGiveStuff - StartTimer")
endEvent

Event OnTimer(int timerID)
	If (timerID == 0)
		ObjectReference curObject = Game.GetPlayerGrabbedRef()

		If curObject != None
			Debug.Trace("CompanionGiveStuff - curObject = " + curObject)
			Debug.Trace("GetLength = " + curObject.GetLength())
			Debug.Trace("GetWidth = " + curObject.GetWidth())
			Debug.Trace("GetHeight = " + curObject.GetHeight())
			Debug.Trace("GetBaseObject = " + curObject.GetBaseObject())

			;curObjectLocal = curObject

			Form BaseObject = curObject.getBaseObject()

			If ((BaseObject is Form && (lootItemsCommon.HasForm(BaseObject) || lootItemsRare.HasForm(BaseObject) || lootItemsUncommon.HasForm(BaseObject))) || BaseObject is Weapon || BaseObject is Armor)
				Debug.Trace("is lootItem, Weapon or Armor")
				RegisterForDistanceLessThanEvent(Companion.GetActorRef(), curObject, distanceCheck)
				Debug.Trace("distanceCheck = " + distanceCheck)
			Else
				Debug.Trace("not lootItem, Weapon or Armor")
			EndIf

			RegisterForRemoteEvent(curObject, "OnRelease")
			curObject = None

			;StartTimer(0.2, 1)

		Else
			StartTimer(1, 0)
		EndIf
	;/ElseIf (timerID == 1)
		Debug.Trace("GetDistance = " + curObjectLocal.GetDistance(Companion.GetActorRef()))
		StartTimer(0.2, 1)/;
	EndIf
endEvent

Event OnDistanceLessThan(ObjectReference akObj1, ObjectReference akObj2, float afDistance)
	Debug.Trace("CompanionGiveStuff  - OnDistanceLessThan")
	Debug.Trace("akObj2 = " + akObj1)
	Debug.Trace("akObj2 = " + akObj2)
	Debug.Trace("afDistance = " + afDistance)

	Debug.Trace("Waiting 1.5 seconds")
	Utility.Wait(1.5)

	If (Game.GetPlayerGrabbedRef() == None)
		Debug.Trace("No longer holding an object!")
	Else
		If (akObj1.GetDistance(akObj2) <= distanceCheck)
			Debug.Trace("Done waiting. Add Item. GetDistance = " + akObj1.GetDistance(akObj2))

			;Debug.Trace("CarryWeight = " + akObj1.GetValue(CarryWeight))
			;Debug.Trace("Base CarryWeight = " + akObj1.GetBaseValue(CarryWeight))
			;Debug.Trace("GetInventoryValue = " + akObj1.GetInventoryValue())
			If akObj2.IsQuestItem() == false
				akObj1.AddItem(akObj2)
			EndIf
		Else
			Debug.Trace("Done waiting. Distance changed!. GetDistance = " + akObj1.GetDistance(akObj2))
			RegisterForDistanceLessThanEvent(akObj1, akObj2, distanceCheck)
		EndIf
	EndIf
endEvent

Event ObjectReference.OnRelease(ObjectReference source)
	Debug.Trace("CompanionGiveStuff - OnRelease = " + source)

	UnregisterForDistanceEvents(Companion.GetActorRef(), source)

	UnRegisterForRemoteEvent(source, "OnRelease")

	StartTimer(1, 0)
	;CancelTimer(1)
EndEvent
