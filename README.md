# mytalktools
iOS AAC solution

# Introduction
This is the incomplete open-source version of the MyTalkTools iOS client. Communication Disabilities Foundation Inc. is taking over support for the commercial MyTalkTools suite. This change will occur throughout 2023. By the end of 2023 the foundation will offer all of the MyTalkTools Suite (MyTalkTools Mobile for iOS, MyTalkTools for Android, and MyTalkTools Workspace) for no charge.

By the start of 2024 - new bug fixes and feature requests will be handled through open source contributors

# Project
The code, as is, lets you view and use most boards using your MyTalkTools account (with the exception of hotspot boards). In the current phase, the code is scaffolding out UI elements for editing and library management. Once the UI is scaffolded - functionality will be added.

We need your assistance in identifying new features, improving features, coding - or new language translations.

# Features
These are the features that are being replicated in this new SwiftUI implementation. Note - all accessibility features will now be managed by iOS. The existing scanning feature will be deprecated.

||MyTalkTools Mobile|MyTalkTools for Android|Workspace Family|Workspace Pro|
| :- | :- | :- | :- | :- |
|[Device Management](#_device_management)|||||
|- Operating Systems/Browsers|iPad, iPad Pro, iPhone|Android 4+|Edge, Chrome, FF, Safari|Chrome, FF, Safari|
|- [Synchronize Settings Across Devices with iCloud](#_synchronize_settings_across) (e.g. username, password, maximum rows, etc.)|x||||
|- [Keep media content in device photo library](#_keep_media_content) (creates a local backup of related media on device)|x|x|||
|- [Turn off screen rotation](#_turn_off_screen) (and stay in portrait or landscape always)|x||||
|- [Spotlight searches include MyTalkTools content](#_spotlight_searches_include)|x||||
|- Turn on “pinch gesture” setting. With pinch you can zoom in/out to cells. When zoomed in you can swipe right/left to pan. Good when trying to using large boards on smaller devices. Can also be applied for certain assessment scenarios.|x||||
|[Security Management](#_security_management)|||||
|- HIPAA compliant security|x|x|x|x|
|- [Require Password to Make Content Changes](#_require_password_to)|x|x|x|x|
|- [Login using ](#_login_using_touch)biometric identification|x||||
|- [Show/Hide Author Login in User Interface](#_show/hide_author_login)|x|x|||
|[Display Options](#_display_options)|||||
|- [Display Content as 2 Dimensional Grids, or as a 1-Dimensional List](#_display_content_as) (high functioning adults sometimes prefer the list-style)|x|grid|grid|grid|
|<p>- [Optionally display global commands](#_optionally_display_global) (for high functioning users)</p><p>&emsp;- Home</p><p>&emsp;- Back</p><p>&emsp;- Type Words - free form typing </p><p>&emsp;- Sync</p><p>&emsp;- Settings</p><p>&emsp;- Most Viewed - display a board of cells that are used most often)</p><p>&emsp;- Recents - display a board of cells that are the most recently used cells)</p><p>&emsp;- Wizard – shows likely next cells, based on previous cell selections</p>|x|x<br>(except for Wizard)|||
|- [Control spacing between grid cells](#_control_spacing_between) (margin width)|x|x|||
|- [Show/Hide cell dividing lines](#_show/hide_cell_dividing)|x||||
|- <a name="ole_link1"></a><a name="ole_link2"></a>[Show/Hide Popup User Hints](#_show/hide_popup_user)|x||||
|- <a name="ole_link5"></a><a name="ole_link6"></a>[Show/Hide Popup Authoring Hints](#_show/hide_popup_author) |x||||
|- <a name="ole_link9"></a><a name="ole_link10"></a>[Define max rows to display for device](#_define_max_rows)|x|x|||
|- [Switch from white/black to black/white color schemes](#_switch_from_white/black) to support certain visual impairments|x|x|||
|- Use [Goosen or Fitzgerald color coding](#_goosen_or_fitzgerald) as cell background color, or alternatively as a margin color (appears as a colored rectangle that surrounds the cell).|x|x|x|x|
|- [Cells can have multiple touch areas](#_hotspots) (referred to as hotspots), you can show the hotspots explicitly, or otherwise they are implicit to user.|x|x|x|x|
|- When tapping a cell – you can have it “[zoom](#_zoom)” (cover the entire screen), and then explicitly return, or have it go back based on a timer. For example, tapping a cell might zoom it), wait for 5 seconds, and then return the original board.|x|x|x|x|
|- Supports split screen on iPad and iPad Pro|x|n/a|n/a|n/a|
|- Display cells using a cards and folders metaphor (instead of a flat grid).|x||||
|[Sharing Content & Collaborating with Parents, Family and Caregivers](#_sharing_content_&)|||||
|- [Share printed board links](#_share_printed_board) (URLs) through email, facebook, twitter, SMS, etc.|x||x|x|
|- [Print your content libraries](#_print_content_libraries)|\*||x|x|
|- [View fully functioning boards in a web browser](#_preview_boards_from) (aka previews)|||x|x|
|- [Share preview links](#_share_preview_links) (URLs) through email, facebook, twitter, SMS, etc.|x||x|x|
|- [Print your boards](#_print_your_boards), with optional table of contents|1|1|x|x|
|- Create and share PDFs of boards|x||||
|- Create and share library items through iCloud, OneDrive, Google Drive, DropBox, SMS or Email|x||x|x|
|- Create and share cells/boards through iCloud, OneDrive, Google Drive, DropBox, SMS or Email|x||x|x|
|- Import boards from products that support the OpenBoard format. See openboardformat.org for more information|x||||
|[Touch Options](#_touch_options) (Fine motor adjustments for individuals who struggle to touch the display as expected)|||||
|- Set the minimum time to register a touch (to match with persons natural tapping speed)|x||||
|- Set the maximum amount of movement allowed for a touch (for people who tend to drag, you would want to increase the allowable movement)|x||||
|- Set the tap-time-out (for touch stutters, you can make it not register a second touch for a period of time).|x||||
|- Allow a touch to be recognized immediately on the down press without waiting for the release of the finger. This can be useful for people with certain physical disabilities.|x||||
|[Scanning](#_scanning)|||||
|<p>- [Can use any 1 or 2 button switch](#_switches) to register the equivalent of a tap</p><p>&emsp;- Supports Ablenet & RJCooper switches by Bluetooth.</p><p>&emsp;- Supports Apple TV controller (as a 1-switch device)</p><p>&emsp;- Supports Apple Watch</p><p>&emsp;- Supports other Bluetooth devices (contact us to discuss how to enter the custom configuration values)</p>|<p>Uses iOS accessibility settings.</p><p></p>|x |||
|- [Scan patterns](#_scanning_patterns) 1) Upper left to lower right, by cell, or 2) top to bottom, by row, tap-once, and then scan the row left to right by cell|||||
|- [Scan speeds](#_scan_speeds) can be adjusted from 1 to 10 seconds per cell||x|||
|- [Auditory Scanning](#_auditory_scanning) – as each cell is scanned, an optional, short, auditory cue can be voiced using text-to-speech. Useful for the visually impaired.||x|||
|- [Automatically begin scanning OR start scanning after first tap](#_overview)||x|||
|- [Optionally, scanning can automatically “go back”](#_scan_loops) after a set number of complete scans of a board. If a board does not have an explicit “go back” cell, this keeps the user from being trapped without a method to return to previous board. ||x|||
|- [Select alternate scanning animations.](#_scan_animation) Use a “popout” animation or a background color change.|||||
|[Text-To-Speech](#_text-to-speech)|||||
|- [Generate a Text-To-Speech Recording](#_generate_a_text-to-speech) and attach to a cell (useful when sharing content with users who do not have TTS capability)|x|x|||
|- [Voice cell text dynamically using Text-To-Speech](#_voice_cell_text)|x|x|x|x|
|- [Voice alternate text](#_voice_alternate_text) (something other than the cell text) using Text-To-Speech|x|x|x|x|
|- ` `[Low quality Text-To-Speech voices](#_low_quality_text-to-speech) (English / adult / male / female)|x|x|<p>27 voices in 11 languages</p><p></p>|
|- ` `[High quality Text-To-Speech voices](#_high_quality_text-to-speech) (English, French, German, Dutch, etc. / child / adult / male / female)|$$$|$$$|||
|[Phrases/Language Generation/Communication](#_phrases/language_generation/communicati)|||||
|- [A “phrase bar” can be optionally displayed](#_display_phrase_bar), and then when tapping on cells it adds them to the phrase bar. Tapping on the phrase bar voices the cells in order.|x|x|||
|- Phrase bar history – double-tapping the phrase bar will display a history of all phrases used. Or, on an iPad tap the arrow to the left of the phrase bar to view the phrase history. |x||||
|- Phrase bar favorites – swipe left on a phrase bar history item (see above) and make it a favorite. Favorites are always displayed at the top of list.|x||||
|- [4 alternate phrase bar displays](#_display_phrase_bar_1) – 1) text only 2) text only in blocks 3) images and text displayed side by side, 4) images displayed above text|x|2|||
|- [Delete last cell added to phrase, Delete entire phrase.](#_delete_phrase_bar)|x|x|||
|- [Long press on the phrase bar displays alternate communication options](#_additional_phrase_bar): Facebook, Twitter, SMS, Email, Photos, Notes, etc.|x|x|||
|- [Related conjugations, adjectives, adverbs and plurals (English only) can be dynamically displayed using a global option](#_use_automatic_word). If a cell has a single word, has no sound or child boards associated with it, and this option is set, the system will automatically create a child board with the above word variants and display it to the user. Allows high functioning users ability to create grammatically correct communications, with less effort from author.|x|x|||
|- [Dynamically generated word variants board can be automatically coded with Goosen or Fitzgerald codes](#_automatic_coded_word). Supports English.|x|x|||
|- [Dynamically generated word variants board can take hint from parent cell.](#_automatic_coded_word_2) If parent cell is coded as a noun – the word variants board would only include plurals. If coded as a verb – it would only include conjugations, etc. Supports English.|x||||
|- [Word prediction](#_word_prediction) – cell and word usage patterns are tracked and cell and word predictions, based on previous usage patterns, can be used to select cells within Wizard mode.|x||||
|- Direct Selection – swipe right to view full directory of cells. You can scroll or search to find cells. Tap on the cell to navigate directly to it.|iPad||||
|[Content Management](#_content_management)|||||
|- [Get Help](#_getting_help)|x|x|x|x|
|- [Undo/Redo](#_undo/redo) edits|x|x|||
|- Create initial content on a device using 4 [starter boards](#_starter_boards): male/female: child/adult (Sync / Overwrite from Sample)|x|x|||
|- [Copy content from any account to another account](#_updating_with_a) using the accounts’ username (Sync / Overwrite From Sample / I will type in name)|x|x|||
|- [Backup/Restore](#_backup/restore) content to account|x|x|x|x|
|- [Automatically synchronize content](#_automatically_synchronize_content) changes across devices and workspace.|x||||
|- [Merge content](#_merge) created on device with content created in same account on the web using Workspace. |x|x|||
|- [Overwrite content on the device](#_overwrite_device) with content created in same account on the web using Workspace|x|x|||
|- [Overwrite content in workspace](#_overwrite_workspace) created in the same account, authored on the device|x|x|||
|- [Manage the content for multiple users](#_manage_content_for) (clients) using a web browser||||x|
|- Create and manage content using a web browser|||x|x|
|- Create multiple content libraries – to organize media content by topic (client, work, home, etc.)|x||x|x|
|- Collaborate with others, through workspace, by sharing your content libraries|x||x|x|
|- Store images, sound, videos, boards & cells in your personal content libraries|x||x|x|
|- Search content by search term|x|x|x|x|
|- Tag media in content libraries to facilitate searching|x||x|x|
|- [Swipe from left side towards the right display directory of boards and cells](#_display_directory_of).|iPad||||
|- From board directory (see above) swipe left on an item and make it a favorite. Favorites are displayed at the top of the list.|iPad||||
|- Search the board directory using the search bar at top of directory|iPad||||
|[Integration/Automation](#_integration/automation)|||||
|- [Launch other applications](#_launch_other_applications) using openUrl: Facetime, Skype, Pandora, Google, 1000’s of applications support openUrl|x|x|||
|- [MyTalkTools has comprehensive openUrl support to allow for unlimited automation](#_mytalktools_automation). For example, program a cell to show/hide the phrase bar. Or program a cell to print a board. |x|x|||
|[Content Creation](#_content_creation)|||||
|- [Usage Tracking](#_usage_tracking) – Tracks when and where content is used. Assists authors in refining and improving content.|x||	||
|- [Boards](#_boards)|||||
|- [Create a basic grid of up to 100 cells.](#_create_a_board) Each cell can have sound, video, pictures or additional child boards associated with it. Allows you to create a hierarchical set of boards and cells to represent the vocabulary and taxonomy of the user.|x|x|x|x|
|- [Rearrange cells on a board](#_rearrange_cells_in) using drag’n’drop|x|x|x|x|
|- [Create a hotspot grid of up to 100 cells](#_hotspots_3). A hotspot grid is like a board that overlays an image. You assign sounds, video, child boards, etc. (like any cell) to areas of the image. For example, you can have a family picture, and tapping each family member might announce the person’s name, or perhaps go to another board displaying the person’s children.|x|x|x|x|
|- [Search for boards that other uses have contributed to the submissions library](#_create_a_board_1), and download copies of them to build your boards. For example, search for Food. You will find several of these. Select one, and it will download the entire set of boards onto your device.|x|x|x|x|
|- [Cells within a board may be sorted](#_dynamically_sort_board) in any combination alphabetically, by frequency of usage, or by color coding (part of speech – noun, verb, descriptor).|x|x|||
|- [Delete a board](#_delete_boards)|x|x|x|x|
|- [Change the dimensions of a board](#_change_board_dimensions) (go from 4 x 3, to 3 x 4, for example)|x|x|x|x|
|- [Add a row or a column to a board](#_change_board_dimensions_1)|x|x|x|x|
|- [Create common content](#_create_common_content). Define repeating rows, columns or cells (for example, put a Home cell, Back cell, and Core Words cell on every board).|x||x|x|
|- [Cells](#_cells)|||||
|- [Add text to a cell](#_managing_cell_properties)|x|x|x|x|
|- [Set text font sizes](#_managing_cell_properties_1)|x|x|x|x|
|- [Set text color](#_managing_cell_properties_2)|x|x|x|x|
|- [Set cell background color (use Goosen or Fitzgerald codes)](#_managing_cell_properties_3)|x|x|x|x|
|- [A cell can be designated as a “Go Home” cell. When tapped will return to home board.](#_managing_cell_properties_4)|x|x|x|x|
|- [A cell can be designated as a “Go Back” cell. When tapped will return to previous board.](#_managing_cell_properties_5)|x|x|x|x|
|- [A cell can be programmed with MyTalkTools automations](#_mytalktools_automation_1) to perform virtually any function when tapped: show/hide phrase bar, go back, voice a cell, show most used, etc.|x|x|||
|- [A cell can use other apps openUrl support to integrate with other applications](#_launch_other_applications_1). For example – you can program a cell to start a Facetime conversation.|x|x|||
|- [Cells can be copied/pasted](#_copy_&_paste) to create duplicates|x|x|x|x|
|- [Cells can be cleared](#_clear_cells) (remove text, images, etc.)|x|x|x|x|
|- [Cells can override the device “zoom” setting – to always or never “zoom”.](#_managing_cell_properties_6)|x|x|x|x|
|- [Cells can contain a child board](#_create_a_board_2). Tapping a cell with a child board, displays the child board.|x|x|x|x|
|- [Cells can be linked to another cell’s child board](#_adding_an_existing). Tapping a cell with a linked child board, displays the child board.|x|x|x|x|
|- [Cell size – a cell can occupy an adjacent space. If you give a cell a size of 2 it will occupy 2 cell spaces.](#_managing_cell_properties_7)|x||||
|- [Copy Cell to Library](#_copy_a_cell) – you can share a cell by copying it and its child board to a private library or the public submissions library|x||x|x|
|- [Cells can be hidden from the user](#_hide_cells) and only exposed to the user by the author specifically when needed.|x||x|x|
|- [Cells can have a negation symbol](#_negation_symbol) (a red circle and slash) placed over its contents. This is a convenience for creating yes/no-type pairs of cells. |x||x|x|
|- Cells can be combined to create custom keyboards and used with the phrase bar. Add the mytalktools:/phraseBarKeyPress command to a cell. The text will be added to the phrase bar, subsequent cells with the same command will be added to the phrase bar. When a cell is pressed without the keypress command it will aggregate the previous cells. So, if in your custom keyboard you pressed ‘a’, ‘n’, ‘d’. It would show as three separate cells ‘a’,’n’,’d’. When you pressed another cell like ‘store’, the phrase bar would show ‘and’,’store’. The prior keypress commands are aggregated together.|x||||
|- [Sound](#_sound_1)|||||
|- [Record sound from the device](#_record_sound_from)|x|x|x|x|
|- [Attach a recorded sound to a cell](#_add_recorded_sound)||x|x|x|
|- [Copy a sound file](#_copy_and_paste) from one cell and paste it into another|x|x|||
|- [Delete sound from a cell](#_delete_sound_recording)|x|x|x|x|
|- Type a phrase, and [create sound file from the text-to-speech voicing](#_create_text-to-speech_sound), and attach the sound file to a cell|x|x|x|x|
|- [Add or delete sound to/from a content library](#_using_sound_from)|x|x|x|x|
|- [Copy sound from content libraries into a cell](#_using_sound_from_1)|x|x|x|x|
|- [Video](#_video)|||||
|- [Record video from the device](#_record_video_from)|x|x|||
|- Attach a recorded video to a cell from the device’s photo library (and automatically create a screen capture image for the cell).|x|x|x|x|
|- [Copy a video file from one cell and paste it into another](#_copy_and_paste_1)|x|x|x|x|
|- [Delete video from a cell](#_delete_video_from)|x|x|x|x|
|- [Add or delete video to/from a content library](#_using_video_from)|||x|x|
|- [Copy video from content libraries into a cell](#_using_video_from_1)|x|x|x|x|
|- [Images](#_images)|||||
|- [Use images in your device’s photo library](#_from_your_device)|x|x|||
|- [Use images from Symbolstix ©](#_from_a_workspace)|x|x|x|x|
|- [Add, delete or modify images to/from a content library](#_adding_images_to)|add||x|x|
|- [Use images submitted by other users from the submissions library](#_from_a_workspace_1)|x|x|x|x|
|- [Use images from Bing © image searches](#_from_your_web)|x|x|x|x|
|- [Scheduling/Time-Based](#_schedules) |||||
|- Add a schedule to a cell with a child board. When the set time arrives, a notification will be display on the phone. Click the notification and you will be taken to the cell’s child board.|x|x|||
|- Notifications on device – when tapped will display board on device|x|x|||
|- Supports start date/time, supports periodicity (weekly, weekday, monthly, etc.), Supports repeat (once, forever, until)|x|x|||
|- Notifications do not require app to be active to be triggered. |x|x|||
|- [Locations](#_locations)|||||
|- Add a location to a cell with a child board. When the device is within 100 meters of the location a notification will be displayed on the phone or the apple watch. Click the notification and you will be taken to the cell’s child board.|x|x|||
|- Search for a location based on a location name – like “McDonald’s” or “Wendy’s”.|x|x|||
|- Search for a location based on a street address – like “1000 Central Ave”|x|x|||
|- Show nearby businesses or locations of interest|x|x|||
