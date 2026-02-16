# Demo NPC Dialogue Content — Roothollow

This document contains all NPC dialogue for the Roothollow town area in the first playable demo. Dialogue is written in `DialogueLine.create(speaker, text)` format for easy implementation.

All dialogue accounts for story progression via `EventFlags`. NPCs have **multiple dialogue states** that change as the player advances through the demo's key events:

| Flag | Trigger |
|------|---------|
| *(none set)* | Game start — Kael hasn't left town yet |
| `opening_lyra_discovered` | Kael found Lyra in the Overgrown Ruins |
| `iris_recruited` | Iris joined the party in Verdant Forest |
| `garrick_recruited` | Garrick joined the party in Roothollow |

---

## NPC Roster

| NPC | Location | Role | Personality |
|-----|----------|------|-------------|
| **Maren** (Innkeeper) | The Hollow Rest inn, mid-level | Warm, maternal, gossip hub | Kind but shrewd; remembers every face that passes through |
| **Bram** (Shopkeeper) | General goods shop, mid-level | Equipment and supplies | Anxious, practical, worried about supply routes |
| **Elder Thessa** | Elder's house, mid-level south | Village elder, exposition | Wise, cryptic, knows more than she lets on |
| **Wren** (Scout) | Wandering near south exit | Forest scout, gameplay hints | Alert, laconic, wry humor |
| **Garrick** | Near village center | Pre-recruitment casual NPC | Gruff, guarded, observant |
| **Lina** (Child) | Near the save crystal | Townsfolk flavor | Curious, innocent, collects "pretty rocks" |

---

## 1. Maren — Innkeeper of The Hollow Rest

**Emotional Tone:** Warm and welcoming, but with an undercurrent of worry. Maren is the emotional heart of the village — she feeds people, listens to their troubles, and keeps Roothollow's spirits up. She has a motherly softness toward Kael specifically, having watched them grow up.

### State: Game Start (no flags)

```
DialogueLine.create("Maren", "Kael! Come in, come in. You look like you haven't eaten since yesterday. ...You haven't, have you?")
DialogueLine.create("Maren", "The stew's still warm. Sit down before you fall down.")
DialogueLine.create("Maren", "I heard you're heading out to the old ruins again. Please be careful. The echoes have been stranger lately.")
DialogueLine.create("Maren", "A trader from Prismfall passed through last week. Said the roads south are crawling with corrupted creatures. Stay close to the forest paths, will you?")
```

**Gameplay effect:** Party healed to full HP/EE.

### State: After Lyra Discovery (`opening_lyra_discovered`)

```
DialogueLine.create("Maren", "There you are! Half the village was worried sick. You were gone longer than usual.")
DialogueLine.create("Maren", "You found something in the ruins? Something... alive?")
DialogueLine.create("Maren", "I won't pretend to understand echoes the way you do. But if this one can speak, that changes things.")
DialogueLine.create("Maren", "The world's been holding its breath for three hundred years, Kael. Maybe it's finally ready to exhale.")
DialogueLine.create("Maren", "Rest here tonight. Whatever comes next, you'll face it better on a full stomach.")
```

**Gameplay effect:** Party healed to full HP/EE.

### State: After Iris Recruited (`iris_recruited`)

```
DialogueLine.create("Maren", "So you've brought company! A soldier, by the look of her. Or... former soldier?")
DialogueLine.create("Maren", "Don't worry, I don't pry. Anyone who fights alongside Kael is welcome at my table.")
DialogueLine.create("Maren", "That arm of hers... Resonance-powered, isn't it? Haven't seen Initiative tech this far east in years.")
DialogueLine.create("Maren", "I'll set out extra bowls. You all look like you could use a real meal.")
```

**Gameplay effect:** Party healed to full HP/EE.

### State: After Garrick Recruited (`garrick_recruited`)

```
DialogueLine.create("Maren", "Old Iron himself, traveling with my favorite Echo hunter. Now that's a sight.")
DialogueLine.create("Maren", "Garrick used to pass through years ago. Always ordered the same thing — black tea, no sugar. Sat in the corner and watched the door.")
DialogueLine.create("Maren", "He's a good man, Kael. Whatever he's running from, he's running toward something better now.")
DialogueLine.create("Maren", "You take care of each other out there. And come back for stew when you can.")
```

**Gameplay effect:** Party healed to full HP/EE.

---

## 2. Bram — Shopkeeper

**Emotional Tone:** Nervous and practical. Bram is a worrier — he counts inventory twice, frets about supply caravans, and sees danger in every shadow. But he's genuinely kind underneath the anxiety, and he wants to help Kael even when he can't stock his shelves properly.

### State: Game Start (no flags)

> **Note:** The shop is not functional in the demo. Bram's dialogue explains why narratively while hinting at future shop mechanics.

```
DialogueLine.create("Bram", "Oh, Kael. Good timing. Well... actually, terrible timing.")
DialogueLine.create("Bram", "The supply caravan from Prismfall is three days late. Three days! That's never happened before.")
DialogueLine.create("Bram", "I've got some basic provisions left, but the good equipment? Gone. Bought up by a group of hunters heading south.")
DialogueLine.create("Bram", "If you're heading to the ruins, I can spare a couple of salves. It's not much, but it's what I've got.")
```

### State: After Lyra Discovery (`opening_lyra_discovered`)

```
DialogueLine.create("Bram", "Everyone's talking about what you found in the ruins. A conscious echo? That's... that's not supposed to happen, is it?")
DialogueLine.create("Bram", "I don't like it, Kael. Change is coming, and change is bad for business. Change is bad for everything.")
DialogueLine.create("Bram", "The caravan still hasn't arrived. I'm starting to think something happened on the road.")
DialogueLine.create("Bram", "If you run into any traders out there, tell them Roothollow is paying double for medical supplies. Triple, even. I don't care.")
```

### State: After Iris Recruited (`iris_recruited`)

```
DialogueLine.create("Bram", "Your new friend... she's from the Ironcoast, isn't she? I can tell by the armor.")
DialogueLine.create("Bram", "N-not that there's anything wrong with that! The Federation makes good gear. Very reliable. Very... heavily armed.")
DialogueLine.create("Bram", "Actually, if she has any contacts in the supply chain, I'd love an introduction. Strictly business!")
```

### State: After Garrick Recruited (`garrick_recruited`)

```
DialogueLine.create("Bram", "Garrick Thorne is with you? THE Garrick Thorne? The man's a legend around here.")
DialogueLine.create("Bram", "He saved a caravan from crystal-corrupted wolves ten years back. Single-handedly held the pass while they escaped.")
DialogueLine.create("Bram", "If he's decided to travel with you, then whatever you're doing must be important. Or incredibly dangerous. ...Or both.")
```

---

## 3. Elder Thessa — Village Elder & Mentor

**Emotional Tone:** Calm, measured, and layered. Thessa speaks like someone who has seen civilizations rise and fall — because in a way, she has, through the echoes she's studied her whole life. She's the closest thing Roothollow has to a scholar. She cares deeply for Kael but communicates through riddles and leading questions, wanting them to discover truths on their own. She knows more about the Severance than she admits.

### State: Game Start (no flags)

```
DialogueLine.create("Elder Thessa", "Ah, Kael. I was wondering when you'd visit. The crystals in my study have been humming all morning.")
DialogueLine.create("Elder Thessa", "You're heading to the ruins again. I can see it in your eyes — that restless look you get when the echoes call.")
DialogueLine.create("Elder Thessa", "Before you go, a word of caution. The echoes in the old capital have been... different lately. More coherent. Almost purposeful.")
DialogueLine.create("Elder Thessa", "In all my years studying Resonance, I've never felt anything like it. It's as if something buried is trying to wake up.")
DialogueLine.create("Elder Thessa", "Trust your instincts out there. You've always had an unusual connection to the echoes. That's a gift, not a curse.")
```

**Gameplay purpose:** Establishes the ruins as the next objective. Foreshadows Lyra. Hints at Kael's special nature.

### State: After Lyra Discovery (`opening_lyra_discovered`)

```
DialogueLine.create("Elder Thessa", "A conscious echo. I've read theories... fragments of old research papers recovered from the capital. But I never believed it possible.")
DialogueLine.create("Elder Thessa", "Do you know what this means, Kael? Echoes are crystallized memory — fragments of lives lived and lost. If one has achieved consciousness...")
DialogueLine.create("Elder Thessa", "...then the boundary between what was and what is may be thinner than we thought.")
DialogueLine.create("Elder Thessa", "The Shepherds of Silence would destroy her on sight. The Reclamation Initiative would cage her and study her. Neither can learn of this.")
DialogueLine.create("Elder Thessa", "Protect her, Kael. And listen to what she has to say. The dead don't speak without reason.")
```

**Gameplay purpose:** Introduces the two major factions as threats. Gives the player motivation to protect Lyra. Heavy foreshadowing.

### State: After Iris Recruited (`iris_recruited`)

```
DialogueLine.create("Elder Thessa", "An Initiative deserter. Interesting company you're keeping.")
DialogueLine.create("Elder Thessa", "Don't look surprised — I recognize the armor modifications. She's stripped the insignias, but the alloy is unmistakable. Gearhaven titanium-crystal composite.")
DialogueLine.create("Elder Thessa", "The fact that she left the Initiative tells me more about her character than anything she could say. It takes courage to walk away from power.")
DialogueLine.create("Elder Thessa", "But be careful. The Initiative doesn't let its assets go quietly. If they're looking for her, they may eventually look here.")
```

**Gameplay purpose:** Reveals Thessa's deeper knowledge of the world. Seeds tension about the Initiative tracking Iris.

### State: After Garrick Recruited (`garrick_recruited`)

```
DialogueLine.create("Elder Thessa", "Garrick Thorne. It's been many years.")
DialogueLine.create("Elder Thessa", "He won't remember me — we met only once, at a peace summit between the Shepherds and the free villages. Before he lost his faith.")
DialogueLine.create("Elder Thessa", "He carries a heavy burden, Kael. The Shepherds did terrible things in the name of silence, and he was part of it. But guilt can be transmuted into purpose.")
DialogueLine.create("Elder Thessa", "The three of you together... an Echo hunter, an engineer, and a penitent knight. The echoes brought you together for a reason.")
DialogueLine.create("Elder Thessa", "Go to the ruins. Find what the conscious echo needs. And when the path divides, trust each other more than you trust the world.")
```

**Gameplay purpose:** Gives the party their main quest direction. Foreshadows that their gathering is significant.

---

## 4. Wren — Village Scout

**Emotional Tone:** Terse and no-nonsense. Wren patrols the forest perimeter and keeps Roothollow safe from corrupted wildlife. They've seen things in the Verdant Tangle that keep them up at night, but they deal with it through dry humor and pragmatism. They respect Kael as a fellow "person who walks into danger on purpose."

### State: Game Start (no flags)

```
DialogueLine.create("Wren", "Heading out? The western trail's clear, but I wouldn't stray too far south. Saw tracks.")
DialogueLine.create("Wren", "Big ones. Not wolves. Something... wrong. Crystal growths where the paw prints should be.")
DialogueLine.create("Wren", "The forest is getting worse. Used to be you'd see a corrupted creature once a month. Now it's every other day.")
```

**Gameplay purpose:** Warns about enemies in the forest. Teaches the player about corrupted creatures.

### State: After Lyra Discovery (`opening_lyra_discovered`)

```
DialogueLine.create("Wren", "You came back from the ruins looking like you'd seen a ghost. Or... whatever's worse than a ghost.")
DialogueLine.create("Wren", "Look, I don't need details. But if something's changing in there, I need to know. My job is keeping this village safe.")
DialogueLine.create("Wren", "The Verdant Forest has been restless since you got back. More echo activity, more corrupted beasts. Like something stirred them up.")
DialogueLine.create("Wren", "If you're going out again, stick to the main paths. And maybe bring a friend or two.")
```

**Gameplay purpose:** Hints that Lyra's discovery has consequences. Suggests the player recruit allies before continuing.

### State: After Iris Recruited (`iris_recruited`)

```
DialogueLine.create("Wren", "Your new companion handles herself well. I watched her take down a crystal-shard serpent near the forest edge without breaking stride.")
DialogueLine.create("Wren", "That arm of hers packs a punch. Literally. The serpent didn't know what hit it.")
DialogueLine.create("Wren", "Good. You're going to need someone who can fight. The creatures between here and the ruins aren't getting any friendlier.")
```

### State: After Garrick Recruited (`garrick_recruited`)

```
DialogueLine.create("Wren", "I know Garrick by reputation. Twenty years of guarding trade routes, purifying corrupted zones, the whole legend.")
DialogueLine.create("Wren", "With him, Iris, and you? You might actually survive what's out there. High praise from me.")
```

---

## 5. Garrick — Pre-Recruitment Casual Dialogue

**Emotional Tone:** Before recruitment, Garrick is a weary traveler passing through Roothollow. He's guarded and observant, speaking in short sentences that reveal a lifetime of hard experience. He's not unfriendly, just careful — a man who has learned that words have weight and silence has value.

> **Implementation note:** Garrick's casual dialogue plays when the player interacts with his NPC *before* recruitment conditions are met. Once `opening_lyra_discovered` AND `iris_recruited` are both set, the recruitment event triggers via the GarrickRecruitZone instead.

### State: Game Start (no flags)

```
DialogueLine.create("Garrick", "Hmm. You're young for an Echo hunter. Then again, the young ones are usually the bravest. Or the most foolish.")
DialogueLine.create("Garrick", "Don't take that the wrong way. I've been both in my time.")
DialogueLine.create("Garrick", "This village... it's peaceful. Reminds me of places that don't exist anymore. Enjoy it while it lasts.")
```

### State: After Lyra Discovery (`opening_lyra_discovered`, but NOT `iris_recruited`)

```
DialogueLine.create("Garrick", "Word travels fast in a small village. You found something unusual in the ruins.")
DialogueLine.create("Garrick", "A conscious echo... I once served people who would have called that an abomination. I've since learned not to trust their definitions.")
DialogueLine.create("Garrick", "You're in over your head, kid. No offense. What you've found — it'll attract attention. The kind that arrives with swords drawn.")
DialogueLine.create("Garrick", "If I were you, I'd find allies. Real ones. Not the kind who smile when they want something.")
```

**Gameplay purpose:** Garrick hints at his Shepherd past ("I once served people who would have called that an abomination"). His advice to find allies nudges the player toward recruiting Iris.

---

## 6. Lina — Village Child

**Emotional Tone:** Bright, chatty, and endlessly curious. Lina is about eight years old and collects interesting rocks, which sometimes turn out to be minor Echo Fragments. She represents the innocence of Roothollow — the normal life that Kael is fighting to protect. Her dialogue is light and charming, providing contrast to the heavier exposition.

### State: Game Start (no flags)

```
DialogueLine.create("Lina", "Kael! Kael! Look what I found by the river!")
DialogueLine.create("Lina", "It's a pretty rock. See how it shines? Mama says it's just quartz, but I think it's an echo. A tiny one.")
DialogueLine.create("Lina", "When I hold it up to my ear, I can almost hear someone singing. Is that weird?")
DialogueLine.create("Lina", "When I grow up, I want to be an Echo hunter like you! I'll have a big journal and everything!")
```

**Gameplay purpose:** Light world-building. Humanizes the village. The "singing rock" is a subtle hint about Echo Fragments appearing everywhere, even in the hands of children.

### State: After Lyra Discovery (`opening_lyra_discovered`)

```
DialogueLine.create("Lina", "Everyone's acting all serious today. Did something happen?")
DialogueLine.create("Lina", "My pretty rock started glowing last night! Just for a second. Then it stopped.")
DialogueLine.create("Lina", "Mama told me to throw it away, but I hid it under my pillow instead. Don't tell, okay?")
```

**Gameplay purpose:** Mirrors the larger Echo instability in miniature. A child's innocent connection to crystals — echoing the pre-Severance world where everyone was connected to Resonance.

### State: After Iris Recruited (`iris_recruited`)

```
DialogueLine.create("Lina", "Your friend has a SHINY ARM! Is it made of crystal? Can I touch it?")
DialogueLine.create("Lina", "She said maybe later. That's grown-up talk for no, isn't it?")
```

### State: After Garrick Recruited (`garrick_recruited`)

```
DialogueLine.create("Lina", "The big man with the shield told me a story about a knight who fought a dragon made of memories!")
DialogueLine.create("Lina", "He's kinda scary but also kinda nice. Like a grumpy grandpa.")
DialogueLine.create("Lina", "Are you going on an adventure? A REAL adventure? Bring me back something cool!")
```

---

## 7. Signpost Text

The existing signpost text is functional but could be expanded with more character.

### Village Entrance Sign (already in scene)

```
"Welcome to Roothollow — Last safe haven before the Verdant Reach."
```

### Additional Signs (if placed)

**Near the Inn:**
```
"The Hollow Rest — Maren's cooking since before you were born. Hot meals, warm beds, no questions asked."
```

**Near the Shop:**
```
"Bram's General Goods — 'If I don't have it, you probably don't need it.' (Currently experiencing supply difficulties.)"
```

**Near the Forest Exit:**
```
"CAUTION — Verdant Forest ahead. Corrupted wildlife reported. Travel in groups. Report unusual Echo activity to the village scout."
```

---

## 8. Ambient Dialogue — Overheard Townsfolk

These are optional one-liners that could be spoken by background NPCs the player walks near (not interactable, just atmospheric). They reinforce the world-building without requiring interaction.

```
"Did you see the sky last night? Went white for a moment. Un-Sun pulse, they're calling it..."
"My grandmother remembers when the echoes were just... feelings. Warmth on your skin when you walked past one. Now they have teeth."
"The caravan from Prismfall is late. Again. What's happening out there?"
"I found a crystal shard in my garden this morning. Wasn't there yesterday. It whispered my mother's name."
"The Shepherds sent missionaries through last month. Garrick scared them off before they got past the forest."
"They say the old capital is still standing beneath all those vines. A whole city, frozen in time."
"Echo hunters get paid well, but is it worth it? My cousin went out last spring and came back... different."
```

---

## 9. Opening Sequence Refinements

The existing opening sequence (`opening_sequence.gd`) is solid but could be expanded for the demo to provide more context. Here's an enhanced version:

### Enhanced Opening — Lyra Discovery

```
DialogueLine.create("Kael", "These ruins go deeper than I thought. The echoes down here are... dense. Layer upon layer of memory.")
DialogueLine.create("Kael", "Wait. What is that? An Echo Fragment, but... the resonance pattern is completely different.")
DialogueLine.create("Kael", "It's not looping. It's not replaying a memory. It's... reaching out?")
DialogueLine.create("Lyra", "Please... can you hear me? You're the first person who's listened in... I don't know how long.")
DialogueLine.create("Kael", "You can speak? You're... aware? I've catalogued hundreds of echoes and none of them—")
DialogueLine.create("Lyra", "My name is Lyra. I was a researcher, before... before everything ended. I've been scattered. Fragmented.")
DialogueLine.create("Lyra", "Something is wrong with the echoes. They're becoming unstable. The resonance patterns are shifting in ways I haven't seen since—")
DialogueLine.create("Lyra", "...Since the Severance.")
DialogueLine.create("Kael", "That was three hundred years ago. What are you saying?")
DialogueLine.create("Lyra", "I'm saying it could happen again. Please. Help me find the rest of my fragments. I need to remember... to warn you.")
DialogueLine.create("Kael", "I... alright. I'll help you. Let's get out of these ruins first. We can figure out the rest in Roothollow.")
```

---

## 10. Garrick Recruitment — Enhanced Dialogue

An expanded version of the recruitment scene with more personality and emotional weight:

```
DialogueLine.create("Garrick", "You. Echo hunter. We need to talk.")
DialogueLine.create("Kael", "Garrick? What is it?")
DialogueLine.create("Garrick", "I've been watching you since you came back from the ruins. Watching the engineer, too. And that crystal you've been carrying — the conscious one.")
DialogueLine.create("Garrick", "I know what it is. Or rather, I know what my old brothers in the Shepherds would call it. A blasphemy. Something to be silenced.")
DialogueLine.create("Kael", "And what do you call it?")
DialogueLine.create("Garrick", "...A second chance.")
DialogueLine.create("Garrick", "I've spent twenty years trying to make up for the things I did in the name of 'silence.' Burning crystal caches. Purging villages deemed 'corrupted.'")
DialogueLine.create("Garrick", "If what that echo says is true — if a second Severance is coming — then standing here doing nothing is just another form of cowardice.")
DialogueLine.create("Kael", "You want to come with us?")
DialogueLine.create("Garrick", "I want to do something that matters. My shield arm is still strong. My knowledge of crystal purification might be useful. And... someone needs to keep you kids alive out there.")
DialogueLine.create("Kael", "We'd be glad to have you, Garrick.")
DialogueLine.create("Garrick", "Don't be glad yet. Be glad when we're all still standing at the end of this.")
```

---

## 11. Emotional Tone Guidelines by Character

| Character | Voice | Typical Sentence Length | Speech Patterns |
|-----------|-------|------------------------|-----------------|
| **Maren** | Warm, maternal, grounded | Medium-long, flowing | Uses pet names ("dear"), asks caring questions, talks about food/comfort |
| **Bram** | Anxious, stammering, earnest | Short, choppy | Interrupts himself, uses ellipses, mentions numbers/inventory |
| **Elder Thessa** | Measured, cryptic, scholarly | Long, deliberate | Speaks in observations and questions, rarely gives direct answers |
| **Wren** | Terse, dry, practical | Short, clipped | Reports facts, makes sardonic observations, avoids emotion |
| **Garrick** | Gruff, weighted, spare | Short-medium, heavy | Pauses before speaking (implied by "..."), uses military phrasing |
| **Lina** | Bright, rapid, innocent | Short, excitable | Exclamation points, ALL CAPS for emphasis, asks questions constantly |
| **Kael** | Curious, empathetic, uncertain | Medium, thoughtful | Asks questions, processes aloud, uses humor when deflecting |
| **Lyra** | Patient, weary, precise | Medium-long, careful | Scientific vocabulary softened by exhaustion, speaks with weight of centuries |
| **Iris** | Sharp, cynical, guarded | Short-medium, punchy | Sarcastic, deflects with humor, drops guard in moments of vulnerability |

---

## 12. Quest Hooks and Foreshadowing

NPCs should plant seeds for future content. These are embedded in the dialogue above but collected here for reference:

| NPC | Hook | Payoff |
|-----|------|--------|
| **Maren** | "A trader from Prismfall passed through..." | Prismfall as Act I destination |
| **Bram** | Caravan is three days late | Supply route disrupted by corrupted creatures or faction interference |
| **Elder Thessa** | "The Shepherds would destroy her on sight" | Shepherd attack on Roothollow (Act I major event) |
| **Elder Thessa** | "The Initiative would cage her and study her" | Initiative pursuit of the party |
| **Wren** | Crystal growths in animal tracks | Crystal corruption spreading, escalating threat |
| **Garrick** | "I once served people who would call that an abomination" | His Shepherd backstory, Prophet Null connection |
| **Lina** | Rock that glows and whispers | Echo Fragments becoming active everywhere, resonance instability |
| **Ambient** | "Un-Sun pulse" reference | Atmospheric anomalies from world lore, escalating toward second Severance |

---

## 13. Implementation Notes

### Dialogue State System

The current NPC system uses a flat `dialogue_lines: Array[String]` exported on each NPC. For state-dependent dialogue, the implementation should either:

**Option A — Script override:** Create `roothollow_npcs.gd` that checks `EventFlags` and swaps dialogue lines on NPCs at runtime in `_ready()` and after events complete.

**Option B — Dialogue resource:** Create a `DialogueTree` resource that maps flag states to line arrays. More scalable but higher upfront cost.

**Recommended for demo:** Option A. It's simpler and matches the existing event pattern used in `garrick_recruitment.gd` and `opening_sequence.gd`. The full dialogue tree system can be built later.

### NPC Name Changes

The current scene uses generic names ("Innkeeper", "Shopkeeper", "Elder", "Scout"). This document gives them proper names to add personality:

| Scene Node | Current `npc_name` | New `npc_name` |
|------------|-------------------|-----------------|
| InnkeeperNPC | "Innkeeper" | "Maren" |
| ShopkeeperNPC | "Shopkeeper" | "Bram" |
| TownfolkNPC1 | "Elder" | "Elder Thessa" |
| TownfolkNPC2 | "Scout" | "Wren" |
| GarrickNPC | "Garrick" | "Garrick" (unchanged) |
| *(new)* | — | "Lina" |

### Adding Lina

Lina (the child NPC) should be placed near the save crystal at approximately `Vector2(340, 240)`. Use a smaller sprite frame if available, or the same NPC sprite at a reduced scale.

### Dialogue Length Targets

For the demo, each NPC interaction should feel substantial but not exhausting:

- **Primary NPCs** (Maren, Thessa): 3-5 lines per state
- **Secondary NPCs** (Bram, Wren, Garrick pre-recruit): 2-4 lines per state
- **Flavor NPCs** (Lina): 2-3 lines per state
- **Event sequences** (Opening, Recruitment): 8-12 lines

Total estimated dialogue: ~120 lines across all states and NPCs.
