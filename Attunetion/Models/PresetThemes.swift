//
//  PresetThemes.swift
//  Attunetion
//
//  Created by Nathan Fennel on 12/2/25.
//

import Foundation
import SwiftData

/// Preset themes for the Attunetion app
enum PresetThemes {
    /// Get all preset theme definitions
    static func getAll() -> [IntentionTheme] {
        return [
            createSerene(),
            createVibrant(),
            createMinimal(),
            createSunset(),
            createOcean(),
            createForest(),
            createSlate(),
            createRose(),
            createAmber(),
            createLavender(),
            createTeal(),
            createNavy(),
            createCream(),
            createIndigo(),
            createCoral(),
            createMoss(),
            createMidnight(),
            createSky(),
            createPlum(),
            createStone(),
            createSage(),
            createBlush(),
            createWine(),
            createMint(),
            createPeach(),
            createCopper(),
            createLilac(),
            createFrost(),
            createBerry(),
            createSand(),
            createGold(),
            createIvy(),
            createSmoke(),
            createHoney(),
            createDenim(),
            createJade(),
            createOnyx(),
            createPear(),
            createFlame(),
            createDusk(),
            createPearl(),
            createRust(),
            createSeafoam(),
            createCobalt(),
            createMarigold(),
            createObsidian(),
            createThistle(),
            createClay(),
            createMist(),
            createLinen(),
            createCrimson(),
            createAzure(),
            createBasil(),
            createGraphite(),
            createChiffon(),
            createMerlot(),
            createSaffron(),
            createSteel(),
            createVelvet(),
            createTangerine(),
            createDove(),
            createPeacock(),
            createLemon(),
            createMulberry(),
            createFog(),
            createWillow(),
            createNoir(),
            createScarlet(),
            createAsh(),
            createIris(),
            createRosewood(),
            createCeladon(),
            createTaupe(),
            createCamel(),
            createCyan(),
            createMagenta(),
            createPine(),
            createShell(),
            createCharcoal(),
            createCanary(),
            createOrchid(),
            createSepia(),
            createSnow(),
            createMauve(),
            createEspresso(),
            createAqua(),
            createSalmon(),
            createInk(),
            createOat(),
            createHaze(),
            createMocha(),
            createCarnation(),
            createFern(),
            createSapphire(),
            createUmber(),
            createBlizzard(),
            createClover(),
            createFlint(),
            createCerise(),
            createParchment()
        ]
    }
    
    /// Serene - Calm and peaceful theme
    private static func createSerene() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            name: "Serene",
            backgroundColor: "#F5F7FA",
            textColor: "#2C3E50",
            accentColor: "#A8D5BA",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "A calm, peaceful palette with soft gray-blue and mint accents."
        )
    }
    
    /// Vibrant - Energetic and bold theme (rich violet)
    private static func createVibrant() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
            name: "Vibrant",
            backgroundColor: "#7C3AED",
            textColor: "#FFFFFF",
            accentColor: "#FBBF24",
            fontName: "SF Pro Display",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Energetic and bold with rich violet and warm amber accents."
        )
    }
    
    /// Minimal - Clean and simple theme
    private static func createMinimal() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
            name: "Minimal",
            backgroundColor: "#FFFFFF",
            textColor: "#000000",
            accentColor: "#808080",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Clean and simple with pure white and classic black."
        )
    }
    
    /// Sunset - Warm and cozy theme (burnt orange / terracotta)
    private static func createSunset() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
            name: "Sunset",
            backgroundColor: "#C2410C",
            textColor: "#FFFFFF",
            accentColor: "#FCD34D",
            fontName: "SF Pro Display",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Warm and cozy with burnt orange and golden accents."
        )
    }
    
    /// Ocean - Cool and refreshing theme
    private static func createOcean() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
            name: "Ocean",
            backgroundColor: "#4A90E2",
            textColor: "#FFFFFF",
            accentColor: "#87CEEB",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Cool and refreshing with ocean blue and sky-blue highlights."
        )
    }
    
    /// Forest - Grounded and natural theme (deep emerald)
    private static func createForest() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000006")!,
            name: "Forest",
            backgroundColor: "#047857",
            textColor: "#FFFFFF",
            accentColor: "#6EE7B7",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Grounded and natural with deep emerald and fresh mint."
        )
    }
    
    /// Slate - Dark and focused theme (charcoal)
    private static func createSlate() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000007")!,
            name: "Slate",
            backgroundColor: "#374151",
            textColor: "#F9FAFB",
            accentColor: "#9CA3AF",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Dark and focused with charcoal gray and soft highlights."
        )
    }
    
    /// Rose - Romantic and soft theme (deep pink)
    private static func createRose() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000008")!,
            name: "Rose",
            backgroundColor: "#BE185D",
            textColor: "#FFFFFF",
            accentColor: "#F9A8D4",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Romantic and soft with deep pink and delicate accents."
        )
    }
    
    /// Amber - Warm and golden theme
    private static func createAmber() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000009")!,
            name: "Amber",
            backgroundColor: "#D97706",
            textColor: "#FFFFFF",
            accentColor: "#FEF3C7",
            fontName: "SF Pro Display",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Warm and golden with rich amber and cream highlights."
        )
    }
    
    /// Lavender - Soft and dreamy theme (light purple)
    private static func createLavender() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000000A")!,
            name: "Lavender",
            backgroundColor: "#A78BFA",
            textColor: "#FFFFFF",
            accentColor: "#E9D5FF",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Soft and dreamy with light purple and pale lavender accents."
        )
    }
    
    /// Teal - Calm and clear theme (cyan-green)
    private static func createTeal() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000000B")!,
            name: "Teal",
            backgroundColor: "#0D9488",
            textColor: "#FFFFFF",
            accentColor: "#5EEAD4",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Calm and clear with cyan-green and soft aqua highlights."
        )
    }
    
    /// Navy - Deep and steady theme (dark blue)
    private static func createNavy() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000000C")!,
            name: "Navy",
            backgroundColor: "#1E40AF",
            textColor: "#FFFFFF",
            accentColor: "#93C5FD",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Deep and steady with classic navy blue and light blue accents."
        )
    }
    
    /// Cream - Warm and soft theme (light golden)
    private static func createCream() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000000D")!,
            name: "Cream",
            backgroundColor: "#FEF3C7",
            textColor: "#78350F",
            accentColor: "#FCD34D",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Warm and soft with light golden cream and amber accents."
        )
    }
    
    /// Indigo - Rich and balanced theme (blue-purple)
    private static func createIndigo() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000000E")!,
            name: "Indigo",
            backgroundColor: "#4F46E5",
            textColor: "#FFFFFF",
            accentColor: "#A5B4FC",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Rich and balanced with blue-purple and soft indigo highlights."
        )
    }
    
    /// Coral - Soft and inviting theme (salmon pink)
    private static func createCoral() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000000F")!,
            name: "Coral",
            backgroundColor: "#FB7185",
            textColor: "#FFFFFF",
            accentColor: "#FECDD3",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Soft and inviting with salmon pink and delicate accents."
        )
    }
    
    /// Moss - Fresh and natural theme (lime green)
    private static func createMoss() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!,
            name: "Moss",
            backgroundColor: "#65A30D",
            textColor: "#FFFFFF",
            accentColor: "#BEF264",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Fresh and natural with lime green and bright highlights."
        )
    }
    
    /// Midnight - Deep and restful theme (near black)
    private static func createMidnight() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000011")!,
            name: "Midnight",
            backgroundColor: "#111827",
            textColor: "#F3F4F6",
            accentColor: "#6B7280",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Deep and restful with near-black and subtle gray accents."
        )
    }
    
    /// Sky - Bright and airy theme (sky blue)
    private static func createSky() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000012")!,
            name: "Sky",
            backgroundColor: "#0EA5E9",
            textColor: "#FFFFFF",
            accentColor: "#7DD3FC",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Bright and airy with sky blue and soft cloud accents."
        )
    }
    
    /// Plum - Rich and elegant theme (deep purple)
    private static func createPlum() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000013")!,
            name: "Plum",
            backgroundColor: "#6B21A8",
            textColor: "#FFFFFF",
            accentColor: "#E9D5FF",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Rich and elegant with deep purple and pale violet accents."
        )
    }
    
    /// Stone - Neutral and grounded theme (warm gray)
    private static func createStone() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000014")!,
            name: "Stone",
            backgroundColor: "#57534E",
            textColor: "#FAFAF9",
            accentColor: "#A8A29E",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Neutral and grounded with warm gray and stone accents."
        )
    }
    
    /// Sage - Muted and peaceful theme (soft green)
    private static func createSage() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000015")!,
            name: "Sage",
            backgroundColor: "#4A7C59",
            textColor: "#FFFFFF",
            accentColor: "#86EFAC",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Muted and peaceful with soft green and mint accents."
        )
    }
    
    /// Blush - Delicate and soft theme (light pink)
    private static func createBlush() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000016")!,
            name: "Blush",
            backgroundColor: "#FBCFE8",
            textColor: "#831843",
            accentColor: "#F9A8D4",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Delicate and soft with light pink and dark rose accents."
        )
    }
    
    /// Wine - Bold and deep theme (burgundy red)
    private static func createWine() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000017")!,
            name: "Wine",
            backgroundColor: "#991B1B",
            textColor: "#FFFFFF",
            accentColor: "#FCA5A5",
            fontName: "SF Pro Display",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Bold and deep with burgundy red and soft pink accents."
        )
    }
    
    /// Mint - Fresh and clean theme (bright aqua)
    private static func createMint() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000018")!,
            name: "Mint",
            backgroundColor: "#2DD4BF",
            textColor: "#FFFFFF",
            accentColor: "#99F6E4",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Fresh and clean with bright aqua and pale mint accents."
        )
    }
    
    /// Peach - Soft and warm theme (warm peach)
    private static func createPeach() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000019")!,
            name: "Peach",
            backgroundColor: "#FDBA74",
            textColor: "#431407",
            accentColor: "#FED7AA",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Soft and warm with peach and cream accents."
        )
    }
    
    /// Copper - Warm and metallic theme
    private static func createCopper() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000001A")!,
            name: "Copper",
            backgroundColor: "#B45309",
            textColor: "#FFFFFF",
            accentColor: "#FDE68A",
            fontName: "SF Pro Display",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Warm and metallic with copper brown and golden accents."
        )
    }
    
    /// Lilac - Soft and dreamy theme (light purple)
    private static func createLilac() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000001B")!,
            name: "Lilac",
            backgroundColor: "#DDD6FE",
            textColor: "#4C1D95",
            accentColor: "#C4B5FD",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Soft and dreamy with pale lilac and deep purple accents."
        )
    }
    
    /// Frost - Cool and crisp theme (ice blue)
    private static func createFrost() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000001C")!,
            name: "Frost",
            backgroundColor: "#E0F2FE",
            textColor: "#0C4A6E",
            accentColor: "#7DD3FC",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Cool and crisp with ice blue and dark blue accents."
        )
    }
    
    /// Berry - Vivid and bold theme (fuchsia magenta)
    private static func createBerry() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000001D")!,
            name: "Berry",
            backgroundColor: "#A21CAF",
            textColor: "#FFFFFF",
            accentColor: "#F5D0FE",
            fontName: "SF Pro Display",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Vivid and bold with fuchsia magenta and pale pink accents."
        )
    }
    
    /// Sand - Warm and neutral theme (soft beige)
    private static func createSand() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000001E")!,
            name: "Sand",
            backgroundColor: "#E7E5E4",
            textColor: "#292524",
            accentColor: "#D6D3D1",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Warm and neutral with soft beige and stone accents."
        )
    }
    
    /// Gold - Rich and luminous theme (yellow-gold)
    private static func createGold() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000001F")!,
            name: "Gold",
            backgroundColor: "#CA8A04",
            textColor: "#FFFFFF",
            accentColor: "#FEF08A",
            fontName: "SF Pro Display",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Rich and luminous with yellow-gold and cream accents."
        )
    }
    
    /// Ivy - Deep and lush theme (dark green)
    private static func createIvy() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000020")!,
            name: "Ivy",
            backgroundColor: "#166534",
            textColor: "#FFFFFF",
            accentColor: "#4ADE80",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Deep and lush with dark green and bright mint accents."
        )
    }
    
    /// Smoke - Cool and understated theme (mid gray)
    private static func createSmoke() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000021")!,
            name: "Smoke",
            backgroundColor: "#6B7280",
            textColor: "#FFFFFF",
            accentColor: "#D1D5DB",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Cool and understated with mid gray and light gray accents."
        )
    }
    
    /// Honey - Warm and sunny theme (bright yellow)
    private static func createHoney() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000022")!,
            name: "Honey",
            backgroundColor: "#EAB308",
            textColor: "#422006",
            accentColor: "#FEF08A",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Warm and sunny with bright yellow and cream accents."
        )
    }

    /// Denim - Classic and dependable theme (medium blue)
    private static func createDenim() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000023")!,
            name: "Denim",
            backgroundColor: "#2563EB",
            textColor: "#FFFFFF",
            accentColor: "#93C5FD",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Classic and dependable with medium blue and light blue accents."
        )
    }
    
    /// Jade - Refined and natural theme (emerald-teal)
    private static func createJade() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000024")!,
            name: "Jade",
            backgroundColor: "#059669",
            textColor: "#FFFFFF",
            accentColor: "#6EE7B7",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Refined and natural with emerald-teal and mint accents."
        )
    }
    
    /// Onyx - Deep and dramatic theme (near black)
    private static func createOnyx() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000025")!,
            name: "Onyx",
            backgroundColor: "#171717",
            textColor: "#FAFAFA",
            accentColor: "#525252",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Deep and dramatic with near black and gray accents."
        )
    }
    
    /// Pear - Bright and zesty theme (lime green)
    private static func createPear() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000026")!,
            name: "Pear",
            backgroundColor: "#84CC16",
            textColor: "#FFFFFF",
            accentColor: "#BEF264",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Bright and zesty with lime green and light lime accents."
        )
    }
    
    /// Flame - Bold and energetic theme (true red)
    private static func createFlame() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000027")!,
            name: "Flame",
            backgroundColor: "#DC2626",
            textColor: "#FFFFFF",
            accentColor: "#FECACA",
            fontName: "SF Pro Display",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Bold and energetic with true red and soft pink accents."
        )
    }
    
    /// Dusk - Moody and atmospheric theme (deep indigo)
    private static func createDusk() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000028")!,
            name: "Dusk",
            backgroundColor: "#3730A3",
            textColor: "#FFFFFF",
            accentColor: "#818CF8",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Moody and atmospheric with deep indigo and lavender accents."
        )
    }
    
    /// Pearl - Soft and luminous theme (cool white)
    private static func createPearl() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000029")!,
            name: "Pearl",
            backgroundColor: "#F8FAFC",
            textColor: "#0F172A",
            accentColor: "#94A3B8",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Soft and luminous with cool white and slate accents."
        )
    }
    
    /// Rust - Warm and earthy theme (red-orange)
    private static func createRust() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000002A")!,
            name: "Rust",
            backgroundColor: "#B91C1C",
            textColor: "#FFFFFF",
            accentColor: "#FED7AA",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Warm and earthy with red-orange and peach accents."
        )
    }
    
    /// Seafoam - Light and breezy theme (pale aqua)
    private static func createSeafoam() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000002B")!,
            name: "Seafoam",
            backgroundColor: "#99F6E4",
            textColor: "#134E4A",
            accentColor: "#CCFBF1",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Light and breezy with pale aqua and teal accents."
        )
    }
    
    /// Cobalt - Strong and confident theme (deep blue)
    private static func createCobalt() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000002C")!,
            name: "Cobalt",
            backgroundColor: "#1D4ED8",
            textColor: "#FFFFFF",
            accentColor: "#BFDBFE",
            fontName: "SF Pro Display",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Strong and confident with deep blue and light blue accents."
        )
    }
    
    /// Marigold - Bright and cheerful theme (orange-yellow)
    private static func createMarigold() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000002D")!,
            name: "Marigold",
            backgroundColor: "#F59E0B",
            textColor: "#422006",
            accentColor: "#FDE68A",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Bright and cheerful with orange-yellow and golden accents."
        )
    }
    
    /// Obsidian - Deep and intense theme (blue-black)
    private static func createObsidian() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000002E")!,
            name: "Obsidian",
            backgroundColor: "#0F172A",
            textColor: "#F1F5F9",
            accentColor: "#64748B",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Deep and intense with dark blue-black and slate accents."
        )
    }
    
    /// Thistle - Soft and whimsical theme (pale purple)
    private static func createThistle() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000002F")!,
            name: "Thistle",
            backgroundColor: "#E9D5FF",
            textColor: "#5B21B6",
            accentColor: "#C4B5FD",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Soft and whimsical with pale purple and violet accents."
        )
    }
    
    /// Clay - Earthy and grounded theme (terracotta brown)
    private static func createClay() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000030")!,
            name: "Clay",
            backgroundColor: "#A16207",
            textColor: "#FFFFFF",
            accentColor: "#FDE68A",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Earthy and grounded with terracotta brown and golden accents."
        )
    }
    
    /// Mist - Subtle and understated theme (cool gray)
    private static func createMist() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000031")!,
            name: "Mist",
            backgroundColor: "#F4F4F5",
            textColor: "#18181B",
            accentColor: "#D4D4D8",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Subtle and understated with cool gray and soft accents."
        )
    }
    
    /// Linen - Warm and inviting theme (soft cream)
    private static func createLinen() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000032")!,
            name: "Linen",
            backgroundColor: "#FFFBEB",
            textColor: "#422006",
            accentColor: "#FDE68A",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Warm and inviting with soft cream and golden accents."
        )
    }
    
    /// Crimson - Rich and dramatic theme (deep red)
    private static func createCrimson() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000033")!,
            name: "Crimson",
            backgroundColor: "#BE123C",
            textColor: "#FFFFFF",
            accentColor: "#FDA4AF",
            fontName: "SF Pro Display",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Rich and dramatic with deep red and soft pink accents."
        )
    }
    
    /// Azure - Clear and bright theme (light blue)
    private static func createAzure() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000034")!,
            name: "Azure",
            backgroundColor: "#38BDF8",
            textColor: "#FFFFFF",
            accentColor: "#BAE6FD",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Clear and bright with light blue and sky accents."
        )
    }
    
    /// Basil - Fresh and herbal theme (olive green)
    private static func createBasil() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000035")!,
            name: "Basil",
            backgroundColor: "#4D7C0F",
            textColor: "#FFFFFF",
            accentColor: "#86EFAC",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Fresh and herbal with olive green and mint accents."
        )
    }
    
    /// Graphite - Modern and sleek theme (dark gray)
    private static func createGraphite() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000036")!,
            name: "Graphite",
            backgroundColor: "#404040",
            textColor: "#FAFAFA",
            accentColor: "#A3A3A3",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Modern and sleek with dark gray and silver accents."
        )
    }
    
    /// Chiffon - Delicate and airy theme (pale yellow)
    private static func createChiffon() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000037")!,
            name: "Chiffon",
            backgroundColor: "#FEF9C3",
            textColor: "#422006",
            accentColor: "#FEF08A",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Delicate and airy with pale yellow and golden accents."
        )
    }
    
    /// Merlot - Sophisticated and deep theme (dark wine)
    private static func createMerlot() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000038")!,
            name: "Merlot",
            backgroundColor: "#7F1D1D",
            textColor: "#FFFFFF",
            accentColor: "#FECACA",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Sophisticated and deep with dark wine and soft red accents."
        )
    }
    
    /// Saffron - Warm and spicy theme (vibrant orange)
    private static func createSaffron() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000039")!,
            name: "Saffron",
            backgroundColor: "#F97316",
            textColor: "#FFFFFF",
            accentColor: "#FDBA74",
            fontName: "SF Pro Display",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Warm and spicy with vibrant orange and peach accents."
        )
    }
    
    /// Steel - Cool and industrial theme (cool gray)
    private static func createSteel() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000003A")!,
            name: "Steel",
            backgroundColor: "#71717A",
            textColor: "#FFFFFF",
            accentColor: "#D4D4D8",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Cool and industrial with cool gray and light gray accents."
        )
    }
    
    /// Velvet - Luxurious and rich theme (deep purple)
    private static func createVelvet() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000003B")!,
            name: "Velvet",
            backgroundColor: "#5B21B6",
            textColor: "#FFFFFF",
            accentColor: "#A78BFA",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Luxurious and rich with deep purple and violet accents."
        )
    }
    
    /// Tangerine - Zesty and bright theme (bright orange)
    private static func createTangerine() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000003C")!,
            name: "Tangerine",
            backgroundColor: "#EA580C",
            textColor: "#FFFFFF",
            accentColor: "#FDBA74",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Zesty and bright with bright orange and warm accents."
        )
    }
    
    /// Dove - Soft and neutral theme (light gray)
    private static func createDove() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000003D")!,
            name: "Dove",
            backgroundColor: "#E5E5E5",
            textColor: "#262626",
            accentColor: "#A3A3A3",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Soft and neutral with light gray and charcoal accents."
        )
    }
    
    /// Peacock - Bold and striking theme (dark cyan)
    private static func createPeacock() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000003E")!,
            name: "Peacock",
            backgroundColor: "#0E7490",
            textColor: "#FFFFFF",
            accentColor: "#22D3EE",
            fontName: "SF Pro Display",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Bold and striking with dark cyan and bright aqua accents."
        )
    }
    
    /// Lemon - Fresh and sunny theme (bright yellow)
    private static func createLemon() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000003F")!,
            name: "Lemon",
            backgroundColor: "#FACC15",
            textColor: "#422006",
            accentColor: "#FEF08A",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Fresh and sunny with bright yellow and golden accents."
        )
    }
    
    /// Mulberry - Bold and fruity theme (fuchsia purple)
    private static func createMulberry() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000040")!,
            name: "Mulberry",
            backgroundColor: "#86198F",
            textColor: "#FFFFFF",
            accentColor: "#F0ABFC",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Bold and fruity with fuchsia purple and pink accents."
        )
    }
    
    /// Fog - Gentle and muted theme (pale gray)
    private static func createFog() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000041")!,
            name: "Fog",
            backgroundColor: "#E4E4E7",
            textColor: "#27272A",
            accentColor: "#D4D4D8",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Gentle and muted with pale gray and soft accents."
        )
    }
    
    /// Willow - Calm and natural theme (muted sage)
    private static func createWillow() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000042")!,
            name: "Willow",
            backgroundColor: "#84A98C",
            textColor: "#FFFFFF",
            accentColor: "#BBF7D0",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Calm and natural with muted sage green and mint accents."
        )
    }
    
    /// Noir - Striking and minimal theme (pure black)
    private static func createNoir() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000043")!,
            name: "Noir",
            backgroundColor: "#0A0A0A",
            textColor: "#FAFAFA",
            accentColor: "#525252",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Striking and minimal with pure black and gray accents."
        )
    }
    
    /// Scarlet - Vivid and attention-grabbing theme (bright red)
    private static func createScarlet() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000044")!,
            name: "Scarlet",
            backgroundColor: "#EF4444",
            textColor: "#FFFFFF",
            accentColor: "#FECACA",
            fontName: "SF Pro Display",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Vivid and attention-grabbing with bright red and soft pink accents."
        )
    }
    
    /// Ash - Warm and understated theme (taupe gray)
    private static func createAsh() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000045")!,
            name: "Ash",
            backgroundColor: "#A8A29E",
            textColor: "#1C1917",
            accentColor: "#D6D3D1",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Warm and understated with taupe gray and stone accents."
        )
    }
    
    /// Iris - Soft and dreamy theme (periwinkle blue)
    private static func createIris() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000046")!,
            name: "Iris",
            backgroundColor: "#6366F1",
            textColor: "#FFFFFF",
            accentColor: "#A5B4FC",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Soft and dreamy with periwinkle blue and lavender accents."
        )
    }
    
    /// Rosewood - Rich and dramatic theme (dark red)
    private static func createRosewood() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000047")!,
            name: "Rosewood",
            backgroundColor: "#450A0A",
            textColor: "#FFFFFF",
            accentColor: "#FECACA",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Rich and dramatic with dark red and soft pink accents."
        )
    }
    
    /// Celadon - Fresh and delicate theme (pale mint)
    private static func createCeladon() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000048")!,
            name: "Celadon",
            backgroundColor: "#A7F3D0",
            textColor: "#064E3B",
            accentColor: "#6EE7B7",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Fresh and delicate with pale mint and dark green accents."
        )
    }
    
    /// Taupe - Sophisticated and neutral theme (warm brown-gray)
    private static func createTaupe() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000049")!,
            name: "Taupe",
            backgroundColor: "#78716C",
            textColor: "#FAFAF9",
            accentColor: "#A8A29E",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Sophisticated and neutral with warm brown-gray accents."
        )
    }
    
    /// Camel - Earthy and warm theme (tan)
    private static func createCamel() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000004A")!,
            name: "Camel",
            backgroundColor: "#D4A574",
            textColor: "#292524",
            accentColor: "#FDE68A",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Earthy and warm with tan and golden accents."
        )
    }
    
    /// Cyan - Bright and modern theme (electric cyan)
    private static func createCyan() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000004B")!,
            name: "Cyan",
            backgroundColor: "#06B6D4",
            textColor: "#FFFFFF",
            accentColor: "#67E8F9",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Bright and modern with electric cyan and light aqua accents."
        )
    }
    
    /// Magenta - Bold and vibrant theme (vivid pink-purple)
    private static func createMagenta() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000004C")!,
            name: "Magenta",
            backgroundColor: "#D946EF",
            textColor: "#FFFFFF",
            accentColor: "#F5D0FE",
            fontName: "SF Pro Display",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Bold and vibrant with vivid pink-purple and pale pink accents."
        )
    }
    
    /// Pine - Deep and natural theme (forest green)
    private static func createPine() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000004D")!,
            name: "Pine",
            backgroundColor: "#14532D",
            textColor: "#FFFFFF",
            accentColor: "#4ADE80",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Deep and natural with forest green and bright mint accents."
        )
    }
    
    /// Shell - Warm and cozy theme (peach cream)
    private static func createShell() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000004E")!,
            name: "Shell",
            backgroundColor: "#FFF7ED",
            textColor: "#431407",
            accentColor: "#FED7AA",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Warm and cozy with peach cream and amber accents."
        )
    }
    
    /// Charcoal - Sleek and modern theme (dark gray)
    private static func createCharcoal() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000004F")!,
            name: "Charcoal",
            backgroundColor: "#27272A",
            textColor: "#FAFAFA",
            accentColor: "#71717A",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Sleek and modern with dark gray and zinc accents."
        )
    }
    
    /// Canary - Cheerful and bright theme (yellow)
    private static func createCanary() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000050")!,
            name: "Canary",
            backgroundColor: "#FDE047",
            textColor: "#422006",
            accentColor: "#FEF08A",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Cheerful and bright with yellow and golden accents."
        )
    }
    
    /// Orchid - Elegant and floral theme (bright purple)
    private static func createOrchid() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000051")!,
            name: "Orchid",
            backgroundColor: "#A855F7",
            textColor: "#FFFFFF",
            accentColor: "#E9D5FF",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Elegant and floral with bright purple and pale violet accents."
        )
    }
    
    /// Sepia - Vintage and warm theme (dark brown)
    private static func createSepia() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000052")!,
            name: "Sepia",
            backgroundColor: "#78350F",
            textColor: "#FEF3C7",
            accentColor: "#FDE68A",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Vintage and warm with dark brown and cream accents."
        )
    }
    
    /// Snow - Clean and crisp theme (off-white)
    private static func createSnow() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000053")!,
            name: "Snow",
            backgroundColor: "#FAFAFA",
            textColor: "#171717",
            accentColor: "#A3A3A3",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Clean and crisp with off-white and charcoal accents."
        )
    }
    
    /// Mauve - Soft and romantic theme (light violet)
    private static func createMauve() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000054")!,
            name: "Mauve",
            backgroundColor: "#C084FC",
            textColor: "#FFFFFF",
            accentColor: "#E9D5FF",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Soft and romantic with light violet and pale purple accents."
        )
    }
    
    /// Espresso - Rich and deep theme (dark brown)
    private static func createEspresso() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000055")!,
            name: "Espresso",
            backgroundColor: "#292524",
            textColor: "#FAFAF9",
            accentColor: "#78716C",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Rich and deep with dark brown and stone accents."
        )
    }
    
    /// Aqua - Refreshing and clear theme (bright aqua)
    private static func createAqua() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000056")!,
            name: "Aqua",
            backgroundColor: "#22D3EE",
            textColor: "#FFFFFF",
            accentColor: "#67E8F9",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Refreshing and clear with bright aqua and light cyan accents."
        )
    }
    
    /// Salmon - Soft and warm theme (light orange)
    private static func createSalmon() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000057")!,
            name: "Salmon",
            backgroundColor: "#FB923C",
            textColor: "#431407",
            accentColor: "#FDBA74",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Soft and warm with light orange and peach accents."
        )
    }
    
    /// Ink - Deep and moody theme (dark indigo)
    private static func createInk() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000058")!,
            name: "Ink",
            backgroundColor: "#1E1B4B",
            textColor: "#FFFFFF",
            accentColor: "#818CF8",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Deep and moody with dark indigo and lavender accents."
        )
    }
    
    /// Oat - Warm and natural theme (soft beige-gray)
    private static func createOat() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000059")!,
            name: "Oat",
            backgroundColor: "#F5F5F4",
            textColor: "#27272A",
            accentColor: "#A8A29E",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Warm and natural with soft beige-gray and stone accents."
        )
    }
    
    /// Haze - Soft and diffused theme (blue-gray)
    private static func createHaze() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000005A")!,
            name: "Haze",
            backgroundColor: "#CBD5E1",
            textColor: "#1E293B",
            accentColor: "#94A3B8",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Soft and diffused with blue-gray and slate accents."
        )
    }
    
    /// Mocha - Smooth and rich theme (dark gray)
    private static func createMocha() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000005B")!,
            name: "Mocha",
            backgroundColor: "#3F3F46",
            textColor: "#FAFAFA",
            accentColor: "#71717A",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Smooth and rich with dark gray and zinc accents."
        )
    }
    
    /// Carnation - Sweet and gentle theme (soft pink)
    private static func createCarnation() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000005C")!,
            name: "Carnation",
            backgroundColor: "#F472B6",
            textColor: "#FFFFFF",
            accentColor: "#FBCFE8",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Sweet and gentle with soft pink and rose accents."
        )
    }
    
    /// Fern - Lush and organic theme (green)
    private static func createFern() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000005D")!,
            name: "Fern",
            backgroundColor: "#15803D",
            textColor: "#FFFFFF",
            accentColor: "#86EFAC",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Lush and organic with green and mint accents."
        )
    }
    
    /// Sapphire - Deep and precious theme (dark blue)
    private static func createSapphire() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000005E")!,
            name: "Sapphire",
            backgroundColor: "#0C4A6E",
            textColor: "#E0F2FE",
            accentColor: "#7DD3FC",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Deep and precious with dark blue and ice blue accents."
        )
    }
    
    /// Umber - Earthy and warm theme (dark brown)
    private static func createUmber() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000005F")!,
            name: "Umber",
            backgroundColor: "#92400E",
            textColor: "#FFFFFF",
            accentColor: "#FDE68A",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Earthy and warm with dark brown and golden accents."
        )
    }
    
    /// Blizzard - Cool and airy theme (ice blue)
    private static func createBlizzard() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000060")!,
            name: "Blizzard",
            backgroundColor: "#F0F9FF",
            textColor: "#0C4A6E",
            accentColor: "#BAE6FD",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Cool and airy with ice blue and sky blue accents."
        )
    }
    
    /// Clover - Lucky and fresh theme (bright green)
    private static func createClover() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000061")!,
            name: "Clover",
            backgroundColor: "#16A34A",
            textColor: "#FFFFFF",
            accentColor: "#BBF7D0",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Lucky and fresh with bright green and mint accents."
        )
    }
    
    /// Flint - Sharp and refined theme (near black)
    private static func createFlint() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000062")!,
            name: "Flint",
            backgroundColor: "#1C1917",
            textColor: "#F5F5F4",
            accentColor: "#57534E",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Sharp and refined with near black and stone accents."
        )
    }
    
    /// Cerise - Bold and fruity theme (red-pink)
    private static func createCerise() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000063")!,
            name: "Cerise",
            backgroundColor: "#E11D48",
            textColor: "#FFFFFF",
            accentColor: "#FECACA",
            fontName: "SF Pro Display",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Bold and fruity with red-pink and soft pink accents."
        )
    }
    
    /// Parchment - Vintage and classic theme (warm cream)
    private static func createParchment() -> IntentionTheme {
        IntentionTheme(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000064")!,
            name: "Parchment",
            backgroundColor: "#FEFCE8",
            textColor: "#713F12",
            accentColor: "#FEF08A",
            fontName: "SF Pro Text",
            isPreset: true,
            isAIGenerated: false,
            createdAt: Date(timeIntervalSince1970: 0),
            themeDescription: "Vintage and classic with warm cream and golden accents."
        )
    }
    
    /// Helper function to populate preset themes in the database
    /// This should be called during app initialization or onboarding
    static func populatePresetThemes(in repository: ThemeRepository) throws {
        let existingThemes = repository.getPresetThemes()
        let existingThemeNames = Set(existingThemes.map { $0.name })

        // Only add themes that don't already exist
        for theme in PresetThemes.getAll() {
            if !existingThemeNames.contains(theme.name) {
                try repository.create(theme)
            }
        }
    }
}



