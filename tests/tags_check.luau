--[[
	"What's that?" chips (pack.glossary): a chip must only light up when the card really names
	the thing. The Middle is a Finger; "pushed into the middle of it" is a candle stub.
	  - fixed cases: ordinary words never light a chip, the names always do
	  - every glossary entry can be reached by at least one card in the pack
	  - `--list` prints what every card would show (read it after changing the Glossary)
		lune run tests/tags_check [--list] [--term "The Middle"]
]]
local process = require("@lune/process")
local Loader = require("./loader")
local root = Loader.preload(Loader.node("src/shared", "LifeSim", nil))
Loader.require(root.Config).pack = "City"
local Engine = Loader.require(root.Engine)
local pack = Loader.require(root.Pack)
local sim = Engine.Sim.new(pack)

local listAll, onlyTerm = false, nil
for i, a in process.args do
	if a == "--list" then
		listAll = true
	elseif a == "--term" then
		onlyTerm = process.args[i + 1]
	end
end

local fails = 0
local function check(ok: any, msg: string)
	if not ok then
		fails += 1
		print("  FAIL  " .. msg)
	end
end

local life = sim:newLife({ seed = 5, rollOrigin = true })
local function terms(title: string, text: string, said: string?): { [string]: boolean }
	life.termsSeen = nil
	local out = {}
	local event: any = { title = title, text = text }
	if said then
		event.dialogue = { { who = "Someone", line = said } }
	end
	-- a card shows three at most; ask entry by entry so nothing hides behind the limit
	local body = text .. (if said then "\n" .. said else "")
	local lower = string.lower(title .. " " .. body)
	for _, g in pack.glossary do
		if sim:termMatches(g, title, body, lower) then
			out[g.term] = true
		end
	end
	return out
end
local function none(title: string, text: string, term: string)
	check(not terms(title, text)[term], ("'%s' must NOT show %s"):format(text, term))
end
local function has(title: string, text: string, term: string)
	check(terms(title, text)[term], ("'%s' must show %s"):format(text, term))
end

-- ── the card the player sent: a candle stub, and no Finger anywhere near it ──
none("A Candle Stub", "Somebody left a bun on the step, with a candle stub pushed into the middle of it.", "The Middle")
has("A Favour Owed", "The baker pays the Middle every month, and smiles while he does it.", "The Middle")
has("Family", "\"Little Brother,\" the man said, \"you've grown.\"", "The Middle")
none("Family", "Your little brother has your mother's ears and nobody's manners.", "The Middle")
none("Family", "Your big sister walked you to school.", "The Middle")

-- ── ordinary words that used to light a chip ──
none("A Bump", "You hit your head on the low beam, and saw the eye of the storm in it.", "The Head")
has("A Knock", "Nobody says the Head out loud after dark.", "The Head")
none("A Bump", "A cat's claw caught your sleeve.", "The Head")
has("A Knock", "They say a Claw stood at the end of the street for an hour.", "The Head")
none("A Gift", "She wore her mother's ring on a string.", "The Ring")
has("A Gift", "An envelope from the Ring came, cream paper, no stamp.", "The Ring")
none("A List", "He ran one finger down the index of the ledger.", "The Index")
none("A List", "He ran one finger down the index of the ledger.", "The Fingers")
has("A List", "The Index sent a letter to number nine.", "The Index")
none("A Splinter", "You caught your thumb in the door.", "The Thumb")
has("A Bow", "You bowed to a Soldato of the Thumb.", "The Thumb")
has("A Bow", "You bowed to a Soldato of the Thumb.", "Capo")
none("A Bird", "A pigeon with a bent wing sat on the nest it had built in the gutter, one feather out of place.", "Wing")
none("A Bird", "A pigeon with a bent wing sat on the nest it had built in the gutter, one feather out of place.", "Nest")
none("A Bird", "A pigeon with a bent wing sat on the nest it had built in the gutter, one feather out of place.", "Feather")
has("A Badge", "Her badge said she was a Feather, and that a Wing owned her mornings.", "Feather")
has("A Badge", "Her badge said she was a Feather, and that a Wing owned her mornings.", "Wing")
has("A Wall", "On the far side of the wall, the Nest keeps its lawns green.", "Nest")
none("A Desk", "The records office closes at four.", "Office")
has("A Desk", "The Office took a contract nobody else would.", "Office")
none("School", "You got a good grade in sums.", "Grade")
has("License", "The card says Grade 9, the lowest there is.", "Grade")
none("Paint", "The color ran in the wash.", "Color")
has("Paint", "They say a Color walked through the market and the market went quiet.", "Color")
none("Vermin", "A rat ran under the stove.", "Rats")
has("Vermin", "Three of the Rats were waiting by the pump.", "Rats")
none("The Night Bus", "You stayed up half the night and missed the bus.", "The Night")
has("Curfew", "It is 3:13. The street is empty.", "The Night")
has("Curfew", "Be indoors before the Night.", "The Night")
none("A Letter", "An invitation to your cousin's party came.", "The Library")
has("A Letter", "An invitation from the Library came, black-edged.", "The Library")
none("A Fall", "A tremor ran through the floor and the cups danced.", "Tremor")
none("A Fall", "She kept her poise all the way down the stairs.", "Poise")

-- ── a longer name that happens to begin the same way ──
none("Head of Research", "The Head of Research is stepping down, and the committee is choosing.", "The Head")
none("School", "Fixers earn. The Head Teacher has asked you to take a class.", "The Head")
none("School", "You asked the Head Teacher for a week off.", "The Head")
none("Stalls", "You bought noodles at the Night Market.", "The Night")
has("Sentence", "The Head is thorough.", "The Head")
has("Sentence", "It came from the Head itself.", "The Head")
has("Sentence", "The Middle repays in kind.", "The Middle")

-- ── the first word of a sentence wears a capital whatever it means ──
none("Brooms", "\"The yard needs sweeping,\" she says. \"Sweepers get a free lesson.\"", "The Night")
none("Brooms", "\"The yard needs sweeping,\" she says. \"Sweepers get a free lesson.\"", "Sweepers")
none("Birds", "Feathers everywhere. The cat looked pleased.", "Feather")
none("Birds", "Nests in the eaves again. Wings beating at the glass.", "Nest")
none("Birds", "Nests in the eaves again. Wings beating at the glass.", "Wing")
none("Hands", "Fingers crossed, you knocked.", "The Fingers")
none("Vermin", "Rats in the flour again.", "Rats")
has("Curfew", "The lamps go out. Then the Sweepers come.", "Sweepers")
-- titles capitalise everything: an ordinary word in a title is not a name
none("The Wing of a Moth", "It sat on your wrist a while.", "Wing")
none("Office Hours", "You waited an hour for a stamp.", "Office")
-- but a name is a name wherever it stands
has("Fixers", "Fixers swept the block before breakfast.", "Fixer")
has("Fixers", "HANA IS CHECKING LICENSES, the board says.", "Hana")

-- ── a sister called Hana is not the Association: names are filled in after the match ──
do
	local event = { title = "Supper", text = "{sibling} set the table. {mother} said grace of a sort." }
	life.termsSeen = nil
	check(sim:termsIn(life, event) == nil, "a card with only people's names in it shows no chip")
end

-- ── a card shows three chips at most, and stops showing one the life has met twice ──
do
	local event = { title = "Everything", text = "A Fixer from an Office under the Zwei Association walked a Feather home to the Nest past the Thumb." }
	life.termsSeen = nil
	local t = sim:termsIn(life, event)
	check(t ~= nil and #t == 3, "three chips at most (got " .. tostring(t and #t) .. ")")
	sim:markTerms(life, event)
	sim:markTerms(life, event)
	local t2 = sim:termsIn(life, event)
	check(t2 ~= nil and t2[1].term ~= (t :: any)[1].term, "a chip seen twice makes room for the next")
end

-- ── the whole pack: what each card would show ──
local function variants(text: any): { string }
	if type(text) == "table" then
		return text
	end
	return { if type(text) == "string" then text else "" }
end
local reached: { [string]: number } = {}
local shownOn: { [string]: { string } } = {}
local cards, tagged = 0, 0
for _, e in pack.events do
	cards += 1
	local hit: { [string]: boolean } = {}
	for _, title in variants(e.title) do
		for _, text in variants(e.text) do
			local body = text
			for _, d in e.dialogue or {} do
				for _, line in variants(d.line) do
					body ..= "\n" .. line
				end
			end
			local lower = string.lower(title .. " " .. body)
			for _, g in pack.glossary do
				if sim:termMatches(g, title, body, lower) then
					hit[g.term] = true
				end
			end
		end
	end
	local any = false
	for term in hit do
		any = true
		reached[term] = (reached[term] or 0) + 1
		shownOn[term] = shownOn[term] or {}
		table.insert(shownOn[term], tostring(e.id) .. "  " .. variants(e.title)[1])
	end
	if any then
		tagged += 1
	end
end
for _, g in pack.glossary do
	check((reached[g.term] or 0) > 0, "no card in the pack would ever show '" .. g.term .. "'")
end
if listAll or onlyTerm then
	for _, g in pack.glossary do
		if not onlyTerm or onlyTerm == g.term then
			print(("%-16s %4d cards"):format(g.term, reached[g.term] or 0))
			if onlyTerm then
				for _, where in shownOn[g.term] or {} do
					print("     " .. where)
				end
			end
		end
	end
end
print(("tags: %d cards, %d would offer a chip, %d glossary entries"):format(cards, tagged, #pack.glossary))
if fails > 0 then
	print(fails .. " FAILED")
	process.exit(1)
end
print("TAGS OK")
