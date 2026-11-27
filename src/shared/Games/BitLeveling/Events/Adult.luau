--[[
	GROWN-UP LIFE (ORIGINAL GAME CONTENT): work, family and the city, for Hunters and for the
	people who never awaken. Hunter society (licences, guilds, raid rights, mana crystals, the
	Surveillance Team) follows canon; the people and the incidents are this game's own.
]]

local HUNTERS = { "hunter_e", "hunter_d", "hunter_c", "hunter_b", "hunter_a", "hunter_s" }
local LOW = { "hunter_e", "hunter_d" }
local HIGH = { "hunter_b", "hunter_a", "hunter_s" }

return {
	-- ── anyone ──
	{ id = "ad_first_room", title = "A Room of Your Own", text = "You've found a room: a rooftop studio with a view of the guild towers and a heater that works when it wants to.", weight = 6, once = true, when = { minAge = 19, maxAge = 30 },
		choices = {
			{ label = "Take it", result = { money = -2, sanity = 3, log = "Your own four walls. You lay on the floor the first night and just listened." } },
			{ label = "Stay at home and save", result = { money = 2, sanity = -1, log = "Your mother was quietly delighted." } },
		} },
	{ id = "ad_insurance", title = "Gate Insurance", text = "A salesman at your door: Gate insurance. 'Breaks don't check whose building they're in,' he says.", weight = 5, cooldown = 6, when = { minAge = 22, minYear = 2 },
		choices = {
			{ label = "Buy a policy", result = { money = -3, sanity = 2, setFlags = { "gate_insured" }, log = "You signed. You felt slightly stupid and slightly safer." } },
			{ label = "Shut the door", result = { log = "He went next door." } },
		} },
	{ id = "ad_neighbor_hunter", title = "The Hunter Next Door", text = "The new neighbour is a Hunter: a quiet D-rank who comes home at odd hours smelling of caves.", weight = 5, once = true, when = { minAge = 18, minYear = 2 },
		choices = {
			{ label = "Bring them something to eat", result = { charisma = 1, addRelation = { kind = "acquaintance", bond = 40, age = { 22, 40 } }, log = "They ate it standing in the doorway and told you about a goblin that tried to steal their boots." } },
			{ label = "Keep to yourself", result = { log = "You nodded at each other in the lift for years." } },
		} },
	{ id = "ad_rent_hike", title = "The Rent Goes Up", text = "Your landlord says the building's been reassessed: it's now in a 'high Gate-activity zone', and the insurance costs are being passed on.", weight = 5, cooldown = 5, when = { minAge = 20, minYear = 3 },
		choices = {
			{ label = "Argue", clash = { stat = "charisma", foe = "The landlord", coins = 2, base = 6, coinPower = 3 }, win = { charisma = 1, log = "He halved the increase, grumbling." }, lose = { money = -2, sanity = -1, log = "He didn't budge." } },
			{ label = "Pay it", result = { money = -3, log = "You paid. Everyone pays." } },
		} },
	{ id = "ad_family_dinner", title = "Family Dinner", text = "The whole family is together for the holiday. Your aunt has opinions about everyone's life.", weight = 6, cooldown = 3, when = { minAge = 18, maxAge = 60 },
		choices = {
			{ label = "Smile through it", result = { willpower = 1, sanity = 1, log = "You survived. The food was very good." } },
			{ label = "Talk back", clash = { stat = "charisma", foe = "Your aunt", coins = 2, base = 5, coinPower = 2 }, win = { charisma = 2, sanity = 2, log = "Your cousins applauded you in the car park." }, lose = { sanity = -3, log = "It became a fight. Your mother cried." } },
		} },
	{ id = "ad_blackout", title = "Blackout", text = "A Gate opened at a power substation across the city and half the district has no electricity.", weight = 5, cooldown = 4, when = { minAge = 14, minYear = 1 }, result = { sanity = -2, log = "Three days of candles and cold rice. When the lights came back on the whole block cheered." } },
	{ id = "ad_mana_stocks", title = "Crystal Futures", text = "A coworker won't shut up about mana crystal stocks. 'Every Gate is money,' he says. 'Every break is a dip to buy.'", weight = 4, cooldown = 8, when = { minAge = 22, minYear = 3 },
		choices = {
			{ label = "Invest a little", clash = { stat = "luck", foe = "The crystal market", coins = 2, base = 6, coinPower = 3 }, win = { money = { 4, 12 }, log = "A guild cleared a huge A-rank Gate and the price went the other way from what he said. You made money anyway." }, lose = { money = -4, log = "A new deposit was found in Russia and the price collapsed." } },
			{ label = "Keep your savings where they are", result = { log = "You kept your money in the bank." } },
		} },
	{ id = "ad_hospital_visit", title = "Visiting Hours", text = "A relative is in hospital after being caught near a Dungeon Break. They're going to be fine. They keep saying so.", weight = 4, cooldown = 6, when = { minAge = 16, minYear = 2, hasRelation = "mother" },
		choices = {
			{ label = "Visit every day", result = { charisma = 1, sanity = -1, relationBond = { kind = "mother", amount = 8 }, log = "You brought fruit and sat with them. Most of the ward was Gate injuries." } },
			{ label = "Pay for a Hunter healer", hint = "Healers are expensive.", result = { money = -8, relationBond = { kind = "mother", amount = 12 }, log = "A C-rank Healer came for twenty minutes and they walked out the next morning." } },
		} },
	{ id = "ad_child_born", title = "A Child", text = "You're going to be a parent.", weight = 4, once = true, when = { minAge = 24, maxAge = 42, flags = { "partnered" } },
		result = { addRelation = { kind = "child", bond = 85, age = { 0, 0 } }, sanity = 4, log = "A tiny, furious person. Your whole life rearranged itself around them in an afternoon." } },
	{ id = "ad_settle", title = "Someone to Come Home To", text = "Someone in your life has started to feel like home.", weight = 4, once = true, when = { minAge = 23, maxAge = 45, notFlags = { "partnered" } },
		choices = {
			{ label = "Make a life together", result = { setFlags = { "partnered" }, sanity = 4, addRelation = { kind = "acquaintance", bond = 70, age = { 22, 45 } }, log = "You started a household together. Two names on the door." } },
			{ label = "Not yet", result = { log = "Not yet." } },
		} },
	{ id = "ad_burnout", title = "Burnout", text = "You've been working without a break for so long you can't remember the last day off.", weight = 5, cooldown = 4, when = { minAge = 24, maxAge = 60 },
		choices = {
			{ label = "Take a week off", result = { money = -1, sanity = 5, log = "You slept for two days and walked by the river for five." } },
			{ label = "Push through", result = { money = 2, sanity = -4, vitality = -3, log = "You pushed through. It cost something." } },
		} },
	{ id = "ad_volunteer", title = "Rebuilding", text = "A block near yours was damaged in a break. Volunteers are clearing rubble at weekends.", weight = 5, cooldown = 4, when = { minAge = 16, minYear = 2 },
		choices = {
			{ label = "Volunteer", result = { strength = 1, charisma = 2, sanity = 2, log = "You hauled rubble for three Saturdays. An old man gave you a jar of kimchi you'll remember forever." } },
			{ label = "Donate instead", result = { money = -1, sanity = 1, log = "You sent money. It's something." } },
		} },
	{ id = "ad_journalist", title = "A Journalist Calls", text = "A reporter wants to interview people from your neighbourhood about 'life near the Gates'.", weight = 3, once = true, when = { minAge = 20, minYear = 3 },
		choices = {
			{ label = "Talk to them", clash = { stat = "charisma", foe = "A camera", coins = 1, base = 5, coinPower = 2 }, win = { charisma = 2, log = "You were on the evening news for eleven seconds. Your mother recorded it." }, lose = { sanity = -2, log = "They used the clip where you stammered." } },
			{ label = "Decline", result = { log = "You said no." } },
		} },

	-- ── the unawakened ──
	{ id = "ad_civ_envy", title = "The Ones Who Woke Up", text = "A classmate who awakened as a C-rank just bought a car that costs more than your parents' apartment.", weight = 5, cooldown = 6, when = { minAge = 20, maxAge = 45, minYear = 3, form = "human" },
		choices = {
			{ label = "Be happy for them", result = { willpower = 1, sanity = -1, log = "You meant it, mostly." } },
			{ label = "Work harder", result = { intelligence = 1, money = 1, sanity = -2, log = "You took the extra project. Nobody awakens from overtime, but it pays." } },
		} },
	{ id = "ad_civ_cordon_job", title = "Cordon Duty", text = "The district office is hiring civilians to staff Gate cordons: tape, crowd control, the radio.", weight = 4, once = true, when = { minAge = 19, maxAge = 45, minYear = 1, form = "human" },
		choices = {
			{ label = "Sign up", result = { money = 2, willpower = 2, setFlags = { "cordon_staff" }, log = "You got a vest and a radio. Most days nothing happened. Some days you saw a Gate up close." } },
			{ label = "No", result = { log = "You let someone else do it." } },
		} },
	{ id = "ad_civ_hero", title = "The Delivery Rider", text = "A delivery rider in your area has been on the news: during a break he ferried people out on his scooter, one at a time, eleven trips.", weight = 3, once = true, when = { minAge = 16, minYear = 2 }, result = { willpower = 1, sanity = 2, log = "You don't have to awaken to be brave. You thought about him for a long time." } },

	-- ── Hunters: work and society (canon structure, original people) ──
	{ id = "hn_register_late", title = "The Licence", text = "You've been an unregistered Hunter long enough. A neighbour noticed you carrying a fridge up four flights.", weight = 8, once = true, when = { minAge = 14, form = HUNTERS, flags = { "unregistered" } },
		choices = {
			{ label = "Go and register", result = { setFlags = { "licensed" }, clearFlags = { "unregistered" }, codex = { "lore_kha" }, log = "The Association measured you, scolded you, and licensed you." } },
			{ label = "Keep hiding it", result = { sanity = -2, log = "You started carrying things more slowly in public." } },
		} },
	{ id = "hn_porter", title = "Porter Work", text = "A guild needs porters for an A-rank raid: carry the supplies, mine the crystals, stay out of the way. The pay is good for low-rank Hunters and nobody pretends it's safe.", weight = 6, cooldown = 3, tags = { "danger" }, when = { minAge = 18, form = LOW, flags = { "licensed" } },
		choices = {
			{ label = "Sign on", clash = { stat = "agility", foe = "A high-rank dungeon's stragglers", coins = 2, base = 9, coinPower = 4, fixed = true }, win = { strength = 1, money = { 4, 9 }, codex = { "lore_crystals" }, log = "You carried crates for nine hours and never had to fight. The Hunters in front did all of that." }, lose = { vitality = { -40, -16 }, sanity = -4, log = "A straggler came back for the porters.", cause = "Killed working as a raid porter" } },
			{ label = "Not this one", result = { log = "You passed." } },
		} },
	{ id = "hn_recruiter", title = "A Guild Recruiter", text = "A recruiter from a mid-size guild buys you coffee and slides a contract across the table.", weight = 6, cooldown = 4, when = { minAge = 18, form = { "hunter_c", "hunter_b", "hunter_a", "hunter_s" }, flags = { "licensed" } },
		choices = {
			{ label = "Read it carefully", clash = { stat = "intelligence", foe = "The small print", coins = 2, base = 7, coinPower = 3 }, win = { intelligence = 1, money = { 10, 30 }, log = "You found the clause that would have given them your raid shares for five years, and negotiated it out. Signing bonus." }, lose = { money = -5, log = "You signed. The clause found you later." } },
			{ label = "Say you're happy freelancing", result = { charisma = 1, log = "They left their card. They always leave their card." } },
		} },
	{ id = "hn_surveillance", title = "The Surveillance Team", text = "Two officers from the Association's Surveillance Team are waiting at your door. A Hunter in your raid party has been accused of attacking civilians, and they want to know what you saw.", weight = 4, once = true, when = { minAge = 19, form = HUNTERS, flags = { "licensed" } },
		choices = {
			{ label = "Tell them everything", result = { willpower = 2, charisma = 1, codex = { "lore_kha" }, log = "You gave a full statement. The Hunter lost their licence. Some of the party stopped calling you." } },
			{ label = "Say you didn't see anything", result = { sanity = -3, log = "You said you didn't see anything. You did." } },
		} },
	{ id = "hn_crystal_auction", title = "The Auction", text = "Something you brought out of a Gate turns out to be worth a lot more than crystal: a weapon, an old one, humming. The auction house wants it.", weight = 3, cooldown = 6, lucky = true, when = { minAge = 18, form = HUNTERS },
		choices = {
			{ label = "Sell it at auction", result = { money = { 15, 60 }, log = "It went for more than you'd earned all year." } },
			{ label = "Keep it", result = { gear = "w_moonlit_katana_2", log = "You kept it. It sits right in your hand, like it was made for it." } },
		} },
	{ id = "hn_rank_shame", title = "'Only an E-rank'", text = "At a raid briefing, a C-rank laughs when he sees your licence. 'They let anyone in now?'", weight = 5, cooldown = 4, when = { minAge = 18, form = "hunter_e" },
		choices = {
			{ label = "Let it go", result = { willpower = 2, sanity = -2, log = "You let it go. You did your job. He didn't remember your name." } },
			{ label = "Say something", clash = { stat = "charisma", foe = "A C-rank's ego", coins = 2, base = 6, coinPower = 3 }, win = { charisma = 2, sanity = 2, log = "The whole room laughed, at him this time." }, lose = { sanity = -4, log = "He made sure everyone heard what he said next." } },
		} },
	{ id = "hn_fame", title = "Recognised", text = "Someone at a cafe recognises you from a raid clip. They want a photo.", weight = 5, cooldown = 3, when = { minAge = 18, form = HIGH },
		choices = {
			{ label = "Smile for the photo", result = { charisma = 2, sanity = 1, log = "It had ten thousand likes by evening." } },
			{ label = "Politely decline", result = { sanity = 1, log = "They took one anyway, from across the room." } },
		} },
	{ id = "hn_injury_rest", title = "The Healer's Advice", text = "The guild Healer has looked at your shoulder twice now. 'Mana heals a lot,' she says, 'not everything. Take a month.'", weight = 5, cooldown = 4, when = { minAge = 20, form = HUNTERS, max = { vitality = 70 } },
		choices = {
			{ label = "Take the month", result = { vitality = { 10, 20 }, money = -2, sanity = 3, log = "A month of physio and sleep. It helped." } },
			{ label = "Keep raiding", result = { money = 3, vitality = -5, sanity = -2, log = "You kept going. The shoulder kept complaining." } },
		} },
	{ id = "hn_mentor", title = "An Old Hunter", text = "A retired B-rank who runs a training gym in your district has been watching you train.", weight = 5, once = true, when = { minAge = 16, maxAge = 30, form = HUNTERS },
		choices = {
			{ label = "Ask them to teach you", result = { strength = 2, agility = 2, addRelation = { kind = "mentor", bond = 55, age = { 48, 62 } }, log = "'Fear is a muscle,' they said. 'We'll work it.'" } },
			{ label = "Train alone", result = { strength = 1, log = "You kept your own counsel." } },
		} },
	{ id = "hn_partner_dies", title = "The Empty Locker", text = "Your raid partner of three years died on a Gate you weren't on. They're clearing out their locker at the guild.", weight = 3, once = true, tags = { "danger" }, when = { minAge = 21, form = HUNTERS, minYear = 2 },
		choices = {
			{ label = "Help clear it", result = { willpower = 3, sanity = -6, log = "You found a photo of the two of you in it. You kept it." } },
			{ label = "Stay away", result = { sanity = -5, log = "You couldn't go in. You haven't been back to that floor since." } },
		} },
	{ id = "hn_stream", title = "The Stream", text = "A broadcasting company wants to put a camera on your raids: 'Hunters get millions of viewers.'", weight = 3, once = true, when = { minAge = 18, form = HUNTERS },
		choices = {
			{ label = "Do it", result = { charisma = 3, money = { 5, 15 }, sanity = -2, log = "It turns out people love watching you trip over goblins." } },
			{ label = "Refuse", result = { log = "You'd rather not have your worst day on the internet." } },
		} },
	{ id = "hn_unsanctioned_gate", title = "A Gate Nobody's Reported", text = "Hiking in the hills, you find a small Gate in a ravine. No tape, no reading, no Association. It's probably E-rank. Probably.", weight = 3, cooldown = 6, tags = { "danger" }, when = { minAge = 18, form = HUNTERS },
		choices = {
			{ label = "Report it", result = { intelligence = 1, money = 1, codex = { "lore_rights" }, log = "The Association thanked you, measured it at D, and sold the raid rights the same afternoon." } },
			{ label = "Clear it yourself", hint = "Illegal without the raid rights.", clash = { stat = "strength", foe = "Whatever is in the ravine", enemy = "gate_d", coins = 2, base = 9, coinPower = 4, fight = true, fixed = true }, win = { strength = 2, money = { 3, 8 }, sanity = -1, log = "It was D-rank. You cleared it, sold the crystals quietly, and told nobody." }, lose = { vitality = { -40, -18 }, sanity = -4, log = "It was more than you thought.", cause = "Killed in an unreported Gate" } },
		} },
	{ id = "hn_guild_war", title = "Bad Blood", text = "A rival guild's Hunters have been 'accidentally' showing up at your team's Gates first.", weight = 3, cooldown = 6, when = { minAge = 20, form = HUNTERS, anyCareer = true },
		choices = {
			{ label = "Report them to the Association", result = { intelligence = 1, log = "The Association fined them. It stopped, mostly." } },
			{ label = "Confront them", clash = { stat = "charisma", foe = "A rival guild's team leader", coins = 2, base = 8, coinPower = 3 }, win = { charisma = 2, log = "You made it very clear. They found other Gates." }, lose = { sanity = -3, vitality = -6, log = "It got physical. Hunters don't do 'physical' gently." } },
		} },
	{ id = "hn_family_worry", title = "Every Time You Go In", text = "Your mother calls every time she sees a raid on the news. Every time.", weight = 5, cooldown = 4, when = { minAge = 18, form = HUNTERS, hasRelation = "mother" },
		choices = {
			{ label = "Call her after every raid", result = { charisma = 1, relationBond = { kind = "mother", amount = 6 }, log = "A thirty-second call: 'I'm out. I'm fine.' She waits up for it." } },
			{ label = "Ask her to stop watching", result = { sanity = -1, log = "She said she'd try. She didn't." } },
		} },
	{ id = "hn_rank_ceiling", title = "The Ceiling", text = "You've trained for years and the numbers have stopped moving. Rank is rank, the old Hunters say. You can get better at being what you are.", weight = 4, once = true, when = { minAge = 26, form = HUNTERS },
		choices = {
			{ label = "Get better at what you are", result = { willpower = 3, intelligence = 2, sanity = 2, log = "You stopped measuring yourself against the rankings and started measuring against last year." } },
			{ label = "Keep pushing anyway", result = { strength = 1, sanity = -3, log = "You pushed. The numbers moved a little, and you paid for every point." } },
		} },
	{ id = "hn_retire", title = "Hanging It Up", text = "Your knees, your back, your nerves. The guild is offering you a desk: training rookies.", weight = 5, once = true, when = { minAge = 45, form = HUNTERS },
		choices = {
			{ label = "Take the desk", result = { sanity = 4, charisma = 1, log = "You teach rookies how not to die. It's the best work you've ever done." } },
			{ label = "One more year in the field", result = { money = 4, sanity = -2, log = "One more year. You said that last year." } },
		} },

	-- ── old age ──
	{ id = "el_grandchild", title = "A Grandchild", text = "Your child has a child.", weight = 4, once = true, when = { minAge = 50, hasRelation = "child" }, result = { sanity = 5, charisma = 1, log = "You held them and forgot every Gate you ever saw." } },
	{ id = "el_memories", title = "The Way It Was", text = "A young person asks you what the world was like before the Gates.", weight = 4, once = true, when = { minAge = 45, minYear = 12 },
		choices = {
			{ label = "Tell them the truth", result = { intelligence = 1, sanity = 2, log = "You told them about summers when the sky was just the sky. They didn't quite believe you." } },
			{ label = "Say it wasn't so different", result = { log = "You lied. It was very different." } },
		} },
	{ id = "el_health_scare", title = "The Scan", text = "The doctor wants to talk about your scan results.", weight = 5, cooldown = 5, tags = { "danger" }, when = { minAge = 58 },
		choices = {
			{ label = "Do everything she says", result = { money = -4, vitality = { 4, 10 }, sanity = -2, log = "Pills, walks, no salt. It worked, for now." } },
			{ label = "Ignore it", clash = { stat = "luck", foe = "Your own body", coins = 2, base = 8, coinPower = 3 }, win = { log = "It turned out to be nothing much." }, lose = { vitality = { -30, -12 }, log = "It wasn't nothing.", cause = "Died of an illness they ignored" } },
		} },
	{ id = "el_park", title = "The Park Bench", text = "You've started spending mornings on the same park bench, feeding pigeons and arguing with the old man who has the next one.", weight = 5, cooldown = 3, when = { minAge = 62 }, result = { sanity = 3, charisma = 1, log = "You've solved most of the world's problems on that bench." } },
	{ id = "el_old_hunter", title = "Old Hunters", text = "A reunion of the Hunters you raided with, years ago. Fewer chairs than there used to be.", weight = 4, once = true, when = { minAge = 50, form = HUNTERS }, result = { sanity = 2, willpower = 2, log = "You toasted the empty chairs with barley tea and told the same stories as always." } },
}
