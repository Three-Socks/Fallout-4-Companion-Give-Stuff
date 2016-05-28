Scriptname CompanionGiveStuffScript extends Quest Conditional

ReferenceAlias Property Companion Auto Const mandatory
ReferenceAlias Property GiveItemActor Auto Const
FormList Property lootItemsCommon Auto Const
FormList Property lootItemsRare Auto Const
FormList Property lootItemsUncommon Auto Const
Message Property CompanionGiveStuffMessage Auto
;ActorValue Property CarryWeight Auto Const

float distanceCheck = 115.0

;ObjectReference curObjectLocal

Event onInit()
	Debug.Trace("CompanionGiveStuff - onInit")
	StartTimer(1, 0)
	Debug.Trace("CompanionGiveStuff - StartTimer")
endEvent

Function EFF_DistanceEvent(bool register, ObjectReference curObject)
	ScriptObject FollowersExtension = Game.GetFormFromFile(0x01000EFF, "EFF.esp")
	ScriptObject EFF_Script = FollowersExtension.CastAs("EFF:CompanionManager")

	Var result = EFF_Script.GetPropertyValue("CompanionList")
	RefCollectionAlias EFF_CompanionList = result as RefCollectionAlias

	Debug.Trace("EFF_Companion = " + EFF_CompanionList)

	If EFF_CompanionList
		int i = 0
		while (i < EFF_CompanionList.GetCount())
			Actor CompanionActor
			CompanionActor = (EFF_CompanionList.GetAt(i) as Actor)

			Debug.Trace(i + " - EFF_CompanionActor = " + CompanionActor)

			If register
				RegisterForDistanceLessThanEvent(CompanionActor, curObject, distanceCheck)
				Debug.Trace("Register - curObject = " + curObject)
			Else
				UnregisterForDistanceEvents(CompanionActor, curObject)
				Debug.Trace("Unregister - curObject = " + curObject)
			EndIf

			i += 1
		endwhile
	Else
		; EFF_CompanionList is none so fallback to normal method.
		Debug.Trace("EFF_CompanionList - fallback")

		If register
			RegisterForDistanceLessThanEvent(Companion.GetActorRef(), curObject, distanceCheck)
		Else
			UnregisterForDistanceEvents(Companion.GetActorRef(), curObject)
		EndIf
	EndIf
EndFunction

Event OnTimer(int timerID)
	If (timerID == 0)
		ObjectReference curObject = Game.GetPlayerGrabbedRef()

		If curObject != None
			Debug.Trace("CompanionGiveStuff - curObject = " + curObject)
			Debug.Trace("GetLength = " + curObject.GetLength())
			Debug.Trace("GetWidth = " + curObject.GetWidth())
			Debug.Trace("GetHeight = " + curObject.GetHeight())
			Debug.Trace("GetBaseObject = " + curObject.GetBaseObject())
			Debug.Trace("GetMass = " + curObject.GetMass())

			;curObjectLocal = curObject

			Form BaseObject = curObject.getBaseObject()

			If ((BaseObject is Form && (lootItemsCommon.HasForm(BaseObject) || lootItemsRare.HasForm(BaseObject) || lootItemsUncommon.HasForm(BaseObject))) || BaseObject is Weapon || BaseObject is Armor)
				Debug.Trace("is lootItem, Weapon or Armor")

				If (Game.IsPluginInstalled("EFF.esp"))
					EFF_DistanceEvent(true, curObject)
					Debug.Trace("EFF Installed - Register")
				Else
					RegisterForDistanceLessThanEvent(Companion.GetActorRef(), curObject, distanceCheck)
				EndIf

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
				GiveItemActor.ForceRefTo(akObj1)
				Debug.Trace("GiveItemActor = " + GiveItemActor)
				CompanionGiveStuffMessage.Show()
			EndIf
		Else
			Debug.Trace("Done waiting. Distance changed!. GetDistance = " + akObj1.GetDistance(akObj2))
			RegisterForDistanceLessThanEvent(akObj1, akObj2, distanceCheck)
		EndIf
	EndIf
endEvent

Event ObjectReference.OnRelease(ObjectReference source)
	Debug.Trace("CompanionGiveStuff - OnRelease = " + source)

	If (Game.IsPluginInstalled("EFF.esp"))
		EFF_DistanceEvent(false, source)
		Debug.Trace("EFF Installed - UnRegister")
	Else
		UnRegisterForRemoteEvent(source, "OnRelease")
	EndIf

	StartTimer(1, 0)
	;CancelTimer(1)
EndEvent
