--[[
	Chronicle acts: deeds that go out to the whole server. A result `chronicle = "act"`
	records it; `announce = true` also puts it in the chat. Events written for other players
	can check when = { chronicle = "act" } and name the doer with {actor} / {actorDistrict}.
	Tones: "news" (default), "good", "danger", "strange", "accent".
]]

return {
	manifested_ego = { text = "{name} faced their own distortion in {district} and manifested E.G.O.", announce = true, tone = "accent" },
	distorted = { text = "{name} became a Distortion in {district}. Fixers are on the way.", announce = true, tone = "danger" },
	lcorp_evacuated = { text = "{name} got a whole corridor of L Corp staff out as the facility sealed.", announce = true, tone = "good" },
	saved_child_breach = { text = "{name} pulled a child off the street during the breach in {district}.", announce = false, tone = "good" },
	fought_abnormality = { text = "{name} held off an escaped Abnormality in {district} until L Corp arrived.", announce = true, tone = "danger" },
	opened_door_night = { text = "{name} opened their door during the Night to let a stranger in, and lived.", announce = true, tone = "good" },
	defied_thumb = { text = "{name} shut the door on the Thumb in {district}. The Thumb remembers rudeness.", announce = true, tone = "danger" },
	calmed_distortion = { text = "{name} talked a Distortion down in {district}.", announce = true, tone = "strange" },
	fought_distortion = { text = "{name} fought a Distortion to a standstill in {district}.", announce = false, tone = "danger" },
	won_reception = { text = "{name} won a reception at the Library and walked out with a book.", announce = true, tone = "accent" },
	became_book = { text = "{name} accepted an invitation to the Library, and became a book.", announce = true, tone = "strange" },
	licensed_fixer = { text = "{name} passed the Hana exam in {district}: a new Grade 9 Fixer.", announce = false, tone = "good" },
}
