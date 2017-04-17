# Config.pri file version 2.0. Auto-generated by IDE. Any changes made by user will be lost!
BASEDIR = $$quote($$_PRO_FILE_PWD_)

device {
    CONFIG(debug, debug|release) {
        profile {
            CONFIG += \
                config_pri_assets \
                config_pri_source_group1
        } else {
            CONFIG += \
                config_pri_assets \
                config_pri_source_group1
        }

    }

    CONFIG(release, debug|release) {
        !profile {
            CONFIG += \
                config_pri_assets \
                config_pri_source_group1
        }
    }
}

simulator {
    CONFIG(debug, debug|release) {
        !profile {
            CONFIG += \
                config_pri_assets \
                config_pri_source_group1
        }
    }
}

config_pri_assets {
    OTHER_FILES += \
        $$quote($$BASEDIR/assets/cards/CreateTaskFromTextCard.qml) \
        $$quote($$BASEDIR/assets/cards/CreateTaskFromUrlCard.qml) \
        $$quote($$BASEDIR/assets/cards/TestCard.qml) \
        $$quote($$BASEDIR/assets/cards/UpdateTaskCard.qml) \
        $$quote($$BASEDIR/assets/components/AttachmentsContainer.qml) \
        $$quote($$BASEDIR/assets/components/CustomTitleBar.qml) \
        $$quote($$BASEDIR/assets/components/DeleteTaskDialog.qml) \
        $$quote($$BASEDIR/assets/components/ExpandableButton.qml) \
        $$quote($$BASEDIR/assets/components/InputTitleBar.qml) \
        $$quote($$BASEDIR/assets/components/OkButton.qml) \
        $$quote($$BASEDIR/assets/components/Task.qml) \
        $$quote($$BASEDIR/assets/components/TaskDeadlineContainer.qml) \
        $$quote($$BASEDIR/assets/components/TaskDescriptionContainer.qml) \
        $$quote($$BASEDIR/assets/components/TaskNameContainer.qml) \
        $$quote($$BASEDIR/assets/components/ToggleBlock.qml) \
        $$quote($$BASEDIR/assets/images/apk_icon_big_512x512.png) \
        $$quote($$BASEDIR/assets/images/audio_icon_big_512x512.png) \
        $$quote($$BASEDIR/assets/images/doc_icon_big_512x512.png) \
        $$quote($$BASEDIR/assets/images/generic_icon_big_512x512.png) \
        $$quote($$BASEDIR/assets/images/grey_pellet.png) \
        $$quote($$BASEDIR/assets/images/ic_add.png) \
        $$quote($$BASEDIR/assets/images/ic_attach.png) \
        $$quote($$BASEDIR/assets/images/ic_calendar.png) \
        $$quote($$BASEDIR/assets/images/ic_clear.png) \
        $$quote($$BASEDIR/assets/images/ic_compose.png) \
        $$quote($$BASEDIR/assets/images/ic_delete.png) \
        $$quote($$BASEDIR/assets/images/ic_deselect.png) \
        $$quote($$BASEDIR/assets/images/ic_doctype_doc.png) \
        $$quote($$BASEDIR/assets/images/ic_doctype_generic.png) \
        $$quote($$BASEDIR/assets/images/ic_doctype_music.png) \
        $$quote($$BASEDIR/assets/images/ic_doctype_pdf.png) \
        $$quote($$BASEDIR/assets/images/ic_doctype_picture.png) \
        $$quote($$BASEDIR/assets/images/ic_doctype_ppt.png) \
        $$quote($$BASEDIR/assets/images/ic_doctype_video.png) \
        $$quote($$BASEDIR/assets/images/ic_doctype_xls.png) \
        $$quote($$BASEDIR/assets/images/ic_done.png) \
        $$quote($$BASEDIR/assets/images/ic_done_all.png) \
        $$quote($$BASEDIR/assets/images/ic_feedback.png) \
        $$quote($$BASEDIR/assets/images/ic_folder.png) \
        $$quote($$BASEDIR/assets/images/ic_forward.png) \
        $$quote($$BASEDIR/assets/images/ic_history.png) \
        $$quote($$BASEDIR/assets/images/ic_list.png) \
        $$quote($$BASEDIR/assets/images/ic_minus.png) \
        $$quote($$BASEDIR/assets/images/ic_notes.png) \
        $$quote($$BASEDIR/assets/images/ic_plus.png) \
        $$quote($$BASEDIR/assets/images/ic_search.png) \
        $$quote($$BASEDIR/assets/images/ic_select_more.png) \
        $$quote($$BASEDIR/assets/images/ic_send.png) \
        $$quote($$BASEDIR/assets/images/ic_share.png) \
        $$quote($$BASEDIR/assets/images/ic_sort.png) \
        $$quote($$BASEDIR/assets/images/ic_watch.png) \
        $$quote($$BASEDIR/assets/images/js_icon_big_512x512.png) \
        $$quote($$BASEDIR/assets/images/ok_button.png) \
        $$quote($$BASEDIR/assets/images/pdf_icon.png) \
        $$quote($$BASEDIR/assets/images/pdf_icon_big.png) \
        $$quote($$BASEDIR/assets/images/ppt_icon_big_512x512.png) \
        $$quote($$BASEDIR/assets/images/video_icon_big_512x512.png) \
        $$quote($$BASEDIR/assets/images/xls_icon_big_512x512.png) \
        $$quote($$BASEDIR/assets/images/yellow_pellet.png) \
        $$quote($$BASEDIR/assets/images/zip_icon_big_512x512.png) \
        $$quote($$BASEDIR/assets/main.qml) \
        $$quote($$BASEDIR/assets/migrations/1_create_schema_version_table.sql) \
        $$quote($$BASEDIR/assets/migrations/2_create_table_tasks.sql) \
        $$quote($$BASEDIR/assets/migrations/3_create_table_df_users.sql) \
        $$quote($$BASEDIR/assets/migrations/4_create_table_attachments.sql) \
        $$quote($$BASEDIR/assets/migrations/5_alter_table_tasks_add_calendar_id.sql) \
        $$quote($$BASEDIR/assets/migrations/6_create_index_parent_id_type.sql) \
        $$quote($$BASEDIR/assets/migrations/7_create_index_parent_id.sql) \
        $$quote($$BASEDIR/assets/migrations/8_create_index_type.sql) \
        $$quote($$BASEDIR/assets/pages/ContactsPage.qml) \
        $$quote($$BASEDIR/assets/pages/DebugPage.qml) \
        $$quote($$BASEDIR/assets/pages/HelpPage.qml) \
        $$quote($$BASEDIR/assets/pages/MoveTaskPage.qml) \
        $$quote($$BASEDIR/assets/pages/SettingsPage.qml) \
        $$quote($$BASEDIR/assets/pages/TaskViewPage.qml) \
        $$quote($$BASEDIR/assets/pages/TasksListPage.qml) \
        $$quote($$BASEDIR/assets/sheets/AddContactSheet.qml) \
        $$quote($$BASEDIR/assets/sheets/FilePickersSheet.qml) \
        $$quote($$BASEDIR/assets/sheets/TaskSheet.qml) \
        $$quote($$BASEDIR/assets/templates/pap_push.template) \
        $$quote($$BASEDIR/assets/templates/pap_subscription.template)
}

config_pri_source_group1 {
    SOURCES += \
        $$quote($$BASEDIR/src/applicationui.cpp) \
        $$quote($$BASEDIR/src/config/AppConfig.cpp) \
        $$quote($$BASEDIR/src/config/DBConfig.cpp) \
        $$quote($$BASEDIR/src/main.cpp) \
        $$quote($$BASEDIR/src/models/Task.cpp) \
        $$quote($$BASEDIR/src/services/AttachmentsService.cpp) \
        $$quote($$BASEDIR/src/services/DropboxService.cpp) \
        $$quote($$BASEDIR/src/services/PushNotificationService.cpp) \
        $$quote($$BASEDIR/src/services/SearchService.cpp) \
        $$quote($$BASEDIR/src/services/TasksService.cpp) \
        $$quote($$BASEDIR/src/services/UsersService.cpp) \
        $$quote($$BASEDIR/src/util/CalendarUtil.cpp) \
        $$quote($$BASEDIR/src/util/Signal.cpp) \
        $$quote($$BASEDIR/src/vendor/Console.cpp)

    HEADERS += \
        $$quote($$BASEDIR/src/applicationui.hpp) \
        $$quote($$BASEDIR/src/config/AppConfig.hpp) \
        $$quote($$BASEDIR/src/config/DBConfig.hpp) \
        $$quote($$BASEDIR/src/models/Task.hpp) \
        $$quote($$BASEDIR/src/services/AttachmentsService.hpp) \
        $$quote($$BASEDIR/src/services/DropboxService.hpp) \
        $$quote($$BASEDIR/src/services/PushNotificationService.hpp) \
        $$quote($$BASEDIR/src/services/SearchService.hpp) \
        $$quote($$BASEDIR/src/services/TasksService.hpp) \
        $$quote($$BASEDIR/src/services/UsersService.hpp) \
        $$quote($$BASEDIR/src/util/CalendarUtil.hpp) \
        $$quote($$BASEDIR/src/util/Signal.hpp) \
        $$quote($$BASEDIR/src/vendor/Console.hpp)
}

CONFIG += precompile_header

PRECOMPILED_HEADER = $$quote($$BASEDIR/precompiled.h)

lupdate_inclusion {
    SOURCES += \
        $$quote($$BASEDIR/../src/*.c) \
        $$quote($$BASEDIR/../src/*.c++) \
        $$quote($$BASEDIR/../src/*.cc) \
        $$quote($$BASEDIR/../src/*.cpp) \
        $$quote($$BASEDIR/../src/*.cxx) \
        $$quote($$BASEDIR/../src/config/*.c) \
        $$quote($$BASEDIR/../src/config/*.c++) \
        $$quote($$BASEDIR/../src/config/*.cc) \
        $$quote($$BASEDIR/../src/config/*.cpp) \
        $$quote($$BASEDIR/../src/config/*.cxx) \
        $$quote($$BASEDIR/../src/models/*.c) \
        $$quote($$BASEDIR/../src/models/*.c++) \
        $$quote($$BASEDIR/../src/models/*.cc) \
        $$quote($$BASEDIR/../src/models/*.cpp) \
        $$quote($$BASEDIR/../src/models/*.cxx) \
        $$quote($$BASEDIR/../src/services/*.c) \
        $$quote($$BASEDIR/../src/services/*.c++) \
        $$quote($$BASEDIR/../src/services/*.cc) \
        $$quote($$BASEDIR/../src/services/*.cpp) \
        $$quote($$BASEDIR/../src/services/*.cxx) \
        $$quote($$BASEDIR/../src/util/*.c) \
        $$quote($$BASEDIR/../src/util/*.c++) \
        $$quote($$BASEDIR/../src/util/*.cc) \
        $$quote($$BASEDIR/../src/util/*.cpp) \
        $$quote($$BASEDIR/../src/util/*.cxx) \
        $$quote($$BASEDIR/../src/vendor/*.c) \
        $$quote($$BASEDIR/../src/vendor/*.c++) \
        $$quote($$BASEDIR/../src/vendor/*.cc) \
        $$quote($$BASEDIR/../src/vendor/*.cpp) \
        $$quote($$BASEDIR/../src/vendor/*.cxx) \
        $$quote($$BASEDIR/../assets/*.qml) \
        $$quote($$BASEDIR/../assets/*.js) \
        $$quote($$BASEDIR/../assets/*.qs) \
        $$quote($$BASEDIR/../assets/cards/*.qml) \
        $$quote($$BASEDIR/../assets/cards/*.js) \
        $$quote($$BASEDIR/../assets/cards/*.qs) \
        $$quote($$BASEDIR/../assets/components/*.qml) \
        $$quote($$BASEDIR/../assets/components/*.js) \
        $$quote($$BASEDIR/../assets/components/*.qs) \
        $$quote($$BASEDIR/../assets/images/*.qml) \
        $$quote($$BASEDIR/../assets/images/*.js) \
        $$quote($$BASEDIR/../assets/images/*.qs) \
        $$quote($$BASEDIR/../assets/migrations/*.qml) \
        $$quote($$BASEDIR/../assets/migrations/*.js) \
        $$quote($$BASEDIR/../assets/migrations/*.qs) \
        $$quote($$BASEDIR/../assets/pages/*.qml) \
        $$quote($$BASEDIR/../assets/pages/*.js) \
        $$quote($$BASEDIR/../assets/pages/*.qs) \
        $$quote($$BASEDIR/../assets/sheets/*.qml) \
        $$quote($$BASEDIR/../assets/sheets/*.js) \
        $$quote($$BASEDIR/../assets/sheets/*.qs) \
        $$quote($$BASEDIR/../assets/templates/*.qml) \
        $$quote($$BASEDIR/../assets/templates/*.js) \
        $$quote($$BASEDIR/../assets/templates/*.qs)

    HEADERS += \
        $$quote($$BASEDIR/../src/*.h) \
        $$quote($$BASEDIR/../src/*.h++) \
        $$quote($$BASEDIR/../src/*.hh) \
        $$quote($$BASEDIR/../src/*.hpp) \
        $$quote($$BASEDIR/../src/*.hxx)
}

TRANSLATIONS = $$quote($${TARGET}_fr.ts) \
    $$quote($${TARGET}_ru.ts) \
    $$quote($${TARGET}.ts)
