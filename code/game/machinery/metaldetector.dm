/obj/machinery/metal_detector
	name = "metal detector"
	desc = "A advanced metal detector used to detect weapons."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "metal_detector"
	plane = FLY_LAYER
	anchored = 1

	var/list/banned_objects=list(/obj/item/weapon/gun,
								/obj/item/weapon/material,
								/obj/item/weapon/melee,
								/obj/item/device/transfer_valve,
								/obj/item/weapon/grenade/,
								/obj/item/ammo_casing/,
								/obj/item/ammo_magazine
								)

/obj/machinery/metal_detector/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/metal_detector(src)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(src)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(src)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(src)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(src)
	RefreshParts()

/obj/machinery/metal_detector/attackby(obj/item/W, mob/usr)
	if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))
		if(!req_access_faction && W.GetFaction())
			req_access_faction = W.GetFaction()
			to_chat(usr, "<span class='notice'>\The [src] has been synced to your faction</span>")
			return

	if(default_deconstruction_screwdriver(usr, W))
		return

	if(default_deconstruction_crowbar(usr, W))
		return

/obj/machinery/metal_detector/Crossed(var/atom/A)
	if(istype(A, /mob/living))
		var/mob/living/M = A
		if(req_access_faction)
			if(has_access(list(core_access_security_programs), list(), M.GetAccess(req_access_faction)) && (M.GetFaction() == req_access_faction))
				return //Faction-members with security access are immune.

	var/list/checked_items = list()
	checked_items += A
	if(A.contents.len)
		checked_items += A.contents // Double-recursive check. A gun in a satchel will set it off, a knife in a box in a satchel will too.
		for(var/obj/O in A.contents) // A knife in a bible in a box in a satchel will not.
			if(O.contents.len)
				checked_items += O.contents
				for(var/obj/OT in O.contents)
					if(OT.contents.len)
						checked_items += OT.contents

	check_items(checked_items)
	..()

/obj/machinery/metal_detector/proc/check_items(var/list/L)
	for(var/O in banned_objects)
		for(var/A in L)
			if(istype(A, O))
				flick("metal_detector_anim",src)
				visible_message("<span class='danger'>\The [src] sends off an alarm!</span>")
				playsound(src, 'sound/ambience/alarm4.ogg', 60, 1)
				return