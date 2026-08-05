# Low-Fidelity Wireframes: ANLEYLAB Bible

This file visualizes the flat 3-step navigation flow for the application using text-based layouts.

---

## Screen 1: Home Dashboard (ብሉይና ሐዲስ ኪዳን)
Goal: Rapid access to the two main Testaments and a quick-resume reading card.

+-------------------------------------------------+
|  [☀️/🌙]          ANLEYLAB BIBLE                 | <-- Top Bar (44dp Height)
+-------------------------------------------------+
|                                                 |
|  +-------------------------------------------+  |
|  | 📖 ካለፈው የቀጠለ (Continue Reading)           |  | <-- 24dp Outer Margin
|  | ኦሪት ዘፍጥረት: ምዕራፍ 3                        |  | <-- Quick Resume Card
|  +-------------------------------------------+  |
|                                                 |
|     [ ብሉይ ኪዳን ]       |     [ ሐዲስ ኪዳን ]     |  | <-- Large Segmented Tabs
|   (Old Testament)     |   (New Testament)    |  |     (44dp Touch Targets)
|  _____|______  |
|                                                 |
|  * ኦሪት ዘፍጥረት (Genesis)                        |  | <-- Clean Scrollable List
|  * ኦሪት ዘጸአት (Exodus)                          |  |     with 16dp spacing
|  * ኦሪት ዘሌዋውያን (Leviticus)                     |  |     between rows
|  * ኦሪት ዘዳግም (Deuteronomy)                     |  |
|  * ...                                         |  |
|                                                 |
+-------------------------------------------------+

---

## Screen 2: Chapter Selector (ምዕራፍ መምረጫ)
Goal: Grid-based view to select a chapter instantly.

+-------------------------------------------------+
|  [<-]  ኦሪት ዘፍጥረት (Genesis)                     | <-- Header with Back Button
+-------------------------------------------------+
|  ምዕራፍ ምረጡ (Select Chapter):                    |
|                                                 |
|  +--------+   +--------+   +--------+   +--------+  |
|  |   1    |   |   2    |   |   3    |   |   4    |  | <-- 44dp x 44dp Grid Boxes
|  +--------+   +--------+   +--------+   +--------+  | <-- 12dp Border Radius
|                                                 |
|  +--------+   +--------+   +--------+   +--------+  |
|  |   5    |   |   6    |   |   7    |   |   8    |  | <-- 8dp Grid Spacing
|  +--------+   +--------+   +--------+   +--------+  |
|                                                 |
+-------------------------------------------------+

---

## Screen 3: Scriptural Reader (የንባብ ገጽ)
Goal: Zero distraction, maximum readability, anti-glare spacing.

+-------------------------------------------------+
|  [<-]  ኦሪት ዘፍጥረት: ምዕራፍ 1                     | <-- Top Navigation Bar
+-------------------------------------------------+
|                                                 |
|    1 በመጀመሪያ እግዚአብሔር ሰማይንና ምድርን ፈጠረ።       |  | <-- 24dp Left/Right Margin
|                                                 |  |     to prevent bezel text hugging
|    2 ምድርም ባዶ ነበረች፥ አንዳችም አልነበረባትም፤     |  |
|    ጨለማም በጥልቁ ላይ ነበረ፥ የእግዚአብሔርም መንፈስ   |  | <-- 16sp Minimum Font Size
|    በውኃ ላይ ይሰፍፍ ነበር።                          |  |     with generous line heights
|                                                 |
|    3 እግዚአብሔርም፦ ብርሃን ይሁን አለ፤ ብርሃንም     |  |
|    ሆነ።                                         |  |
|                                                 |
+-------------------------------------------------+
|   [ < የቀደመው ]      [ A+ / A- ]     [ ቀጣይ > ]  | <-- Bottom Utility Bar
|   (Prev Chapter)    (Text Size)   (Next Chapter) | <-- 44dp Interactive Targets
+-------------------------------------------------+
