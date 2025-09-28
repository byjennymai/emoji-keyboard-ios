import Foundation

class EmojiDataService: ObservableObject {
    static let shared = EmojiDataService()
    
    @Published var emojiCategories: [EmojiCategory] = []
    @Published var recentEmojis: [String] = []
    @Published var isLoading = false
    
    private let recentEmojisKey = "RecentEmojis"
    private let maxRecentEmojis = 27 // 3 rows of 9
    
    // Dictionary to store emoji categories
    private var categories: [String: Set<String>] = [:]
    
    // Emoji name mappings for search
    private let emojiNames: [String: String] = [
        // Objects
        "👓️": "Glasses",
        "🕶️": "Sunglasses",
        "🥽": "Goggles",
        "🥼": "Lab coat",
        "🦺": "Safety vest",
        "👔": "Necktie",
        "👕": "T-shirt",
        "👖": "Jeans",
        "🧣": "Scarf",
        "🧤": "Gloves",
        "🧥": "Coat",
        "🧦": "Socks",
        "👗": "Dress",
        "👘": "Kimono",
        "🥻": "Sari",
        "🩱": "One-piece swimsuit",
        "🩲": "Briefs",
        "🩳": "Shorts",
        "👙": "Bikini",
        "👚": "Woman's clothes",
        "🪭": "Folding hand fan",
        "👛": "Purse",
        "👜": "Handbag",
        "👝": "Clutch bag",
        "🛍️": "Shopping bags",
        "🎒": "Backpack",
        "🩴": "Thong sandal",
        "👞": "Man's shoe",
        "👟": "Running shoe",
        "🥾": "Hiking boot",
        "🥿": "Flat shoe",
        "👠": "High-heeled shoe",
        "👡": "Woman's sandal",
        "🩰": "Ballet shoes",
        "👢": "Woman's boot",
        "🪮": "Hair pick",
        "👑": "Crown",
        "👒": "Woman's hat",
        "🎩": "Top hat",
        "🎓️": "Graduation cap",
        "🧢": "Billed cap",
        "🪖": "Military helmet",
        "⛑️": "Rescue worker's helmet",
        "📿": "Prayer beads",
        "💄": "Lipstick",
        "💍": "Ring",
        "💎": "Gem stone",
        "🔇": "Muted speaker",
        "🔈️": "Speaker low volume",
        "🔉": "Speaker medium volume",
        "🔊": "Speaker high volume",
        "📢": "Loudspeaker",
        "📣": "Megaphone",
        "📯": "Postal horn",
        "🔔": "Bell",
        "🔕": "Bell with slash",
        "🎼": "Musical score",
        "🎵": "Musical note",
        "🎶": "Musical notes",
        "🎙️": "Studio microphone",
        "🎚️": "Level slider",
        "🎛️": "Control knobs",
        "🎤": "Microphone",
        "🎧️": "Headphone",
        "📻️": "Radio",
        "🎷": "Saxophone",
        "🪗": "Accordion",
        "🎸": "Guitar",
        "🎹": "Musical keyboard",
        "🎺": "Trumpet",
        "🎻": "Violin",
        "🪕": "Banjo",
        "🥁": "Drum",
        "🪘": "Long drum",
        "🪇": "Maracas",
        "🪈": "Flute",
        "🪉": "Harp",
        "📱": "Mobile phone",
        "📲": "Mobile phone with arrow",
        "☎️": "Telephone",
        "📞": "Telephone receiver",
        "📟️": "Pager",
        "📠": "Fax machine",
        "🔋": "Battery",
        "🪫": "Low battery",
        "🔌": "Electric plug",
        "💻️": "Laptop",
        "🖥️": "Desktop computer",
        "🖨️": "Printer",
        "⌨️": "Keyboard",
        "🖱️": "Computer mouse",
        "🖲️": "Trackball",
        "💽": "Computer disk",
        "💾": "Floppy disk",
        "💿️": "Optical disk",
        "📀": "DVD",
        "🧮": "Abacus",
        "🎥": "Movie camera",
        "🎞️": "Film frames",
        "📽️": "Film projector",
        "🎬️": "Clapper board",
        "📺️": "Television",
        "📷️": "Camera",
        "📸": "Camera with flash",
        "📹️": "Video camera",
        "📼": "Videocassette",
        "🔍️": "Magnifying glass tilted left",
        "🔎": "Magnifying glass tilted right",
        "🕯️": "Candle",
        "💡": "Light bulb",
        "🔦": "Flashlight",
        "🏮": "Red paper lantern",
        "🪔": "Diya lamp",
        "📔": "Notebook with decorative cover",
        "📕": "Closed book",
        "📖": "Open book",
        "📗": "Green book",
        "📘": "Blue book",
        "📙": "Orange book",
        "📚️": "Books",
        "📓": "Notebook",
        "📒": "Ledger",
        "📃": "Page with curl",
        "📜": "Scroll",
        "📄": "Page facing up",
        "📰": "Newspaper",
        "🗞️": "Rolled-up newspaper",
        "📑": "Bookmark tabs",
        "🔖": "Bookmark",
        "🏷️": "Label",
        "💰️": "Money bag",
        "🪙": "Coin",
        "💴": "Yen banknote",
        "💵": "Dollar banknote",
        "💶": "Euro banknote",
        "💷": "Pound banknote",
        "💸": "Money with wings",
        "💳️": "Credit card",
        "🧾": "Receipt",
        "💹": "Chart increasing with yen",
        "✉️": "Envelope",
        "📧": "E-mail",
        "📨": "Incoming envelope",
        "📩": "Envelope with arrow",
        "📤️": "Outbox tray",
        "📥️": "Inbox tray",
        "📦️": "Package",
        "📫️": "Closed mailbox with raised flag",
        "📪️": "Closed mailbox with lowered flag",
        "📬️": "Open mailbox with raised flag",
        "📭️": "Open mailbox with lowered flag",
        "📮": "Postbox",
        "🗳️": "Ballot box with ballot",
        "✏️": "Pencil",
        "✒️": "Black nib",
        "🖋️": "Fountain pen",
        "🖊️": "Pen",
        "🖌️": "Paintbrush",
        "🖍️": "Crayon",
        "📝": "Memo",
        "💼": "Briefcase",
        "📁": "File folder",
        "📂": "Open file folder",
        "🗂️": "Card index dividers",
        "📅": "Calendar",
        "📆": "Tear-off calendar",
        "🗒️": "Spiral notepad",
        "🗓️": "Spiral calendar",
        "📇": "Card index",
        "📈": "Chart increasing",
        "📉": "Chart decreasing",
        "📊": "Bar chart",
        "📋️": "Clipboard",
        "📌": "Pushpin",
        "📎": "Paperclip",
        "🖇️": "Linked paperclips",
        "📏": "Straight ruler",
        "📐": "Triangular ruler",
        "✂️": "Scissors",
        "🗃️": "Card file box",
        "🗄️": "File cabinet",
        "🗑️": "Wastebasket",
        "🔒️": "Locked",
        "🔓️": "Unlocked",
        "🔏": "Locked with pen",
        "🔐": "Locked with key",
        "🔑": "Key",
        "🗝️": "Old key",
        "🔨": "Hammer",
        "🪓": "Axe",
        "⛏️": "Pick",
        "⚒️": "Hammer and pick",
        "🛠️": "Hammer and wrench",
        "🗡️": "Dagger",
        "⚔️": "Crossed swords",
        "💣️": "Bomb",
        "🪃": "Boomerang",
        "🏹": "Bow and arrow",
        "🛡️": "Shield",
        "🪚": "Carpentry saw",
        "🔧": "Wrench",
        "🪛": "Screwdriver",
        "🔩": "Nut and bolt",
        "⚙️": "Gear",
        "🗜️": "Clamp",
        "⚖️": "Balance scale",
        "🦯": "White cane",
        "🔗": "Link",
        "⛓️‍💥": "Broken chain",
        "⛓️": "Chains",
        "🪝": "Hook",
        "🧰": "Toolbox",
        "🧲": "Magnet",
        "🪜": "Ladder",
        "🪏": "Shovel",
        "⚗️": "Alembic",
        "🧪": "Test tube",
        "🧫": "Petri dish",
        "🧬": "DNA",
        "🔬": "Microscope",
        "🔭": "Telescope",
        "📡": "Satellite antenna",
        "💉": "Syringe",
        "🩸": "Drop of blood",
        "💊": "Pill",
        "🩹": "Adhesive bandage",
        "🩼": "Crutch",
        "🩺": "Stethoscope",
        "🩻": "X-ray",
        "🚪": "Door",
        "🛗": "Elevator",
        "🪞": "Mirror",
        "🪟": "Window",
        "🛏️": "Bed",
        "🛋️": "Couch and lamp",
        "🪑": "Chair",
        "🚽": "Toilet",
        "🪠": "Plunger",
        "🚿": "Shower",
        "🛁": "Bathtub",
        "🪤": "Mouse trap",
        "🪒": "Razor",
        "🧴": "Lotion bottle",
        "🧷": "Safety pin",
        "🧹": "Broom",
        "🧺": "Basket",
        "🧻": "Roll of paper",
        "🪣": "Bucket",
        "🧼": "Soap",
        "🫧": "Bubbles",
        "🪥": "Toothbrush",
        "🧽": "Sponge",
        "🧯": "Fire extinguisher",
        "🛒": "Shopping cart",
        "🚬": "Cigarette",
        "⚰️": "Coffin",
        "🪦": "Headstone",
        "⚱️": "Funeral urn",
        "🧿": "Nazar amulet",
        "🪬": "Hamsa",
        "🗿": "Moai",
        "🪧": "Placard",
        "🪪": "Identification card",
        
        // Animals & Nature
        "🐵": "Monkey face",
        "🐒": "Monkey",
        "🦍": "Gorilla",
        "🦧": "Orangutan",
        "🐶": "Dog face",
        "🐕️": "Dog",
        "🦮": "Guide dog",
        "🐕‍🦺": "Service dog",
        "🐩": "Poodle"
    ]
    
    // Ordered list of Smileys & Emotion emojis
    private let smileysAndEmotionEmojis: [String] = [
        "😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣", "😊", "😇",
        "🙂", "🙃", "😉", "😍", "🥰", "😘", "😗", "😙", "😚", "😋",
        "😛", "😜", "🤪", "😝", "🤑", "🤗", "🤭", "🤫", "🤔", "🤐",
        "🤨", "😐", "😑", "😶", "😶‍🌫️", "😏", "😒", "🙄", "😬", "🤥",
        "😌", "😔", "😪", "🤤", "😴", "😷", "🤒", "🤕", "🤢", "🤮",
        "🤧", "🥵", "🥶", "🥴", "😵", "😵‍💫", "🤠", "🥳", "🥸", "😎",
        "🤓", "🧐", "😕", "😟", "🙁", "☹️", "😮", "😯", "😲", "😳",
        "🥺", "😦", "😧", "😨", "😰", "😥", "😢", "😭", "😱", "😖",
        "😣", "😞", "😓", "😩", "😫", "🥱", "😤", "😡", "😠", "🤬",
        "😈", "👿", "💀", "☠️", "💩", "🤡", "👹", "👺", "👻", "👽",
        "👾", "🤖", "😺", "😸", "😹", "😻", "😼", "😽", "🙀", "😿",
        "😾", "🙈", "🙉", "🙊", "💌", "💘", "💝", "💖", "💗", "💓",
        "💞", "💕", "💟", "❣️", "💔", "❤️‍🔥", "❤️‍🩹", "❤️", "🧡", "💛",
        "💚", "💙", "💜", "🤎", "🖤", "🤍", "💯", "💢", "💥", "💫",
        "💦", "💨", "🗨️", "👁️‍🗨️", "🗯️", "💭", "💤"
    ]
    
    // Ordered list of People & Body emojis
    private let peopleAndBodyEmojis: [String] = [
        "👋", "🤚", "🖐️", "✋️", "🖖", "🫱", "🫲", "🫳", "🫴", "🫷",
        "🫸", "👌", "🤌", "🤏", "✌️", "🤞", "🫰", "🤟", "🤘", "🤙",
        "👈️", "👉️", "👆️", "🖕", "👇️", "☝️", "🫵", "👍️", "👎️", "✊️",
        "👊", "🤛", "🤜", "👏", "🙌", "🫶", "👐", "🤲", "🤝", "🙏",
        "✍️", "💅", "🤳", "💪", "🦾", "🦿", "🦵", "🦶", "👂️", "🦻",
        "👃", "🧠", "🫀", "🫁", "🦷", "🦴", "👀", "👁️", "👅", "👄",
        "🫦", "👶", "🧒", "👦", "👧", "🧑", "👱", "👨", "🧔", "🧔‍♂️",
        "🧔‍♀️", "👨‍🦰", "👨‍🦱", "👨‍🦳", "👨‍🦲", "👩", "👩‍🦰", "🧑‍🦰", "👩‍🦱", "🧑‍🦱",
        "👩‍🦳", "🧑‍🦳", "👩‍🦲", "🧑‍🦲", "👱‍♀️", "👱‍♂️", "🧓", "👴", "👵", "🙍",
        "🙍‍♂️", "🙍‍♀️", "🙎", "🙎‍♂️", "🙎‍♀️", "🙅", "🙅‍♂️", "🙅‍♀️", "🙆", "🙆‍♂️",
        "🙆‍♀️", "💁", "💁‍♂️", "💁‍♀️", "🙋", "🙋‍♂️", "🙋‍♀️", "🧏", "🧏‍♂️", "🧏‍♀️",
        "🙇", "🙇‍♂️", "🙇‍♀️", "🤦", "🤦‍♂️", "🤦‍♀️", "🤷", "🤷‍♂️", "🤷‍♀️", "🧑‍⚕️",
        "👨‍⚕️", "👩‍⚕️", "🧑‍🎓", "👨‍🎓", "👩‍🎓", "🧑‍🏫", "👨‍🏫", "👩‍🏫", "🧑‍⚖️", "👨‍⚖️",
        "👩‍⚖️", "🧑‍🌾", "👨‍🌾", "👩‍🌾", "🧑‍🍳", "👨‍🍳", "👩‍🍳", "🧑‍🔧", "👨‍🔧", "👩‍🔧",
        "🧑‍🏭", "👨‍🏭", "👩‍🏭", "🧑‍💼", "👨‍💼", "👩‍💼", "🧑‍🔬", "👨‍🔬", "👩‍🔬", "🧑‍💻",
        "👨‍💻", "👩‍💻", "🧑‍🎤", "👨‍🎤", "👩‍🎤", "🧑‍🎨", "👨‍🎨", "👩‍🎨", "🧑‍✈️", "👨‍✈️",
        "👩‍✈️", "🧑‍🚀", "👨‍🚀", "👩‍🚀", "🧑‍🚒", "👨‍🚒", "👩‍🚒", "👮", "👮‍♂️", "👮‍♀️",
        "🕵️", "🕵️‍♂️", "🕵️‍♀️", "💂", "💂‍♂️", "💂‍♀️", "🥷", "👷", "👷‍♂️", "👷‍♀️",
        "🫅", "🤴", "👸", "👳", "👳‍♂️", "👳‍♀️", "👲", "🧕", "🤵", "🤵‍♂️",
        "🤵‍♀️", "👰", "👰‍♂️", "👰‍♀️", "🤰", "🫃", "🫄", "🤱", "👩‍🍼", "👨‍🍼",
        "🧑‍🍼", "👼", "🎅", "🤶", "🧑‍🎄", "🦸", "🦸‍♂️", "🦸‍♀️", "🦹", "🦹‍♂️",
        "🦹‍♀️", "🧙", "🧙‍♂️", "🧙‍♀️", "🧚", "🧚‍♂️", "🧚‍♀️", "🧛", "🧛‍♂️", "🧛‍♀️",
        "🧜", "🧜‍♂️", "🧜‍♀️", "🧝", "🧝‍♂️", "🧝‍♀️", "🧞", "🧞‍♂️", "🧞‍♀️", "🧟",
        "🧟‍♂️", "🧟‍♀️", "🧌", "💆", "💆‍♂️", "💆‍♀️", "💇", "💇‍♂️", "💇‍♀️", "🚶",
        "🚶‍♂️", "🚶‍♀️", "🚶‍➡️", "🚶‍♀️‍➡️", "🚶‍♂️‍➡️", "🧍", "🧍‍♂️", "🧍‍♀️", "🧎", "🧎‍♂️",
        "🧎‍♀️", "🧎‍➡️", "🧎‍♀️‍➡️", "🧎‍♂️‍➡️", "🧑‍🦯", "🧑‍🦯‍➡️", "👨‍🦯", "👨‍🦯‍➡️", "👩‍🦯", "👩‍🦯‍➡️",
        "🧑‍🦼", "🧑‍🦼‍➡️", "👨‍🦼", "👨‍🦼‍➡️", "👩‍🦼", "👩‍🦼‍➡️", "🧑‍🦽", "🧑‍🦽‍➡️", "👨‍🦽", "👨‍🦽‍➡️",
        "👩‍🦽", "👩‍🦽‍➡️", "🏃", "🏃‍♂️", "🏃‍♀️", "🏃‍➡️", "🏃‍♀️‍➡️", "🏃‍♂️‍➡️", "💃", "🕺",
        "🕴️", "👯", "👯‍♂️", "👯‍♀️", "🧖", "🧖‍♂️", "🧖‍♀️", "🧗", "🧗‍♂️", "🧗‍♀️",
        "🤺", "🏇", "⛷️", "🏂️", "🏌️", "🏌️‍♂️", "🏌️‍♀️", "🏄️", "🏄‍♂️", "🏄‍♀️",
        "🚣", "🚣‍♂️", "🚣‍♀️", "🏊️", "🏊‍♂️", "🏊‍♀️", "⛹️", "⛹️‍♂️", "⛹️‍♀️", "🏋️",
        "🏋️‍♂️", "🏋️‍♀️", "🚴", "🚴‍♂️", "🚴‍♀️", "🚵", "🚵‍♂️", "🚵‍♀️", "🤸", "🤸‍♂️",
        "🤸‍♀️", "🤼", "🤼‍♂️", "🤼‍♀️", "🤽", "🤽‍♂️", "🤽‍♀️", "🤾", "🤾‍♂️", "🤾‍♀️",
        "🤹", "🤹‍♂️", "🤹‍♀️", "🧘", "🧘‍♂️", "🧘‍♀️", "🛀", "🛌", "🧑‍🤝‍🧑", "👭",
        "👫", "👬", "💏", "👩‍❤️‍💋‍👨", "👨‍❤️‍💋‍👨", "👩‍❤️‍💋‍👩", "💑", "👩‍❤️‍👨", "👨‍❤️‍👨", "👩‍❤️‍👩",
        "👨‍👩‍👦", "👨‍👩‍👧", "👨‍👩‍👧‍👦", "👨‍👩‍👦‍👦", "👨‍👩‍👧‍👧", "👨‍👨‍👦", "👨‍👨‍👧", "👨‍👨‍👧‍👦", "👨‍👨‍👦‍👦", "👨‍👨‍👧‍👧",
        "👩‍👩‍👦", "👩‍👩‍👧", "👩‍👩‍👧‍👦", "👩‍👩‍👦‍👦", "👩‍👩‍👧‍👧", "👨‍👦", "👨‍👦‍👦", "👨‍👧", "👨‍👧‍👦", "👨‍👧‍👧",
        "👩‍👦", "👩‍👦‍👦", "👩‍👧", "👩‍👧‍👦", "👩‍👧‍👧", "🗣️", "👤", "👥", "🫂", "👪️",
        "🧑‍🧑‍🧒", "🧑‍🧑‍🧒‍🧒", "🧑‍🧒", "🧑‍🧒‍🧒", "👣", "🫆"
    ]
    
    // Ordered list of Animals & Nature emojis
    private let animalsAndNatureEmojis = [
        // Mammals
        "🐵", "🐒", "🦍", "🦧", "🐶", "🐕️", "🦮", "🐕‍🦺", "🐩", "🐺", "🦊", "🦝", 
        "🐱", "🐈️", "🐈‍⬛", "🦁", "🐯", "🐅", "🐆", "🐴", "🫎", "🫏", "🐎", "🦄", 
        "🦓", "🦌", "🦬", "🐮", "🐂", "🐃", "🐄", "🐷", "🐖", "🐗", "🐽", "🐏", 
        "🐑", "🐐", "🐪", "🐫", "🦙", "🦒", "🐘", "🦣", "🦏", "🦛", "🐭", "🐁", 
        "🐀", "🐹", "🐰", "🐇", "🐿️", "🦫", "🦔", "🦇", "🐻", "🐻‍❄️", "🐨", "🐼", 
        "🦥", "🦦", "🦨", "🦘", "🦡", "🐾",

        // Birds
        "🦃", "🐔", "🐓", "🐣", "🐤", "🐥", "🐦️", "🐧", "🕊️", "🦅", "🦆", "🦢", 
        "🦉", "🦤", "🪶", "🦩", "🦚", "🦜", "🪽", "🐦‍⬛", "🪿", "🐦‍🔥",

        // Reptiles & Amphibians
        "🐸", "🐊", "🐢", "🦎", "🐍", "🐲", "🐉", "🦕", "🦖",

        // Marine Life
        "🐳", "🐋", "🐬", "🦭", "🐟️", "🐠", "🐡", "🦈", "🐙", "🐚", "🪸", "🪼", 
        "🦀", "🦞", "🦐", "🦑", "🦪",

        // Insects & Arachnids
        "🐌", "🦋", "🐛", "🐜", "🐝", "🪲", "🐞", "🦗", "🪳", "🕷️", "🕸️", "🦂", 
        "🦟", "🪰", "🪱", "🦠",

        // Plants & Flowers
        "💐", "🌸", "💮", "🪷", "🏵️", "🌹", "🥀", "🌺", "🌻", "🌼", "🌷", "🪻", 
        "🌱", "🪴", "🌲", "🌳", "🌴", "🌵", "🌾", "🌿", "☘️", "🍀", "🍁", "🍂", 
        "🍃", "🪹", "🪺", "🍄", "🪾"
    ]
    
    // Ordered list of Food & Drink emojis
    private let foodAndDrinkEmojis = [
        // Fruits
        "🍇", "🍈", "🍉", "🍊", "🍋", "🍋‍🟩", "🍌", "🍍", "🥭", "🍎", "🍏", "🍐", 
        "🍑", "🍒", "🍓", "🫐", "🥝", "🍅", "🫒", "🥥",
        
        // Vegetables
        "🥑", "🍆", "🥔", "🥕", "🌽", "🌶️", "🫑", "🥒", "🥬", "🥦", "🧄", "🧅", 
        "🥜", "🫘", "🌰", "🫚", "🫛", "🍄‍🟫", "🫜",
        
        // Prepared Foods
        "🍞", "🥐", "🥖", "🫓", "🥨", "🥯", "🥞", "🧇", "🧀", "🍖", "🍗", "🥩", 
        "🥓", "🍔", "🍟", "🍕", "🌭", "🥪", "🌮", "🌯", "🫔", "🥙", "🧆", "🥚", 
        "🍳", "🥘", "🍲", "🫕", "🥣", "🥗", "🍿", "🧈", "🧂", "🥫",
        
        // Asian Foods
        "🍱", "🍘", "🍙", "🍚", "🍛", "🍜", "🍝", "🍠", "🍢", "🍣", "🍤", "🍥", 
        "🥮", "🍡", "🥟", "🥠", "🥡",
        
        // Sweets & Desserts
        "🍦", "🍧", "🍨", "🍩", "🍪", "🎂", "🍰", "🧁", "🥧", "🍫", "🍬", "🍭", 
        "🍮", "🍯",
        
        // Drinks
        "🍼", "🥛", "☕️", "🫖", "🍵", "🍶", "🍾", "🍷", "🍸️", "🍹", "🍺", "🍻", 
        "🥂", "🥃", "🫗", "🥤", "🧋", "🧃", "🧉", "🧊",
        
        // Utensils
        "🥢", "🍽️", "🍴", "🥄", "🔪", "🫙", "🏺"
    ]

    // Ordered list of Activities emojis
    private let activitiesEmojis = [
        // Celebrations & Events
        "🎃", "🎄", "🎆", "🎇", "🧨", "✨️", "🎈", "🎉", "🎊", "🎋", "🎍", "🎎", 
        "🎏", "🎐", "🎑", "🧧", "🎀", "🎁", "🎗️", "🎟️", "🎫",
        
        // Awards & Medals
        "🎖️", "🏆️", "🏅", "🥇", "🥈", "🥉",
        
        // Sports Equipment & Activities
        "⚽️", "⚾️", "🥎", "🏀", "🏐", "🏈", "🏉", "🎾", "🥏", "🎳", "🏏", "🏑", 
        "🏒", "🥍", "🏓", "🏸", "🥊", "🥋", "🥅", "⛳️", "⛸️", "🎣", "🤿", "🎽", 
        "🎿", "🛷", "🥌",
        
        // Games & Entertainment
        "🎯", "🪀", "🪁", "🔫", "🎱", "🔮", "🪄", "🎮️", "🕹️", "🎰", "🎲", "🧩", 
        "🧸", "🪅", "🪩", "🪆",
        
        // Card & Board Games
        "♠️", "♥️", "♦️", "♣️", "♟️", "🃏", "🀄️", "🎴",
        
        // Arts & Crafts
        "🎭️", "🖼️", "🎨", "🧵", "🪡", "🧶", "🪢"
    ]

    // Ordered list of Travel & Places emojis
    private let travelAndPlacesEmojis = [
        // Globes & Maps
        "🌍️", "🌎️", "🌏️", "🌐", "🗺️", "🗾", "🧭",
        
        // Geographic Locations
        "🏔️", "⛰️", "🌋", "🗻", "🏕️", "🏖️", "🏜️", "🏝️", "🏞️",
        
        // Buildings & Construction
        "🏟️", "🏛️", "🏗️", "🧱", "🪨", "🪵", "🛖", "🏘️", "🏚️", "🏠️", "🏡", 
        "🏢", "🏣", "🏤", "🏥", "🏦", "🏨", "🏩", "🏪", "🏫", "🏬", "🏭️", "🏯", 
        "🏰", "💒", "🗼", "🗽", "⛪️", "🕌", "🛕", "🕍", "⛩️", "🕋",
        
        // City & Scenery
        "⛲️", "⛺️", "🌁", "🌃", "🏙️", "🌄", "🌅", "🌆", "🌇", "🌉", "♨️",
        
        // Entertainment Places
        "🎠", "🛝", "🎡", "🎢", "💈", "🎪",
        
        // Ground Transportation
        "🚂", "🚃", "🚄", "🚅", "🚆", "🚇️", "🚈", "🚉", "🚊", "🚝", "🚞", "🚋", 
        "🚌", "🚍️", "🚎", "🚐", "🚑️", "🚒", "🚓", "🚔️", "🚕", "🚖", "🚗", "🚘️", 
        "🚙", "🛻", "🚚", "🚛", "🚜", "🏎️", "🏍️", "🛵", "🦽", "🦼", "🛺", "🚲️", 
        "🛴", "🛹", "🛼",
        
        // Transport Infrastructure
        "🚏", "🛣️", "🛤️", "🛢️", "⛽️", "🛞", "🚨", "🚥", "🚦", "🛑", "🚧",
        
        // Water Transportation
        "⚓️", "🛟", "⛵️", "🛶", "🚤", "🛳️", "⛴️", "🛥️", "🚢",
        
        // Air Transportation
        "✈️", "🛩️", "🛫", "🛬", "🪂", "💺", "🚁", "🚟", "🚠", "🚡", "🛰️", "🚀", "🛸",
        
        // Travel Items
        "🛎️", "🧳",
        
        // Time
        "⌛️", "⏳️", "⌚️", "⏰️", "⏱️", "⏲️", "🕰️",
        "🕛️", "🕧️", "🕐️", "🕜️", "🕑️", "🕝️", "🕒️", "🕞️", "🕓️", "🕟️",
        "🕔️", "🕠️", "🕕️", "🕡️", "🕖️", "🕢️", "🕗️", "🕣️", "🕘️", "🕤️",
        "🕙️", "🕥️", "🕚️", "🕦️",
        
        // Sky & Weather
        "🌑", "🌒", "🌓", "🌔", "🌕️", "🌖", "🌗", "🌘", "🌙", "🌚", "🌛", "🌜️",
        "🌡️", "☀️", "🌝", "🌞", "🪐", "⭐️", "🌟", "🌠", "🌌", "☁️", "⛅️", "⛈️",
        "🌤️", "🌥️", "🌦️", "🌧️", "🌨️", "🌩️", "🌪️", "🌫️", "🌬️", "🌀", "🌈",
        "🌂", "☂️", "☔️", "⛱️", "⚡️", "❄️", "☃️", "⛄️", "☄️", "🔥", "💧", "🌊"
    ]
    
    // Ordered list of Objects emojis
    private let objectsEmojis = [
        "👓️", "🕶️", "🥽", "🥼", "🦺", "👔", "👕", "👖", "🧣", "🧤", "🧥", "🧦", "👗", "👘", "🥻", "🩱", "🩲", "🩳", "👙", "👚", "🪭", "👛", "👜", "👝", "🛍️", "🎒", "🩴", "👞", "👟", "🥾", "🥿", "👠", "👡", "🩰", "👢", "🪮", "👑", "👒", "🎩", "🎓️", "🧢", "🪖", "⛑️", "📿", "💄", "💍", "💎", "🔇", "🔈️", "🔉", "🔊", "📢", "📣", "📯", "🔔", "🔕", "🎼", "🎵", "🎶", "🎙️", "🎚️", "🎛️", "🎤", "🎧️", "📻️", "🎷", "🪗", "🎸", "🎹", "🎺", "🎻", "🪕", "🥁", "🪘", "🪇", "🪈", "🪉", "📱", "📲", "☎️", "📞", "📟️", "📠", "🔋", "🪫", "🔌", "💻️", "🖥️", "🖨️", "⌨️", "🖱️", "🖲️", "💽", "💾", "💿️", "📀", "🧮", "🎥", "🎞️", "📽️", "🎬️", "📺️", "📷️", "📸", "📹️", "📼", "🔍️", "🔎", "🕯️", "💡", "🔦", "🏮", "🪔", "📔", "📕", "📖", "📗", "📘", "📙", "📚️", "📓", "📒", "📃", "📜", "📄", "📰", "🗞️", "📑", "🔖", "🏷️", "💰️", "🪙", "💴", "💵", "💶", "💷", "💸", "💳️", "🧾", "💹", "✉️", "📧", "📨", "📩", "📤️", "📥️", "📦️", "📫️", "📪️", "📬️", "📭️", "📮", "🗳️", "✏️", "✒️", "🖋️", "🖊️", "🖌️", "🖍️", "📝", "💼", "📁", "📂", "🗂️", "📅", "📆", "🗒️", "🗓️", "📇", "📈", "📉", "📊", "📋️", "📌", "📎", "🖇️", "📏", "📐", "✂️", "🗃️", "🗄️", "🗑️", "🔒️", "🔓️", "🔏", "🔐", "🔑", "🗝️", "🔨", "🪓", "⛏️", "⚒️", "🛠️", "🗡️", "⚔️", "💣️", "🪃", "🏹", "🛡️", "🪚", "🔧", "🪛", "🔩", "⚙️", "🗜️", "⚖️", "🦯", "🔗", "⛓️‍💥", "⛓️", "🪝", "🧰", "🧲", "🪜", "🪏", "⚗️", "🧪", "🧫", "🧬", "🔬", "🔭", "📡", "💉", "🩸", "💊", "🩹", "🩼", "🩺", "🩻", "🚪", "🛗", "🪞", "🪟", "🛏️", "🛋️", "🪑", "🚽", "🪠", "🚿", "🛁", "🪤", "🪒", "🧴", "🧷", "🧹", "🧺", "🧻", "🪣", "🧼", "🫧", "🪥", "🧽", "🧯", "🛒", "🚬", "⚰️", "🪦", "⚱️", "🧿", "🪬", "🗿", "🪧", "🪪"
    ]
    
    private init() {
        loadRecentEmojis()
        isLoading = true
        
        // Initialize categories dictionary with our ordered lists
        categories["Smileys & Emotion"] = Set(smileysAndEmotionEmojis)
        categories["People & Body"] = Set(peopleAndBodyEmojis)
        categories["Animals & Nature"] = Set(animalsAndNatureEmojis)
        categories["Food & Drink"] = Set(foodAndDrinkEmojis)
        categories["Activities"] = Set(activitiesEmojis)
        categories["Travel & Places"] = Set(travelAndPlacesEmojis)
        categories["Objects"] = Set(objectsEmojis)
        
        // Process ranges for other categories
        let ranges: [(Range<Int>, String)] = [
            // Animals & Nature
            (0x1F400..<0x1F440, "Animals & Nature"),   // Animals
            (0x1F980..<0x1F9B0, "Animals & Nature"),   // More animals
            (0x1F330..<0x1F340, "Animals & Nature"),   // Plants
            (0x1F340..<0x1F350, "Animals & Nature"),   // More plants
            
            // Food & Drink
            (0x1F32D..<0x1F380, "Food & Drink"),       // Food items
            (0x1F950..<0x1F970, "Food & Drink"),       // More food
            (0x1F96C..<0x1F970, "Food & Drink"),       // Even more food
            (0x1F9C0..<0x1F9CB, "Food & Drink"),       // Additional food
            
            // Activities
            (0x1F380..<0x1F394, "Activities"),         // Celebration
            (0x1F3A0..<0x1F3B0, "Activities"),         // Entertainment
            (0x1F3B0..<0x1F3C0, "Activities"),         // Games
            (0x1F3C0..<0x1F3D0, "Activities"),         // Sports
            (0x1F93A..<0x1F950, "Activities"),         // More sports
            
            // Travel & Places
            (0x1F680..<0x1F6B0, "Travel & Places"),    // Transport
            (0x1F6B0..<0x1F6C0, "Travel & Places"),    // Additional transport
            (0x1F3D4..<0x1F3E0, "Travel & Places"),    // Landscapes
            (0x1F3DB..<0x1F3E0, "Travel & Places"),    // Buildings
            
            // Objects
            (0x1F4A0..<0x1F500, "Objects"),            // Various objects
            (0x1F500..<0x1F53D, "Objects"),            // More objects
            (0x1F6CC..<0x1F6D0, "Objects"),            // Household
            (0x1F9F0..<0x1FA00, "Objects"),            // Additional objects
            
            // Symbols
            (0x2600..<0x2700, "Symbols"),              // Misc symbols
            (0x2700..<0x27C0, "Symbols"),              // Dingbats
            (0x2B00..<0x2C00, "Symbols"),              // Arrows
            (0x1F300..<0x1F321, "Symbols"),            // Weather
            
            // Flags
            (0x1F1E6..<0x1F200, "Flags"),             // Regional indicators
            (0x1F3F3..<0x1F3F6, "Flags"),             // Various flags
            (0x1F38C..<0x1F390, "Flags")              // Flag ornaments
        ]
        
        for (range, category) in ranges {
            if !["Smileys & Emotion", "People & Body", "Animals & Nature", "Food & Drink", "Activities", "Travel & Places", "Objects"].contains(category) {
                for codePoint in range {
                    if let scalar = UnicodeScalar(codePoint),
                       scalar.properties.generalCategory != .unassigned {
                        let emoji = String(scalar)
                        if categories[category] == nil {
                            categories[category] = []
                        }
                        categories[category]?.insert(emoji)
                    }
                }
            }
        }
        
        // Convert categories to EmojiCategory objects
        emojiCategories = EmojiCategory.categoryOrder.compactMap { name in
            guard let emojis = categories[name] else { return nil }
            return EmojiCategory(name: name, emojis: getEmojis(for: name))
        }
        
        isLoading = false
    }
    
    func loadSystemEmojis() {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let categories = self.generateEmojiCategories()
            
            DispatchQueue.main.async {
                self.emojiCategories = categories
                self.isLoading = false
            }
        }
    }
    
    private func generateEmojiCategories() -> [EmojiCategory] {
        var categories: [String: Set<String>] = [:]
        
        // Initialize all categories from the order list
        for category in EmojiCategory.categoryOrder where category != "Recent" {
            categories[category] = Set()
        }
        
        // Add Smileys & Emotion category with exact ordering
        categories["Smileys & Emotion"] = Set(smileysAndEmotionEmojis)
        
        // Add People & Body category with exact ordering
        categories["People & Body"] = Set(peopleAndBodyEmojis)
        
        // Add Animals & Nature category with exact ordering
        categories["Animals & Nature"] = Set(animalsAndNatureEmojis)
        
        // Add Food & Drink category with exact ordering
        categories["Food & Drink"] = Set(foodAndDrinkEmojis)
        
        // Add Activities category with exact ordering
        categories["Activities"] = Set(activitiesEmojis)
        
        // Add Travel & Places category with exact ordering
        categories["Travel & Places"] = Set(travelAndPlacesEmojis)
        
        // Add Objects category with exact ordering
        categories["Objects"] = Set(objectsEmojis)
        
        // 1. Basic emoji collection from Unicode ranges (for other categories)
        let ranges: [(Range<Int>, String)] = [
            // Symbols
            (0x2600..<0x2700, "Symbols"),              // Misc symbols
            (0x2700..<0x27C0, "Symbols"),              // Dingbats
            (0x2B00..<0x2C00, "Symbols"),              // Arrows
            (0x1F300..<0x1F321, "Symbols"),            // Weather
            
            // Flags
            (0x1F1E6..<0x1F200, "Flags"),             // Regional indicators
            (0x1F3F3..<0x1F3F6, "Flags"),             // Various flags
            (0x1F38C..<0x1F390, "Flags")              // Flag ornaments
        ]
        
        // Process ranges for other categories
        for (range, category) in ranges {
            if !["Smileys & Emotion", "People & Body", "Animals & Nature", "Food & Drink", "Activities", "Travel & Places", "Objects"].contains(category) { // Skip categories we handle separately
                for codePoint in range {
                    if let scalar = UnicodeScalar(codePoint),
                       scalar.properties.isEmoji && scalar.properties.isEmojiPresentation {
                        let emoji = String(scalar)
                        categories[category]?.insert(emoji)
                    }
                }
            }
        }
        
        // Convert to EmojiCategory objects and sort by defined order
        return categories.compactMap { name, emojis in
            guard !emojis.isEmpty else { return nil }
            // For ordered categories, preserve the exact order
            let sortedEmojis = if name == "Smileys & Emotion" {
                smileysAndEmotionEmojis
            } else if name == "People & Body" {
                peopleAndBodyEmojis
            } else if name == "Animals & Nature" {
                animalsAndNatureEmojis
            } else if name == "Food & Drink" {
                foodAndDrinkEmojis
            } else if name == "Activities" {
                activitiesEmojis
            } else if name == "Travel & Places" {
                travelAndPlacesEmojis
            } else if name == "Objects" {
                objectsEmojis
            } else {
                Array(emojis).sorted()
            }
            return EmojiCategory(name: name, emojis: sortedEmojis)
        }.sorted { cat1, cat2 in
            cat1.sortOrder < cat2.sortOrder
        }
    }
    
    // MARK: - Recent Emojis Management
    
    func addToRecent(_ emoji: String) {
        // Remove if already exists
        recentEmojis.removeAll { $0 == emoji }
        
        // Add to front
        recentEmojis.insert(emoji, at: 0)
        
        // Limit size
        if recentEmojis.count > maxRecentEmojis {
            recentEmojis.removeLast()
        }
        
        saveRecentEmojis()
    }
    
    private func loadRecentEmojis() {
        if let data = UserDefaults.standard.data(forKey: recentEmojisKey),
           let emojis = try? JSONDecoder().decode([String].self, from: data) {
            recentEmojis = emojis
        }
    }
    
    private func saveRecentEmojis() {
        if let data = try? JSONEncoder().encode(recentEmojis) {
            UserDefaults.standard.set(data, forKey: recentEmojisKey)
        }
    }
    
    // MARK: - Search
    
    func searchEmojis(query: String) -> [String] {
        guard !query.isEmpty else { return [] }
        
        let lowercaseQuery = query.lowercased()
        var results: [String] = []
        
        // Search through emoji names
        for (emoji, name) in emojiNames {
            if name.lowercased().contains(lowercaseQuery) {
                results.append(emoji)
            }
        }
        
        // Also search through emojis themselves
        for category in emojiCategories {
            for emoji in category.emojis {
                if emoji.localizedCaseInsensitiveContains(lowercaseQuery) && !results.contains(emoji) {
                    results.append(emoji)
                }
            }
        }
        
        return results
    }

    func getEmojis(for name: String) -> [String] {
        if name == "Smileys & Emotion" {
            return smileysAndEmotionEmojis
        } else if name == "People & Body" {
            return peopleAndBodyEmojis
        } else if name == "Animals & Nature" {
            return animalsAndNatureEmojis
        } else if name == "Food & Drink" {
            return foodAndDrinkEmojis
        } else if name == "Activities" {
            return activitiesEmojis
        } else if name == "Travel & Places" {
            return travelAndPlacesEmojis
        } else if name == "Objects" {
            return objectsEmojis
        } else {
            return Array(categories[name] ?? []).sorted()
        }
    }
} 