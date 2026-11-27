--[[
	SECOND STORIES, the third shelf (act = 2; chapters in Events/Story_Second3.luau). Ten more
	stories that find a grown life, most of them open to anyone, so that two lives (and two
	players on one server: Sim:storiesInPlay) rarely live the same adult years.

	Each stands on something true of the City:
	  Missing            people vanish from the Backstreets every Night; the Sweepers clean the
	                     streets, Syndicates take what they want, and nobody is obliged to look
	  The Old Office     an Office is a licence, a sign and its unfinished contracts; Hana keeps
	                     the paperwork after the Fixers are gone
	  The Parcel         couriers carry what can't be sent any other way, between Districts
	  The Quiet Tenant   Fixers who live long enough to retire collect enemies on the way
	  Clean Books        Syndicates launder their Ahn through ordinary shops
	  Changing           after the Light, a person can Distort: the self bends around an
	                     obsession until something else stands where they stood (library era on)
	  The Grudge Book    the Middle files every grudge in its Book by Title, Section, Row and Line,
	                     and pays back every debt, in whichever form
	  The Pit            Backstreets fighting pits pay fighters from the door; Syndicates own them
	  The Hand-Me-Down   a weapon from a Workshop outlives its owner, and its owner's enemies
	  The Last Stop      the Night in the Backstreets: whoever is outside after the hour is fair game
]]

return {
	{
		id = "sl2_missing",
		act = 2,
		name = "Missing",
		hook = "The girl from the flat below didn't come home before the Night. Her mother is on your stairs at dawn, asking everyone.",
		tone = "grim",
		weight = 12,
		when = { minAge = 18 },
		goal = "Pia Lenk, eleven, didn't come home. Somebody should look.",
		cast = { "sl3_mi_mother", "sl3_mi_pia" },
	},
	{
		id = "sl2_old_office",
		act = 2,
		name = "The Old Office",
		hook = "A dead Fixer's Office is for lease, cheap. The previous tenant's unfinished contracts come with the desk.",
		tone = "grim",
		weight = 11,
		when = { minAge = 20 },
		goal = "The lease is yours. So is a drawer of contracts nobody finished.",
		cast = { "sl3_oo_clerk", "sl3_oo_client" },
	},
	{
		id = "sl2_parcel",
		act = 2,
		name = "The Parcel",
		hook = "A courier collapses in your doorway with a parcel chained to his wrist. He gives you the key and an address three Districts away.",
		tone = "strange",
		weight = 11,
		when = { minAge = 18 },
		goal = "Deliver the parcel. Don't open it. Everyone wants it.",
		cast = { "sl3_pc_courier", "sl3_pc_buyer" },
	},
	{
		id = "sl2_quiet_tenant",
		act = 2,
		name = "The Quiet Tenant",
		hook = "The old woman upstairs carries her groceries like they weigh nothing, and sleeps with a sword. She was a Grade 1, once.",
		tone = "hopeful",
		weight = 11,
		when = { minAge = 18 },
		goal = "Get to know the old Fixer upstairs. Somebody else is trying to, too.",
		cast = { "sl3_qt_fixer", "sl3_qt_hunter" },
	},
	{
		id = "sl2_clean_books",
		act = 2,
		name = "Clean Books",
		hook = "A laundry hires you to keep its books. The laundry washes very little, and earns a great deal.",
		tone = "grim",
		weight = 10,
		when = { minAge = 19, min = { intelligence = 20 } },
		goal = "Your new employer's books don't add up. That's the job.",
		cast = { "sl3_cb_boss", "sl3_cb_auditor" },
	},
	{
		id = "sl2_changing",
		act = 2,
		name = "Changing",
		hook = "Teodor, who you grew up with, has stopped sleeping. He says he can hear his clock thinking. People don't talk like that, after the Light, unless something is wrong.",
		tone = "strange",
		weight = 14,
		when = { minAge = 18, world = { era = { "library", "limbus" } } },
		goal = "Teodor is changing. You might be able to keep him himself.",
		cast = { "sl3_ch_teodor", "sl3_ch_fixer" },
	},
	{
		id = "sl2_grudge_book",
		act = 2,
		name = "The Grudge Book",
		hook = "A Little Sibling of the Middle was beaten on your street, and you were the one who saw it. The Middle wants a name. The men who did it want you quiet.",
		tone = "grim",
		weight = 11,
		when = { minAge = 18, side = "backstreets", notFlags = { "fn_middle_member" } },
		goal = "You saw who beat a Little Sibling. Both sides know it.",
		cast = { "sl3_gb_big", "sl3_gb_little" },
	},
	{
		id = "sl2_pit",
		act = 2,
		name = "The Pit",
		hook = "Under a shuttered cannery there's a ring of sand and a crowd. A Syndicate runs it. It pays fighters from the door, and it's looking for a new face.",
		tone = "grim",
		weight = 11,
		when = { minAge = 18, side = "backstreets" },
		goal = "The pit pays by the fight. Each one is harder than the last.",
		cast = { "sl3_pt_owner", "sl3_pt_champion" },
	},
	{
		id = "sl2_hand_me_down",
		act = 2,
		name = "The Hand-Me-Down",
		hook = "A blade comes to you in a will: a Workshop piece, notched, with a name on the tang that isn't yours. Somebody has been looking for it for twenty years.",
		tone = "strange",
		weight = 10,
		when = { minAge = 20 },
		goal = "You inherited a famous blade. Its old owner's enemies know.",
		cast = { "sl3_hd_smith", "sl3_hd_seeker" },
	},
	{
		id = "sl2_last_stop",
		act = 2,
		name = "The Last Stop",
		hook = "You missed the last bus before the Night, by a minute. The driver of the one after it says he can take you home. There is never a bus after it.",
		tone = "strange",
		weight = 10,
		when = { minAge = 18, side = "backstreets" },
		goal = "A bus that runs in the Night knows where you live now.",
		cast = { "sl3_ls_driver", "sl3_ls_rider" },
	},
}
