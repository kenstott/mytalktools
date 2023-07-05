# MyTalkTools
iOS AAC solution

# IMPORTANT
To rebuild this project requires the Acapela voice library. Contact me directly for download instructions.

# Introduction
This is the incomplete open-source version of the MyTalkTools iOS client. Communication Disabilities Foundation Inc. is taking over support for the commercial MyTalkTools suite. This change will occur throughout 2023. By the end of 2023 the foundation will offer all of the MyTalkTools Suite (MyTalkTools Mobile for iOS, MyTalkTools for Android, and MyTalkTools Workspace) for no charge.

By the start of 2024 - new bug fixes and feature requests will be handled through open source contributors

# Project
The code, as is, lets you view and use most boards using your MyTalkTools account (with the exception of hotspot boards). In the current phase, the code is scaffolding out UI elements for editing and library management. Once the UI is scaffolded - functionality will be added.

We need your assistance in identifying new features, improving features, coding - or new language translations.

# Features
These are the features that are being replicated in this new SwiftUI implementation. Note - all accessibility features will now be managed by iOS. The existing scanning feature will be deprecated.

||MyTalkTools Mobile|MyTalkTools for Android|Workspace Family|Workspace Pro|Notes
| :- | :- | :- | :- | :- | :- |
|[Device Management](#_device_management)||||||
|- Operating Systems/Browsers|iPad, iPad Pro, iPhone|Android 4+|Edge, Chrome, FF, Safari|Chrome, FF, Safari||
|- [Synchronize Settings Across Devices with iCloud](#_synchronize_settings_across) (e.g. username, password, maximum rows, etc.)|x||||TBD|
|- [Keep media content in device photo library](#_keep_media_content) (creates a local backup of related media on device)|x|x|||feature removed. All files are available in the File application|
|- [Turn off screen rotation](#_turn_off_screen) (and stay in portrait or landscape always)|x||||done|
|- [Spotlight searches include MyTalkTools content](#_spotlight_searches_include)|x||||done|
|- Turn on “pinch gesture” setting. With pinch you can zoom in/out to cells. When zoomed in you can swipe right/left to pan. Good when trying to using large boards on smaller devices. Can also be applied for certain assessment scenarios.|x||||TBD|
|[Security Management](#_security_management)|||||
|- HIPAA compliant security|x|x|x|x|done|
|- [Require Password to Make Content Changes](#_require_password_to)|x|x|x|x|done|
|- [Login using ](#_login_using_touch)biometric identification|x||||done|
|- [Show/Hide Author Login in User Interface](#_show/hide_author_login)|x|x|||done|
|[Display Options](#_display_options)|||||
|- [Display Content as 2 Dimensional Grids, or as a 1-Dimensional List](#_display_content_as) (high functioning adults sometimes prefer the list-style)|x|grid|grid|grid|done|
|<p>- [Optionally display global commands](#_optionally_display_global) (for high functioning users)</p><p>&emsp;- Home</p><p>&emsp;- Back</p><p>&emsp;- Type Words - free form typing </p><p>&emsp;- Sync</p><p>&emsp;- Settings</p><p>&emsp;- Most Viewed - display a board of cells that are used most often)</p><p>&emsp;- Recents - display a board of cells that are the most recently used cells)</p><p>&emsp;- Wizard – shows likely next cells, based on previous cell selections</p>|x|x<br>(except for Wizard)|||home,back,type words, recents, most views - done, Wizard - TBD|
|- [Control spacing between grid cells](#_control_spacing_between) (margin width)|x|x|||done|
|- [Show/Hide cell dividing lines](#_show/hide_cell_dividing)|x||||TBD|
|- <a name="ole_link1"></a><a name="ole_link2"></a>[Show/Hide Popup User Hints](#_show/hide_popup_user)|x||||done|
|- <a name="ole_link5"></a><a name="ole_link6"></a>[Show/Hide Popup Authoring Hints](#_show/hide_popup_author) |x||||TBD|
|- <a name="ole_link9"></a><a name="ole_link10"></a>[Define max rows to display for device](#_define_max_rows)|x|x|||done|
|- [Switch from white/black to black/white color schemes](#_switch_from_white/black) to support certain visual impairments|x|x|||done|
|- Use [Goosen or Fitzgerald color coding](#_goosen_or_fitzgerald) as cell background color, or alternatively as a margin color (appears as a colored rectangle that surrounds the cell).|x|x|x|x|done|
|- [Cells can have multiple touch areas](#_hotspots) (referred to as hotspots), you can show the hotspots explicitly, or otherwise they are implicit to user.|x|x|x|x|TBD|
|- When tapping a cell – you can have it “[zoom](#_zoom)” (cover the entire screen), and then explicitly return, or have it go back based on a timer. For example, tapping a cell might zoom it), wait for 5 seconds, and then return the original board.|x|x|x|x|done|
|- Supports split screen on iPad and iPad Pro|x|n/a|n/a|n/a|done|
|- Display cells using a cards and folders metaphor (instead of a flat grid).|x||||TBD|
|[Sharing Content & Collaborating with Parents, Family and Caregivers](#_sharing_content_&)||||||
|- [Share printed board links](#_share_printed_board) (URLs) through email, facebook, twitter, SMS, etc.|x||x|x|TBD|
|- [Print your content libraries](#_print_content_libraries)|\*||x|x|TBD|
|- [View fully functioning boards in a web browser](#_preview_boards_from) (aka previews)|||x|x|TBD|
|- [Share preview links](#_share_preview_links) (URLs) through email, facebook, twitter, SMS, etc.|x||x|x|TBD|
|- [Print your boards](#_print_your_boards), with optional table of contents|1|1|x|x|TBD|
|- Create and share PDFs of boards|x||||TBD|
|- Create and share library items through iCloud, OneDrive, Google Drive, DropBox, SMS or Email|x||x|x|TBD|
|- Create and share cells/boards through iCloud, OneDrive, Google Drive, DropBox, SMS or Email|x||x|x|TBD|
|- Import boards from products that support the OpenBoard format. See openboardformat.org for more information|x||||TBD|
|[Touch Options](#_touch_options) (Fine motor adjustments for individuals who struggle to touch the display as expected)||||||
|- Set the minimum time to register a touch (to match with persons natural tapping speed)|x||||TBD|
|- Set the maximum amount of movement allowed for a touch (for people who tend to drag, you would want to increase the allowable movement)|x||||TBD|
|- Set the tap-time-out (for touch stutters, you can make it not register a second touch for a period of time).|x||||TBD|
|- Allow a touch to be recognized immediately on the down press without waiting for the release of the finger. This can be useful for people with certain physical disabilities.|x||||TBD|
|[Text-To-Speech](#_text-to-speech)||||||
|- [Generate a Text-To-Speech Recording](#_generate_a_text-to-speech) and attach to a cell (useful when sharing content with users who do not have TTS capability)|x|x|||done|
|- [Voice cell text dynamically using Text-To-Speech](#_voice_cell_text)|x|x|x|x|done|
|- [Voice alternate text](#_voice_alternate_text) (something other than the cell text) using Text-To-Speech|x|x|x|x|done|
|- ` `[Low quality Text-To-Speech voices](#_low_quality_text-to-speech) (English / adult / male / female)|x|x|<p>27 voices in 11 languages</p><p></p>|done|
|- ` `[High quality Text-To-Speech voices](#_high_quality_text-to-speech) (English, French, German, Dutch, etc. / child / adult / male / female)|$$$|$$$|||done - except for recording, and in-app purchase|
|[Phrases/Language Generation/Communication](#_phrases/language_generation/communication)||||||
|- [A “phrase bar” can be optionally displayed](#_display_phrase_bar), and then when tapping on cells it adds them to the phrase bar. Tapping on the phrase bar voices the cells in order.|x|x|||done|
|- Phrase bar history – double-tapping the phrase bar will display a history of all phrases used. Or, on an iPad tap the arrow to the left of the phrase bar to view the phrase history. |x||||TBD|
|- Phrase bar favorites – swipe left on a phrase bar history item (see above) and make it a favorite. Favorites are always displayed at the top of list.|x||||TBD|
|- [4 alternate phrase bar displays](#_display_phrase_bar_1) – 1) text only 2) text only in blocks 3) images and text displayed side by side, 4) images displayed above text|x|2|||TBD|
|- [Delete last cell added to phrase, Delete entire phrase.](#_delete_phrase_bar)|x|x|||done|
|- [Long press on the phrase bar displays alternate communication options](#_additional_phrase_bar): Facebook, Twitter, SMS, Email, Photos, Notes, etc.|x|x|||TBD|
|- [Related conjugations, adjectives, adverbs and plurals (English only) can be dynamically displayed using a global option](#_use_automatic_word). If a cell has a single word, has no sound or child boards associated with it, and this option is set, the system will automatically create a child board with the above word variants and display it to the user. Allows high functioning users ability to create grammatically correct communications, with less effort from author.|x|x|||TBD|
|- [Dynamically generated word variants board can be automatically coded with Goosen or Fitzgerald codes](#_automatic_coded_word). Supports English.|x|x|||TBD|
|- [Dynamically generated word variants board can take hint from parent cell.](#_automatic_coded_word_2) If parent cell is coded as a noun – the word variants board would only include plurals. If coded as a verb – it would only include conjugations, etc. Supports English.|x||||TBD|
|- [Word prediction](#_word_prediction) – cell and word usage patterns are tracked and cell and word predictions, based on previous usage patterns, can be used to select cells within Wizard mode.|x||||TBD|
|- Direct Selection – swipe right to view full directory of cells. You can scroll or search to find cells. Tap on the cell to navigate directly to it.|iPad||||TBD|
|[Content Management](#_content_management)||||||
|- [Get Help](#_getting_help)|x|x|x|x|done|
|- [Undo/Redo](#_undo/redo) edits|x|x|||done|
|- Create initial content on a device using 4 [starter boards](#_starter_boards): male/female: child/adult (Sync / Overwrite from Sample)|x|x|||TBD|
|- [Copy content from any account to another account](#_updating_with_a) using the accounts’ username (Sync / Overwrite From Sample / I will type in name)|x|x|||TBD|
|- [Backup/Restore](#_backup/restore) content to account|x|x|x|x|TBD|
|- [Automatically synchronize content](#_automatically_synchronize_content) changes across devices and workspace.|x||||TBD|
|- [Merge content](#_merge) created on device with content created in same account on the web using Workspace. |x|x|||done|
|- [Overwrite content on the device](#_overwrite_device) with content created in same account on the web using Workspace|x|x|||done|
|- [Overwrite content in workspace](#_overwrite_workspace) created in the same account, authored on the device|x|x|||done|
|- [Manage the content for multiple users](#_manage_content_for) (clients) using a web browser||||x|done|
|- Create and manage content using a web browser|||x|x|done|
|- Create multiple content libraries – to organize media content by topic (client, work, home, etc.)|x||x|x|done|
|- Collaborate with others, through workspace, by sharing your content libraries|x||x|x|done|
|- Store images, sound, videos, boards & cells in your personal content libraries|x||x|x|done|
|- Search content by search term|x|x|x|x|done|
|- Tag media in content libraries to facilitate searching|x||x|x|tag|
|- [Swipe from left side towards the right display directory of boards and cells](#_display_directory_of).|iPad||||TBD|
|- From board directory (see above) swipe left on an item and make it a favorite. Favorites are displayed at the top of the list.|iPad||||TBD|
|- Search the board directory using the search bar at top of directory|iPad||||TBD|
|[Integration/Automation](#_integration/automation)||||||
|- [Launch other applications](#_launch_other_applications) using openUrl: Facetime, Skype, Pandora, Google, 1000’s of applications support openUrl|x|x|||done|
|- [MyTalkTools has comprehensive openUrl support to allow for unlimited automation](#_mytalktools_automation). For example, program a cell to show/hide the phrase bar. Or program a cell to print a board. |x|x|||done|
|[Content Creation](#_content_creation)||||||
|- [Usage Tracking](#_usage_tracking) – Tracks when and where content is used. Assists authors in refining and improving content.|x||||TBD|
|- [Boards](#_boards)|||||
|- [Create a basic grid of up to 100 cells.](#_create_a_board) Each cell can have sound, video, pictures or additional child boards associated with it. Allows you to create a hierarchical set of boards and cells to represent the vocabulary and taxonomy of the user.|x|x|x|x|
|- [Rearrange cells on a board](#_rearrange_cells_in) using drag’n’drop|x|x|x|x|done|
|- [Create a hotspot grid of up to 100 cells](#_hotspots_3). A hotspot grid is like a board that overlays an image. You assign sounds, video, child boards, etc. (like any cell) to areas of the image. For example, you can have a family picture, and tapping each family member might announce the person’s name, or perhaps go to another board displaying the person’s children.|x|x|x|x|TBD|
|- [Search for boards that other uses have contributed to the submissions library](#_create_a_board_1), and download copies of them to build your boards. For example, search for Food. You will find several of these. Select one, and it will download the entire set of boards onto your device.|x|x|x|x|done|
|- [Cells within a board may be sorted](#_dynamically_sort_board) in any combination alphabetically, by frequency of usage, or by color coding (part of speech – noun, verb, descriptor).|x|x|||done|
|- [Delete a board](#_delete_boards)|x|x|x|x|done|
|- [Change the dimensions of a board](#_change_board_dimensions) (go from 4 x 3, to 3 x 4, for example)|x|x|x|x|done|
|- [Add a row or a column to a board](#_change_board_dimensions_1)|x|x|x|x|done|
|- [Create common content](#_create_common_content). Define repeating rows, columns or cells (for example, put a Home cell, Back cell, and Core Words cell on every board).|x||x|x|TBD|
|- [Cells](#_cells)||||||
|- [Add text to a cell](#_managing_cell_properties)|x|x|x|x|done|
|- [Set text font sizes](#_managing_cell_properties_1)|x|x|x|x|done|
|- [Set text color](#_managing_cell_properties_2)|x|x|x|x|done|
|- [Set cell background color (use Goosen or Fitzgerald codes)](#_managing_cell_properties_3)|x|x|x|x|done|
|- [A cell can be designated as a “Go Home” cell. When tapped will return to home board.](#_managing_cell_properties_4)|x|x|x|x|done|
|- [A cell can be designated as a “Go Back” cell. When tapped will return to previous board.](#_managing_cell_properties_5)|x|x|x|x|done|
|- [A cell can be programmed with MyTalkTools automations](#_mytalktools_automation_1) to perform virtually any function when tapped: show/hide phrase bar, go back, voice a cell, show most used, etc.|x|x|||done|
|- [A cell can use other apps openUrl support to integrate with other applications](#_launch_other_applications_1). For example – you can program a cell to start a Facetime conversation.|x|x|||done|
|- [Cells can be copied/pasted](#_copy_&_paste) to create duplicates|x|x|x|x|done|
|- [Cells can be cleared](#_clear_cells) (remove text, images, etc.)|x|x|x|x|done|
|- [Cells can override the device “zoom” setting – to always or never “zoom”.](#_managing_cell_properties_6)|x|x|x|x|done|
|- [Cells can contain a child board](#_create_a_board_2). Tapping a cell with a child board, displays the child board.|x|x|x|x|done|
|- [Cells can be linked to another cell’s child board](#_adding_an_existing). Tapping a cell with a linked child board, displays the child board.|x|x|x|x|TBD|
|- [Cell size – a cell can occupy an adjacent space. If you give a cell a size of 2 it will occupy 2 cell spaces.](#_managing_cell_properties_7)|x||||done|
|- [Copy Cell to Library](#_copy_a_cell) – you can share a cell by copying it and its child board to a private library or the public submissions library|x||x|x|TBD|
|- [Cells can be hidden from the user](#_hide_cells) and only exposed to the user by the author specifically when needed.|x||x|x|TBD|
|- [Cells can have a negation symbol](#_negation_symbol) (a red circle and slash) placed over its contents. This is a convenience for creating yes/no-type pairs of cells. |x||x|x|done|
|- Cells can be combined to create custom keyboards and used with the phrase bar. Add the mytalktools:/phraseBarKeyPress command to a cell. The text will be added to the phrase bar, subsequent cells with the same command will be added to the phrase bar. When a cell is pressed without the keypress command it will aggregate the previous cells. So, if in your custom keyboard you pressed ‘a’, ‘n’, ‘d’. It would show as three separate cells ‘a’,’n’,’d’. When you pressed another cell like ‘store’, the phrase bar would show ‘and’,’store’. The prior keypress commands are aggregated together.|x||||TBD|
|- [Sound](#_sound_1)||||||
|- [Record sound from the device](#_record_sound_from)|x|x|x|x|done|
|- [Attach a recorded sound to a cell](#_add_recorded_sound)||x|x|x|done|
|- [Copy a sound file](#_copy_and_paste) from one cell and paste it into another|x|x|||done|
|- [Delete sound from a cell](#_delete_sound_recording)|x|x|x|x|done|
|- Type a phrase, and [create sound file from the text-to-speech voicing](#_create_text-to-speech_sound), and attach the sound file to a cell|x|x|x|x|done|
|- [Add or delete sound to/from a content library](#_using_sound_from)|x|x|x|x|done|
|- [Copy sound from content libraries into a cell](#_using_sound_from_1)|x|x|x|x|TBD|
|- [Video](#_video)||||||
|- [Record video from the device](#_record_video_from)|x|x|||TBD|
|- Attach a recorded video to a cell from the device’s photo library (and automatically create a screen capture image for the cell).|x|x|x|x|TBD|
|- [Copy a video file from one cell and paste it into another](#_copy_and_paste_1)|x|x|x|x|TBD|
|- [Delete video from a cell](#_delete_video_from)|x|x|x|x|done|
|- [Add or delete video to/from a content library](#_using_video_from)|||x|x|TBD|
|- [Copy video from content libraries into a cell](#_using_video_from_1)|x|x|x|x|TBD|
|- [Images](#_images)||||||
|- [Use images in your device’s photo library](#_from_your_device)|x|x|||done|
|- [Use images from Symbolstix ©](#_from_a_workspace)|x|x|x|x|done|
|- [Add, delete or modify images to/from a content library](#_adding_images_to)|add||x|x|TBD|
|- [Use images submitted by other users from the submissions library](#_from_a_workspace_1)|x|x|x|x|done
|- [Use images from Bing © image searches](#_from_your_web)|x|x|x|x|done|
|- [Scheduling/Time-Based](#_schedules) ||||||
|- Add a schedule to a cell with a child board. When the set time arrives, a notification will be display on the phone. Click the notification and you will be taken to the cell’s child board.|x|x|||done|
|- Notifications on device – when tapped will display board on device|x|x|||done|
|- Supports start date/time, supports periodicity (weekly, weekday, monthly, etc.), Supports repeat (once, forever, until)|x|x|||done|
|- Notifications do not require app to be active to be triggered. |x|x|||done|
|- [Locations](#_locations)||||||
|- Add a location to a cell with a child board. When the device is within 100 meters of the location a notification will be displayed on the phone. Click the notification and you will be taken to the cell’s child board.|x|x|||done|
|- Search for a location based on a location name – like “McDonald’s” or “Wendy’s”.|x|x|||TBD|
|- Search for a location based on a street address – like “1000 Central Ave”|x|x|||done|
|- Show nearby businesses or locations of interest|x|x|||done|

